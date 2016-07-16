---
aliases: ["/archives/1289"]
title: "New stuff in DBIx::Class::Helpers 2.00200"
date: "2010-02-07T07:32:24-06:00"
tags: ["cpan", "dbix-class", "dbix-class-helpers", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1289"
---
A new release of the resplendent [Perl ORM](http://search.cpan.org/perldoc?DBIx::Class) [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) means new release of [DBIx::Class::Helpers](http://search.cpan.org/perldoc?DBIx::Class::Helpers)

The [ResultSet::Random helper](http://search.cpan.org/~frew/DBIx-Class-Helpers-2.00200/lib/DBIx/Class/Helper/ResultSet/Random.pm) had the wrong function used for MySQL. That was fixed thanks to an RT from pldoh.

get\_namespace\_parts from [the util package](http://search.cpan.org/~frew/DBIx-Class-Helpers-2.00200/lib/DBIx/Class/Helpers/Util.pm) was unnecessarily strict. Thanks to melo for the prodding to do that.

I refactored some of the code in core DBIx::Class so that I can more easily detect is\_numeric with [Row::NumifyGet](http://search.cpan.org/~frew/DBIx-Class-Helpers-2.00200/lib/DBIx/Class/Helper/Row/NumifyGet.pm), instead of requiring the user to specify it. Normally DBIx::Class autodetects it based on column type, but that code wasn't quite generic enough until now. Nice!

And then the most exciting bit is a new helper entirely for the suite: [Row::ToJSON](http://search.cpan.org/~frew/DBIx-Class-Helpers-2.00200/lib/DBIx/Class/Helper/Row/ToJSON.pm). Basically I was sick of doing this:

    package ACD::Schema::Result::Foo;

    # regular package stuff here

    sub TO_JSON {
      my $self = shift;
      return {
        id => $self->id,
        foo => $self->foo,
        # etc etc ad nausium
      }
    }

    "distraction";

Of course that can be shortened to:

    sub TO_JSON {
      my $self = shift;
      return { map +( $_ => $self->$_), qw{id foo ...} }
    }

But I still have to make that stupid columns list! This shiny new helper makes a TO\_JSON method that will simply include all of your columns except for the "heavy" ones like TEXT, NTEXT, or BLOB. Of course you can have finer-grained control than that by explicitly saying to include (or not) a column in it's configuration. See [the docs](http://search.cpan.org/~frew/DBIx-Class-Helpers-2.00200/lib/DBIx/Class/Helper/Row/ToJSON.pm) for all the nitty gritty details.
