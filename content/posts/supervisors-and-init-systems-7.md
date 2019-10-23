---
title: "Supervisors and Init Systems: Part 7"
date: 2017-08-02T08:30:19
tags: [ init, supervisors ]
guid: E82EB15C-772F-11E7-B261-0E90D9B18A8B
---
This post is the seventh in my [series about supervisors][supervisors] and I'm
discussing some ideas that I've had while writing this series.

<!--more-->

While I've written this series I've had a few ideas that I think would improve
the usage of the supervisors I prefer and also make life easier for those who
don't really care.  The first, is of the latter variety:

## Inside-out supervisord wrapper

[`supervisord`][sd] has some great features that clearly make it attractive to
most developers.  Instead of using it and being forced to reimplement the low
level guts of a supervisor in Python, why not use an existing supervisor (maybe
[`runit`][runit] if you wanted to keep it simple, or [`nosh`][nosh] or
[`s6`][s6] if you wanted something advanced) and then just expose the features
you want (the web interface, the XML-RPC, etc) as tooling on top?  Similarly,
the INI style configuration could be compiled to `runit` (or whatever) style
service directories.

I don't think this would be a huge amount of work and it would reduce (I think)
overall code and I suspect it would be more reliable since `runit` has been
around forever and is totally battle tested.

## Supervisor Translator

[`nosh` already does this][csu] for `systemd` units, but I think it would be
worth to consider going further.  I think `systemd` units being the interchange
format would be perfectly reasonable, but being able to render simple ones into
`runit` and more complex ones into `nosh` and `s6` would be a great end game to
me.  Similarly the tool could ship with a `supervisord` parser that would allow
easy migration if you wanted.

And unlike the `nosh` version, since this is an offline tool it can be written
simply with Perl or some other friendly language, instead of C or C++.  At the
very least this might make it simpler for people to help.

## Better container support

systemd uses `cgroups` out of the box to support constraining the resources of
user sessions, services, etc.  This is useful, and [`nosh` provides similar
utility][m2cg] though at what feels like a pretty low level.  `cgroups` are only half
of what we call "containers" though.  [A couple of years ago I blogged about
`unshare`](/posts/pid-namespaces-in-linux/), which takes care of the other half
of the equation: namespaces.  Namespaces allow you to more accurately constrain
(or contain) your services, such that if you terminate a service, all of it's
children go away as well.

While this can be done with process groups and sessions, if the service writer
is sufficiently determined (or just as likely: confused) they can situate their
processes such that some will end up outside of the process group or session or
whatever.

While I could use `nosh`'s [`move-to-control-group`][m2cg] and `unshare` to
achieve a semblance of containers, I have a feeling that there may be a better
option.  On the other hand, I do suspect that the underlying Linux features of
containers (`cgroups` and namespaces, respectively) just are too weird to be
cleanly made into pretty chain-loading tools.  [This is not the first time I've
felt this way][angst].

---

If anyone wants to get started on a project to do one of the above ideas, let
me know.  I am happy to promote or pitch in or help in any other way.  I doubt
I'll have a chance to work on any of these things, but I think all of them
(well maybe not the last one) are worth doing.

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

[supervisors]: /tags/supervisors
[m2cg]: https://jdebp.eu/Softwares/nosh/guide/move-to-control-group.html
[angst]: /posts/linux-containers-and-docker-pstree/#the-inevitable-angst
[sd]: http://supervisord.org/
[runit]: http://smarden.org/runit/
[nosh]: https://jdebp.eu/Softwares/nosh/
[s6]: http://skarnet.org/software/s6/
[csu]: https://jdebp.eu/Softwares/nosh/guide/convert-systemd-units.html
