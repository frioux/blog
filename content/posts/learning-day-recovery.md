---
title: "Learning Day: Recovery"
date: 2019-04-08T07:10:58
tags: [ learning-day, golang, circleci, travis-ci ]
guid: 6860156f-2251-4bcd-997f-6001412c5e99
---
This weekend I did one of [my learning days](/tags/learning-day/) but instead of my preferred
aggressive pace I took it a little easier.

<!--more-->

Due to a family emergency last week I have been stressed and a little upset this
past week.  Before you ask: I am fine, but that doesn't mean that I am as put
together as normal.  I had already earmarked this Saturday to be a learning day
and didn't want to squander it, but I also knew I wouldn't be able to focus as
much as normal, so I chose to take a middle ground.

Instead of watching a day or two of conference videos on youtube I literally
watched two videos (neither of which are worth linking to) and spent the rest
of my time "sharpening" my leatherman.

I started by
[migrating](https://github.com/frioux/leatherman/commit/23af02f0f11b44e6ceec3cdbd2d25d0ac8dc1f41),
[a
few](https://github.com/frioux/leatherman/commit/3fee3e2a5e4935089211ac7d95f7b4aedf6076e1),
[of my
OSS](https://github.com/frioux/leatherman/commit/9cf2af8c8ab4172ff09900e800a5af1af6a342a8),
[packages](https://github.com/frioux/leatherman/commit/e8b5162ba10091af7a488c9cf5ee9393dc1f3e3e)
into the leatherman.  This simplifies things for me if I ever need to change the
interface of any of them, and helps me ensure that everything gets the same care
(like linting) I put into the leatherman.

Next I took [a
huge](https://github.com/frioux/leatherman/commit/00a00f3065ef0aa778e671337b4130d4baac358b)
[simplification](https://github.com/frioux/leatherman/commit/10d64a420bfdc8974834d8d90c541a8d8f25ddb9)
[pass](https://github.com/frioux/leatherman/commit/b6127ba8621aa7f1efda0610a7cf283831b66289)
[on](https://github.com/frioux/leatherman/commit/dd7c8ad0d9a318a04b213f905ba5fd1410501393)
[my](https://github.com/frioux/leatherman/commit/5d7af8d0222179039faa975e506406151c9e8510)
[netrc](https://github.com/frioux/leatherman/commit/532680fe5c132cd3c65de0d68d8bcd7edb12bec3)
[fork](https://github.com/frioux/leatherman/commit/33fa3e0729f7cc6bcac41ada1204c6b58c8a063e).
[It felt
great.](https://github.com/frioux/leatherman/commit/f950d9562836bd5d986a8085cdbd625a09846eb0)

[I removed a silly
dependency](https://github.com/frioux/leatherman/commit/625ce00ff267cf0e6cbf5bb370a4a610f4fe5d3c).
[I removed a less silly dependency
too.](https://github.com/frioux/leatherman/commit/d23a644765300cdd37fd26afdb490a3cbd1ea816)

[I migrated a bunch of non-Go
html](https://github.com/frioux/leatherman/commit/4f5b182e813f201f62355824d0a26a23c364ea03)
[used in tests to `testdata`
directories](https://github.com/frioux/leatherman/commit/f8f7db5243940ee369bea401df26d66f78e150dd)
[and then told github not to count them as my
code](https://github.com/frioux/leatherman/commit/a9295b970f0f37f6327e5d949bc1ab5ac7ec9cbb).

[I added some new
tests](https://github.com/frioux/leatherman/commit/480209b7ba1a28531c88202471966a6c673cdbde).
[I fixed issues raised by a
linter](https://github.com/frioux/leatherman/commit/2e29d78ba7fd4889fc04d433c01445ca21e12aee).
[I fixed a race condition that was detected by a
test](https://github.com/frioux/leatherman/commit/dd53022de00d254d37f5079ea003e09bb5a5b173).

Finally, I spent a bunch of time [migrating from TravisCI to
CircleCI.](https://github.com/frioux/leatherman/commit/952ece327275be4a499eb0519a84e51c64822abf)
I wouldn't have done this except my Travis builds were failing in pathological
ways that I couldn't reproduce and word on the street is that the future of
travis is uncertain anyway.  If anyone is interested in the original failure,
here's the error I was getting:

```
# github.com/frioux/leatherman/cmd/leatherman
/home/travis/.gimme/versions/go1.12.2.linux.amd64/pkg/tool/linux_amd64/link: running gcc failed: exit status 1
/usr/bin/ld: /tmp/go-link-147863353/000008.o: unrecognized relocation (0x2a) in section `.text'
/usr/bin/ld: final link failed: Bad value
collect2: error: ld returned 1 exit status
```

Migration to CircleCI was annoying but generally it worked well and the
resulting system is faster and more flexible than it was with Travis, so at
least there's that.

Depending on how I feel tonight I have other plans; I'd like to remove my
dependency on `github.com/headzoo/surf` and refactor `debounce` such that it's
testable (without sleeps.)  Both of those tasks are easy and the latter should
produce much cleaner code anyway.

---

(The following includes affiliate links.)

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
