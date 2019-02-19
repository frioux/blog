---
title: DBI Logging and Profiling
date: 2016-03-24T09:04:25
tags: [ziprecruiter, perl, dbi, dbix-class]
guid: "https://blog.afoolishmanifesto.com/posts/dbi-logging-and-profiling"
---
I built some code to profile DBI usage.

<!--more-->

If you use Perl and connect to traditional relational databases, you use
[DBI](https://metacpan.org/pod/DBI).  Most of the Perl shops I know of nowadays
use [DBIx::Class](https://metacpan.org/pod/DBIx::Class) to interact with a
database.  This blog post is how I "downported" some of my DBIx::Class ideas to
DBI.  Before I say much more I have to thank my boss Bill Hamlin, for showing me
how to do this.

Ok so when debugging queries, with DBIx::Class you can set the `DBIC_TRACE`
environment variable and see the queries that the storage layer is running.
Sadly sometimes the queries end up mangled, but that is the price you pay for
pretty printing.

You can actually get *almost* the same thing with DBI directly by setting
`DBI_TRACE` to `SQL`.  That is technically not supported everywhere, but it has
worked everywhere I've tried it.  If I recall correctly though, unlike with
`DBIC_TRACE`, using `DBI_TRACE=SQL` will not include any bind arguments.

Those two features are great for ad hoc debugging, but at some point in the
lifetime of an application you want to count the queries executed during some
workflow.  The obvious example is during the lifetime of a request.  One could
use [DBIx::Class::QueryLog](https://metacpan.org/pod/DBIx::Class::QueryLog) or
something like it, but that will miss queries that were executed directly
through DBI, and it's also a relatively expensive way to just count queries.

The way to count queries efficiently involves using
[DBI::Profile](https://metacpan.org/pod/DBI::Profile), which is very old school,
like a lot of DBI.  Here's how I got it to work just recording counts:

```
#!/usr/bin/env perl

use 5.12.0;
use warnings;

use Devel::Dwarn;
use DBI;
use DBI::Profile;
$DBI::Profile::ON_DESTROY_DUMP = undef;

my $dbi_profile = DBI::Profile->new(
  Path => [sub { $_[1] eq 'execute' ? ('query') : (\undef) }]
);

$DBI::shared_profile = $dbi_profile;

my $dbh = DBI->connect('dbi:SQLite::memory:');
my $sth = $dbh->prepare('SELECT 1');
$sth->execute;
$sth->execute;
$sth->execute;

$sth = $dbh->prepare('SELECT 2');
$sth->execute;
$sth->execute;
$sth->execute;

my @data = $dbi_profile->as_node_path_list;
Dwarn \@data;
```

And in the above case the output is:

```
[
  [
    [
      6,
      "6.67572021484375e-06",
      "2.86102294921875e-06",
      0,
      "2.86102294921875e-06",
      "1458836436.12444",
      "1458836436.12448"
    ],
    "query"
  ]
]
```

The outermost arrayref is supposed to contain all of the profiled queries, so
each arrayref inside of that is a query, with [it's profile data as the first
value (another arrayref)](https://metacpan.org/pod/DBI::Profile#Profile-Data)
inside, and all of the values after that first arrayref are user configurable.

So the above means that we ran six queries.  There are some numbers about
durations but they are so small that I won't consider them carefully here.  See
the link above for more information.  Normally if you had used DBI::Profile you
would see two distinct queries, with a set of profiling data for each, but here
we see them all merged into a single bucket.  **All** of the magic for that is
in my `Path` code references.

Let's dissect it carefully:

```
$_[1] eq 'execute' # 1
  ? ('query')      # 2
  : (\undef)       # 3
```

Line 1 checks the DBI method being used.  This is how we avoid hugely inflated
numbers.  We are trading off some granularity here for a more comprehensible
number.  See, if you prepare 1000 queries, you are still doing 1000 roundtrips
to the database, typically.  But that's a weird thing, and telling a developer
how many "queries they did" is easier to understand when that means simply
executing the query.

In line 2 we return `('query')`.  This is what causes all queries to be treated
as if they were the same.  We could have returned any constant string here.  If
we wanted to do something weird, like count based on type of query, we could do
something clever like the following:

```
return (\undef) if $_[1] eq 'execute';
local $_ = $_;

s/^\s*(\w+)\s+.*$/$1/;
return ($_);
```

That would create a bucket for `SELECT`, `UPDATE`, etc.

Ok back to dissection; line 3 returns `(\undef)`, which is weird, but it's how
you signal that you do not want to include a given sample.

---

So the above is how you generate all of the profiling information.  You can be
more clever and include caller data or even bind parameters, though I'll leave
those as a post for another time.  Additionally, you could carefully record your
data and then do some kind of formatting at read time.  Unlike `DBIC_TRACE`
where you can end up with invalid SQL, you could use this with post-processing
to show a formatted query if and only if it round trips.

Now go forth; record some performance information and ensure your app is fast!

**UPDATE:** I modified the `ON_DESTROY_DUMP` to set it to undef instead of an
empty code reference.  This correctly avoids a lot of work at object destriction
time.  [Read this for more information](/posts/faster-dbi-profiling).
