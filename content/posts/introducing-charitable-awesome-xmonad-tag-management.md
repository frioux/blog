---
title: "Introducing Charitable: XMonad-like Tag Management for AwesomeWM"
date: 2019-06-05T18:52:20
tags: [ awesome, xmonad ]
guid: 1d1823aa-f945-4a9e-9415-68dfce587014
---
I am announcing a library for AwesomeWM that provides XMonad-like tag
management.

<!--more-->

I've written about AwesomeWM [a few](/posts/awesomewm/)
[times](/posts/hello-xmonad-goodbye-awesomewm/) [now](/posts/awesomewm-ii/).
It's an X11 window manager mostly written in Lua and exclusively configured with
Lua.

If you've used a window manager before you are probably familiar with the idea
of "virtual desktops."  The idea there is that you have a handful of windows on
the desktop, and when you switch to a different virtual desktop, you can have a
totally different set of windows shown.  You can then switch back to the first
virtual desktop and see the original windows in their original layout.

When you have multiple monitors this can get a little silly, swapping out all of
the windows on *all* of your monitors.  By default, AwesomeWM provides you a set
of tags (which are like Virtual Desktops) *per monitor*.  This means that you
can swap sets of windows around, but by default they never go from one monitor
to another without a deliberate action to move the windows that way.

XMonad has a different, and initially bewildering, way of working.  Instead of a
set of tags for each screen, it provides a single set of tags that are *shared*
across all screens.  Initially tag 1 will be on the first screen, tag 2 will be
on the second screen, and so on.  For the most part this works as one might
expect, except when you try to switch to a tag on one screen that is already
visible on another.  If tag 1 is shown on screen 1 and tag 2 is shown on screen
2 and you attempt to show tag 2 on screen 1, XMonad will swap tag 1 and tag 2.
This can be startling, but once you are used to it it can be both natural and
incredibly useful.

A common way I use this is that if someone comes to lookat some code and sits
next to me, I'll show the tag that has the code visible on the screen closest to
them.  Instead of some kind of explicit window management commands, I just show
the tag on that screen.  It's weird, but I love it.

In the original post I mentioned that there was a library
([sharetags](https://github.com/lammermann/awesome-configs)) to provide
XMonad-like tag management, but that it needed some love.  It has since been
abandoned ([twice!](https://github.com/XLegion/sharetags)) such that it stopped
working and needed love.  I have updated the code so that it is now back to
ship-shape, with help from Rob Hoelz, Meredith, and the AwesomeWM authors.
Awesome.

Installation is a little weird, since the API reflects the older AwesomeWM APIs.
Check out [the charitable readme](https://github.com/frioux/charitable) for how
to do that.  Hope this helps!

---

(The following includes affiliate links.)

If you want to try your hand at configuring or using AwesomeWM, you could get
<a target="_blank" href="https://www.amazon.com/gp/product/8590379868/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=8590379868&linkCode=as2&tag=afoolishmanif-20&linkId=5f6949f1db3442a9e5563e419ffca939">Programming in Lua</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=8590379868" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
which is sortav the de facto reference.

Apropos of nothing, I'm just starting the final book in
<a target="_blank" href="https://www.amazon.com/gp/product/0765348780/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0765348780&linkCode=as2&tag=afoolishmanif-20&linkId=cfe93eaf7363bee04db86f9d75abeb3a">Malazan Book of the Fallen</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0765348780" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's pretty great fantasy.
