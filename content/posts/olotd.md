---
aliases: ["/archives/85"]
title: "OLOTD"
date: "2009-01-27T19:34:35-06:00"
tags: ["one-liner-of-the-day"]
guid: "http://blog.afoolishmanifesto.com/archives/85"
---
perl5

    join(' ', map { ucfirst } split(/s+/, lc($words)));

perl6

    $words.lc.split(/s+/).map({ ucfirst }).join(' ')

This really should be a builtin. It is in perl6 and (I think) ruby.

\*Update\*: So I was on the perl6 mailing list and this happened:

    19:42 <@TimToady> std: $a ==>>= $b
    19:42 < p6eval> std 25080: OUTPUT«00:05 84m␤»
    19:42 <@TimToady> oops
    19:42 < frew> nice
    19:43 < pugs_svn> r25081 | lwall++ | [STD] catch ==>>=

p6eval is a bot that you can check your perl6 code on. pugs\_svn says when someone checks into the source repository. It was then that I realize that TimToady was Larry Wall.

He has actually spoken with me numerous times, which is pretty awesome. A lot of times I would ask a question and he would answer and add extra details. So that's pretty great. I asked him a lot of questions about various things and he kindly answered. One of the things he told me was a shorter implementation of the code above in perl5:

    $words =~ s/(S+)/uL$1/g

How many of you have spoken to your language's benevolent dictator?
