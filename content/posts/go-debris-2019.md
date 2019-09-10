---
title: Go Debris (2019)
date: 2019-09-09T19:41:46
tags: [ golang ]
guid: db941bdb-ff02-4f60-94af-8ff63e9dd829
---
Go 1.13 is out and the Gophercon 2019 videos have been released; I have thoughts
on both.

<!--more-->

## Go 1.13

[Go 1.13 has been released](https://golang.org/doc/go1.13); here are the changes
I'm most excited about.  This is ordered by importance.

The **Error Wrapping Proposal** ([which I wrote about
before](/posts/golang-errors-proposal/)) merged.  They kept what I like and left
out what I didn't, which is nice.

**Go modules** have had a lot of work done.  They are closer to default than before,
[the proxy](https://proxy.golang.org/) (which speeds up use of modules and makes
them safer to use) is officially released and on-by-default, and [the related
sumdb](https://sum.golang.org/) prevents MITM changes of existing releases.

> Out of range panic messages now include the index that was out of bounds and
> the length (or capacity) of the slice. For example, s[3] on a slice of length
> 1 will panic with "runtime error: index out of range [3] with length 1". 

**Clearer runtime errors** are *always* welcome.

The following three quotes are **optimizations** that I'm sure everyone will
appreciate:

> The compiler has a new implementation of escape analysis that is more precise.

> This release improves performance of most uses of defer by 30%.

> The runtime is now more aggressive at returning memory to the operating system
> to make it available to co-tenant applications. Previously, the runtime could
> retain memory for five or more minutes following a spike in the heap size. It
> will now begin returning it promptly after the heap shrinks.


> Digit separators: The digits of any number literal may now be separated
> (grouped) using underscores, such as in `1_000_000`... 

Coming from Perl, I've always been surprised **digit separators** are absent.
It's a relief for it to be added.

`go version <binary>` allows you to interrogate a compiled binary and see which
compiler built it.  I wish it also surfaced the versions of the modules used and
the version of the binary itself, but this is still useful.

`go build -trimpath` is subtle but useful. Go has a lot of tooling to allow
reproducable builds, but in my experience they are very difficult to actually
achieve.  This helps.

## Gophercon 2019

I watched nearly all of [the Gophercon
2019](https://www.youtube.com/playlist?list=PL2ntRZ1ySWBdDyspRTNBIKES1Y-P__59_) videos when they were released
([including the lightning
talks](https://www.youtube.com/playlist?list=PL2ntRZ1ySWBedT1MDWF4xAD39vAad0DBT)).  The following are the talks I think are worth watching:

[Chris Hines - Death by 3,000 Timers: Streaming Video-on-Demand for Cable TV](https://www.youtube.com/watch?v=h0s8CWpIKdg&list=PL2ntRZ1ySWBdDyspRTNBIKES1Y-P__59_&index=14)
starts slow but ended up with some fascinating information about Go timers and
how far a little optimization will go.

[Jonathan Amsterdam - Detecting Incompatible API Changes](https://www.youtube.com/watch?v=JhdL5AkH-AQ&list=PL2ntRZ1ySWBdDyspRTNBIKES1Y-P__59_&index=20)
is a topic I'm not especially interested in, but in discussing breaking changes
subtle features in Go were illuminated in ways I'd never considered before.

[Dave Cheney - Two Go Programs, Three Different Profiling Techniques](https://www.youtube.com/watch?v=nok0aYiGiYA&list=PL2ntRZ1ySWBdDyspRTNBIKES1Y-P__59_&index=9)
went through a couple programs that could be optimized after some basic
profiling.  Almost anything involving profiling in Go is impressive, though (as
you'll see later) it's almost a cliche to talk about at this point.

[Yusuke Miyake - Optimization for Number of goroutines Using Feedback Control](https://www.youtube.com/watch?v=O_R7Nwsix1c&list=PL2ntRZ1ySWBdDyspRTNBIKES1Y-P__59_&index=3&t=0s)
was hard to follow (both technically and due to accent) but fascinating
nonetheless.  I am really interested in how we can use feedback control (or more
generally cybernetics) to optimize systems in real time.

Both [Jason Keene - Dynamically Instrumenting Go Programs](https://www.youtube.com/watch?v=de9cVAx6REA&list=PL2ntRZ1ySWBdDyspRTNBIKES1Y-P__59_&index=21)
and [Daniel Marti - Optimizing Go Code Without a Blindfold](https://www.youtube.com/watch?v=oE_vm7KeV_E&list=PL2ntRZ1ySWBdDyspRTNBIKES1Y-P__59_&index=22)
are yet more talks about either Go's built in profiling support or using system
level profiling.  This is my bag so I am here for it, but I suspect it's not as
univesally appealing as the rest.

The remaining three talks are lightning talks, so are only seven minutes long.

[Paul Jolly - gopls + vim =
govim](https://www.youtube.com/watch?v=DiBZetR733Y&list=PL2ntRZ1ySWBedT1MDWF4xAD39vAad0DBT&index=9&t=0s)
is about the in progress Go
[LSP](https://microsoft.github.io/language-server-protocol/) and a codeveloped
vim plugin (which I use and generally works really well.)

[Kevin Gillette - Forking Stdlib JSON](https://www.youtube.com/watch?v=AssQY0c_fEo&list=PL2ntRZ1ySWBedT1MDWF4xAD39vAad0DBT&index=10&t=0s)
goes through doing some patches atop `encoding/json` to simplify json encoding.
Very fun.

[Frederic Branczyk - Continuous Profiling](https://www.youtube.com/watch?v=HDXEX4zQKoo&list=PL2ntRZ1ySWBedT1MDWF4xAD39vAad0DBT&index=27&t=0s)
presents both the idea and tooling to do profiling, in production, all the time.
Not especially polished, but I can definitely see this becoming a sort of
standard for running code in production.

---

If you are interested in learning Go, this is my recommendation:

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
