---
title: DBIx::Class::Helper::ResultSet::Errors
date: 2015-02-20T23:04:16
tags: ["perl", "cpan", "dbic", "dbix-class", "dbix-clas-helpers"]
guid: "https://blog.afoolishmanifesto.com/posts/dbix-class-helper-resultset-errors"
---
This is just a quick post to update you all on a nice new helper.

Recently at my work we hired a new programmer and I've been showing him the
ropes.  I noticed him running into the age old confusion of treating a ResultSet
like a Result, so I took note and decided to make a helper to give specific
error messages when the user makes that mistake.

If you plan on hiring new people ever, or you are a mere human yourself, why not
add
[DBIx::Class::Helper::ResultSet::Errors](https://metacpan.org/pod/release/FREW/DBIx-Class-Helpers-2.025000/lib/DBIx/Class/Helper/ResultSet/Errors.pm)
to your base ResultSet?  You'll get a fairly obvious error when you forget that
you are using a ResultSet and accidentally thing it is a Result.

That is all.
