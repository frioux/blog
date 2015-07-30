---
title: Index Hints in MySQL with DBIx::Class
date: 2015-06-24T19:39:50
tags: ["mysql", "dbic", "dbix-class", "ziprecruiter"]
guid: "https://blog.afoolishmanifesto.com/posts/index-hints-in-mysql-with-dbix-class"
---
I started at [ZipRecruiter](https://www.ziprecruiter.com) nearly two weeks ago
and I finally feel like I'm finding my stride.  It's nice!

Anyway, this post is mostly because I am positive that a lot of people need this
and it's difficult to make into an actual component.

Sometimes in life one finds oneself using a "database" called MySQL.  In order
to make this "database" perform, one must sometimes hint at which indices to use
or not use.  That's what we did today!

I could go into a *lot* more detail about all of this, and really, the hard part
is not the hinting, but tooling your schema to allow the hinting.  I'll show a
ghetto way to do it and maybe make a more complete post later on how to override
your storage later.

Here's the actual machinery of inserting the hinting:

```perl
package MyApp::DBIC::SQLMaker::MySQL;

use strict;
use warnings;

use base 'DBIx::Class::SQLMaker::MySQL';

our @indices_to_ignore;
sub _gen_from_blocks {
  my $self = shift;

  my @blocks = $self->next::method(@_);

  $blocks[0] .= " IGNORE INDEX (" . join(',',@indices_to_ignore) . ")";

  return @blocks
}
```

Then you can make an API like this:

```perl
package MyApp::Schema::ResultSet::Users;

# ...

sub count_ignoring_indices {
  my ($self, @indices) = @_;

  local @MyApp::DBIC::SQLMaker::MySQL::indices_to_ignore = @indices;
  $self->count
}
```

Now if you find yourself doing this all the time, you could make the API nicer
and figure out how to get it into a ResultSet attribute.  You could also try to
fix your indices or consider other less needy storage options.

Ok so finally you need to apply the SQLMaker subclass to your schema.  The lame
way that I'll posit right now is:

```perl
MyApp::Schema;

# ...

sub connection {
  my ($self, @rest) = @_;

  my $schema = $self->next::method(@rest);

  $schema->ensure_connected;

  $schema->storage->sql_maker_class('MyApp::DBIC::SQLMaker::MySQL');

  return $schema
}

```

And then usage of the above:

```perl
$schema->resultset('User')->count_ignoring_indices('index_user_name')
```

So hopefully this helps some people out there.  I intend to update it later when
I eventually post my article on the more correct way to override the
storage/sqlmaker for your schema.
