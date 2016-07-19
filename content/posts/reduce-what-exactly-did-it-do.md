---
aliases: ["/archives/413"]
title: "Reduce: what exactly did it do?"
date: "2009-03-07T06:09:25-06:00"
tags: [perl, perl-6, functional-programming]
guid: "http://blog.afoolishmanifesto.com/?p=413"
---
Did you do a reduce and get confused about how it got the final answer? Do you just want to see the computer write out it's work? Check it:

    (1,2,3).reduce({ $^a / $^b })
    RESULT«0.166666666666667»

    (1,2,3).reduce({"($^a / $^b)"})
    RESULT«"((1 / 2) / 3)"»

    (1,2,3).reduce({ $^b / $^a })
    RESULT«1.5»

    (1,2,3).reduce({"($^b / $^a)"})
    RESULT«"((3 / 2) / 1)"»

How cool is that?
