---
aliases: ["/archives/78"]
title: "You too can help implement the language of the future!"
date: "2009-01-24T19:16:17-06:00"
tags: [perl, perl-6]
guid: "http://blog.afoolishmanifesto.com/?p=78"
---
I just committed my first change to the perl6 spectest suite. It's exciting
because perl6 has all of the great functional chaining that I love about ruby,
but it also has killer awesome features that extremely few modern languages have
(AST based macros anyone?) But it's been in active development for almost four
years now and people have talked about it for almost nine! So what do you do
when you see these amazing things that are just outside of our reach? Jump in
and help!

Helping with perl6, especially the test suite, is not hard at all. The first
thing you will want to do is find something to do. One good place to look is
[here](http://svn.pugscode.org/pugs/t/TASKS). But that's really not all. If you
read through the spec files (a really great way to learn perl6 if you learn by
examples) and look at the [generated pod
files](http://svn.pugscode.org/pugs/docs/Perl6/Spec/) you will surely find some
discrepancies in the tests.

Once you find something you are confident that you can do join the irc channel
(irc.freenode.net/#perl6) and ask for a commit bit for pugs. Then you'll just
download the source,

svn co http://_username_@svn.pugscode.org/pugs/

make changes (probably in t/spec), and check them in.

And now you have helped implement the spec for perl6!
