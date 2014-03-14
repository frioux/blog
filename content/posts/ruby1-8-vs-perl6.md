---
aliases: ["/archives/88"]
title: "Ruby1.8 vs. Perl6"
date: "2009-01-28T05:08:34-06:00"
tags: ["perl", "perl6", "ruby"]
guid: "http://blog.afoolishmanifesto.com/?p=88"
---
First off let me say that I love ruby. Ruby more or less taught me functional programming, which I love. But I do think that perl6 (which you may think is vaporware) is better. I only post about features which I can use right now in rakudo. With that said we shall move onward.

**Update**: the rest of this post, although still correct, is flawed. See comments for the Correct Ruby solution :-)

[Fjord](http://curtis.hawthorne.name/blog/) asked me about how to iterate over two lists at the same time in perl6. I have only had to do this a couple of times and I usually just end up doing a ghetto c-style for loop. In perl6 there is a better way. Check it!

**Perl6:**

    my @a = 1,2,3;
    my @b = 4,5,6;
    for @a Z @b { say "$^a $^b" }

prints:

    1 4
    2 5
    3 6

You may think, "fREW, ruby can do this and it does it exactly the same, if not better!"

**Ruby1.8:**

    a = [1,2,3]
    b = [4,5,6]
    a.zip(b).each { puts "#{x[0]} #{x[1]}" }

Do you notice the subtle difference? In ruby we get \[[1,4],[2,5],[3,6]] vs perl's (1,4,2,5,3,6).

That may not seem like a big deal, but what if you want to iterate over three lists? Here's perl6:

    my @a = 1,2,3;
    my @b = 4,5,6;
    my @c = 7,8,9;
    for @a Z @b Z @c { say "$^a $^b $^c" }

prints:

    1 4 7
    2 5 8
    3 6 9

and Ruby:

    a = [1,2,3]
    b = [4,5,6]
    c = [7,8,9]
    a.zip(b).zip(c).each {
       puts "#{x[0]\[0]} #{x[0]\[1]} #{x[1]}"
    }

That's a drag! Anyway, I once read that there is a way to do this nicely in ruby, but I never could figure it out. I'd say the perl6 solution here is much nicer. Can someone prove me wrong?
