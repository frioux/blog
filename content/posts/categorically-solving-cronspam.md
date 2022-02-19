---
title: Categorically Solving Cronspam
date: 2018-02-26T06:39:10
tags: [ ziprecruiter, perl, aws ]
guid: 557c28bc-2725-47c3-8371-9494c9c4d745
---
For a little over a year at
[ZipRecruiter](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) we have had some tooling that
"fixes" a non-trivial amount of cronspam.  Read on to see what I mean and how.

<!--more-->

If you have administered a Unix system for much time at all you will likely know
about cronspam.  Basically, cron captures any output from a cronjob and emails
it to the `MAILTO` address, or (I think) `cron@fqdn`.  We always set the
`MAILTO` environment variable so that teams who the job is relevant to get the
email, instead of a central team getting all matter of random failures.

So the tough thing is, when you have tens or hundreds of servers, through the
law of averages, you are bound to get some non-recurring errors.  Further,
sometimes someone will commit a bug that will cause a job to print a warning or
even a non-warning status message.  If this job runs more than daily you are
likely to be annoyed when you get tens or hundreds of emails in your inbox that
are not actionable.

## `zr-cron`

So at some point I decided to write (the typically named) `zr-cron`.  It is a
fairly straightforward perl script that takes a `-c` argument and gets installed
into every single crontab as the `SHELL`.  Here's an example prelude:

```
STARTERVIEW=/var/starterview
PATH=/var/starterview/bin:/usr/bin:/bin
SHELL=/bin/zr-cron
ZRC_CRON_FILE=/etc/cron.d/zr-email-bot
```

The first two are environment variables that basically all of our code needs;
the `SHELL` is how cron knows to use `zr-cron` instead of `bash`.  The final
environment variable is how we communicate to `zr-cron` what it should be doing.
Users add more environment variables to tweak `zr-cron` 's behavior, discussed
more in depth later.

After being invoked by `cron(8)`, `zr-cron` creates a temporary directory and
sets `TMPDIR` to the relevant path, to aid in cleaning up after cronjobs. ([I
had originally used a namespace, but that caused more trouble than it was
worth](/posts/perl-linux-namespaces-and-pedestrian-problems/).)

Then, `zr-cron`, runs the underlying program, capturing all of `STDOUT` and
`STDERR`, merged into a single scalar.  It then logs the output, along with all
of the environment variables, the command that was run, the time the job started
and stopped, and a few other miscellaneous details.  If the `ZRC_LOUD`
environment variable is set, it instead sends an email with the output to
`MAILTO` immediately.  Jobs with `ZRC_LOUD` set tend to be cron based monitoring
that point to a pager, or a job that no one has figured out how to monitor in a
better fashion (or both, I guess.)

That's it for `zr-cron`.  There is another tool that picks up where it leaves
off, though.

## `zr-cron-report`

Once a day a script called `zr-cron-report` runs.  It uses [Amazon
Athena](/posts/using-amazon-athena-from-perl/) to gather up all the logged
details about all of the cronjobs that have run across the whole fleet in the
past day.  (It used to run directly against our logging ElasticSearch cluster,
but Athena is more powerful and reliable.)  The amount of data that comes back
from this query could easily cause an out-of-memory condition, so instead of
reading the results into memory, we download all of the results, iterate over a
single result at a time (using a filehandle as an ersatz cursor,) and insert
them into a temporary (but not in-memory) SQLite database.  Here is the entire
schema for that database:

``` SQL
  CREATE TABLE _ (
    command,
    message,
    output,
    source_host,
    env_ZRC_CRON_FILE,
    env_MAILTO,
    timestamp,
    exit_code,
    signal
  )
```

Once the temporary, local database has been populated, generating the `zr-cron`
report is fairly straightforward and pedestrian code.

We do a lot of work to group together cronjobs that errored in the same way.
This way instead of getting 24 of the same email for a crashing hourly cronjob,
we have a single section in the report that says a given error occurred 24
times, on the host called foo, invoked from such-and-such cronfile.  Included
are the exit code or signal causing termination.

Similarly, when we generate the report we group by the `MAILTO`, so that each
team gets a custom report just for their own services.  `zr-cron-report` also
injects a synthetic `cron@` `MAILTO` entry so that for posterity we have a
gigantic report of all of the cronjobs that failed in the entire company.

On top of that, to bound the size of the report, when grouping by output we only
take ten unique sets of output per cronjob.  This keeps the system useful even
when an exception contains some nonce or something that causes it to be unique
every time.  (By the way, the report also munges all output in a fairly basic
way before inserting the data into the SQLite database, to assist such
grouping.)

When I first wrote the report I did all of the work in memory, iterating over
the results from ElasticSearch and doing my best to keep the in-memory reports
efficient and also trying to support the features I needed to.  Recall that I am
grouping at (at least) two levels here.  Doing that manually with nested hashes
is confusing and error prone.  The SQL version is almost always a breeze to work
with and is suprisingly efficient.  The report for today took less than three
minutes.

---

I hope that this post inspires you to consider how to systematically reduce
operational overhead, especially thankless overhead like "reading email."  I
regularly try to think strategically, with the goal being to figure out various
ways that we can reduce a lot of this toil.  In my opinion it almost always pays
off.

---

I didn't intend for this post to showcase SQL in two relatively unusual
contexts: one being a MapReduce alike frontend and the other being a single
file, transient database.  SQL is really useful!  Here are the books I learned
with, many moons ago:

(The following includes affiliate links.)

<a target="_blank" href="https://www.amazon.com/gp/product/0321884493/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321884493&linkCode=as2&tag=afoolishmanif-20&linkId=9264185c3d13c7c67e237a963060f488">Database Design for Mere Mortals</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321884493" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is an excellent book for getting started on good RDBMS design.  I read an
older edition (the 3rd edition wasn't out at the time) but I cannot imagine it
changed much, other than newer data types that are relevant these days.

If you need something more basic, check out
<a target="_blank" href="https://www.amazon.com/gp/product/0672336073/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0672336073&linkCode=as2&tag=afoolishmanif-20&linkId=b1c9ef8b26a8eb1cc86ed4ba8ae42237">SQL in 10 Minutes</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0672336073" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I started with this book and it was a lot of fun for me at the time, though that
was more than a decade ago at this point.
