---
title: Set-based DBIx::Class
date: 2016-07-16T07:41:34
tags: ["perl", "dbix-class", "dbix-class-helpers"]
guid: 64A5161C-4B63-11E6-8918-27C04DBD8D92
---
[This was originally posted to the 2012 Perl Advent
Calendar.](http://www.perladvent.org/2012/2012-12-21.html)  I refer people to
this article so often that I decided to repost it here in case anything happens
to the server it was originally hosted on.

<!--more-->

---

I've been using [DBIx::Class](https://metacpan.org/module/DBIx::Class) for a few
years, and I've been part of the development team for just a little bit less.
Three years ago I wrote a [Catalyst Advent
article](http://www.catalystframework.org/calendar/2009/20) about the five
[DBIx::Class::Helpers](https://metacpan.org/module/DBIx::Class::Helpers), which
have since ballooned to twenty-four. I'll be mentioning a few helpers in this
post, but the main thing I want to describe is a way of using DBIx::Class that
results in efficient applications as well as reduced code duplication.

(Don't know anything about `DBIx::Class`? Want a refresher before diving in more
deeply? Maybe watch [my
presentation](https://www.youtube.com/watch?v=Vm_NlfHNVvg) on it, or, if you
don't like my face, try [this one](http://www.youtube.com/watch?v=N-tbMPyNlM8).)

The thesis of this article is that **when you write code to act on things at the
set level, you can often leverage the database's own optimizations** and thus
produce faster code at a lower level.

# Set Based `DBIx::Class`

The most important feature of `DBIx::Class` is not the fact that it saves you time
by allowing you to sidestep database incompatibilities. It's not that you never
have to learn the exact way to paginate correctly with SQL Server. It isn't even
that you won't have to write DDL for some of the most popular databases. Of
course `DBIx::Class` **does** do these things. Any ORM worth it's weight in salt
should.

## Chaining

The most important feature of `DBIx::Class` is the
[ResultSet](https://metacpan.org/module/DBIx::Class::ResultSet). I'm not an
expert on ORMs, but I've yet to hear of another ORM which has an immutable (if
it weren't for the fact that there is an implicit iterator akin to each %foo it
would be 100% immutable. It's pretty close though!) query representation
framework. The first thing you **must** understand to achieve `DBIx::Class` mastery is
ResultSet chaining. This is basic but critical.

The basic pattern of chaining is that you can do the following and not hit the
database:

```
$resultset->search({
   name => 'frew',
})->search({
   job => 'software engineer',
})
```

What the above implies is that you can add methods to your resultsets like the
following:

```
sub search_by_name {
   my ($self, $name) = @_;

   $self->search({ $self->current_source_alias . ".name" => $name })
}

sub is_software_engineer {
   my $self = shift;

   $self->search({
      $self->current_source_alias . ".job" => 'software engineer',
   })
}
```

And then the query would become merely

```
$resultset->search_by_name('frew')->is_software_engineer
``` 

(microtip: use
[DBIx::Class::Helper::ResultSet::Me](https://metacpan.org/module/DBIx::Class::Helper::ResultSet::Me)
to make defining searches as above less painful.)

## Relationship Traversal

The next thing you need to know is relationship traversal. This can happen two
different ways, and to get the most code reuse out of `DBIx::Class` you'll need to
be able to reach for both when the time arrises.

The first is the more obvious one:

```
$person_rs->search({
   'job.name' => 'goblin king',
}, {
   join => 'job',
})
```

The above finds person rows that have the job "[goblin
king.](https://www.google.com/search?tbm=isch&q=david+bowie+jareth)"

The alternative to use [`related_resultset` in
DBIx::Class::ResultSet](https://metacpan.org/module/DBIx::Class::ResultSet#related_resultset):

```
$job_rs->search_by_name('goblin_king')
       ->related_resultset('person')
``` 

The above generates the same query, but allows you to use methods that are
defined on the job resultset.

## Subqueries

Subqueries are less important for code reuse and more important in avoiding
incredibly inefficient database patterns. Basically, they allow the database to
do more on its own. Without them, you'll end up asking the database for data,
then you'll send that data right back to the database as part of your next
query. It's not only pointless network overhead but also two queries.

Here's an example of what not to do in `DBIx::Class`:

```
my @failed_tests = $tests->search({
   pass => 0,
})->all;

my @not_failed_tests = $tests->search({
  id => { -not_in => [map $_->id, @failed_tests] }, # XXX: DON'T DO THIS
});
``` 

If you got enough failed tests back, this would probably just error. **Just Say No**
to inefficient database queries:

```
my $failed_tests = $tests->search({
   pass => 0,
})->get_column('id')->as_query;

my @not_failed_tests = $tests->search({
  id => { -not_in => $failed_tests },
});
``` 

This is much more efficient than before, as it's just a single query and lets
the database do what it does best and gives you what you exactly want.

## Christmas!

Ok so now you know how to reuse searches as much as is currently possible. You
understand the basics of subqueries in `DBIx::Class` and how they can save you
time. My guess is that you actually already knew that. "This wasn't any kind of
ninja secret, fREW! You lied to me!" I'm sorry, but now we're getting to the
real meat.

## Correlated Subqueries

One of the common, albeit expensive, usage patterns I've seen in `DBIx::Class` is
using `N + 1` queries to get related counts. The idea is that you do something
like the following:

```
my @data = map +{
   %{ $_->as_hash },
   friend_count => $_->friends->count, # XXX: BAD CODE, DON'T COPY PASTE
}, $person_rs->all
``` 

Note that the `$_->friends->count` is a query to get the count of friends. The
alternative is to use correlated subqueries. Correlated subqueries are hard to
understand and even harder to explain. The gist is that, just like before, we
are just using a subquery to avoid passing data to the database for no good
reason. This time we are just going to do it for each row in the database. Here
is how one would do the above query, except as promised, with only a single hit
to the database:

```
my @data = map +{
   %{ $_->as_hash },
   friend_count => $_->get_column('friend_count'),
}, $person_rs->search(undef, {
   '+columns' => {
      friend_count => $friend_rs->search({
         'friend.person_id' =>
            { -ident => $person_rs->current_source_alias . ".id" },
      }, {
        alias => 'friend',
      })->count_rs->as_query,
   },
})->all
``` 

There are only two new things above. The first is `-ident`. All `-ident` does is
tell `DBIx::Class` "this is the name of a thing in the database, quote it
appropriately." In the past people would have written `-ident` using queries like
this:

```
'friend.person_id' => \' = foo.id' # don't do this, it's silly
``` 

So if you see something like that in your code base, change it to `-ident` as
above.

The next new thing is the `alias => 'friend'` directive. This merely ensures that
the inner rs has it's own alias, so that you have something to correlate
against. If that doesn't make sense, just trust me and cargo cult for now.

This adds a virtual column, which is itself a subquery. The column is,
basically, `$friend_rs->search({ 'friend.person_id' => $_->id })->count`, except
it's all done in the database. The above is **horrible** to recreate every time,
so I made a helper:
[DBIx::Class::Helper::ResultSet::CorrelateRelationship](https://metacpan.org/module/DBIx::Class::Helper::ResultSet::CorrelateRelationship).
With the helper the above becomes:

```
my @data = map +{
   %{ $_->as_hash },
   friend_count => $_->get_column('friend_count'),
}, $person_rs->search(undef, {
   '+columns' => {
      friend_count => $person_rs->correlate('friend')->count_rs->as_query
   },
})->all
```
 
## [::ProxyResultSetMethod](https://metacpan.org/module/DBIx::Class::Helper::Row::ProxyResultSetMethod)

Correlated Subqueries are nice, especially given that there is a helper to make
creating them easier, but it's still not as nice as we would like it. I made
another helper which is the icing on the cake. It encourages more
forward-thinking `DBIx::Class` usage with respect to resultset methods.

Let's assume you need friend count very often. You should make the following
resultset method in that case:

```
sub with_friend_count {
   my $self = shift;

   $self->search(undef, {
      '+columns' => {
         friend_count => $self->correlate('friend')->count_rs->as_query
      }
   }
}
```
 
Now you can just do the following to get a resultset with a friend count included:

```
$person_rs->with_friend_count
```
 

But to access said friend count from a result you'll still have to use
`->get_column('friend')`, which is a drag since using `get_column` on a
`DBIx::Class` result is nearly using a private method. That's where my helper
comes in. With
[DBIx::Class::Helper::Row::ProxyResultSetMethod](https://metacpan.org/module/DBIx::Class::Helper::Row::ProxyResultSetMethod),
you can use the `->with_friend_count` method **from** your row methods, and
better yet, if you used it when you originally pulled data with the resultset,
the result will use the data that it already has! The gist is that you add this
to your result class:

```
__PACKAGE__->load_components(qw( Helper::Row::ProxyResultSetMethod ));
__PACKAGE__->proxy_resultset_method('friend_count');
``` 

and that adds a `friend_count` method on your row objects that will correctly
proxy to the resultset or use what it pulled or cache if called more than once!

## [::ProxyResultSetUpdate](https://metacpan.org/module/DBIx::Class::Helper::Row::ProxyResultSetUpdate)

I have one more, small gift for you. Sometimes you want to do something when
either your row or resultset is updated. I posit that the best way to do this is
to write the method in your resultset and then proxy to the resultset from the
row. If you force your API to update through the result you are doing N updates
(one per row), which is inefficient. My helper simply needs to be loaded:

```
__PACKAGE__->load_components(qw( Helper::Row::ProxyResultSetUpdate ));
``` 

and your results will use the update defined in your resultset.

## Don't Stop!

This isn't all! `DBIx::Class` can be very efficient **and also** reduce code
duplication. Whenever you have something that's slow or bound to result objects,
think about what you could do to leverage your amazing storage layer's speed
(the RDBMS) and whether you can push the code down a layer to be reused more.
