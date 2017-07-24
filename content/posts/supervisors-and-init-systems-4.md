---
title: "Supervisors and Init Systems: Part 4"
date: 2017-07-24T08:06:57
tags: [ init, supervisors ]
guid: C450AC42-6F5D-11E7-AB9D-3F03F3BD3F5C
---
This is the latest in my apparently unending [series about
supervisors][supervisors]. While [the first][1] [two posts][2] were about
"traditional supervisors," [the third][3] was about a few odd variants, both
good and bad.  This post is about the current reigning champions: Upstart and
systemd.

<!--more-->

Note that in the previous posts I have used the term "supervisor" and never the
term "init system."  The only difference, in my mind, is if the supervisor in
question is actually running as pid 1.  In this post I will be explicitly
discussing init systems and thus often use that term.

I haven't really discussed the original SysV `init`, which one could argue all
of these various systems are ultimately a reaction to.  `init` basically ran a
pile of scripts in lexicographical order based on symlinks in a directory.
I don't really want to dedicate a lot of time to `init` but basically the issues
it has are:

 * Almost no parallelism
 * No built in way to automatically restart services
 * Init scripts are the opposite of declarative

So in the mid 00's Canonical released Upstart.

## Upstart

[Upstart][upstart] really had a lot going for it.  It has this interesting
event driven model, which as far as I know no other supervisor implements.
One cool thing I experimented with a couple of years ago was an Upstart job
that would react to all start or stop events on a system.  This job would send
a status to a central server, allowing us to know if services are restarting
over and over or something without having to build that kind of code into
each service.

Upstart is one of the few init systems that is declarative (so far the only
other declarative system I've discussed is `supervisord`.)  It uses an Upstart
specific domain specific language. Being declarative is a bit of a spectrum.
The SysV init script for `ssh` on my system is 174 lines long.  The upstart
version is 29 lines.  Upstart is *almost* purely declarative, while the
traditional supervisors are not really declarative at all, but remove most of
the cruft from a traditional init script by virtue of not needing so much.

One specific thing that I like about Upstart is that you can make the "start" of
a service block on readiness.  `runit`, [discussed in the first post][1], can do
the same thing but has a hardcoded timeout of 7s.  In Upstart I wrote the
following, to block start for up to 30s, polling every second:

```
post-start script
  wget http://127.0.0.1:8001/ping --retry-connrefused -O /dev/null --tries 30 --waitretry 1
end script
```

This can have some really confusing semantics when you include the
restarting, but I think it's pretty cool.  I also think making a purpose built
tool just for this, instead of using wget, could make this a lot more clear, but
I'm getting in the weeds.

Unfortunately Upstart is far from perfect.  While it is declarative, Upstart
lacks a built-in mechanism for a proper logger.  It does capture all output from
a job and send it to a predictable location (`/var/log/upstart/$jobname`,) that
is literally all it does.  There are no timestamps and there is no way to send
the output to another program unless you are willing to manage the pipe
yourself.

Upstart's documentation has always felt haphazard to me.  I prefer to read local
manpages in general, and I have yet to find a manpage that defines the syntax of
an Upstart job.  I'm sure one exists; but it's not called something sensible
like, say, `upstart-job`.  I always find myself [looking at this giant
webpage][cookbook] (yes, including the anchor) when I need to do something with
Upstart.  In my mind it is quite a condemnation when the only useful docs are a
single page cookbook.

Despite the fact that Upstart was fairly early in it's generation of supervisor,
as well as having an elegant model, it has been effectively abandoned.  I have
run into bugs at work that are known and will presumably never be fixed.  I
suspect that this is because Upstart is no longer the official init system for
Ubuntu; even though `14.04` is supported for a couple more years and uses
Upstart.

So what is the new init system for Ubuntu?  systemd.

## systemd

[systemd][systemd] is the current king when it comes to init systems on Linux.
As of about 2015 RedHat and Debian based Linuxes (which is a pretty big
proportion of Linux installs) use systemd by default.

systemd is more declarative than Upstart; the services are defined in a simple
INI file.  I am bewildered at the fact that INI is so popular for system
configuration, but because it is such a well-defined format
[`convert-systemd-units`][csu] from `nosh` is possible.

I have found the systemd manpages, while legion, to be both discoverable and
readable.  They follow a somewhat strange naming convention, but given the
amount of information, I think it's a sensible tradeoff.

Despite all of the many problems systemd has (which I'll get into shortly) I do
think that it is bringing back some solid, good tech and adding some innovation.
Fundamentally socket-activation is something like a combination between ye olde
xinetd and UCSPI.  Additionally, while `journald` is a huge SPOF, the
integration into `systemd` is more than cute; it makes looking into a problem
much easier, since simply getting the status of a service includes about a dozen
log lines.

The last "innovation" I'll mention is default cgroup integration.  I will
hopefully discuss that more on Friday, but basically it adds security and
predictability to services.  If you start a service in almost any supervisor and
it double forks unexpectedly, you no longer have control and it can become a
surprise child without a known service.  With cgroups it should not be able to
escape the pid namespace you put it into and it will get killed if it's parent
goes away.  There's more, but this is, in my mind, a huge simplifying factor.

systemd has a couple of ways a service can say that it is ready, but they are
built in such a way that the service must coöperate with systemd instead of,
like Upstart, allowing some form of blackbox readiness checking.  This has been
remedied elegantly by the `sdnotify-wrapper` I mentioned in [the second
post][2].

There have been many, many blog posts about the doom that is systemd.  I don't
care to write a thousand words just about systemd so I'll make a list of the
problems that I think it has:

 * The Kitchen Sink: systemd ships with (on my system) a dns resolver, a syslog
   implementation called journald, `systemd-logind` which does a bunch of user
   related things, an ntp client, and a udev implementation.
 * Linux Only: systemd supports some nice Linux features, but instead of
   implementing them such that they could be left out, they are instead
   required, locking systemd into Linux only.
 * Lots of Parsers: parsers are a great place for security vulnerabilities to
   hide.  systemd has to parse INI files, dbus events, and then whatever random
   network protocol is implemented in subsidiary systemd services (like ntp.)
   This has already caused [multiple][v1] [vulnerabilities][v2].

---

Overall I think both Upstart and systemd are the right direction, in that they
are supervisors, but also the wrong direction, in that they are complicated
pieces of software running in privileged positions.  Despite all of the above I
actually do think they are both better than SysV init, and that any effort to
move back to SysV is backwards.

If I had to pick one over the other I would pick systemd.  Hopefully systemd can
be a good "gateway" supervisor for many Linux distributions; and we can later
use nosh or s6.

On Wednesday I have a pile of odds and ends about supervisors and their authors
that I will discuss.  The list keeps getting longer so it may spill into Friday.
After that I expect to write one final post wrapping up the series and proposing
some of the ideas that writing all of this inspired in me.

---

This topic is very unix heavy, so if you are totally lost or would like an in
depth refresher, <a target="_blank" href="https://www.amazon.com/gp/product/0321637739/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321637739&linkCode=as2&tag=afoolishmanif-20&linkId=9f20643e726defaa727849b7606fb656">Advanced Programming in the UNIX Environment, by Stevens</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321637739" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is a good option.

Similarly, some of the tools above (and many more in later posts) discuss tools
that while written for assistance in supervision are useful in isolation.  I
think that
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=6279d8d234dff9ee5623e7ad7bed35df">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> 
does a great job diving into tools that are general enough to stand on their
own.

For some reason, writing about systemd made me think of <a target="_blank" href="https://www.amazon.com/gp/product/0596001088/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0596001088&linkCode=as2&tag=afoolishmanif-20&linkId=956aa2da6f0dafbfe730336168b4df8b">The Cathedral &amp; the Bazaar</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0596001088" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
though I would say almost all of the supervisors discussed in this series have
been "cathedral" style development.

[cookbook]: http://upstart.ubuntu.com/cookbook/#stanzas-by-category
[1]: /posts/supervisors-and-init-systems-1/
[2]: /posts/supervisors-and-init-systems-2/
[3]: /posts/supervisors-and-init-systems-3/
[upstart]: http://upstart.ubuntu.com/
[v1]: https://usn.ubuntu.com/usn/usn-3341-1/
[v2]: https://github.com/systemd/systemd/issues/4234
[csu]: https://jdebp.eu/Softwares/nosh/guide/convert-systemd-units.html
[supervisors]: /tags/supervisors
[systemd]: https://freedesktop.org/wiki/Software/systemd/
