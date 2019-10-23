---
title: Monitoring Service start/stop in Upstart
date: 2017-09-25T07:55:39
tags: [ upstart, init ]
guid: 8C5137B8-9E82-11E7-B0E0-23CECFB86AB0
---
Recently at ZipRecruiter I implemented a tool to ensure that we know if some
service is crashlooping.  It was really easy thanks to Upstart but it took
almost a whole day to get just right.

<!--more-->

I called the tool cerberus; you could call it anything though.  Fundamentally it
watches all `starting` or `stopping` events that go through Upstart, excluding
itself.  Here's the guts of the implementation:

In `/etc/init/cerberus.conf`:

```
description "Monitor service events"

start on (starting JOB!="cerberus" JOB!="startpar-bridge" INSTANCE!="cerberus*") \
      or (stopping JOB!="cerberus" JOB!="startpar-bridge" INSTANCE!="cerberus*")

exec perl -E 'say localtime . qq( $ARGV[0] $_) for split /\s+/, $ARGV[1]' "$JOB" "$UPSTART_EVENTS"
```

This would log something like `Sun Sep 24 19:45:00 2017 www stopping`.

We are actually sending this data to our stats server so we can build monitors
based on it, but that's the basic idea.  A frustrating side note is that, as a
feature, Upstart only lets a single process run for a given job.  When we
initially did this I used the event `starting` and `stopping` instead of
`started` and `stopped`.  The upshot was that if you ran `restart www` it would
only record the first event, because the second one couldn't start as it
happened at the same time.  For some reason (I really am not sure why) the
`starting`/`stopping` version doesn't have that problem.

Additionally there is still a race condition.  If two services advertise that
they are either `starting` or `stopping` at the same time, we will only hear
about one of them.  Because I made this to monitor crashlooping I am not too
worried about that.  If you wanted to be 100% confident you got all the events
you could build a watchdog per service, but that sounds easy to get wrong to me.

This change allowed us to remove the limit on respawning and configure all
services to respawn forever.  Worst case there would be a syntax error and we'd
get alerted.  More likely, if some other service goes down (like `s3` or
something) our service will restart fifty times and then comes back.

Somewhat comically, if a service is crashing over and over, you get multiple
`stopping` events, but no `starting` events.  I think this is because a
`respawn` is technically not actually one of the events.  Annoying.

---

I am sad to say that I haven't found a great resource for how to monitor
effectively.  The main thing that I can say is that if you are willing to think
for an hour or so you might be able to come up with an alert that is less likely
to trigger spuriously but also give you more time to react.

The alert discussed in this post could be expressed such that any time a service
exits non-zero you get an alert.  That would be the worst.

(The following includes affiliate links.)

<a target="_blank" href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=e8bc077013e5126a20036a3d20144e7d">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
discusses some of this, though it dedicates an absurd amount of time to an
internal monitoring tool that is, as far as I understand it, going away.

I also suspect that
<a target="_blank" href="https://www.amazon.com/gp/product/0133390098/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0133390098&linkCode=as2&tag=afoolishmanif-20&linkId=fe6d850049eaba4afde5227d2508aa6f">Brendan Gregg's Systems Performance</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0133390098" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
would be worth reading.  Good alerting requires good collection and, later, good
analysis.  This book can help with some of that.
