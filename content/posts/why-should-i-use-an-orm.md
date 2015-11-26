---
aliases: ["/archives/1031"]
title: "Why should I use an ORM?"
date: "2009-08-27T02:37:39-05:00"
tags: ["object-relational-mapper", "orm"]
guid: "http://blog.afoolishmanifesto.com/?p=1031"
---
At work I tend to play an...Evangelical role? I tend to experiment with various
technologies, get sold on them, and then sell them to coworkers. Examples:
Apache, [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class),
[CGIApp](http://search.cpan.org/perldoc?CGI::Application), and lately
[Catalyst](http://search.cpan.org/perldoc?Catalyst). So I typically find various
ways that the new tool helps make my job easier and tell people about that.
After they believe me, I then educate them about various nuances and whatnot of
the tool. Eventually this will happen with git, when it doesn't suck so much
with Windows.

So recently one of my coworkers asked me why he should use an ORM. I had thought
I'd mostly fought that battle, but he wasn't sold (he is now by far :-) ).
Anyway, here is my answer, open to the world.

### ORM's let you forget SQL

In general this isn't a huge benefit. SQL is pretty simple and remembering it's
syntax isn't so bad. But when you want to do something in like paging in SQL
Server is when an ORM really starts to shine. In general the ORM makes tasks
that you want to do with SQL all the time nice and simple. For example, since we
use Ext at work for most grids, users expect to be able to sort by all columns,
have pagination, etc. That's entirely abstracted away. I rarely think about
those pedestrian things now :-)

### ORM's allow you to predefine the relationships between your tables

This is where a good ORM really shines. Instead of trying to remember seemingly
transient relationships, like how the Shop table joins with the Orders table, we
can document that by writing code using our ORM. After that the relationship is
there forever. It's an entirely new level of code reuse, if you are used to just
vanilla SQL, even if you are reusing it with functions.

### ORM's give you all the features of OOP

This is actually a lot more subtle in my mind. When I first started using a ORM
for real ([DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class)) I kept
looking for DBIC ways to do various things. Typically the answer was: "override
insert" or "override update." As a noob this can be pretty intimidating, but it
really gives great amounts of flexibility. At some point I'll do a post on OOP
revelations I've had (interestingly, mostly I get those from hacking on the code
of my ORM of choice :-),) but for now I'll just leave it at that.

What are the reasons that **you** use an ORM?

**update**: as Stevan notes, I really shouldn't say all in the final bullet
point above. It's more subtle than that. When I say OOP I don't actually mean
the classes that the ORM represents inherit from each other. I just meant that
if I want to do some extra stuff for one class when I store/retrieve it I can
localize those changes.
