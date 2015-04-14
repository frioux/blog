---
title: "MRO's and you; how the distinction between C3 and DFS changed my life"
date: 2015-04-14T10:44:36
tags: ["c3", "dfs", "mro", "perl", "DBIx::Class::Helpers"]
guid: "https://blog.afoolishmanifesto.com/posts/mros-and-you-how-the-distinction-between-c3-and-dfs-changed-my-life"
---
Recently [I fixed DBIx::Class::Helpers so that each helper would have a base
class](https://github.com/frioux/DBIx-Class-Helpers/commit/80f47ec6437b8e44923912396c06e43fb4df4188).
This is actually something that ribasushi had been sorta hounding me to do for
years but I could never figure out the case where it mattered.  The reason I
finally made the change was because a user ran into an issue that fixing the
base class actually resolved.  Unfortunately I neither documented what it was
nor wrote a test.  Such is life, live and learn.

So today I was documenting one of our products that I know all the guts of and,
before I did anything, I ran the tests.  A non-trivial number of them failed,
something like 40% of them.  I was astounded; nothing has changed on this thing
in months.  As you might be able to guess, the commit mentioned above caused the
problem.

First off, let me illustrate the problem.  You care about the longevity and
overall quality of your codebase, so you carefully create a base class for your
DBIx::Class resultsets that might look something like this:

```perl
package MyCompany::Schema::ResultSet;

use strict;
use warnings;

use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components('Helper::ResultSet::IgnoreWantarray');

1;
```
And then in your project you do something like this:

```perl
package TeaTime::Schema::ResultSet;

use strict;
use warnings;

use parent 'MyCompany::Schema::ResultSet';

__PACKAGE__->load_components(qw(
   Helper::ResultSet::IgnoreWantarray
   Helper::ResultSet::Errors
));

1;
```
Ok, so it doesn't do much, but at the very least it guards you against some
pretty typical mistakes while using your DBIx::Class resultsets.

Next, you make a resultset class, maybe something like this:

```perl
package TeaTime::Schema::ResultSet::Milk;

use parent 'TeaTime::Schema::ResultSet';

sub in_order {
   shift->search(undef, { order_by => { -desc => 'when_expires'} })
}

1;
```

Now you have a handy method to get your results in a sensible order.  Great!

So just to be clear, here is your inheritance hierarchy:

```
          ...
           |
         DBIC
           |
DBIC::ResultSet-*-*-*-*-*-*-*\-*-*-*-*-*-*-*-*\
           |                 |                 |
           |            ::IgnoreWantarray      *
           |    /------------/                 |
MC::Schema::ResultSet        |              ::Errors
           |                 |                   |
TT::Schema::ResultSet--------/-------------------/
           |
TT::Schema::ResultSet::Milk
```

Note the line with astrisks in it; that line was added by the commit mentioned
in the first paragraph.  Here's where it gets scary.  The linear isa of our
`::ResultSet` is:

```
  "TeaTime::Schema::ResultSet",
  "DBIx::Class::Helper::ResultSet::Errors",
  "MyCompany::Schema::ResultSet",
  "DBIx::Class::Helper::ResultSet::IgnoreWantarray",
  "DBIx::Class::ResultSet",
  "DBIx::Class",
  "DBIx::Class::Componentised",
  "Class::C3::Componentised",
  "DBIx::Class::AccessorGroup",
  "Class::Accessor::Grouped"
```

Perfect, that's what we expect!

What about `::Milk`?

```
  "TeaTime::Schema::ResultSet::Milk",
  "TeaTime::Schema::ResultSet",
  "DBIx::Class::Helper::ResultSet::Errors",
  "DBIx::Class::ResultSet",
  "DBIx::Class",
  "DBIx::Class::Componentised",
  "Class::C3::Componentised",
  "DBIx::Class::AccessorGroup",
  "Class::Accessor::Grouped",
  "MyCompany::Schema::ResultSet",
  "DBIx::Class::Helper::ResultSet::IgnoreWantarray"
```

WOAH!  Why is `::IgnoreWantarray` all the way at the bottom?

Well it turns out that `::Milk` is using the `dfs` MRO.  Basically what that
means is that it picks a path, in this case the one via `::Errors`, and
traverses down (`dfs` stands for depth first search, afterall) instead of going
side to side.  Fundamentally the `c3` resolution solves this problem.

Here's where it gets even weirder.  If I remove the parent classes from
`::Errors` and `::IgnoreWantarray` both `c3` and `dfs` work fine.  The
reason for that is that if there is no parent, `dfs` won't traverse to it,
obviously.

At some point I'd like to make a little web app that allows the user to create a
hierarchy and see the different orderings based on algorithms, because I still
don't quite understand why the above hierarchy is needed (there needs to be two
layers of base classes, to be clear.)

## What's wrong with my brain?

So why did I make this mistake?  To be clear, this code has worked for **years** at
MTSI, and suddenly, a relatively small change to make things "more correct"
broke nearly everything!  Well the problem was that I assumed that if your
parent class used `c3` you would too.  That's not the case at all.  The reason
the parent classes above use `c3` is because they call `load_components`.  Many
of you may not have this problem because you are using either `Moo` or `Moose`
in your resultsets.  So basically, I assumed that `c3` would be turned on for
me, and it's not.

## What's the next step?

This is a big problem.  It needs to be trivially easy to do the right thing
because there is no doubt in my mind that other people have made the same
mistake.  My plan is to make a `DBIx::Class::Candy::ResultSet` which will do the
same type of things as `DBIx::Class::Candy`, but also set the `c3` mro.  I will
also do some research and see if the original `DBIx::Class::Candy` needs to do
the same thing.

In the meantime, beware of DBIx::Class::Helpers versions 2.025002 and 2.025003.
I will have a short post for when the resultset sugar is available.
