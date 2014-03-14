---
aliases: ["/archives/847"]
title: "YAPC Day 1"
date: "2009-06-23T04:15:59-05:00"
tags: ["perl", "yapc", "yapcna"]
guid: "http://blog.afoolishmanifesto.com/?p=847"
---
Today was the first official day of YAPC. A lot happened! I'll just document what was interesting :-)

First there was an intro. The Pittsburgh guys did a lot of work to get it all to work. Enjoy.

----

The Perl Foundation has had a big year. Mostly with updating p5 and working on p6. The Parrot Foundation (ParF) got created. Big deal.

----

Larry's talk

- He barked at us! And then played many other sound effects.
- Expect the Unexpected
- Paranoia is necessary for success in modern life
- P5 is powerful and extensible
- p6 is more of both, lwall says don't trust it
- He listed various and sundry p5 to p6 differences.
- P6 has great error messages
- And the rest of the talk was tangents based on specific error messages :-)

----

Parrot Foundation

Lots done. [Read This](http://www.linux-mag.com/cache/7373/1.html).

----

Stuck in a room with Schwern.

- Wants to make CPAN stable or add recommended packages. Commercial service.
- PHP does right
  - works out of the box (With a bazillion modules)
  - so typically PHP apps typically work
  - web based configuration
  - Basic OO
- Why PHP sucks
  - or Those who do not learn LISP are doomed to repeat it
  - PHP has 13 sort functions. Nice.
  - no anonymous functions, so that's a drag.
  - PHP is like Lua, arrays are a kind of hash
- Perl 5 + i
  - strict
  - warnings
  - feature ':5.10'
  - MooseX::Declare
  - English
  - Scalar::Util
  - List::Util
  - List::MoreUtils
  - IO::Handle
  - autobox
  - autobox::Core
  - Datetime
  - Time::y2038
- or just: use perl5
- He also related Agile Dating to polyandry... so that was interesting. The ideas was that people do it wrong and of course it's not well defined. Yet people assume a definition of course though.
- Things you know, and things you don't know: can learn
- Things you don't know you don't know: must learn new things to fix this

----

Git is Easy This was a basic overview of git. It would be great to get the slides for this one. But I really shouldn't relate the whole thing here.

----

Hacking on Rakudo

Lots of P6 info. Should be posted on the link below.

[Slides should be here](http://www.pmichaud.com/2009/pres/)

----

KiokuDB

- Object database. Instead of storing tuples, vanilla data.
- KiokuDB is actually a _frontend_ that you can use for other DB's.
- This could be sweet for arbitrary, malleable datastructures
- Backends: BerkeleyDB, DBI, Directory::Transactional, CouchDB, Amazon SimpleDB
- [Slides should be here](http://jrock.us/)

----

CPAN Stats

- 7477 CPAN Pause IDs
- 4460 CPAN authoers who have uploaded to CPAN
- 3017 (obviously) haven't
- CPAN is clearly growing.
- New CPAN authors is consistently increasing.
- 18085 Distributions
- 55409 Distribution Vesions
- 20304 Dists on CPAN Forever
- 112037 Dist Versions on CPAN Forever
- 4054659 Testers Reports
----
Dist::Zilla
  - Sweet to decouple install and build process
  - FakePod to pod conversion, etc. Uses and ini file to configure.This will be really cool stuff for releasing perl modules. Check it out on CPAN. I am **definately** checking this out.
----
Dinner with Steven LittleThis wasn't a talk, it just happened with magic :-) The funny thing was that we talked about KiokuDB the whole time! Also, he didn't start with perl like a lot of us, but started with JavaScript. I feel like a famous person now! We are actually doing very similar stuff as they are at work.
----
Bar with Matthew S. TroutAgain, this just happened. We talked about all kinds of stuff, but the main thing that should be mentioned here is that if you want to be awesome like mst you should read other people's code. He mentioned by name Audrey Tang's code, so yeah.Also mst has a scheme to speed up Moose startup to what it would be if you never used it and to reduce memory usage to the same. Very interesting stuff!
----
It's midnight. The end.
