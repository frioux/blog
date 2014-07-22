---
title: "DBIx::Class: Parameterized Relationships"
date: "2014-07-22T08:07:12"
tags: ["perl", "DBIx::Class", "DBIC", "extrels", "relationships"]
guid: "https://blog.afoolishmanifesto.com/posts/dbix-class-parameterized-relationships"
---
Probably once a week in the DBIx::Class channel someone asks if there is a way
to pass arguments to a relationship.  There is an answer but it isn't pretty or
for the faint of heart, so I finally have decided that I should write up a post
detailing how to do it and nicely hide it from the user.

For what it's worth there *are* plans to make a first class API for this, and
the following code is a workaround.  We just aren't there yet as of July 2014.

## Extended Relationship Refresher

The first tool to use when defining
a parameterized relationship is an [extended
relationship](https://blog.afoolishmanifesto.com/posts/dbix-class-extended-relationships/).
The fundamental trick here is that we're leveraging the fact that a coderef is
able to have access to some variable.  Note that I've never even felt the need
for this, there are real reasons, but in my experience they are rare.

(See
[::RelationshipDWIM](https://blog.afoolishmanifesto.com/posts/dbix-class-helper-row-relationshipdwim-awesome/)
and
[::Candy](https://blog.afoolishmanifesto.com/posts/announcing-dbix-class-candy/)
for part of why these rels are a little shorter than normal.)

Here's an example parameterized relationship:

    package My::Schema::Result::Foo;

    ...

    our $SHARE_TYPE;
    has_many output_devices => '::OutputDevice', sub {
       my $args = shift;
       
       die "no share_type specified!" unless $SHARE_TYPE;

       my %shared = ( "$args->{foreign_alias}.shared" => $SHARE_TYPE );
       
       return ({
          "$args->{foreign_alias}.user" =>
             { -ident => "$args->{self_alias}.user" },
          %shared,
       },
       $args->{self_rowobj} && {
          "$args->{foreign_alias}.user" => $args->{self_rowobj}->user,
          %shared,
       });
    };

The way the user can use this relationship is as follows:

    my @rows = do {
       local $My::Schema::Result::Foo::SHARE_TYPE = [1, 2];
       $rs->search(undef, { join => 'output_devices' })->all
    };

## ResultSet Method

That's a little gross, so lets wrap it in a resultset method:

    package My::Schema::ResultSet::Foo;

    ...

    sub by_output_devices_share_type {
       my ($self, $share_type) = @_;

       local $My::Schema::Result::Foo::SHARE_TYPE = $share_type;
       $self->search(undef, { join => 'output_devices' })->all
    }

And then to use it the user would write:

    $rs->by_output_devices_share_type([1, 2])->all

## Perché?

But why?  That's what I don't understand.  The user could also write the
following:

    package My::Schema::Result::Foo;
    
    ...
    
    has_many output_devices => '::OutputDevice',
      { 'foreign.user' => 'self.user' };
    
    ...
    
    package My::Schema::ResultSet::Foo;
    
    ...
    
    sub by_output_devices_share_type {
       my ($self, $share_type) = @_;

       $self->search({
         'output_devices.shared' => $share_type,
       }, { join => 'output_devices' })->all
    }

The user interface is the same:

    $rs->by_output_devices_share_type([1, 2])->all

The whole thing is much simpler.

## Perché!

The reason, as some have mentioned in the comments, and some on IRC, for putting
the expression in the `JOIN` instead of the `WHERE` is that in the case of a
`LEFT JOIN` the values can (obviously) be different.  A good example that
[moritz](http://perlgeek.de/blog-en/) gave me is basically as follows:

You have two tables, call them `CD` and `Artist`.  For the sake of the example
we are going to say that the title of the CD is not nullable.  In that case, the
following two queries are obviously different:

    -- finds no CDs
    SELECT "a".*, "c".* FROM "Artist" "a"
    LEFT JOIN "CD" "c" ON "c"."artist_id" = "a"."id" AND
                          "c"."title" IS NULL

    -- finds all artists with no CDs
    SELECT "a".*, "c".* FROM "Artist" "a"
    LEFT JOIN "CD" "c" ON "c"."artist_id" = "a"."id"
    WHERE "c"."title" IS NULL

Thanks mortiz and Greg for pointing this out!

