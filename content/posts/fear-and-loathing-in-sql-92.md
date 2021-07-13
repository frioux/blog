---
title: Fear and Loathing in SQL-92
date: 2015-03-04T08:09:35
tags: [mitsi, sql-server, sql, standards, postgresql, war-stories]
geography: "cupertino inn"
guid: "https://blog.afoolishmanifesto.com/posts/fear-and-loathing-in-sql-92"
---
Like the tortoise I've been slowly but surely working on getting our application
working on both SQL Server 2005+ and Postgres 9.4+.  The latter is a new
addition, hence the "latest and greatest" version.  For the most part I've been
surprised at how easy it has been.  Both servers support using `"` as the
identifier quote, which is all that I have to change in the majority of queries.
For some dumb reason (there is a real reason, but it is dumb) most things use
`[`, `]` for the quotes in SQL Server.  It has to do with settings, but really,
it's stupid.  Just use `"` unless you know you need `[`, `]`.

But I digress!  The point of this post is that, interestingly to me, SQL Server
follows the standard, at least in one point, where *no other database does* as
far as I can tell.  I've spoken about this many times on IRC and in person
because it's just such a good war story, so I figure I might as well put it down
in writing.

I remember it vividly.  I was working from home so it must have been a Tuesday
or a Friday, and I lived in a rented house on Jack Finney Boulevard in
Greenville, TX, not the one I live in now.  I think it was a little stormy out.
I had stepped out of my office to add some stuff to a crock pot so that dinner
would be ready when my wife got home.  That's when I got the call.

My coworker was on a customer's machine and had evidence that when going through
one codepath, it was apparent that there were related rows to a given object.
It's not really important what it is to the story, but I might as well explain a
tiny bit so that I can use real words.  Basically in the system we have alarms
that have a set of outputs.  When an alarm is triggered, a message goes to the
outputs.  When the user tested the alarm, she'd get an email, but when she went
to the alarm configuration page, the output was not selected.

Ok, that's weird.  So I pulled up the code and... it was weird.  For starters,
despite the fact that we could get the list of outputs for a given alarm with a
join, and in fact did do that, we still just iterated over all the outputs in
the system for each alarm.  The reason was due to the antiquated HTML 1.0
interface.  The outputs would be displayed in a listbox for all alarms, and you
selected outputs by holding shift or control to select more.

The code (long since replaced) that generated the list has a some code that
looks like this:

       while(my $d = ...) {
          if ($s eq $d->{Phone}) { # !!!
             $table .= qq! <option selected>$lookforshort</option>\n!;
          } else {
             ...
          }
       }

Note the line with `!!!` on it.  It seems sensible, but the fact is, using
basic equality for code that is database driven is rarely the best call.  The
obvious thing is that you need to make sure that at the very least you are using
the same collation.  Normally when people talk about collations that means the
order in which things sort; it has to do with what language your users speak
etc.  The default collation in SQL Server is case insensitive, so at the very
least in the code above the `$s` and the `$d->{Phone}` should be casefolded with
`fc`, a perl builtin which correctly casefolds a string (note that lowercasing
and uppercasing are *not* sufficient if you support non-English language
strings.)

But that's not all!  In SQL-92 there is the following directive:

                ... If the collating sequence for the comparison has
    the PAD SPACE attribute, for the purposes of the comparison, the
    shorter value is effectively extended to the length of the longer
    by concatenation of <space>s on the right.

What that effectively means is that in a SQL-92 compatible database,

    'frew' = 'frew   '

Honestly it's a good feature, but most databases don't do it.  Now, the takeaway
for this post could easily be that PostgreSQL is a crappy database that doesn't
implement all that it promises; that might even be true!  But the fact is that
all databases fall short of the standard somewhere and you as the user just have
to live with that.

Really, Postgres *does* document that this isn't supported.  A slightly more
careful reading of the standard does make it clear that the collation has to
have the `PAD SPACE` attribute and Postgres has this in it's docs:A

    pad_attribute: Always NO PAD (The alternative PAD SPACE is not supported by PostgreSQL.)

([citation](http://www.postgresql.org/docs/current/static/infoschema-collations.html))

What this story means for me is that you should not emulate, imitate, or
otherwise do the job of the database.  Where this comes up most is with caching.
If you want to cache the results of a query that's fine, but if you want to go
further, and use that cache in **new queries**— *watch out*.  You could
certainly take the above facts into consideration, but you could also get it
wrong and introduce very subtle and hard to debug problems into your
application.
