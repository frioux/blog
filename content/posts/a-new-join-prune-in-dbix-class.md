---
title: A new Join Prune in DBIx::Class
date: 2016-04-29T23:03:27
tags: ['dbix-class', 'dbic', 'join']
guid: "https://blog.afoolishmanifesto.com/posts/a-new-join-prune-in-dbix-class"
---
At [work](https://www.ziprecruiter.com) a coworker and I recently went on a
rampage cleaning up our git branches.  Part of that means I need to clean up my
own small pile of unmerged work.  One of those branches is an unmerged change to
our subclass of the [DBIx::Class](https://metacpan.org/pod/DBIx::Class) [Storage
Layer](https://metacpan.org/pod/DBIx::Class::Storage::DBI) to add a new kind of
join prune.

If you didn't know, good databases can avoid doing joins at all by looking at
the query and seeing where (or if) the joined in table was used at all.
`DBIx::Class` does the same thing, for databases that do not have such tooling
built in.  In fact there was a time when it could prune certain kinds of joins
that even the lauded PostgreSQL could not.  That may no longer be the case
though.

The rest of what follows in this blog post is a very slightly tidied up commit
message of the original branch.  Enjoy!

---

Recently Craig Glendennig found a query in the ZR codebase that was using
significant resources; the main problem was that it included a relationship but
didn't need to.  We fixed the query, but I was confused because `DBIx::Class`
has a built in [join
pruner](https://github.com/dbsrgits/dbix-class/blob/e466c62beb412b762f17418cc09b8aced29c628f/lib/DBIx/Class/Storage/DBIHacks.pm#L23-90)
and I expected it to have transparently solved this issue.

It turns out we found a new case where the join pruner can apply!

If you have a query that matches all of the following conditions:

 * a relationship is joined with a `LEFT JOIN`
 * that relationship is not in the `WHERE`
 * that relationship is not in the `SELECT`
 * the query is limited to one row

You can remove the matching relationship.  The `WHERE` and `SELECT` conditions
should be obvious: if a relationship is used in the `WHERE` clause, you need it
to be joined for the `WHERE` clause to be able to match against the column.
Similarly, for the `SELECT` clause the relationship must be included so that the
column can actually be referenced in the `SELECT` clause.

The one row and `LEFT JOIN` conditions are more subtle; but basically consider
this case:

You have a query with a limit of 2 and you join in a relationship that has zero
or more related rows.  If you get back zero rows for all of the relationships,
the root table will basically be returned and you'll just get the first two rows
from that table.  But consider if you got back two related rows for each row in
the root table: you would only get back the first row from the root table.

Similarly, the reason that `LEFT` is specified is that if it were a standard
`INNER JOIN`, the relationship will filter the root table based on relationship.

If you specify a single row, when a relationship is `LEFT` it is not filtering
the root table, and the "exploding" nature of relationships does not apply, so
you will always get the same row.

---

[I've pushed the
change](https://github.com/dbsrgits/dbix-class/compare/master...frioux:join-pruner)
that adds the new join prune to GitHub, and notified the current maintainer of
`DBIx::Class` in the hopes that it can get merged in for everyone to enjoy.
