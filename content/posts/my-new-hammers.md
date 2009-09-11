---
aliases: ["/archives/1032"]
title: "My New Hammers"
date: "2009-09-11T05:25:47-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=1032"
---
For the past 6 months or so I've been doing a lot more design and a lot less coding (due to design and a few other things) and it's interesting to me what the results have been.

I remember when I got excited by grokking the concepts behind map and reduce. Don't get me wrong, I am most happy with map and reduce, but to me they are great ways to be terse and clear. (Also fewer intermediate variables etc.) You use them when you build code but you don't make large systems with them (yeah we could be talking about something more macro like MapReduce, but bear with me here.)

After getting comfortable with those I took the next logical step (in my mind) which was to [start doing more functional programming](/archives/341). That was a huge step. When I first started doing that (dispatch tables) it was so that I could react appropriately to a fairly complex search without resorting to large, overly complex and opaque if blocks. I didn't know that what I was doing even had a name, so I just called it a hash of anonymous subroutines. I knew that I didn't come up with it as my boss had used one in the past in C land on a piece of hardware.

Awesome. It was about at this time that a coworker and I (Maestro to those from #moose) wrote the first Priority ordering system. Our first try wasn't bad! I'll explain the problem so that you can understand why we did what we did etc. Imagine that you work at FooBar Corporation. At FBC you go through bugs in a bugtracker and keep programmers on the ball. Unfortunately FBC can't afford just anyone, so they tend to just get people who will start at the top and go down. Well, my company made a tool for FBC which would accurately prioritize the bugs in the tracker. (Note that it's not really a bug tracker, I'm just trying to speak our language.)

For our first tracker my coworker made a special function which would take a single ticket and correlate all related issues (a ticket has many issues, it is not an issue.) We then iterated over the issues and depending on type of issue and the data inside the issue we would divide the priority if the data means good, or multiply if it means bad. Because we wanted a real scale of 1-10 and not 1-∞, we initialized the number with a log and then only multiplied by numbers between 1 and 0. Those are just details. It worked is the point. The code was kind of messy though, and we ended up doing some special casing in the driver for the dispatch table, which is a drag.

Fast forward 8 months. I've gotten much better at OO programming thanks to ExtJS and [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) and a little better at architecture thanks to [Catalyst](http://search.cpan.org/perldoc?Catalyst). I've also gotten much nicer syntax and features for Perl 5 OO from [Moose](http://search.cpan.org/perldoc?Moose), which makes writing and understanding OO Perl 5 code much nicer.

The same coworker and I work together again to write another priority system. This is because our initial try really wasn't reusable, even though we tried for it to be. So this time we decide (after some implementation effort and discussion) to go with a triune system. Two-thirds of this was obvious to us and the third part was inspired by Catalyst. Here are (from memory) our three parts:

- **Prioritizes** Role
  - requires good dispatch table
  - requires bad dispatch table
  - requires Context instantiation method
  - requires apply method which knows how to apply the Context to the given dispatch table
  - provides generic dispatch driver and framework
- consumer of **Prioritizes**
- **Priority::Context** object
  - has priority and related methods
  - has a stash (thanks again catalyst) of random data that comes from the controller for use in the dispatch table methods

Now at first this system wasn't clearly better than what we had before except that it was easily reusable. There aren't a lot of places I could see reusing it, but once it's written well it isn't too unreasonable to start putting it in other projects just to add value... But then something happened that made all of our work worthwhile. Our customer wanted a certain "issue" to yeild a priority with a minimum of five, no matter what (they have a good reason, but the analogy can't handle it, so you have to trust me.) With our original system we'd be forced to do some stuff after the dispatch table had been exhauseted. Now all we did was add a priority\_minimum method to the Context, and then we added a trigger to priority which would ensure that the priority never dipped below priority\_minimum. That alone made the whole design so much more elegant.
