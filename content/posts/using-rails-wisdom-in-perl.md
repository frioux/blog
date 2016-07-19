---
aliases: ["/archives/64"]
title: "Using \"Rails\" wisdom in Perl"
date: "2009-01-10T20:36:33-06:00"
tags: [perl, rails, ruby, mitsi]
guid: "http://blog.afoolishmanifesto.com/archives/64"
---
Ok so that may be a sensational title, but really the point is this: Rails
people talk a lot, perl people just get stuff done. I am ok with getting stuff
done, but I don't know how perl people do it because they don't talk about it as
much.

Anyway, with that in mind my company (MTSI) is starting a new project next week.
I get to be a big part of the planning and I am pretty excited. Normally our
code is just perl scripts that use SQL and string interpolation or template
toolkit. The use of TT is a big, fairly recent step forward. I recently turned a
utilities file into a full on module, so that's good too.

But really we aren't where we should be. The state of the art with web
applications has moved forward significantly in the past few years (and I think
a lot of that is because of some smart people that use rails,) and there is no
reason that we cannot use this knowledge in perl.

I originally looked at Catalyst, but decided against it because my boss thought
it was a pretty big commitment for something none of us have experience with. So
I decided to look at CGI::Application (which we used for
[TOME](http://code.google.com/p/ptome).)

Before I get into that I just want to say that we have decided on DBIx::Class as
an ORM. I looked at Rose::DB::Object but DBIx::Class just seems to have more
polish and support. Plus they support SQL Server which we use (no comment.)
DBIx::Class is fairly easy to use and next time I'm at work I'll post a snippet
of how to do various things we want to do.

The main reasons I went with CGI::Application are these:

1. It's a fairly small framework, so easy to understand what's happening.
2. It will give us a better, more solid organization of our code.
3. It will let us switch to mod\_perl (from IIS...no comment.)

The biggest issue with CGI::Application that I initially had was this: how can I
have multiple controllers? In TOME we only had one controller but I think we
should have had at least two, maybe three. Anyway, after some research I found
this: [Re: Re: Re: Why
CGI::Application?](http://www.perlmonks.org/index.pl?node_id=321064). Basically
he does what I thought that you are supposed to do, except with some excellent
OO goodness.

I was thinking that you would just have like, 5 CGI::Applications and those
would be the controllers. Well, instead of that you have 5 CGI::Applications
that subclass a main one which has basic functions (logging in etc) that all the
other ones need. If a controller gets too big you either split it into a couple
or you subclass it for a couple related controllers.

Hopefully it goes as well in my mind as it should :-)
