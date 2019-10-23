---
title: "Supervisors and Init Systems: Part 2"
date: 2017-07-19T08:00:18
tags: [ init, supervisors ]
guid: 9E6C547E-6AFB-11E7-9339-E44B60879173
---
[On Monday][part-1] I began a [series about supervisors][supervisors].  It
mostly covered the most basic Supervisors out there, `daemontools`,
`daemontools-encore`, `runit`, and `perp`.  This post will cover the more
advanced generation, which includes `s6` and `nosh`.

<!--more-->

Note: In this post I will treat `s6` and `nosh` as a whole, despite the fact
that each has huge amounts of standalone parts and furthermore that each has
multiple distributions.

## The Advanced Supervisors

Both of the supervisors discussed here have a very similar model and many of the
various pieces can be swapped in and out.  I have used both `nosh` and `s6` at
the same time within different services in the same supervisor tree.  (By the
way, this interchangeability is not true of all supervisors; I'll discuss that
on either Friday or next Monday.)

But to be blunt, while there are some significant additions that, say, `runit`
added to `daemontools` (specifically first class logger support and the check
script, also known as a readiness protocol) the distinctions between `nosh` and
`s6` are much more subtle.  There are absolutely differences, just not enough to
say one is better than the other.  (`runit` is better than `daemontools`.)

### `s6`

[`s6`][s6] is one of the newer supervisors in this list.  I can't find a release
before 2014 and the version control started over at 2.x.  As far as I can tell
`s6` was implemented as an alternative to `systemd`, which we'll get into later.
`s6` (and the next supervisor in this list, `nosh`) has the fairly interesting
property of avoiding shell scripts in order to be more secure and predictable.
If this argument sounds ridiculous, consider how many vulnerabilities in modern
software are caused by parsers, and now consider sidestepping that problem
entirely by just not having a parser.

`s6` leverages a suite of tools collectively called [`execline`][execlineb] for
this.  Fundamentally it and `nosh` are very similar.  The hand-wavy version is,
instead of having a Bourne-shell interpreter that reads a script and manages the
various programs and interaction until the end, both `execlineb` and `nosh` set
up a special environment and then are gone, no longer running at all.  Here is
an example with a program many of us have heard of:

``` sh
#!/bin/sh

exec env FOO=bar perl my-script.pl
```

In the above (Bourne-shell) script we ran `env(1)`, which set the environment
variable `FOO` to `bar`, and then immediately `env(1)` `exec`ed (or
chain-loaded) the perl interpreter.  Now consider that both `nosh` and
`execline` ship with a few dozen commands in the same fashion, including `cd`,
`trap`, a few file descriptor manipulation commands, **flow control**, and more.
Even if you think the security and simplicity arguments are silly, having some
of these commands available can be extremely convenient.  The difference that
`execlineb` and `nosh` have with the above example is that they simply tokenize,
exec, and get out of the way.

In addition to supporting the standard shell features, both `s6` (as [an
addon][s6-networking]) and `nosh` have [UCSPI][ucspi] support and many other
networking tools.

One notable tool that comes from the author of `s6` (Laurent Bercot) is
[`sdnotify-wrapper`][sdw], which allows a process to use the systemd readiness protocol
(which I'll discuss Friday.)  Basically you use it like most of the other tools
in this style (`sdnotify-wrapper -t 60000 myprogram and args`) and it will
advertise that your program is ready after your program writes a single line to
a given file descriptor; by default stdout.

The following is an `execlineb` run script I used to use (before moving my code
to Heroku) that uses `s6` and its UCSPI additions:

```
#!/bin/execlineb

env SERVER_NAME=busybox SERVER_PORT=6000
cd ../..
bin/config-set-env
s6-tcpserver 127.0.0.1 6000
busybox httpd -i -f -h ./www
```

### `nosh`

[`nosh`][nosh] is very similar to `s6`, but adds a really interesting feature:
it can read systemd units, but instead of parsing them at boot time [you compile
them down to `nosh` scripts ahead of time][convert-units], thus adding security,
predictability, and clarity.  `nosh` is the first supervisor in this series not
written in C, instead implemented in C++.  That doesn't bother me much, but some
people are annoyed by it.

On top of all of the various tools that Laurent Bercot has built for the `s6`
suite of tools, `nosh` (built by Jonathan de Boyne Pollard) brings to the table
some console management tools.  I have never used these, but I'd be interested
in trying.

Eventually I moved the script mentioned above from `s6` to `nosh`, and here is
what it became:

```
#!/bin/nosh

chdir ../..
tcp-socket-listen 127.0.0.1 6000
tcp-socket-accept --no-delay
envdir --ignore-nodir --chomp /home/frew/.lizard-brain
bin/config-set-env
cgid plackup www/cgi-bin/impulse-www
```

Clearly a couple other changes were made, including the use of [my own UCSPI
based CGI server][cgid]

---

There is **so much more** that could be discussed about both `nosh` and `s6`.
The software for both (this applies to the suites from the previous post as well,
there is just so much less) is carefully and beautifully designed to make sense
and work with other tools.  In fact, as I was researching this post, I found
this quote about some of the console stuff provided by `nosh`:

> As a bonus feature, the source package contains a getty `execlineb` script
> that does exactly that

Despite the fact that in theory `nosh` and `s6` are competing for mindshare,
there is neither a technical nor even social reason to keep them separate, and
indeed `nosh` code uses `s6` code.

Maybe it's just my personal tastes, but just perusing [Laurent][laurent] and
[Jonathan][jonathan]'s sprawling writing is inspiring and informing to me.  I
highly recommend the following, if you can relate:

 * [execline grammar](http://skarnet.org./software/execline/grammar.html)
 * [s6 sales pitch](http://skarnet.org/software/s6/why.html)
 * [s6 oveview](http://skarnet.org/software/s6/overview.html)
 * [nosh sales pitch](https://jdebp.eu/Softwares/nosh/)
 * [how to daemonize][daemonize]
 * ["Wrapping Apache Tomcat in many pointless extra layers"][tomcat]

Unlike in the first post, in which I could concretely recommend `runit` over the
rest, I do not think I can make such a recommendation here.  `s6` is more normal
(simple compilation) but does not ship packages.  `nosh` is C++ and doesn't use
`make`, but it integrates better with existing systems.  Honestly, having
switched from one to the other, I would say either of these are fine and
swapping in the other, even piecemeal, is fine and pretty cool.

On Friday I'll discuss some of the more unusual, niche supervisors.

---

(The following includes affiliate links.)

This topic is very unix heavy, so if you are totally lost or would like an in
depth refresher, <a target="_blank" href="https://www.amazon.com/gp/product/0321637739/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321637739&linkCode=as2&tag=afoolishmanif-20&linkId=9f20643e726defaa727849b7606fb656">Advanced Programming in the UNIX Environment, by Stevens</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321637739" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is a good option.

Similarly, some of the tools above (and many more in later posts) discuss tools
that while written for assistance in supervision are useful in isolation.  I
think that
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=6279d8d234dff9ee5623e7ad7bed35df">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> 
does a great job diving into tools that are general enough to stand on their
own.

[part-1]: /posts/supervisors-and-init-systems-1/
[supervisors]: /tags/supervisors
[nosh]: https://jdebp.eu/Softwares/nosh/
[s6]: http://skarnet.org/software/s6/
[convert-units]: https://jdebp.eu/Softwares/nosh/worked-example.html
[sdw]: http://skarnet.org/software/misc/sdnotify-wrapper.c
[ucspi]: /posts/ucspi/
[cgid]: /posts/announcing-cgid/
[laurent]: http://skarnet.org/software/
[jonathan]: https://jdebp.eu/Softwares/
[daemonize]: https://jdebp.eu/FGA/unix-daemon-design-mistakes-to-avoid.html
[tomcat]: https://jdebp.eu/FGA/systemd-house-of-horror/tomcat.html
[execlineb]: http://skarnet.org/software/execline/
[s6-networking]: http://skarnet.org/software/s6-networking/
