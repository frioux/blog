---
title: Dropbox Longpoll Bugs
date: 2021-01-09T16:31:30
tags: [ "dropbox", "golang", "frew-warez" ]
guid: 7a925265-4242-4dbd-9dee-e9515b35d858
---
I fixed a subtle bug in my dropbox client's longpoll implementation.

<!--more-->

Recently I noticed that one of my tools (which reloads the current webpage when
a file in the corpus changes, according to dropbox,) was reloading the page way
more than I expected.

I figured either I had a bug in my code or the Dropbox API was much weirder
than I thought.  It turns out that it's somewhere in the middle.

Here's what [the longpoll API says](https://www.dropbox.com/developers/documentation/http/documentation#files-list_folder-longpoll):

> A longpoll endpoint to wait for changes on an account. In conjunction with
> `list_folder/continue`, this call gives you a low-latency way to monitor an
> account for file changes. The connection will block until there are changes
> available or a timeout occurs. This endpoint is useful mostly for client-side
> apps. If you're looking for server-side notifications, check out our webhooks
> documentation. 

That sounds like it monitors the entire account!  But I played with the code
some and found that the related call to continue is limited as you might hope.
In short: the longpoll responses are account-wide, but the contents of the
related responses are limited to the directory you start with.

[The change I made wasn't too complicated](https://github.com/frioux/leatherman/commit/a9e275e3b9058055e78652512b54697609332941)
but
[of course I made plenty](https://github.com/frioux/leatherman/commit/16852ab7bfe383714c5c21f51118b7ab7ad2e3f5)
[of mistakes along the way](https://github.com/frioux/leatherman/commit/3c9f6f87355efd6704901eb7e98c5d19f25f8de8).

I doubt that the frequency I was reloading stuff was causing problems for
Dropbox, my laptop, or the Raspberry Pi running the server code, but who
doesn't like making code much more efficient?

---

(Affiliate links below.)

Recently <a target="_blank"
href="https://www.amazon.com/gp/product/0136820158/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136820158&linkCode=as2&tag=afoolishmanif-20&linkId=6a3d6adabe2966efd8a3b13205d9e0c9">Brendan
Gregg's Systems Performance</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136820158"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" /> got its second edition released.  [He wrote about it
here](http://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html).
I am hoping to get a copy myself soon.  I loved the first edition and think the
second will be even more useful.

At the end of 2019 I read
<a target="_blank"
href="https://www.amazon.com/gp/product/0136554822/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136554822&linkCode=as2&tag=afoolishmanif-20&linkId=9b27a122197fb141065f7276321e4c43">BPF
Performance Tools</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136554822"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.
It was one of my favorite tech books I read in the past five years.  Not only
did I learn how to (almost) trivially see deeply inside of how my computer is
working, but I learned how *that* works via the excellent detail Gregg added in
each chapter.  Amazing stuff.
