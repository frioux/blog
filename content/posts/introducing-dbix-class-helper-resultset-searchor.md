---
aliases: ["/archives/1714"]
title: "Introducing DBIx::Class::Helper::ResultSet::SearchOr"
date: "2012-06-01T14:24:50-05:00"
tags: [frew-warez, announcement, cpan, dbix-class, dbix-class-helpers, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1714"
---
Arguably the most important design decision that mst made when first writing DBIx::Class was the choice to make chainable resultsets. A fundamental part of that design is that when you chain off of a resultset you should always get a subset of what you started with. This is important because it's what makes searching from a user object or similarly using DBIx::Class::Schema::RestrictWithObject work in a safe manner.

Most everyone should know at this point that the best way to use DBIx::Class it to make various ResultSet methods that return named subsets of data. For example, for our Test resultset I have three methods, failed, succeeded, and untested. For some purposes though, we want to get all tests that are failed and untested. I could write a new method and copy paste the contents of failed and untested into it, but that's not good programming practice in general. What I did in the past was actually unioned the two resultsets. That works, but it generates much more complicated SQL and is possibly slower than it could be.

# Introducing DBIx::Class::Helper::ResultSet::SearchOr

SearchOr gives your resultset a search\_or method. It works similarly to union, but instead of an actual union it's just an expression union, also know as "or." Here's an example of it in action for the above example:

    my $rs = $schema->resultset('Test')->search_or([
       $schema->resultset('Test')->failed,
       $schema->resultset('Test')->untested
    ]);

Unfortunately that misses a fairly major point of the module; it works correctly with chaining, as discussed above. So here's a better example:

    my $rs = $schema->resultset('Test')->complete->search_or([
       $schema->resultset('Test')->failed,
       $schema->resultset('Test')->untested
    ]);

To be clear, the above finds all tests that are complete AND ( failed OR untested ). Of course the expressions for complete, failed, and untested are more complicated than that, but it works.

The one fairly major caveat of this module is that it doesn't Just Work with JOINs. Because it fundamentally ONLY puts ors between the passed expressions and looks at pretty much none of the rest of the passed resultsets, that's your job to handle. So if you can get away with it, just add a join to the "root" search. If for some reason that won't work, because of separate join paths for example, you'll need to resort to a union.
