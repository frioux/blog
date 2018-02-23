---
title: Exponential Backoff in Service Startup
date: 2018-02-22T07:01:51
tags: [ init, upstart, perl, oss ]
guid: 80d100a9-9ce0-4814-a19d-7d516dc9ab2c
---
I recently added exponential backoff to service startup.  Read how here.

<!--more-->

At [work](https://www.ziprecruiter.com/hiring/technology) we have discovered
time and again that services can end up restarting over and over.  The typical
solution to this is to set a limit on restart count, but sometimes that just
adds pointless toil.  Imagine that a database is down for an hour; the web app
fails to start because it can't connect.  After having to deal with a database
outage do you really want to go start all of your web workers?

The types of issues you run into when this happens are pretty varied, but off
the top of my head we ran into CPU usage issues, excess logging that could often
saturate a disk, or pressure on backend services that was basically pointless.

After this happened in a handful of different services I decided to write a tool
that would allow you to add exponential backoff to startup of a given service.
I'd like to add it to all of our services, but just haven't found the time.
Here's the code:

``` perl
#!/usr/bin/perl

use strict;
use warnings;

use Time::HiRes 'sleep';
use List::Util 'min';

my $max = shift || 300;

my $file = "/run/shm/backoff-$ENV{UPSTART_JOB}";

if (-e $file) {
  my @stat = stat $file;
  my $ctime = $stat[10];

  # if the file was created more than 2 * max sleep time ago, we assume that the
  # service worked and start over.
  unlink $file
     if $ctime < time - $max * 2;
}

my $attempt = 0;
open my $fh, '<', $file;
if ($! == 2) { # ENOENT 2 No such file or directory
   close $fh;
   update_attempt(1);
} else {
   $attempt = <$fh>;
   update_attempt($attempt + 1);
   close $fh;
}

sleep rand min($max, 2 ** $attempt);

sub update_attempt {
   my $attempt = shift;

   open $fh, '>', $file
      or die "couldn't write to $file: $!";
   print $fh $attempt;
   close $fh;
}
```

I built this for [Upstart](/posts/supervisors-and-init-systems-4/); in Upstart
services get an `UPSTART_JOB` environment variable set automatically to the name
of the unique service (or job) that is running, so I am able to automatically
keep state per service based on that variable.  systemd does not appear to
support the automatic addition of an envvar based on the name of the unit, but
you can of course set the envvar yourself.

Here's an example upstart job using this:

```
description "Kill workers that deserve it"

start on filesystem and started networking
stop on shutdown

respawn
respawn limit unlimited

script
   zr-upstart-backoff

   exec /var/starterview/bin/zr-plack-reaper
end script
```

---

That's it; pretty simply right?  If anyone knows of other init systems that set
a similar variable, I am interested in knowing about it, if only so that I could
theoretically support other init systems with the same script.

---

The main book I'd recommend checking out that elaborates on this kind of thing
is
<a target="_blank" href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=e26b8192ed5ec7a43771355194c2ec3c">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's long and can get pretty in depth, but even just reading chapters 18 through
22 will (I think) go into this topic.

The other one, only because it's a great book and this post contains Perl, is
<a target="_blank" href="https://www.amazon.com/gp/product/1558607013/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1558607013&linkCode=as2&tag=afoolishmanif-20&linkId=0bb514d237caef901f74bef89dda027f">Higher-Order Perl</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1558607013" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The elevator pitch for that book is something like: "Did you ever want to learn
Lisp but wanted a language with enough syntax that you can actually read it?
Check this book out."  Maybe that's ironic because it's Perl?
