---
title: AwesomeWM II
date: 2019-05-20T19:42:11
tags: [ awesome, window-manager, xmonad ]
guid: aae2a8ca-1f0d-4f1a-bb1f-0500c88982bf
---
I just switched back to AwesomeWM.  I used AwesomeWM from 2012 to 2017, so this
almost feels like a relief.

<!--more-->

[I won't bore you with](/posts/awesomewm/) [my sordid window manager
history](/posts/hello-xmonad-goodbye-awesomewm/) and will instead cut to the
chase: a couple of months ago NOAA changed how they store weather data.  That
broke the weather widget I was using.  At the time [I hacked around
it](/posts/fixing-buggy-haskell-programs-with-golang/) but I figured the hack
would break eventually, given how precarious it was at the time.

The hack broke Friday of last week.  I looked into a couple options to fix it
but was annoyed to have to fix something after only eight weeks.

On the other hand [Rob Hoelz](https://hoelz.ro/) joined my team [at
ZR](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) in February; he's an
AwesomeWM user and reassured me that the stability issues I complained about
before had been mostly resolved.  Armed with both that and the ability to ask
him (and Meredith, who also knows Lua pretty well) I decided I'd try to migrate
back to AwesomeWM.

I spent probably something like six hours, off and on, getting AwesomeWM set up
to match my current XMonad setup, in addition to recovering some of the
AwesomeWM features from before.  The only thing I couldn't do was make the
AwesomeWM multihead support work the way it does in XMonad.  I mentioned in both
of my previous posts that I really appreciate the interface but the code is a
little beyond me.

Thanks to Rob and Meredith I was able to get
[sharetags](https://github.com/frioux/sharetags), the XMonad-like multihead
support to compile and actually function.  It's a fork of a fork, and I don't
intend to be the long term maintainer, but it works for me and might work for
others.  I spent most of my lunch time getting it to work.

Anyway, it's pretty amazing how much easier things are when friends are happy to
help.  I am confident I could have gotten help from the AwesomeWM community too,
but that would have meant getting on IRC, figuring out how to ask, etc etc.

---

(The following includes affiliate links.)

If you want to try your hand at configuring or using AwesomeWM, you could get
<a target="_blank" href="https://www.amazon.com/gp/product/8590379868/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=8590379868&linkCode=as2&tag=afoolishmanif-20&linkId=5f6949f1db3442a9e5563e419ffca939">Programming in Lua</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=8590379868" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
which is sortav the de facto reference.

Apropos of nothing, I'm just starting the final book in
<a target="_blank" href="https://www.amazon.com/gp/product/0765348780/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0765348780&linkCode=as2&tag=afoolishmanif-20&linkId=cfe93eaf7363bee04db86f9d75abeb3a">Malazan Book of the Fallen</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0765348780" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's pretty great fantasy.
