---
title: Reap slow and bloated plack workers
date: 2016-06-29T00:46:52
tags: [ziprecruiter, perl, psgi, plack, smaps, shared-memory, private-memory]
guid: "https://blog.afoolishmanifesto.com/posts/plack-reaper"
---
As [mentioned before](/posts/put-mysql-in-timeout/) at
[ZipRecruiter](https://www.ziprecruiter.com/) we are trying to scale our system.
Here are a couple ways we are trying to ensure we maintain good performance:

 1. Add timeouts to everything
 2. Have as many workers as possible

<!--more-->

## Timeouts

Timeouts are always important.  A timeout that is too high will allow an
external service to starve your users.  A timeout that is too low will give up
too quickly.  No timeout is basically a timeout that is too high, no matter
what.  [My previous post on this topic was about adding timeouts to
MySQL](/posts/put-mysql-in-timeout/).  For what it's worth, MySQL *does* have a
default timeout, but it's a year, so it's what most people might call: too
high.

Normally people consider timeouts for external services, but it turns out they
are useful for our own servers as well.  Sometimes people accidentally write
code that can be slow in unusual cases, so while it's fast 99.99% of the time,
that last remaining 0.01% can be outage inducing by how much it can slow down
code and consume web workers.

One way to add timeouts to code is to make everything asyncronous and tie all
actions to clock events, so that you query the database and if the query doesn't
come back before the clock event, you have some kind of error.  This is all well
and good, but it means that you suddenly need async versions of everything, and
I have yet to see universal RDBMS support for async.  If you need to go that
route you are almost better off rewriting all of your code in Go.

The other option is to bolt on an exteral watchdog, very similar to the MySQL
reaper I wrote about last time.

## More Workers

Everywhere I have worked the limiting factor for more workers has been memory.
There are a few basic things you can do to use as little memory as possible.
First and foremost, with most of these systems you are using some kind of
preforking server, so you load up as many libraries before the fork as possible.
This will allow Linux (and nearly all other Unix implementations) to share a
lot of the memory between the master and the workers.  On our system, in
production, most workers are sharing about half a gig of memory with the master.
That goes a really long way when you have tens of workers.

The other things you can do is attempt to not load lots of stuff into memory at
all.  Due to Perl's memory model, when lots of memory is allocated, it is never
returned to the operating system, and instead reserved for later use by the
process.  Instead of slurping a whole huge file into memory, just incrementally
process it.

Lastly, you can add a stop gap solution that fits nicely in a reaper process.
In addition to killing workers that are taking too long serving a single
request, you can reap workers that have allocated too much memory.

### `smaps`

Because of the mentioned sharing above, we really want to care more about
private (that is, not shared) memory more than anything else.  Killing a worker
because the master has gotten larger is definitely counter productive.  We can
leverage Linux's `/proc/[pid]/smaps` for this.  The good news is that if you
simply parse that file for a given worker and sum up the `Private_Clean` and
`Private_Dirty` fields, you'll end up with all of the memory that only that
process has allocated.  The bad news is that it can take a while.  Greater than
ten milliseconds seems typical; that means that adding it to the request
lifecycle is a non-starter.  This is why baking this into your plack reaper
makes sense.

## Plack Reaper

The listing below is a sample of how to make a plack reaper to resolve the above
issues.  It uses `USR1` for timeouts, to simply kill those workers.  The worker
is expected to have code to intercept `USR1`, log what request it was serving
(preferably in the access log) and exit. `USR2` is instead meant to allow the
worker to finish serving its current request, if there is one, and then exit
after.  You can leverage `psgix.harakiri` for that.

We also use
[Parallel::Scoreboard](https://metacpan.org/pod/Parallel::Scoreboard), which is
what
[Plack::Middleware::ServerStatus::Lite](https://metacpan.org/pod/Plack::Middleware::ServerStatus::Lite)
uses behind the scenes.

(Note that this is incredibly simplified from what we are actually using in
production.  We have logging, more robust handling of many various error
conditions, etc.)

```
#!/usr/bin/perl

use strict;
use warnings;

use Linux::Smaps;
use Parallel::Scoreboard;
use JSON 'decode_json';

my $scoreboard_dir = '/tmp/' . shift;
my $max_private    = shift;

my $scoreboard = Parallel::Scoreboard->new(
  base_dir => $scoreboard_dir,
);

while (1) {
  my $stats = $scoreboard->read_all;

  for my $pid (keys %$stats) {
    my %status = %{decode_json($stats->{$pid})};

    # UPDATE 2NOV2016: Do not reap idle workers
    next unless $status{status} eq 'A';

    # undefined time will be become zero, age will be huge, should get killed
    my $age = time - $status{time};

    kill USR1 => $pid
      if $age > timeout(\%status);

    my $smaps = Linux::Smaps->new($pid);

    my $private = $smaps->private_clean + $smaps->private_dirty;
    kill USR2 => $pid
      if $private > $max_private;
  }

  sleep 1;
}

sub timeout {
  return 10 * 60 if shift->{method} eq 'POST';
  2 * 60
}
```

---

I am very pleased that we have the above running in production and increasing
our effective worker count.  Maybe next time I'll blog about our awesome logging
setup, or how I (though not ZipRecruiter) think strictures.pm should be
considered harmful.

Until next time!
