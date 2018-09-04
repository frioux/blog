---
title: GopherCon 2018
date: 2018-09-04T07:30:46
tags: [ golang, conference, ziprecruiter, oss ]
guid: 223094dd-705f-4374-abf1-dbdc8da61a76
---
This year I went to GopherCon.  This post is a grab bag of what I thought was
interesting and some thoughts on this conference vs others and conferences in
general.

<!--more-->

[I've](/posts/yapc-day-1/) [been](/posts/yapc-talks-i-think-are-worth-note/)
[going](/posts/youre-awesome-yapc/) to
[YAPC](/posts/scalability-reliability-and-performance-at-ziprecruiter/) since
2009, and I had planned to go again this year, but my boss said, more or less:
"fREW, you probably are not actually learning a lot there, and should try going
somewhere else.  I suggest GopherCon."  So I went.

---

Before I get into the nitty gritty I have a few thoughts about the conference as
a whole.  It was super polished; there was live closed-captioning, excellent
A/V, swag that included a stuffed gopher, and even my hotel had a Gophercon
branded keycard.  On the other hand, this is probably why it was so expensive.
I could and would personally go to YAPC on my own dime.  I would not go to
Gophercon on my own dime.

Another really impressive thing about Gophercon was the diversity.  Both the
audience and the speakers were way more diverse than a typical tech conference,
which is both refreshing and encouraging.  Maybe things are getting better?

Finally, the community was new to me, so while at YAPC I always look forward to
seeing Rik JellyBean Signes, Fitz Elliott, Henry Van Styn, Michael Conrad, some
of my coworkers from my last job, and lots of other people, this time I arrived
and knew no one except the two other ZR employees.  I did have some great
conversations with Kayla Kasprak, Dan Moore, and Jamie Luck, but it was still a
far cry from YAPC.

If I personally had one takeaway from the conference it would be that it's worth
looking over the documentation for the various flags that can be used when
building Go binaries.  There are a ton of them and they are kinda sprawling.  I
suggest looking over `go help build`, `go doc cmd/compile`, `go doc cmd/link`,
`go tool compile`; [there's an overview of some of the flags here.](https://rakyll.org/go-tool-flags/)

---

The following is a chronological list of talks that I went to and found
interesting.  I went to others that were fine, but just not for me or whatever.

If you read this in the future after the videos have been published, feel free
to let me know or [submit a
PR](https://github.com/frioux/blog/blob/master/content/posts/gophercon-2018.md)
to add relevant links.

## Tue

### The Scheduler Saga [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-the-scheduler-saga), [slides](https://speakerdeck.com/kavya719/the-scheduler-saga)]

This was a great intro talk where [Kavya Joshi](https://twitter.com/kavya719)
discussed how the Go Scheduler, which is what allows go to run many goroutines
without the same amount of threads, basically.  She had various simplified
implementations and added extra details and refinements until she built up to
the actual scheduler.  A great start to the conference, and an accurate keynote.

### An Over-Engineering Disaster with Macaroons [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-an-over-engineering-disaster-with-macaroons), [slides](https://speakerdeck.com/tessr/an-over-engineering-disaster-with-macaroons)]

This was maybe my favorite talk of the whole conference.  [Tess
Rinearson](http://www.tessrinearson.com/) went over how Chain used
[Macaroons (pdf)](http://theory.stanford.edu/%7Eataly/Papers/macaroons.pdf)
(think layered cookies, ha ha) to solve authn and authz.  I love hearing about
the limits of a technology, especially when it involves taking on surprising or
frustrating tradeoffs.

### Asynchronous Networking Patterns [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-asynchronous-networking-patterns), [slides](https://speakerdeck.com/filosottile/asynchronous-networking-at-gophercon-2018)]

In this talk [Filippo Valsorda](https://blog.filippo.io/) went over the basics
of implementing a server in Go.  In the talk he showed some serious pitfalls
while implementing a proxy that could reveal parts of the TLS handshake.  The
pitfalls are worth listing:

 1. **Immediately `go whatever()` when you receive a connection**
 2. Make sure you Close your connections.
 3. Set timeouts before reading any data.

### Allocator Wrestling [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-allocator-wrestling), [slides](https://speakerdeck.com/emfree/allocator-wrestling)]

In this talk [Eben Freeman](https://emfree.me/) discussed how the Go allocator
works.  I have read [a few](https://sourceware.org/glibc/wiki/MallocInternals)
[articles](https://utcc.utoronto.ca/~cks/space/blog/unix/SbrkVersusMmap) about
how the normal Unix allocation works so it was interesting to hear how the Go
allocator works.  One takeaways was that you should limit pointer use not only
because it slows down access, it also makes the garbage collector do more work.
On a related note, if the garbage collector is busy enough goroutines may be
forced to do some of their own garbage collection, slowing them down.

This talk highlights what I meant about the fact that The Scheduler Saga was a
good keynote in that much of this conference was about how the Go compiler
actually works.  Here's a quote from memory from this talk:

> The way the compiler works is inherently interesting.

Sure, it's interesting to me, and maybe even everyone at the conference, but
that is absolutely false on a universal scale and indeed should be false.  It's
great to know how things work, but most programmers are (or maybe should be)
more interested in solving a business or life problem than how their compiler
works.

### Missed

The following were talks I couldn't make and intend to watch the videos for when
they are published.

 * Rethinking Classical Concurrency Patterns [[slides](https://drive.google.com/file/d/1nPdvhB0PutEJzdCq5ms6UI58dp50fcAN/view)]
 * How Do You Structure Your Go Apps?  [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-how-do-you-structure-your-go-apps), [slides](https://github.com/katzien/talks/blob/master/how-do-you-structure-your-go-apps/gophercondenver-2018-08-28/slides.pdf), [eg](https://github.com/katzien/go-structure-examples)]
 * gRPC, State Machines, and... Testing?  [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-grpc-state-machines-and-testing), [slides](https://github.com/amy/Codes/blob/master/gRPC-StateMachines-Testing/gRPC%2C%20State%20Machines%2C%20and%20Testing.pdf), [etc](https://github.com/amy/Codes/tree/master/gRPC-StateMachines-Testing)]

## Wed

### Writing Accessible Go [[liveblog](https://about.sourcegraph.com/go/gophecon-2018-writing-accessible-go), [slides/transcript](https://docs.google.com/document/d/1AsktP9tHph4a714YPoVtWOJ0QCb6eckh-2VtHpYSC6s/edit)]

In this fascinating and somewhat painful talk [Julia
Ferraioli](http://www.juliaferraioli.com/) discussed what it is like to be a
sometimes partially visually disabled programmer.  She had a variety of
recommendations that help with screen readers, but I also think that an unstated
benefit (which she discussed just not directly) was that this can help everyone
else when, for example, they are distracted and can't keep a huge system in
their head.  Or more concretely, consider getting paged at 2am, even focussing
your eyes can be difficult, so code that doesn't require intense effort to read
is great.

### Go in Debian [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-go-in-debian), [slides](https://docs.google.com/presentation/d/1W0xjmh85A8DoGvQa2-MrLayyEec7ivArCus1YvruHiI/edit#slide=id.p)]

[Michael Stapelberg](https://michael.stapelberg.de/) went over four major
topics:

 * Go libraries for working with Debian
 * Generic tools written in Go that are relevant for Debian users
 * Services that are written in Go that are relevant for Debian users
 * How Go module authors can ensure that modules are easy to package for Debian

I'm interested in these:

 * [manpages](https://manpages.debian.org/): should be a good hosted manpages service.
 * [codesearch](https://codesearch.debian.net/): like github search but for all the code in Debian.
 * [pault.ag/go/debian](https://pault.ag/go/debian), [pault.ag/go/archive](https://pault.ag/go/archive): Libraries for working with Debian packages and archives.
 * [pk4](https://github.com/Debian/pk4): A tool for downloading the source of a Debian package.

### C L Eye-Catching User Interfaces [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-c-l-eye-catching-user-interfaces), [slides](https://pedantic-bell-26ad02.netlify.com/#/)]

[James Bowes](https://repl.ca/) showed what is involved in writing nice
(interactive) commandline interfaces.  He explained a ton of TTY stuff, much of
which I already knew but I'd never seen it all presented in one place.  Not
specifically relevant to Go, but very fun.  I might try to use the information
here to have more information dense console tools.


### Missed

 * Micro-optimizing Go Code [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-micro-optimizing-go-code), [slides](https://speakerdeck.com/gtank/micro-optimizing-go-code)]
 * Implementing a Network Protocol in Go [[liveblog](https://about.sourcegraph.com/go/gophercon-2018-implementing-a-network-protocol-in-go), [slides](https://github.com/mdlayher/talks/blob/master/gophercon2018/implementing-a-network-protocol-in-go.pdf)]

## Thu (Lightning Talks)

Unlike YAPC, Gophercon puts all Lightning Talks on one day (Community Day.)  I
think the idea is that you can leave a day early if you want to skip these.  I
personally prefer that they be more spread out, but I get it.

### Lazy JSON Parsing [[slides](https://talks.godoc.org/github.com/packrat386/lightning_talk/talk_v1.slide)]

JSON parsing in Go is super common and a huge stumbling block to new users.
[Aidan Coyle](https://github.com/packrat386) discussed the frustrating issue
where you have to parse JSON like this:

```json
{
   "Users": [{
      "Name": "frew"
   }, {
      "ID": 1
   }]
}
```

Note that the fields in the `Users` array vary.  The magic sauce for this
situation is
[json.RawMessage (see related example)](https://golang.org/pkg/encoding/json/#RawMessage).

### Modular Audio Synthesis with Shaden

In this fascinating talk [Brett Buddin](https://buddin.us/) showed how he does
audio synthesis with [some C, Go, and an LISP
interpreter](https://github.com/brettbuddin/shaden) (that I think he wrote) full
of live demos.  Gotta watch the video for this when it comes out.

### Keeping Important Go Packages Alive

[Tim Heckman](https://twitter.com/theckman) discussed an effort called
[Gofrs](https://github.com/gofrs) to ensure that important packages stay
maintained.  The effort has apparently only just started, with just one package
in the list.  I hope it takes off though, and will gladly volunteer to help out,
as I've already run into many abandoned Go packages.

### The nuclear option, go test -run=InQemu [[slides](https://drive.google.com/file/d/1nPdvhB0PutEJzdCq5ms6UI58dp50fcAN/view)]

[Brad Fitzpatrick](http://bradfitz.com/) discussed [an elaborate system he
built](https://github.com/google/embiggen-disk/blob/master/integration_test.go#L113)
for testing some code that needed root to resize volumes.  He built a system
that would let him run his test as pid 1 under a kernel in qemu.  Very cool.

### Geohash in Golang Assembly [[post](https://mmcloughlin.com/posts/geohash-assembly)]

[Michael McLoughlin](https://mmcloughlin.com/) discussed some work he did to
optimize Geohashish in Go by manipulating the generated assembly.  Given how
short the lightning talks are he was only able to touch on some of the
instructions used to speed it up.  I intend to read the relevant blog post and
see how one does this kind of tweaking.

### Code search tailored for Gophers

[Daniel Martí](https://mvdan.cc/) introduced [a tool he wrote called
`gogrep`](https://github.com/mvdan/gogrep) which allows you to grep your code
with a fairly straightforward pattern language modeled on the Go syntax, but
instead of searching for bytes it searches for matching syntax.  He presented it
as a middle ground between `grep(1)` and Go linters.  He also mentioned a linter
(there are a huge amount of Go linters) I had never heard of called
[rangerdanger](https://github.com/mdempsky/rangerdanger) which seemed cool.

### Missed

I missed the following talks because I had to attend a remote meeting and intend
to watch the videos.

 * Linux, Netlink, and Go in 7 minutes or less!
 * Dynamic distributed tracing for the Edge using Go
 * router7: a pure-Go home router
 * A day in the life of rob Pike
 * Serving GraphQL via Code Generation: gqlgen
 * The Container Network Interface and Go
 * RBAC Manager: Extending the Kubernetes API with a Custom Go Operator
 * Have 7 minutes before lunch? Learn How to Extend the Kubernetes API with Kubebuilder

### Athens - the module proxy for Go

[Aaron Schlesinger](https://twitter.com/arschles) introduced
[Athens](https://github.com/gomods/athens) which is a proxy for Go modules.
Unfortunately it sounds like it can only download by major version, so if an
author adds a new feature but does not break backwards compatibility you cannot
tell Athens to pull the new version.  Definitely a space to watch though.

### Migrating The Go Community

[Marwan Sulaiman](https://www.marwan.io/) introduced [a tool he built called
`mod`](https://github.com/marwan-at-work/mod) which can automatically create
Pull Requests for modules you depend on which do not yet work with the new
modules system.  It was pretty cool and I suspect that this will help all the
non-abandoned packages get migrated.  Not so sure how we resolve the abandoned
ones though.

### What's new in VS Code for Go?

[Ramya Rao](https://github.com/ramya-rao-a) showed off some new features for [Go
integration in VS Code](https://github.com/Microsoft/vscode-go).  I don't use VS
Code but some of the stuff she showed inspired me to figure out if vim-go can do
similar things.  Another really cool thing she mentioned was that eight of the
nine features she showed were actually implemented by members of the community.
Awesome.

### Linux Delay Accounting [[slides](https://speakerdeck.com/andrestc/linux-delay-accounting)]

[André Carvalho](https://andrestc.com/) discussed a rarely exposed but
relatively old feature of Linux that lets you find out how much a given process
has been delayed.  Processes may be delayed because they are blocking on IO, a
higher priority process monopolizing the CPU, etc.  [He built a tool in
Go](https://github.com/andrestc/delaystat) that would let you query the status
of a process pretty simply.  I intend to try this out.

### Evans: more expressive gRPC client

[Taro Aoki](https://www.syfm.me/) discussed the difficulties of debugging gRPC
vs REST and the introduced a really cool interactive client called
[Evans](https://github.com/ktr0731/evans) that has tab completion via
introspection and more. I don't intend to use gRPC any time soon but I love
these kinds of tools.

---

That's all I've got.  Overall the conference was good.  It is unlikely I'll be
able to make it in 2019 since it's such a tax on the family but if it's an
option for you, maybe give it a shot.

---

If you don't already know Go, you should read
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

I've mentioned in the past that [I enjoy good coffee][coffee] and that [I even
have a travel setup][travel].  As a quick refresher, if you want good coffee at
a conference you can get:

 * <a target="_blank" href="https://www.amazon.com/gp/product/B004YIBVZM/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B004YIBVZM&linkCode=as2&tag=afoolishmanif-20&linkId=84ee2fe0e42c1d561709230110c97d6f">This Zassenhaus Grinder</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B004YIBVZM" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 * <a target="_blank" href="https://www.amazon.com/gp/product/B0047BIWSK/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B0047BIWSK&linkCode=as2&tag=afoolishmanif-20&linkId=cf9d9dbf2d439a8bd7cef342923f96da">An Aeropress</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B0047BIWSK" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 * <a target="_blank" href="https://www.amazon.com/gp/product/B00004XSC4/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00004XSC4&linkCode=as2&tag=afoolishmanif-20&linkId=cf82eafce51f3e65725f76d355e7fb44">A Cheap Thermometer</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B00004XSC4" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 * <a target="_blank" href="https://www.amazon.com/gp/product/B003STEJ4S/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B003STEJ4S&linkCode=as2&tag=afoolishmanif-20&linkId=3e09174fc08debd659c2361682ce0dd7">Almost Any Cheap Scale</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B003STEJ4S" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

They pack nicely (the grinder fits inside of the Aeropress) and the coffee is
great.  Highly recommend.

[travel]: /posts/diy-coffee-roasting-and-coffee-setup/#travel-setup
[coffee]: /posts/diy-coffee-roasting-and-coffee-setup/
