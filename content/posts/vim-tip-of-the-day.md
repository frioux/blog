---
aliases: ["/archives/580"]
title: "Vim Tip of the Day"
date: "2009-04-23T15:12:47-05:00"
tags: [vim]
guid: "http://blog.afoolishmanifesto.com/?p=580"
---
Every now and then I want to run a given vim command on a bunch of lines. In the
past I would have either executed the command and then pressed **j.** (Hi
J-Dot!) to go down and repeat the command. Or if the command were more complex I
would have used a macro and done it over and over with **@@**.

Well, for simple stuff on a range there is an easier way! Lets say you want to
delete the first two words of a bunch of lines you have highlighted. This is all
you have to do:

    '<,'>:normal d2w

SWANK.

---

(The following includes affiliate links.)

If you'd like to learn more, I can recommend two excellent books.  I
first learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.
