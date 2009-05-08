---
aliases: ["/archives/669"]
title: "Making MSDOS a little bit nicer"
date: "2009-05-08T01:01:10-05:00"
tags: ["perl", "testing", "windows"]
guid: "http://blog.afoolishmanifesto.com/?p=669"
---
I work at a [Microsoft Company](http://www.mitsi.com/) more or less. We use SQL Server, IIS (moving to Apache...), and various flavors of Windows for all of our machines. I haven't had the cojones to install Ubunutu on my desktop yet, so I am stuck with cygwin and friends. But the perl that runs my server is **not** in cygwin. That means that if I want to do valid testing I have to do it with the regular perl. I've tried running **prove** from the cygwin commandline, (ie, /cygdrive/c/usr/bin/perl/prove,) but it just hangs. So I just have to suck it up and run prove from cmd.

The color highlighting doesn't work (or at least I couldn't get it to) so with code that sometimes throws a lot of warnings (that's intentional, I am testing croaks often) I see way too much noise to follow what's going on. Redirection to the rescue! Instead of just running **prove**, I can run

    prove 2> foo

instead and it redirects all of the warnings to the file foo. Although it's obvious, it makes running tests that much easier, and I think running tests should really be the path of least resistance. So thank you DOS makers, for implementing STDERR redirection, I didn't think you'd have done that, but you did.
