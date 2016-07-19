---
aliases: ["/archives/1501"]
title: "New stuff in DBIx::Class::Helpers"
date: "2011-02-01T01:13:23-06:00"
tags: [frew-warez, dbix-class, dbix-class-helpers, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1501"
---
I just released a new version of [DBIx::Class::Helpers](http://search.cpan.org/perldoc?DBIx::Class::Helpers) and it has two new components: [DBIx::Class::Helper::ResultSet::ResultClassDWIM](http://search.cpan.org/perldoc?DBIx::Class::Helper::ResultSet::ResultClassDWIM) and [DBIx::Class::Helper::Schema::GenerateSource](http://search.cpan.org/perldoc?DBIx::Class::Helper::Schema::GenerateSource).

## [Helper::ResultSet::ResultClassDWIM](http://search.cpan.org/perldoc?DBIx::Class::Helper::ResultSet::ResultClassDWIM)

This component solves an issue I've seen both by myself and with my coworkers; it's too hard to remember/type the following:

    my $rs = $schema->resultset('Foo')->search($q, {
       result_class => 'DBIx::Class::ResultClass::HashRefInflator',
    });

So I wrote this component which will let you generically write:

    my $rs = $schema->resultset('Foo')->search($q, {
       result_class => '::HashRefInflator',
    });

or use the specially hardcoded:

    my $rs = $schema->resultset('Foo')->search($q, {
       result_class => '::HRI',
    });

Handy right?

## [Helper::Schema::GenerateSource](http://search.cpan.org/perldoc?DBIx::Class::Helper::Schema::GenerateSource)

This component is a little more unusual. The idea is to take care of some of the issues I mentioned [here](/archives/1490). It doesn't solve everything due to some design issues in DBIx::Class, which I hope to take care of soon. Basically the idea is that instead of the boilerplate files that you get when you use [DBIx::Class::Helper::Row::SubClass](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::SubClass), you can instead just do the following in your schema:

    package Foo::Schema;

    __PACKAGE__->load_components('Helper::Schema::GenerateSource');

    # ...

    __PACKAGE->generate_source(User => 'MyCompany::Result::User');

    1;

The main issue is that even though this correctly associates a new source to the schema, you cannot currently add relationships to the source. I'll make another post when I fix that, but I doubt I'll get it into the next release of DBIx::Class.

In other news I'm doing some pretty sweet stuff with the SQL generation code in DBIx::Class and I hope it will be ready for the next release. I'll post more when that's released.
