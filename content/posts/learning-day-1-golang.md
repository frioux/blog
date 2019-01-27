---
title: "Learning Day 1: go"
date: 2019-01-26T16:46:28
tags: [ golang, learning-day, meta ]
guid: 2122f364-8a42-4734-880e-c5da312b7a5e
---
This is the first Learning Day Log I'm publishing, and it's about Go.

<!--more-->

[In December I decided to do Learning Days](/posts/goals-2019/) once a month; a
sort of home conference that lasts at most a few hours instead of a few days.
Part of this is because it's difficult for me to plan travel with small
children; part of it is because conferences are expensive; part of it is that
conferences are a very mixed bag and I want to control what I can.

I had a tough time planning out my first Learning Day, so I fell back on doing
something easy and planning a Learning Day on Go, which I use most days [at
work](https://www.ziprecruiter.com/hiring/technology).  The following was what I
watched (in the order I watched them:)

 * [SQLite and Go](https://www.youtube.com/watch?v=RqubKSF3wig): Inspiring;
     [I've long loved SQLite](/posts/hugo-unix-vim-integration/) and have been
     intrigued by the idea of scaling down tech giants.
 * [Static Analysis in Go](https://www.youtube.com/watch?v=mLVxAU_xpEA):
     Interests me because I have a tool in mind.
 * [Brad Fitzpatrick Go 1.11 and beyond](https://www.youtube.com/watch?v=rWJHbh6qO_Y):
   Fun, but maybe a waste of time?  I am ok with wasting time as long as I'm
   insired though; I think the main issue for me here is that I'm well aquainted
   with all the stuff that was discussed in this talk.
 * [Stupid Gopher Tricks](https://www.youtube.com/watch?v=UECh7X07m6E):
     Excellent talk about weird ways to use Go.
 * [7 common mistakes in Go and when to avoid them by Steve Francia](https://www.youtube.com/watch?v=29LLRKIL_TI):
     Good talk on mistakes to avoid.
 * [Go with Versions](https://www.youtube.com/watch?v=F8nrpe0XWRg):
     Personally this was way too in the weeds relating to something I've been
     able to ignore.

I almost suggest that everyone watch the first video.  I don't know how I got so
lucky picking it and watching it first.  Very good.

If you write Go or might write Go in the future, I suggest watching the second
one; it's a little tough to understand due to the speaker's accent, but it gives
a good overview of how you might leverage static analysis for (and in) Go.

Finally, if you already write Go, or are just learning Go, I suggest watching
Stupid Go Tricks.  It's a good talk with some really good explanations of some
of the linguistic nuance that we often miss.

---

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
