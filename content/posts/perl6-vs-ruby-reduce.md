---
aliases: ["/archives/70"]
title: "Perl6 vs Ruby: reduce"
date: "2009-01-21T06:54:56-06:00"
tags: [functional-programming, perl-6, perl, ruby]
guid: "http://blog.afoolishmanifesto.com/archives/70"
---
Ruby:

    sum = (1..10).reduce {|x,y| x+y}

or maybe

    sum = (1..10).reduce {:+}

Perl6:

    my $sum = [+] 1..10;

That has got to be some of the sexiest perl syntax ever!
