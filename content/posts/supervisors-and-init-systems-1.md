---
title: "Supervisors and Init Systems: Part 1"
date: 2017-07-17T07:45:10
tags: [ init, supervisors ]
guid: 7C8A11D6-6A36-11E7-AFD2-6D8C5D879173
---
In 2014 Mike Conrad, of [Perl Delorean fame][delorean], did [a lightning talk
about supervisors][talk], including one he wrote.  It was a watershed moment for
me and since then I have found supervisors interesting.

<!--more-->

![Perl runs on this Delorean](/static/img/perl-delorean.jpg)

If you don't know what a supervisor is, I highly recommend the talk, it's only
five minutes.

This is part one in a series that will likely be in three parts, but maybe more.
See the [supervisors tag](/tags/supervisors) to see the rest as they become
available.

## The Simplest Supervisors

Note that the following are listed in order of complexity, not strictly the
order they were created.

There are a lot of supervisors out there but they, as far as I know, all were
inspired by `daemontools`.  These first three are, as far as I know, the
simplest of the bunch.  Fundamentally they work by writing some files like the
following:

```
/etc/srv/
  offlineimap/run
  ...
```

`/etc/srv/offlineimap/run` (when I used `runit`) looked like this:

``` sh
#!/bin/zsh

exec 2>&1 offlineimap
```

These simple supervisors work by running a main supervisor (`svscan`,
`runsvdir`) which then runs a supervisor (`supervise`, `sv`) per service.  Each
supervisor will maintain status info in a file in the service directory.  While
much is compatible from one supervisor to the next, the format of these files
varies fairly significantly.

All of the services start in parallel.

### `daemontools`

As far as I know the first supervisor was [daemontools][daemontools], which hit
the scene in the late 90s.  If anything, as an example it's great.  The
licensing is and as far as I can tell always has been problematic, but it
doesn't really matter as there are a boatload of alternatives.  But I think that
already we can see something of note about supervisors, or at least those who
make them: the people who build them are strange and interesting people.

The first striking oddity about `daemontools` is it's lack of a real license.
That's fine, it is well within djb's rights to do so, but it's not the end.
Second, there is no public source control.  This may be more of a marker of it's
age than anything else, but I'm not convinced. Third, instead of the typical
"extract, `./configure`, `make`" installation method, `daemontools` completely
skips the typical `./configure` running (and indeed generation via autoconf or
whatever) and also shields the user from directly running `make`, instead opting
to use simple shell scripts and convention.

Even ignoring those oddities a typical user may be wise to skip `daemontools`
and instead use one of the many clones of `daemontools`.  I have more personal
experience with these than straight `daemontools` but I'll do my best to list
all the ones I know of.

One thing that I want to mention before I go further is that many of the little
tools that ship with `daemontools`, like [`tai64n`][tai64n] (which prepends each
line with a weird timestamp) can be used alongside other supervisors.  They
truly can be swapped in and out.  I have often used the original `daemontools`
logging tools with other actual supervisors.

### `daemontools-encore`

First is [`daemontools-encore`][encore] which is a straight fork and
modernization pass, as well as adding more modern, traditional project
management (hosted at github and accepts pull requests.)  This is one of the few
discussed here which I have never used.

### `runit`

[`runit`][runit] could almost get it's own category, as it adds two important
features.  First is a logger process, which each service may have.  When I used
`runit` I used it like this:

```
#!/bin/zsh

exec tinylog -t -k 1 /home/frew/log/offlineimap <&0
```

And then you could also have a `check` script, which `runit` can use to make a
`status` command that actually checks if your service is working, as opposed to
just running but not working.  I never wrote a `check` script for my personal
stuff, but I'll have an example later in a different section.

An interesting fact about `runit`, which I only learned on rewatching Mike's
talk, is that [BusyBox][busybox] has (though not on my system) it built in.

### `perp`

[`perp`][perp], another one I haven't used, makes a small change to the model by
merging the outer supervisor and the inner supervisors.  This leads to a simpler
process model but a more complicated supervisor.  Someone sufficiently paranoid
would say that this is the wrong compromise to make, given that the supervisor
processes are going to be almost always idle.  Aside from that `perp` is pretty
much just like the rest.

`perp` is one of the few discussed here that cannot actually run as pid 1.

---

If you were to stop here, I would personally recommed `runit`.  It's pretty
straightforward to set up, it's incredibly popular, and it is included in many
(most?) package managers.

But I would say there is another generation that should be considered, that
still fits within the "simple" family of supervisors, which I'll post about
Wednesday.

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

[talk]: https://youtu.be/YJrTaMUvjVA?t=1m35s
[delorean]: https://www.youtube.com/watch?v=SERH3_gZOTo&index=17&list=PLA9_Hq3zhoFxjn-BFNMc_n6zsd41I1ISB
[daemontools]: http://cr.yp.to/daemontools.html
[encore]: http://untroubled.org/daemontools-encore/
[runit]: http://smarden.org/runit/
[busybox]: http://busybox.net/
[tai64n]: https://cr.yp.to/daemontools/tai64n.html
[perp]: http://b0llix.net/perp/
