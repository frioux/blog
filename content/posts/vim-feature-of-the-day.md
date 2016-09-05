---
aliases: ["/archives/518"]
title: "Vim Feature of the Day"
date: "2009-04-05T02:45:48-05:00"
tags: [vim]
guid: "http://blog.afoolishmanifesto.com/?p=518"
---
We all know programmers who, when they need to copy/paste more than one thing,
just use a temporary window to keep track of the copied data. Well vim has that
feature **solved**.

First off, we have multiple copy/paste buffers, known as registers. So I can
copy and paste three different things into three different registers. To copy a
line to register a, use **"ayy**. Then to paste that line you would use **"ap**.
So we have plenty of registers. It gets better! What if you want to copy a bunch
of stuff into one register? Well, first I would clear it with **:let @a = ''**,
but that's not required. Anyway, you can add to a register by using **"Ayy**.
This will copy the current line onto "a. So you can do this over and over to add
to the "a register!

But that requires too much work. Yesterday I wanted to add all lines with the
word "name" into "a. Here is how I can do that with one line: **:g/name/y A**.

Awesome!

---

If you'd like to learn more, I can recommend two excellent books.  I first
learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.
