---
aliases: ["/archives/68"]
title: "Why it's OK that perl doesn't really have irb (ipl?)"
date: "2009-01-17T08:57:07-06:00"
tags: ["irb", "perl"]
guid: "http://blog.afoolishmanifesto.com/archives/68"
---
Ok, so irb is totally great for testing out some syntax and general sanity checking, but we don't really have that with perl...or do we?

I am sure that all of the real perl hackers out there know this, but the best perl shell is your real shell. If I wanna do some cool stuff with perl I can do a lot of it directly from my shell with -e (I recommend -E as you can use 'say', which is helpful so that you can avoid quote issues.)

Anyway, since my brain has been so affected by ruby functional programming I have been doing a lot of:

    perl -Mautobox::Core -E '@f = (<*.foo>); @f->foreach(sub { ... })'

So I am making an alias like this:

    alias ipl='perl -Mautobox::Core -E'

Every little keystroke matters in such a case :-)

Anyway, hope this helps at least remind you of the power you already have.
