---
aliases: ["/archives/1926"]
title: "Announcing ::Helper::ResultSet::DateMethods1"
date: "2014-03-04T14:26:38-06:00"
tags: [ announcement, "frew-warez", "cpan", "dbix-class", "dbix-class-helpers", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1926"
---
I have had this ready to go for a few days now, but I figured I might as well wait for Mardi Gras; so feel free to celebrate, put on a masque, and enjoy a nice Hurricane Cocktail while you read this.

----

[A little over three years ago](https://github.com/frioux/dbic-withdates/commit/5e6893d4cb873eca75118061c104bed9b891dee0) I got inspired while on vacation to Crested Butte, CO and started a branch in DBIC called merely, "date-ops." The idea was to allow users to call various date functions, portably, directly in DBIC. With some help from some people who use other databases, I got it working with SQL Server, SQLite, PostgreSQL, MySQL, and Oracle.

Unfortunately after we finished it ([about six months after I started](https://github.com/frioux/dbic-withdates/commit/fcb5b33a58426ee9d4b87fd84144d05d7a1cf9e9)) it merely languished. There were some technical issues we never got around to ironing out, mostly because it wasn't clear to us what the cost of not taking care of them would be.

Fast forward a few more months and I was working on a greenfield project at work. I wanted to do some date math in the database, so far I did all of my development against SQLite but deployed to SQL Server, and it looked like the date ops were my solution. I decided that given that I was the primary author of them, I could live with deploying them to production. I did exactly that and had pretty much no problems. Well, no problems until I had to upgrade DBIC. Every time I needed to upgrade DBIC I had to merge/rebase the branch. It turned out to be much more work than I bargained for, and I ended up just never updating DBIC.

At some point ([just under a month ago](https://github.com/frioux/DBIx-Class-Helpers/commit/5fefda2e5dafb0b78e9ee5a687fb698899d8d2ff)) I decided that I needed to upgrade DBIC and that maintaining these date ops was no longer tenable. Armed with three more years of experience than I had when I started I embarked on converting the date ops to date methods, that would work as Helpers. In addition to not being core, so I could release at my own pace, I could also version the API, so if I end up making some critical mistakes or needing to break the API for some features in the future, I can merely release ::DateMethods2. So without further ado:

# Announcing DBIx::Class::Helper::ResultSet::DateMethods1

Do you store dates in your database? Do you ever want to manipulate them efficiently? Well here's your solution!

First, how do you search in a more comprehensible way?

    $rs->dt_on_or_before(
      { -ident => '.when_created' },
      DateTime->now->subtract(days => 7),
    );

dt\_on\_or\_before (as well as dt\_before, dt\_on\_or\_after, or dt\_after) merely aliases <=, <, >=, and >, respectively. Instead of trying to think about the numerical meaning of a date on a timeline, just use these named methods. In addition to the nicer name, they can take DateTime object (which are automatically converted to UTC), and autoprepend DBIx::Class::ResultSet::current\_source\_alias when passed an -ident that starts with a dot . You can pass any of a value, a column (via -ident), a subquery, literal sql, or a DateTime object to either parameter slots of these methods.

Second, how do I really leverage this module to do stuff with dates in my database?

Here's a query I originally wrote with date ops. Basically it groups some columns by some "date parts" like year, month, day, etc. You can use it to make nice reports of things like how many things have been done per month, or maybe find out if the system is more busy in the summer:

    $rs->search(undef, {
       columns => {
          count => '*',
          year  => $rs->dt_SQL_pluck({ -ident => '.start' }, 'year'),
          month => $rs->dt_SQL_pluck({ -ident => '.start' }, 'month'),
       },
       group_by => [
         $rs->dt_SQL_pluck({ -ident => '.start' }, 'year'),
         $rs->dt_SQL_pluck({ -ident => '.start' }, 'month'),
       ],
    )->hri->all

I use that exact query (though I give the user a UI for which dateparts to include) in my system, and it works on SQL Server and SQLite, and it's fast. Awesome.

Or how about a query to discover how many issues were resolved before the next full day after their creation? Check it out:

    # note that 'day', 1 should also work
    $rs->dt_before(
      { -ident => '.resolution' },
      $rs->dt_SQL_add({ -ident => '.creation' }, 'hour', 24),
    )->all

Both of the above queries work on all of the supported datebases!

Third, some little helpers to extend the above.

On top of those things, I also throw in a couple other handy methods. One, utc converts a DateTime object to a string, in the UTC timezone. Hopefully you shouldn't need it directly, but I've already ended up using it in places where our code forced me to return a simple hash to get merged into a search query, instead of letting me call methods on an RS.

Another lagniappe is utc\_now which returns some literal sql that resolves to the current date and time in UTC on your database. You can pass it in to search just like you would datetime. So if your server and your database have in sync clocks, these would do the same thing:

    $rs->dt_on_or_before(
      { -ident => '.when_created' },
      DateTime->now->subtract(days => 7),
    );

    $rs->dt_on_or_before(
      { -ident => '.when_created' },
      $rs->dt_SQL_add($rs->utc->now, 'day', -7),
    );

(Aside: many people seem to hold suspect the idea that the clock is correct on a given server. If you can't trust the clock of a server, you probably can't trust the server. Use NTP.)

And that's it. I hope you can use and enjoy these helpers! The full docs are on (or will be shortly) [MetaCPAN](https://metacpan.org/pod/release/FREW/DBIx-Class-Helpers-2.020000/lib/DBIx/Class/Helper/ResultSet/DateMethods1.pm).
