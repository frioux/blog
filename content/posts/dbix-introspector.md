---
aliases: ["/archives/1847"]
title: "DBIx::Introspector"
date: "2013-10-19T15:41:48-05:00"
tags: ["cpan", "dbi", "dbixclass", "dbixintrospector", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1847"
---
DBIx::Introspector is a refactorization of some [DBIx::Class](https://metacpan.org/module/RIBASUSHI/DBIx-Class-0.08250/lib/DBIx/Class.pm) code that detects what database a $dbh is connected to, as well as getting various facts from the $dbh. It is currently very much unborn, but given some feedback and battle testing on my own modules I hope to get it released before Christmas of 2013. (Famous last words?)

The gist is that you can do something like the following:

    my $di = DBIx::Introspector->new;
    $di->get($dbh, 'rdbms_engine');

That's certainly nice, as currently there isn't anything like that on the CPAN that works for more than just mysql, SQLite, and Pg. But ultimately the refactoring from what DBIC already did to how it currently works (more on that later) is unjustified for static facts. What DBIx::Introspector buys you is a way to paint in broad strokes about databases in general, while leveraging it's fairly straightforward detection method. Here's an example that will eventually end up in [DBIx::Class::MaterializedPath](https://metacpan.org/module/DBIx::Class::MaterializedPath):

    my $di = DBIx::Introspector->new;
    $di->decorate_driver(DBI   =>
       concat_sql => sub { '%s || %s' });
    $di->decorate_driver(mysql =>
       concat_sql => sub { 'CONCAT( %s, %s)' });
    $di->decorate_driver(MSSQL =>
       concat_sql => sub { '%s + %s' });

    $di->get($dbh, 'concat_sql');

All of the above code works right now, and has [a basic test suite](https://github.com/frioux/DBIx-Introspector/tree/13bd4629a9ec456f50e19999433b1be8cc479389/t) including [CI on travis-ci](https://travis-ci.org/frioux/DBIx-Introspector/builds). Some of the things that I think need to be hammered out before a release are:

- allow decoration of drivers at instantiation instead of in a mutator
- experiment with adding/replacing drivers at runtime
- decide on what facts should be core (rdbms\_engine: probably, concat\_sql: almost certainly not)
- maybe add some memoization so that when a given $dbh is detected twice we don't have to redetect

## WHY

One of the projects that has spawned off of DBIx::Class is [DBIx::Connector](https://metacpan.org/module/DBIx::Connector). It's pretty good at what it does, and for a lightweight project it is perfectly fine. Unfortunately for many projects (most especially DBIx::Class) it is too simple. The problem comes in [this line of code](https://metacpan.org/source/DWHEELER/DBIx-Connector-0.53/lib/DBIx/Connector.pm#L59).

To correctly detect what database your are connected to you must do a lot more than just that. For instance, DBIx::Connector has an [MSSQL Driver](https://metacpan.org/module/DBIx::Connector::Driver::MSSQL). How one uses it with SQL Server I have no idea, because there is no such thing as DBD::MSSQL and when I connect to my database $dbi->\{Driver\}\{Name\} returns 'ODBC', because it's the name of the **driver**, not the database.

To be clear, I'm not criticizing David Wheeler for this, I actualy tried punting on this in the still unborn DBIx::Exceptions in the same way. It's a hard problem! I've tried to cajole other members of the community to do the work on IRC a number of times and never really had any success, so I bit the bullet and wrote it.

## HOW

DBIx::Class detects databases in a "rebless loop." To be clear it's not like there's a while loop, but basically when you connect it reblesses and either keeps reblessing or finishes. The salient code is [here](https://metacpan.org/source/RIBASUSHI/DBIx-Class-0.08250/lib/DBIx/Class/Storage/DBI.pm#L1233).

While it's pretty awesome that perl gives you that kind of rope, it makes discovering what is happening pretty tough. And more importantly to me, when you have a heirarchy of classes (shut up, roles would have the same problem) you can't easily add information to one of the base classes and have it apply to all of the rest without (even dynamic) monkeypatching, which is gross.

What I've done with DBIx::Introspector is to make all detection and "fact-checking" data driven. It's inspired by prototypical OO where you can modify the object without creating some ghetto temporary or "anonymous" class.

There are two parts of DBII, really. The first is detecting which driver most accurately matches the given $dbh, and the next is asking said driver questions about the $dbh. The detection works like this, first you ask the initial driver (DBI) to "detect" the $dbh. It will give you a name for another driver that can more accurately describe the $dbh. From there you keep doing that till you get "1" back. A string other than "1" is a driver to switch to, 1 means "I am the right driver" and undef means "wtf I give up."

Asking questions of the drivers is where the fake prototypical OO comes in. Each driver has a set of parent drivers. If you ask the driver a question it can either

1. Answer the question, with a code reference
2. Refer to another driver by name, with a string, to answer the question
3. Defer to a parent driver, but storing nothing (or a false value)

All parts of the system cleanly represent how the old true OO version worked, but in a much smaller, simpler system. The detection code currently clocks in at something like 20 LoC and is extensible in a non-global fashion.

## YOU

I really want to know what use-cases this will **not** work for. I know that it will work for DBIx::Class::Helpers, DBIx::Class::MaterializedPath, DBIx::Exceptions, and I am pretty sure DBIx:Class itself and DBIx::Connector if David Wheeler is interested. I'm also interested in people who use very esoteric databases and connection methods (Firebird over DBD::Gofer?) to ensure that when I inevitably miss a connection method adding one at runtime isn't hard.

## 2013-10-19 API

Also note that this is totally unreleased. Names of things will certainly change. The name of the module might even change. Look forward to an Advent Calendar article that more accurately describes the end product.
