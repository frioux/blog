---
title: "Supervisors and Init Systems: Part 3"
date: 2017-07-21T08:44:40
tags: [ init, supervisors, perl, python ]
guid: 3A993CB0-6C8A-11E7-9295-593E5E879173
---
This post is a continuation of my [series about suprevisors][supervisors].  [The
first post][1] was about the most basic supervisors.  [The second post][2] was
about some more advanced, but still basically traditional supervisors. This
post is about some more unusual options.

<!--more-->

In the previous posts the supervisors in question were fairly similar; I can
only assume it's because of the obvious djb heritage.  These are all completely
dissimilar.

### ubic

I wouldn't have discussed this, except that someone on twitter directly asked me
about it, so I figured I'd look into it.  [`Ubic`][ubic] is a service framework
written in Perl.  I haven't used it myself though I do have friends who have. I
didn't have a lot of time to fully digest it, so if I get something completely
wrong, I apologize for that.

First off, `ubic` is not really a supervisor.  A supervisor follows a fairly
specific model where it at a minimum:

 * runs the child service
 * watches for a SIGCHLD to immediately react to a crash

And, preferably and additionally:

 * holds pipes
 * maintains a logger service to read from the pipes

Again, [the talk may be a good refresher][talk].  `Ubic` as far as I can tell
does literally none of these things, and instead implements traditional SystemV
init scripts (ie double forking etc) in Perl.  Additionally, it has some of what
I consider to be the worst anti-patterns of service implementations:

 * It uses cron to do the initial bootstrapping
 * Instead of watching for SIGCHLD it runs another service that polls status
 * It can do nothing to ensure that logs go to a logger process, though it
   tries.

Anyway, if you are using `ubic` today and it's working for you, that's great,
but it is really not a supervisor.  There are other, simpler, better options.
Look forward to another post in this series for a comprehensive set of examples
if you'd like to see what each option will look like.

### supervisord

Like `Ubic`, [`supervisord`][supervisord] is written in a high level language.  Specifically it
is written in Python.  Unlike `Ubic`, it is actually a supervisor.

That does not mean that I recommend using it.

`supervisord` has a lot going for it.  It has declarative syntax, instead of the
typical "pile of executables" that many supervisors use.  It provides direct
methods of remote administration, so you can bounce a service without needing a
shell on the box.  These are pretty great features.  On the other hand, there
are some serious drawbacks to both `supervisord` and the features, as
implemented.

`supervisord` runs as a single program, supervising one or more processes.  This
can be done, it's what `perp` does, but it's still a SPOF.  `supervisord`
also does the log redirecting itself.  It may actually not do any log
processing, but that is incredibly limiting, as we'll discuss in Part 4.  On top
of the above limitations, it has a couple parsers; one for INI (the config
format), one for XML-RPC.  The XML-RPC can be used to remotely control
`supervisord`, but I wouldn't be surprised if there were a bug or two lurking in
there.

And on top of that it has the ability to run a rudimentary web interface which,
even if you lock it down, could be a serious vulnerability.

If you ignore all the security fear above, which would be reasonable, another
consideration (which we'll likely discuss in Part 5) is that many other
supervisors are written with loving care to never malloc after a certain point,
to avoid getting killed under memory pressure.  Good luck a supervisor like that
in Python.

For all the things I dislike about `supervisord`, it's probably fine, but I
think there is a better way when you need such features, which I'll discuss in
Part 5 of this series.

### daemonproxy

[`daemonproxy`][daemonproxy], which indirectly inspired this blog series, is an
oddball but a lovable oddball.  The fundamental idea behind `daemonproxy` is
that while you might be interested in customizing your supervision logic, you
may not care to write a supervisor or be intimate enough with the Unix process
model to do so.  So `daemonproxy` will be a supervisor for you, and you tell it
what to do.  It uses an extremely simple line based protocol.  (To be fair this
is a parser and could be vulnerable to various attacks like many other parsers,
but it is a much simpler protocol than, for example, XML with something layered
on top.)

Unfortunately, while I have used `daemonproxy` myself and it worked just fine,
it is not totally complete, and so even though it has some really interesting
ideas, today it is not a replacement for other supervisors.

---

I would love to see `daemonproxy` get completed, though the author tells me that
even though it abstracts away the actual system calls and whatnot that make a
supervisor, the actual logic is not any easier.

On Monday I'll tackle the really popular supervisors: Upstart and systemd.

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

[1]: /posts/supervisors-and-init-systems-1/
[2]: /posts/supervisors-and-init-systems-2/
[supervisors]: /tags/supervisors
[talk]: https://youtu.be/YJrTaMUvjVA?t=1m35s
[ubic]: https://metacpan.org/pod/distribution/Ubic/lib/Ubic/Manual/Intro.pod
[daemonproxy]: https://github.com/nrdvana/daemonproxy
[supervisord]: http://supervisord.org/introduction.html#overview
