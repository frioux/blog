---
aliases: ["/archives/1329"]
title: "New DBIx::Class::Journal!"
date: "2010-05-12T04:01:35-05:00"
tags: [frew-warez, cpan, dbix-class, dbix-class-journal, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1329"
---
I'm proud to announce a new version of DBIx::Class::Journal after almost three years of different people working on different parts!

It's certainly not complete. The main issues for me are:

1. It only versions tables with single column PK's
2. It has no simple way to have related data in the journal

The former is a SMOP, the latter, on the other hand, is a very serious architectural issue which I don't think can even safely be solved. It \*might\* be as simple as just replicating all of the relationships in the original result and then adding in another column to the relationship which points to a version of that result. Or it might not. I need to consider it and look at things, but I think it can be done.

Honestly, if I had all the time in the world, I'd rewrite ::Journal from the ground up and make it a lot more malleable. Unfortunately I don't have all the time in the world and personally I don't have much use for it. Parts of my job do, but they only pay so much for features :-)

Anyway, enjoy it! It should be pretty solid. Just make sure you read the limitations before use.
