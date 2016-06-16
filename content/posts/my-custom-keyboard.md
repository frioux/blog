---
title: My Custom Keyboard
date: 2016-06-04T00:38:35
tags: ["keyboard", "keycaps", "ergodox"]
guid: "https://blog.afoolishmanifesto.com/posts/my-custom-keyboard"
---
A few years ago [I made my own keyboard](/posts/i-made-my-own-keyboard/),
specifically an ErgoDox.  I've been very pleased with it in general and I have
finally decided to write about it.

<!--more-->

# ErgoDox

[The ErgoDox](http://ergodox.org/) is sortav an open-source cross between the
[Kinesis Advantage](https://www.kinesis-ergo.com/shop/advantage-for-pc-mac/) and
the [Kinesis Freestyle](https://www.kinesis-ergo.com/shop/freestyle2-blue-mac/).
It's two effectively independent halves that have a similar layout to the
Advantage, especially the fact that the keys are in a matrix layout.  If you
don't know what that means, think about the layout of a numpad and how the keys
are directly above each other as opposed to staggered like the rest of the
keyboard.  That's a matrix layout.

The other major feature of the ErgoDox is the thumb clusters.  Instead of
delegating various common keys like Enter and Backspace to pinky fingers, many
keys are pressed by a thumb.  Of course the idea is that the thumb is stronger
and more flexible and thus more able to deal with consistent usage.  I am not a
doctor and can't really evaluate the validity of these claims, but it's been
working for me.

The ErgoDox originally only shipped as a kit, so I ended up soldering all of
the diodes, switches, etc together on a long hot day in my home office with a
Weller soldering iron I borrowed from work.  Of course because I had not done a
lot of soldering or even electrical stuff I first soldered half of the diodes
on backwards and had to reverse them.  That was fun!

## Firmware

My favorite thing about my keyboard is that it runs [my own custom
firmware](https://github.com/frioux/tmk_keyboard).  It has a number of
interesting features, but the coolest one is that when the operator holds
down either `a` or `;` the following keys get remapped:

 * `h` becomes `←`
 * `j` becomes `↓`
 * `k` becomes `↑`
 * `l` becomes `→`
 * `w` becomes `Ctrl + →`
 * `b` becomes `Ctrl + ←`
 * `y` becomes `Ctrl + C`
 * `p` becomes `Ctrl + V`
 * `d` becomes `Ctrl + X`
 * `y` becomes `Ctrl + Z`
 * `x` becomes `Delete`

For those who can't tell, this is basically a very minimal implementation of vi
in the hardware of the keyboard.  I can use this in virtually any context.  The
fact that keys that are not modifiers at all are able to be used in such a
manner is due to the ingenuity of [TMK](https://github.com/tmk).

## Keycaps

When I bought the ErgoDox kit from [MassDrop](https://www.massdrop.com/) I had
the option of either buying blank keycaps in a separate but concurrent drop, or
somehow scrounging up my own keycaps somewhere else.  After a tiny bit of
research I decided to get the blank keycaps.

### Zodiak

I had the idea for this part of my keyboard after having the keyboard for just a
week.  I'd been reading [Homestuck](http://www.mspaintadventures.com/?s=6) which
inspired me to use [the
Zodiak](https://en.wikipedia.org/wiki/Zodiac#Twelve_signs) for the function keys
(F1 through F12.)

After having the idea I emailed [Signature Plastics](http://keycapsdirect.com/),
who make a lot of keycaps, about pricing of some really svelte keys.  Note that
this is three years ago so I expect their prices are different.  (And really the
whole keycap business has exploded so who knows.) Here was their response:

> In our DCS family, the Cherry MX compatible mount is the 4U. Will all 12 of
> the Row 5 keycaps have the same text or different text on them? Pricing
> below is based on each different keycap text. As you will see our pricing is
> volume sensitive, so if you had a few friends that wanted the same keys as
> you, you would be better off going that route.

> * 1 pc    $98.46 each
> * 5 pcs   $20.06 each
> * 10 pcs  $10.26 each
> * 15 pcs  $6.99 each
> * 25 pcs  $4.38 each
> * 50 pcs  $2.43 each

> Please note that our prices do not include shipping costs or new legend fees
> should the text you want not be common text.
> Let me know if you need anything else!

So to be absolutely clear, if I were to get a set all by myself the price would
exceed a thousand dollars, for twelve keys.  I decided to start the process of
setting up a group buy.  I'm sad to say that I can't find the forum where I
initiated that.  I thought it was [GeekHack](https://geekhack.org/) but there's
no post from me before I had the Zodiak keys.

Anyway just a couple of days after I posted on the forum I got this email from
Signature Plastics:

> I have some good news! It appears your set has interested a couple people in
> our company and we have an offer we were wondering if you would consider.
> Signature Plastics would like to mold these keycaps and place them on our
> marketplace. In turn for coming up with the idea (and hopefully helping with
> color selection and legend size) we will offer you a set free of charge...
> What do you think?

Of course I was totally down.  I in fact ordered an extra set myself since I
ended up making two of these keyboards eventually!  Here's a screenshot of the
keycaps from their store page:

![Keycaps](/static/img/keys.png)

For those who don't know, these keys are double-shot, which means each key is
actually two pieces of plastic: an orange piece (the legend,) and a black piece
which contains the legend.  This means that no matter how much I type on them,
the legend won't wear off even after twenty years of usage.  Awesome.

### Stealth

A couple of months after building the keyboard I came to the conclusion that I
needed legends on all of the keys.  I can touch type just fine, but when doing
weird things like pressing hotkeys outside of the context of programming or
writing I need the assistance of a legend.  So I decided to make my own stealth
keycaps.

[You can see the original post on GeekHack
here.](https://geekhack.org/index.php?topic=48200.msg1033054)

Here are the pictures from that thread:

<img src="/static/img/left.jpg" height="800" width="1067" alt=Left />

<img src="/static/img/right.jpg" height="800" width="1067" alt=Right />

Also, if you didn't already, I recommend reading that short thread.  The folks
on GeekHack are super friendly, positive, and supportive.  If only the rest of
the internet could be *half* as awesome.

## Miscellany

The one other little thing I've done to the keyboard is to add small rubber
O-rings underneath each key.  I have cherry blues (which are supposed to click
like an IBM Model-M) but with the O-rings they keyboard is both fairly quiet and
feels more gentle on my hands.  A full depress of a key, though unrequired with
a mechanical switch, is cushioned by the rings.

---

My keyboard is one of the many tools that I use on a day to day basis to get my
job done.  It allows me to feel more efficient and take pride in the tools that
I've built to save myself time and hopefully pain down the road.  I have long
had an unfinished post in my queue about how all craftspersons should build
their own tools, and I think this is a fantastic example of that fine tradition.

Go.  Build.
