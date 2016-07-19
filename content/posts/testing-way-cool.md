---
aliases: ["/archives/600"]
title: "Testing: Way Cool!"
date: "2009-04-30T02:58:59-05:00"
tags: [frew-warez, mitsi, perl, testing, perl-critic, webcritic]
guid: "http://blog.afoolishmanifesto.com/?p=600"
---
When I was writing WebCritic I decided that the code was small and simple enough
that it would be a great candidate for me to figure out how to set up automated
testing for the whole stack (except for the javascript.) This is something that
I've wanted to do at work for a long time but I feel bad spending time figuring
out stuff like this on the customer's dollar. I already had [Perl Testing: A
Developer's
Notebook](http://www.amazon.com/gp/product/0596100922?ie=UTF8&tag=afooman-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596100922)![](http://www.assoc-amazon.com/e/ir?t=afooman-20&l=as2&o=1&a=0596100922)
and I figured I'd use it to get a start. Very helpful!

Perl has some great testing modules out there, but the problem is finding which
ones. We all know about Test::Simple, Test::More, and Test::Most. There are tons
more though that can really help with testing. The book helped me find a lot of
them.

But anyway, I decided that before I release my code, because I was doing some OO
work, I might as well use Moose to do the OO parts (more on that later.) When I
was doing the porting it was very helpful to have the tests there to tell me if
I had done things correctly. This is one of the main reasons I have heard people
use for creating a test suite. It is not necessarily that your code will
magically be better, but that you can change code with abandon and know if you
introduce new bugs. Of course this implies good test coverage, but I am not
really at that point yet. I am just to the point where I have decided that
testing is awesome!
