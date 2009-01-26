---
aliases: ["/archives/83"]
title: "Join = reduce"
date: "2009-01-26T07:09:20-06:00"
tags: ["functional-programming", "perl6"]
guid: "http://blog.afoolishmanifesto.com/archives/83"
---
I was driving today and I realized that join is just a form of reduce. Here's some perl6:

    sub join(Str $string, @array) {
       @array.reduce: { $^a ~ $string ~ $^b }
    }

It works exactly as expected.
