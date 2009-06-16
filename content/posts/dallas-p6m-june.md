---
aliases: ["/archives/809"]
title: "Dallas.p6m: June"
date: "2009-06-16T01:33:09-05:00"
tags: ["perl", "perl-6-mongers", "perl-mongers", "perl6"]
guid: "http://blog.afoolishmanifesto.com/?p=809"
---
This month's Dallas.p6m was bigger than before! We had my coworkers Geoff, Neil, and Wes, myself, Graham Barr, Jason Switzer (s1n,) Patrick Michaud, and John Dlugosz. We got a domain hooked up (dallas.p6m.org, which doesn't point at anything yet,) discussed interesting stories about rakudo optimization (and often lack thereof,) and sometimes delved into perl5 stuff.

s1n decided to mention that we need to start doing our feature expositions, which is where someone picks a feature in perl 6, does some research, does a talk on it, and then we write some code which is based on it. s1n is going to talk about .WALK, which allows you to look at the Abstract Syntax Tree. I'm pretty excited about that.

Patrick explained to us how it seems that most traits are becoming declarators. That is, in class foo is bar, class is a declarator, and bar is the trait. Of course the migration isn't a big deal because defining a declarator is similar to defining a subroutine.

We also discussed Rakudo's Unicode support. Patrick mentioned that they are looking for a "golf mode" character which will enable unicode characters for things like >= .

We also discussed some of the Rakudo release strategy. It's very similar (for obvious reasons) to Parrot's release strategy. It's exciting that they will continue to release regularly (monthly.)

I can't recall any other details regarding the meeting. I know we talked about more though. I should start taking notes...
