---
title: "Supervisors and Init Systems: Part 5"
date: 2017-07-26T08:27:19
tags: [ init, supervisors ]
guid: FCA3F61E-70F0-11E7-8497-1E8BF0BD3F5C
---
This post is the fifth in my [series about supervisors][supervisors].  [The
first][1] [two posts][2] were about traditional supervisors.  [The third][3] was
about some more unusual options.  [The fourth][4] was about the current most
popular choices.  This post is about some of the unusual trends I've noticed
during my three year long obsession with supervisors.

<!--more-->

There are some kinds of software that most programmers seem compelled, fated, or
doomed to reinvent or even simply reimplement: templating systems, web
frameworks, and to a lesser extent ORMs.  Supervisors are firmly not in this
category.

The engineers and artists who build these things have tendencies that single
them out from the rest of us.  Much of this may simply be the legacy of djb.
Ultimately it doesn't matter, but I find it interesting to see these weird
corners of Unix systems that most people take for granted or don't even know
about.

## Accurate and In-Depth Documentatoin

Most documentation I interact with on a daily basis is reference.  Often it
lacks examples, any instruction or guidance, or details regarding resource usage
or time complexity. Instead documentation tends to provide just enough to use
the library or tool in question.

Contrast this with *typical* documentation of these supervisors.  Here are just
a few bits of documentation for some of the supervisors discussed here:

 * [`convert-systemd-units`][csu]
 * [`s6-svscan`][sss]
 * [`systemd.unit`][su]

These are all a wealth of helpful and (to me) interesting information.

## Attention to Detail

A lot of what I do in my day to day work is try to think of ways that I can
ensure that, even when engineers don't think about all the ways they could make
mistakes, the system will keep working when Murphy strikes.  I do not blame most
engineers for not being intimately familiar with all of the various details of
the computer, but I could list a dozen incredibly important details that most
engineers forget about or don't even know.

Contrast this with the typical implementor of a supervisor.  Here are a couple
documentation snippets that I think show this:

 > s6-svscan *does not use malloc()*. That means it will *never leak memory.*
 > However, s6-svscan uses opendir(), and most opendir() implementations
 > internally use heap memory - so unfortunately, it's impossible to guarantee
 > that s6-svscan does not use heap memory at all.
 
([from `s6-svscan`][sss]).

 > [daemonproxy supports] command-line options to allocate a fixed number of
 > objects of a fixed size at startup, so it never needs to call malloc again
 
([from the daemonproxy readme][dp]).

While this is simply about `malloc`, there are many other examples if you look.

## Portability

Ignoring systemd, many supervisors make efforts to work on a wide variety of
Unix systems.  `nosh`, for example, was written expressly with FreeBSD in mind
because all other major SysV replacements have either been too weird (launchd)
or Linux specific (systemd.)  So the author made `nosh`.  Most other supervisors
stick to POSIX standards so that they can run on most Unixes. 

---

I really wanted to write more about this.  I had a whole section I cut out about
alternate libc implementations.  I had to stop because I have a cold that I've
gotten due to lack of sleep (due to *children* who are sick.)  Anyway, I expect
to write one more post, *maybe* two if I can pull it off.  The next one will
either be about the ideas that writing these posts inspired, or about readiness
protocols.

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

[csu]: https://jdebp.eu/Softwares/nosh/guide/convert-systemd-units.html
[su]: https://www.freedesktop.org/software/systemd/man/systemd.unit.html
[sss]: http://skarnet.org/software/s6/s6-svscan.html
[dp]: https://github.com/nrdvana/daemonproxy#init-replacement
[1]: /posts/supervisors-and-init-systems-1/
[2]: /posts/supervisors-and-init-systems-2/
[3]: /posts/supervisors-and-init-systems-3/
[4]: /posts/supervisors-and-init-systems-4/
[supervisors]: /tags/supervisors
