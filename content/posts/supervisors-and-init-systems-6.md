---
title: "Supervisors and Init Systems: Part 6"
date: 2017-07-31T07:30:47
tags: [ init, supervisors, perl ]
guid: 11149A7C-728B-11E7-B265-D204F0BD3F5C
---
This post is the sixth in my [series about supervisors][supervisors].  I'll
spare you the recap since it's getting silly at this point.  This post is about
readiness protocols.

<!--more-->

## Readiness Protocols

Before I dive in, a word about terminology.  I personally am using the
term "readiness protocol" to mean "how the supervisor knows the service is
ready."  What it's ready for or if the protocol is implicit or explicit does not
really matter for the purposes of this discussion.  Furthermore, the term
"readiness protocol" is relatively new.  The first use I could find about it was
with respect to systemd in early 2014.

Also I will distinguish between blackbox protocols, which do not use the
internals of the service, and whitebox protocols, which do.  Look up [blackbox
testing][bbt] and [whitebox testing][wbt] if you're interested in where those
terms come from.

One last note: all supervisors have the implicit assumption that a service that
has been started is ready unless otherwise noted.  With that said, I won't
mention this implicit pseudoprotocol again.

### `runit`

Of the supervisors I've mentioned in this series, [`runit`][runit] was the first
to have a readiness protocol worth discussing.  Everything prior basically
assumed that a service that had started was ready to go.  I mentioned the check
script that `runit` has.  This is a "black box" readiness protocol, because the
underlying service barely has to coördinate in this kind of protocol.  As long
as it supports being interrogated in any way (which may be as simple as serving
a simple request, or query, or whatever) this is trivial to implement.

How does `runit` signify that the service is ready?  It lets the `check` (or
`start`) subcommand exit non-zero.  This is very basic but sufficient for a lot
of systems.

Here's an example check script for `runit`:

```
#!/bin/sh

curl http://127.0.0.1:3000 -s > /dev/null
```

This obviously asumes that the service is running on port 3000.  `runit` will
run the above script over and over till it exits zero or passes the timeout,
which is 7s by default but can be set with the `-w` flag to `sv`.

If you want to block arbitrarily long, you can just do the `curl` command in a
loop in the check script itself.

### Upstart

Upstart has three explicit readiness protocols and one implicit.  The explicit
ones are what you'll find from Googling on the internet basically: the
underlying service can advertize that it has completed it's startup and is ready
to be used by

 * [forking once](http://upstart.ubuntu.com/cookbook/#expect-fork)
 * [forking twice](http://upstart.ubuntu.com/cookbook/#expect-daemon)
 * [`SIGSTOP`ing itself](http://upstart.ubuntu.com/cookbook/#expect-stop)

These explicit protocols are "whitebox" protocols, in that the service pretty
much has to do these things itself; though you may be able to duct-tape together
a bash script to do them, it will somewhat defeat the purpose of having the
service doing whatever it needs to do, since you will have to either guess with
a timer or check with a black box checker.

When you configure the service, you state which you will do, and if you get it
wrong [silly things happen.][silly]

The implicit version is that the post-start script completed.

The interesting thing here is that this option can be the good old check script.
[I mentioned it before][upstart-post] when I wrote about Upstart.  As with any
check script, it's a black box protocol.

Unlike `runit` the Upstart version will only run once and has no built in
timeout mechanism.  Upstart also has some special restart semantics (the idea
being you'll give up if the service crashes quickly over and over) that get
confused (or confusing anyway) if you have a slow post-start script.

### systemd

systemd has [a handful of explicit readiness protocols.][sdread]  The are:

 * The underlying command forked once and then exited.
 * The underlying command exited (this can be leveraged for total grossness.)
 * The service appeared in the system bus.
 * The service explicitely said it was ready by sending `READY=1` over the
   notification bus.

The first option is in Upstart.  The second option, which I'm not really sure
what the prescribed use for is, can be used to create init style services where
the oneshot script starts the init and does a blocking healthcheck.

The last two are somewhat controversial.  Both (as far as I know) are limited to
Linux systems.  Arguably *only* the last protocol is a true, explicit readiness
protocol, because all of the other ones are just leveraging something a service
may have always done.  [You can read some great criticisms of these protocols
here.][pcrit]  To take advantage of these last two your service needs to speak
the `dbus` protocol, which some might balk at using exclusively for this
purpose.  Which brings us to

### `s6`

`s6` has a single explicit readiness protocol.  When you define your service you
make a file called `notification-fd` and place a positive integer (like, 7) in the file.
Then in your service you do something like the following:

``` perl
open my $ready, '>>&=', 7
  or die "couldn't fdopen 7: $!";
print $ready "\n";
close $ready;
```

If you can't tell due to the noise: that's *two* system calls: `write(2)` and
`close(2)`.  It's *so much* simpler than using a complicated system bus.

On top of that, [as mentioned before][s6-post] `s6` has an addon that will make
this simple protocol work with the notification bus protocol.  One of the only
efforts at interoperability in this whole mess.

### Big Picture Alternatives

I strongly believe that building your systems well in the small can help when
your systems get large.  The problem is, there are situations where you cross a
boundary and the small cannot be used for the large.  In this case it's when
your services are on more than a single machine.  It's all well and good to have
an init system that helps start services only when their dependencies are ready,
both for efficiency and reliabilitiy.  But once your services are on multiple
machines a lot of these intricate little details go out of the window.  There
are two solutions (that I know of) that work better in a bigger environment.

First: make your clients patient and polite.  This means exponential backoff.
If a service tries to connect to a server and it fails, do not immediately crash
and try again when your supervisor restarts you.  On many services this wastes
huge amounts of resources restarting the client service.  Similarly, don't
simply sleep for two seconds and try again.  If you ever end up with many
thousands of clients and go down, you will be in for a bad time.

A good example of an exponential backoff implementation is
[`DBIx::Connector`][dbixc] by Tim Bunce.  I've used this in situations where
sometimes the underlying database is unavailable for connections.  The service
retries, slower and slower, and after retrying slower and slower for a few
hours, it just gives up.  Then the supervisor restarts it and it tries all over
again, on the assumption that possibly something got messed up inside the
service itself.

Second: use some form of service discovery.  Connecting to a known server and
port will work for a long time, but eventually it won't scale because you have
to keep the servers you maintain in sync with the code that needs to connect to
them.  [I briefly mentioned service discovery before][sd], but it really needs a
post of its own.  All that to say service discovery could be leveraged to
subscribe to some form of readiness, instead of attempting to wire together all
of these little pieces in the large.

---

As with many of the supervisor posts, this one was supposed to be a small
section in a single post and grew to be a post of its own.  My next post will be
some ideas that I think should be implemented.  Stay tuned.

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

Finally, given that I mentioned service discovery and exponential backoff,
<a target="_blank" href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=a7610c779654105cddeb8ee1773e5984">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
seems like it might be applicable to this topic.

[silly]: http://upstart.ubuntu.com/cookbook/#implications-of-misspecifying-expect
[upstart-post]: /posts/supervisors-and-init-systems-4/#upstart
[s6-post]: /posts/supervisors-and-init-systems-2/#s6
[bbt]: https://en.wikipedia.org/wiki/Black-box_testing
[wbt]: https://en.wikipedia.org/wiki/White-box_testing
[sdread]: https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=
[pcrit]: https://jdebp.eu/FGA/unix-daemon-readiness-protocol-problems.html
[sd]: /posts/development-with-docker/#refinements-1
[1]: /posts/supervisors-and-init-systems-1/
[2]: /posts/supervisors-and-init-systems-2/
[3]: /posts/supervisors-and-init-systems-3/
[4]: /posts/supervisors-and-init-systems-4/
[5]: /posts/supervisors-and-init-systems-5/
[supervisors]: /tags/supervisors
[runit]: http://smarden.org/runit/
[dbixc]: https://metacpan.org/pod/DBIx::RetryConnect
