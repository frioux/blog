---
aliases: ["/archives/1063"]
title: "Dallas.p6m: August 2009"
date: "2009-08-12T03:34:21-05:00"
tags: [perl, perl-6, dallas]
guid: "http://blog.afoolishmanifesto.com/?p=1063"
---
So we had another Dallas.p6m tonight. It was fairly laid back compared to some other ones, but it was still a lot of fun.

I did a "talk" on the Perl 6 object model, which I didn't prepare enough for, so it was mostly me asking Patrick some basic questions about stuff I could relate to Moose. So here is the skinny on that stuff:

has in Moose is a method, that ties a string to some attributes.

has in Perl 6 is actually the OO version of my. So you do the following:

    # generate method getters and setters and $!foo
    has $.foo;
    # generate private variable for object
    has $!bar;

And then because Perl 6 has changed to some extent, instead of doing $.bar isa Int, you'd do the following:

    has Int $.foo;

Also, as far as we could discover in our short meeting, instead of before, after, and around, in Perl 6 you'd use wrap. I \*think\* it would work like this, but I'm not sure:

    class Foo extends Bar {
       $.method_from_bar.wrap({
          # codez
       });
    };

After that we had a heated discussion about whether using wrap was monkey patching/violating the Liskov substitution rule. I stand with the majority that it is not.

We also did some initial planning for a monthly hackathon, which is exciting. The idea is to have the hackathon two weeks after the meeting, so we can kinda plan ahead. We'll see how well that goes down.

If you live in the DFW area, you should get in touch and visit!
