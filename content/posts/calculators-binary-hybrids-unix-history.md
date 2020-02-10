---
title: "Calculators, Binary Hybrids, and UNIX History"
date: 2020-02-10T07:57:38
tags: [ frew-warez, unix ]
guid: c3f5d7a7-5e99-4ff2-a457-78c3d218fe67
---
I wanted to add a calculator to my leatherman but I never ever want to write a
parser.  The following is what ensued.

<!--more-->

I've ended up in situations where [I have my
`leatherman`](https://github.com/frioux/leatherman/) handy but `bc(1)` is *not*
installed.  I very briefly considered implementing my own calculator, but every
time I immediately consider the actual parsing of expressions and discard the
idea.  I hate writing parsers!

Recently I considered that maybe there's some weird linker trick I could do
such that the binary would have a statically liked `bc(1)` appended.  I asked
some coworkers and basically the answer was that I could compile my
`leatherman` as a shared library that gets linked into a hacked up `bc(1)` that
would know how to call out to the `leatherman` entrypoint.  This is a bridge
too far for just using a calculator.

Side note: I expect at some point to make some rust based tools and having them
built into `leatherman` in this fashion would be pretty cool, so I expect that
to happen in the next year or two.

I checked to see if [busybox](https://busybox.net/) has a `bc(1)`
implementation and verified that it indeed does not.  But it *does* have
`dc(1)`, the reverse polish notation calculator that preceeded `bc(1)`:

```
$ echo "11 3 / p" | busybox dc
3.66667
```

(That's push 11 and 3 onto the stack, divide the first two numbers on the
stack, and pop/print the number on the stack.)

My coworker Jeremy Leader pointed out that `bc(1)` actually used to be a
frontend for `dc(1)`.  I happened to notice that when reading the manpage for
GNU `bc(1)` today:

```
   DIFFERENCES
       This version of  bc  was  implemented  from  the
       POSIX  P1003.2/D11  draft  and  contains several
       differences and extensions relative to the draft
       and  traditional  implementations.   It  is  not
       implemented in the traditional way using  dc(1).
       This  version  is  a single process which parses
       and runs a byte code translation of the program.
```

My hunch was that "the traditional way" was some yacc based parser. I did some
digging and verified that, as far as I can tell, [the original `bc(1)`
implementation](https://github.com/dspinellis/unix-history-repo/commit/8e40848a),
indeed yacc, was authored by Ken Thompson and the late Dennis Ritchie around
midnight on Wednesday the 14th of May, in 1975.  (Note that the commit metadata
shows a different timestamp, but it's in Pacific Time and Bell Labs is on the
east coast.)

---

I found this a fun little excursion.  At the minimum, I know `dc(1)` is at the
ready even in the rare situation that `bc(1)` is not (it happens!)  On top of that
it's cool to be able to dig so deep into the history of your industry that you can
find this kind of thing.

---

I think a natural book to recommend along with this is
<a target="_blank" href="https://www.amazon.com/gp/product/1695978552/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1695978552&linkCode=as2&tag=afoolishmanif-20&linkId=aba8d10c12250d206a3019f5a91ab912">UNIX: A History and a Memoir</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1695978552" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I haven't read it yet but all the reactions I've seen about it are positive.

Another good, sorta related book is
<a target="_blank" href="https://www.amazon.com/gp/product/1430219483/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1430219483&linkCode=as2&tag=afoolishmanif-20&linkId=043f74b2d742d53aeaa69b2cafa686b8">Coders at Work</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1430219483" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I read it many years ago but really enjoyed it.
