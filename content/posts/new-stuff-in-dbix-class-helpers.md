---
aliases: ["/archives/1234"]
title: "New stuff in DBIx::Class::Helpers"
date: "2009-12-28T20:18:05-06:00"
tags: ["dbic", "dbichelpers", "dbixclass", "dbixclasshelpers", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1234"
---
If I were to pick one of the modules that I've written so far to be my legacy [DBIx::Class::Helpers](http://search.cpan.org/perldoc?DBIx::Class::Helpers) would be it. Maybe later it will be DBIx::Exceptions, but as of now that's technically vaporware.

So over the Christmas break I've been working on updating it a bit. First and foremost I added the exciting [DBIx::Class::Helper::ResultSet::Union](http://search.cpan.org/perldoc?DBIx::Class::Helper::ResultSet::Union) helper. The best use case (I can think of) for a union is when you want to get data from multiple tables as if they were one table. Here is how one might do something like that with the new module (example ripped from wikipedia):

       my $sales_2006 = $schema->resultset('Sales2006')->search(undef, {
          columns => [qw{sales_person_id amount}]
       });
       my $sales_2007 = $schema->resultset('Sales2007')->search(undef, {
          columns => [qw{sales_person_id amount}]
       });
       $sales_2006->result_class('DBIx::Class::ResultClass::HashRefInflator');
       $sales_2007->result_class('DBIx::Class::ResultClass::HashRefInflator');

       my @sales = $sales_2006->union($sales_2007)->all;

I'd argue that if you have tables like the above you are Doin it Rong, but there are other times when it might make more sense, like if you wanted to maybe have some kind of autocompleter that works for more than one table (Artist, Album, Track) where all of the things have names and ids.

As you should be able to see from the name of the Component I have gone from naming things DBIx::Class::Helper::\* to DBIx::Class::Helper::$namespace::\*. Mostly that was because my esteemed [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) janitor, ribasushi, suggested it. I almost had done it before, but his asking for it was enough to get me to do it. The old names will be available for all of the 2.\* series and the 3.\* series with a warning. After that they will be removed.

Speaking of version numbers, I have also switched from using RJBS versions to using a more normal versioning scheme. Again, I wouldn't take the credit for this one as it is mostly due to mst and ribasushi's prodding. Basically the deal is that although RJBS versions make it dead easy for me to release code, they make it hard for the user to see what's going on. How much has changed between releases? All a user knows is if a release breaks backcompat or not. So I'll be using the more normal x.yyyzzw where x breaks backcompat, y means major new features, z means bugfixes, and w means minor fixes like pod or dist fixes. I imagine that even that could be automated by looking at current and previous release... Maybe next time :-)

Next up is a much more complete [DBIx::Class::Helper::ResultSet::Random](http://search.cpan.org/DBIx::Class::Helper::ResultSet::Random) which allows the selection of an arbitrary amount of rows, instead of just one. As mentioned in the POD I've only tested it on a large table with SQL Server (2005.) To be more explicit, if you are using mysql and it is as slow as people always say, show me a benchmark and we can work together to make it fast. The only thing I can think of to make it fast is to use RowNumberOver and do an IN for a list of shuffled numbers generated with perl. We'll see though. It works fine for me right now so I don't care :-)

While I was updating all these little bits I went ahead and pregenerated the DDL for the schema, so I no longer depend on SQLT, which is actually surprisingly heavy. So that's pretty sweet.

Lastly, [String::CamelCase](http://search.cpan.org/perldoc?String::CamelCase) had a new release that no longer fails tests! So I've added it as a dep and removed the conditional load code. This isn't as big a deal as most of the other stuff, but it is certainly a nice change.

Because of all of the major changes I've released the new version to cpan as a [developer version](http://search.cpan.org/~frew/DBIx-Class-Helpers-2.00000_1/), so please [check it out](http://search.cpan.org/~frew/DBIx-Class-Helpers-2.00000_1/). At the very least if someone finds a missing dep or something that would be good. If I somehow messed up the doc or something that would be good to find out as well. I plan on releasing for realz before (or on?) New years.
