---
title: Generics in Go, via Contracts
date: 2019-08-03T09:00:32
tags: [ golang ]
guid: fcd44d71-d436-4dc1-afea-029e8543cf98
---
[The newest Contracts
proposal](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md)
was published just a few days ago.  I read it in full and have a few thoughts.

<!--more-->

You may want to read the proposal to form your own conclusions first; I would
suggest skipping straight to [the
examples](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md#examples)
and then reading the rest if you are up to it.  I do not intend to summarize the
proposal.

Before I go into much more depth I do want to mention a conviction I have about
generics in Go: I am confident that generics in almost any form will
dramatically change the characteristics of Go in the wild.  I think that given
the ability to use a form of abstraction people are more likely to use it than
not, if only because adding the use of an abstraction is easier than removing
it.  It's almost like the computer form of entropy: things get complicated.  I
am resigned to the fact that generics will end up in Go and am a little excited
to use them.  On the other hand I am sure that I'll be reading code that's even
harder to understand than before thanks to them.  I'd love to be wrong though!

Ok all that said, here's my rambling thoughts I jotted down while reading the
proposal:

## [Values of generic types are not boxed](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md#values-of-type-parameters-are-not-boxed)

"Values of generic types are not boxed" first lead me to believe that generic
types will get a little speed boost compared to interfaces, which automatically
turn their values into pointers.  Reading more though, when using generic types
all values *are* turned into pointers to simplify method dispatch, but only
within the generic code, rather than values that are returned from the generic
code.  All this to say: I was excited and I ended up more confused.

## [Function argument type inference](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md#function-argument-type-inference)

Go's type inference is minor but welcome, typically reducing much of the type
duplication that's all over the place in Java.  For some reason I didn't expect
the proposal to include type inference for generics, but it does.  So for
example if you have this generic function call: `Store(int)(5)`, type inference
allows you to simply write `Store(5)`.  The rules for inference are a little
more subtle than I am used to in normal day-to-day Go programming, so it may be
that this ends up disappointing me, but the proposal seems to imply that the
inference could be improved.

## [Map/Reduce/Filter](https://github.com/golang/proposal/blob/master/design/go2draft-contracts.md#mapreducefilter)

I love functional programming in the small; one of the examples given in the
proposal implements all of Map, Reduce, and Filter in just a handful of lines
each; all of the example calls work with type inference as well.  Very
attractive.

---

All in all, I am excited by the proposal.  I doubt I'll be able to actually try
it out any time soon, but I could be wrong about that; modules were released as
vgo first, maybe we'll get a similar ggo to try?

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
