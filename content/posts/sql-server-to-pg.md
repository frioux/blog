---
title: Converting from SQL Server to Postgres
date: 2015-05-05T21:16:36
tags: ["sqlserver", "mssql", "postgresql", "postgres", "pg", "dbix-class"]
guid: "https://blog.afoolishmanifesto.com/posts/sql-server-to-pg"
---
One of the things that I've been working towards for a long time at my current
job (which I'm on the way out of) is to have the project work 100% on Linux.
The main thing holding it back from that is that it depends on SQL Server.  Now
of course DBD::ODBC runs on Linux and even nowadays Microsoft distributes their
Native Client for Linux.  But our project is turnkey and runs on one physical
machine, so the database is included.

The way that I've been trying to resolve this issue is by supporting Postgres as
a backend.  I initially started work on this now and then in September of 2014.
My general workflow was to spend about 30m in the mornings converting one of our
CGI scripts or even a single method.  The goal is not to work only on Pg, but to
support *both* SQL Server and Pg.

There are two good reasons to support both Pg and SQL Server.  First and
foremost is for business reasons.  We have a lot of customers who run their own
SQL Server database and do not want the database to run on the actual server.
That's fine, but in order to support that we need to keep supporting SQL Server.
As cool as Postgres is, I suspect that none of our customers have a central
Postgres database in house.

The other reason is so that it won't be a flag day.  If we support both it's
feasible to make changes and merge them in as we go.  No one likes a flag day;
this just lets us avoid that.

## Specific Tips

SQL Server and Postgres are surprisingly similar, as far as databases go.
Obviously there are differences, but going from SQL Server to Postgres is much
easier (I think) than going from MySQL to Postgres or MySQL to SQL Server.  I've
learned a few things in this conversion that I suspect will maybe help at least
one person out there.  One thing to note is that SQL Server forked off of Sybase
in the distant past and I suspect that a significant amount of these details
apply to a Sybase to Postgres port as well.

### DBIx::Class

A lot of the following tips don't apply if you are using DBIx::Class.  If you
*are* using DBIC though, the main thing I can recommend at this point is that
you will want to use my
[DBIx::Class::Helper::ResultSet::DateMethod1](https://metacpan.org/pod/DBIx::Class::Helper::ResultSet::DateMethods1).
That helps a lot with date math, the most frustrating part of a DB port, aside
from pagination which doesn't apply with DBIC.

### Quoting

For some crazy reason SQL Server queries tend to be quoted with brackets (`[]`.)
Every version of SQL Server I've ever found documentation for supports double
quotes (`"`.)  Double quotes are moderately easier to read but more importantly,
the are portable.  All of SQL Server, Postgres, SQLite, and Oracle use (or at
least support) double quotes.  So use double quotes; they work everywhere that
matters.

### Casing

In SQL Server, like many Microsoft products, columns and table names are case
insensitive.  Postgres is not so forgiving.  Postgres is in fact a little weird,
but once you get used to it it's not so bad.  In Postgres, a column that is all
lowercase (`username`) is merely what you would expect.  A column that contains
uppercase (`UserName`) is actually treated as if it were lowercase.  A column
that is quoted and contains uppercase (`"UserName"`) is treated as itself.  So
to be clear, if the column's actual name in the table definition is lowercase,
you can use uppercase in queries as long as you do not quote your columns.

So what I do is define all columns and table names as lowercase in Postgres.
Initially I tried leaving the case of columns the same, and you can do that, but
it ends up being a hassle no matter what.  So if you have a query like the
following in SQL Server:
```
SELECT SerialNumber FROM Equipment WHERE id = ?
```

The hashref you get back will look like this:
```
{ SerialNumber => 27 }
```

Unfortunately, if you run the exact same query in Postgres, you get back:
```
{ serialnumber => 27 }
```

This is arguably the most subtle but important detail in a conversion.  You now
have to update all of the stuff that's looking at that returned hash reference
with the correct case.  If you miss one, you'll just have a blank spot in a
template or something, so it's *very* easy to miss.

If you were smart you'd have used the `FetchHashKeyName => 'NAME_lc'` directive
when you initially wrote the application, but that seems pretty unlikely.  I
only had ever heard of that when I started this conversion, and flipping that
switch would be pretty hardcore (though not a bad idea!)

I *think* another option is to do the following (untested, I'm on a plane:)

```
SELECT serialnumber AS "SerialNumber" FROM Equipment WHERE id = ?
```

That sucks, but it reduces the overall modification of your code, which is a
good goal.

### SELECT *

You should all know that `SELECT *` should not be used seriously in code.  It's
fine when you're looking at data yourself, but it's a bad call in code as you
can accidentally pull in a lot more data than you really need and also if you
are looking at data as a list instead of as a hash you are accidentally
depending on the order of the columns defined in the database, which is again a
bad call.

The bigger problem is that if you are using `SELECT *` you suddently need to
find *all* of the hash accesses in the following code that comes from the query
and fix the case.  This is a *huge* hassle.  I personally just get rid of the
`*` and put in a real list of columns.  But trust me: this sucks.

### Date Math

As far as I can tell there is no SQL Standard for date math.  Maybe there is in
like, SQL:2013 or something like that, but it's not really out there yet.
Anyway, what I've done is use my
[DBIx::Introspector](https://metacpan.org/pod/DBIx::Introspector) to create a
simple dictionary for date math stuff.

Here's a bit of my DBII definition:

```
sub sql_dict {
   require DBIx::Introspector;

   my $d = DBIx::Introspector->new(drivers => '2013-12.01');

   $d->decorate_driver_unconnected(
      Pg => hours_plus_12 => q{now() < %s + interval '12 hours '},
   );
   $d->decorate_driver_unconnected(
      MSSQL => hours_plus_12 => q{DateDiff(Minute, %s, GetDate()) <= 720},
   );

   $d->decorate_driver_unconnected(Pg => now => 'now()');
   $d->decorate_driver_unconnected(MSSQL => now => 'GetUTCDate()');

   $d->decorate_driver_unconnected(Pg => localnow => 'localtimestamp');
   $d->decorate_driver_unconnected(MSSQL => localnow => 'GetDate()');

   $d;
}
```

And then to use it:

```
my $d = My::Util->sql_dict;
my $localnow = $d->get($dbh, undef, 'localnow');
my $sql = <<"SQL";
  INSERT INTO "Current_Access"
        ("userid", "subuser", "ip_address", "access_num", "last_accessed")
   VALUES
        (?,?,?,?,$localnow)
SQL
```

It's not gorgeous, but it works.

### Booleans

Surprisingly I couldn't find a keyword that would work for both Postgres
booleans and SQL Server bit(1)'s.  Again I had to fall back onto DBII:

```
...
   $d->decorate_driver_unconnected(Pg => true => 'True');
   $d->decorate_driver_unconnected(MSSQL => true => 1);

   $d->decorate_driver_unconnected(Pg => false => 'False');
   $d->decorate_driver_unconnected(MSSQL => false => 0);
...

my $true = $d->get($dbh, undef, 'true');
my $Query = <<"SQL"
   SELECT "user_id", "name", "user"
     FROM "Users"
     JOIN "SubUser" ON "Users"."id" = "SubUser"."user_id"
    WHERE "name" = ? AND "ad" = $true
SQL
```

### The Hammer

This final trick, while gross, works when you end up in situations where a
simple SQL fragment will not do the trick.  Typically complex queries that
involve pagination is where I find myself using this.  First off, you'll need to
add a new DBII fact:

```
   $d->decorate_driver_unconnected(Pg => introspector_driver => 'Pg');
   $d->decorate_driver_unconnected(MSSQL => introspector_driver => 'MSSQL');
```

The you use it in a hash, like this:

```
   my $sql = {
      Pg => qq!
         DELETE FROM "RSS" WHERE guid IN (
            SELECT guid FROM "RSS"
            WHERE feedurl = ?
            AND guid IS NOT NULL
            ORDER BY lastmod ASC
            LIMIT $todelete
         )
      !,
      MSSQL => qq!
         DELETE RSS
         FROM (
         SELECT TOP $todelete  cast (lastmod as datetime) as thedate,guid FROM RSS
          where feedurl =  ?
          and guid is not NULL
          order by thedate asc
         ) AS t1
         WHERE RSS.guid = t1.guid
     !
   }->{My::Util->sql_dict->get($dbh, undef, 'introspector_driver')}
```

This can also be used for fragments that are so specific that putting them in
the dictionary feels silly.

### Misc

There are a few things that are obvious once you see them but I might as well
mention them.

SQL Server allows you to leave the `FROM` keyword off in a `DELETE`; Postgres
does not.

I [mentioned in a previous
post](https://blog.afoolishmanifesto.com/posts/fear-and-loathing-in-sql-92) that
SQL Server pads space when doing a comparison.  Postgres does not.  Similarly,
the default collation in SQL Server is case insensitive.  This matters the most
when it comes to JOINs.  If you are joining on strings and do not have foreign
key constraints... well good luck.

With SQL Server you can do `SELECT @@IDENTITY` or `SELECT SCOPE_IDENTITY()` to
get the previous autoinc id.  I do not know of how to do this in Postgres.  What
I tend to do is just rework *both* so that they use a `RETURNING` pattern like
this:

Postgres:
```
INSERT INTO "Users" ("username") VALUES (?) RETURNING id
```

SQL Server:
```
INSERT INTO "Users" ("username") OUTPUT INSERTED.id VALUES (?)
```

This has been supported in SQL Server all the way back to SQL Server 2005, so
chances are you can use it.

Limiting is different, of course.  SQL Server uses a weird TOP thing:
```
SELECT TOP(1) username FROM Users
```

Postgres:
```
SELECT username FROM Users LIMIT 1
```

And if you were using SQL Server prior to 2012 (which is likely) your actual
paginated queries were a nightmare requiring a `ROW_NUMBER() OVER` at best, and
possibly nested TOPs.

```
SELECT  username
FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY username ) AS RowNum, username
          FROM      Users
        ) AS foo
WHERE   RowNum >= 10
    AND RowNum < 20
ORDER BY RowNum
```

(I won't reproduce nested TOPs, as they are actually buggy anyway.)

Postgres:
```
SELECT username FROM Users LIMIT 10 OFFSET 10
```

## Good Luck!

I think that's it!  Switching databases is a lot of work, and is certainly a
bigger deal than just switching underlying OS.  If anyone has stuff that I
should consider adding to the list of tips above feel free to comment and I'll
see about adding to the post.
