---
aliases: ["/archives/1454"]
title: "Moo: woohoo!"
date: "2010-11-16T03:10:57-06:00"
tags: [cpan, moo, moose, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1454"
---
[Moo](http://search.cpan.org/perldoc?Moo) was just released! As mst says, Moo is almost, but not quite, two thirds of Moose. Or maybe Minimalistic Object Orientation. The idea behind it is basically to be a very performant, pure Perl mini-[Moose](http://search.cpan.org/perldoc?Moose). It supports lots of Moose features already and even more are on the way. It is not (and never will be) the goal to support all of Moose; in fact the biggest feature Moo will never support is the MOP, though mst is planning on implementing on demand [Class::MOP](http://search.cpan.org/perldoc?Class::MOP) inflation before 1.0.

I'm already working on a module which leverages Moo and it's pretty neat! Sadly I've not had a lot of opportunities to use Moose at work, and on CPAN unless I'm working on something big (like [DBIx::Class::DeploymentHandler](http://search.cpan.org/perldoc?DBIx::Class::DeploymentHandler)) I try to avoid it for compile time speed reasons. So now I get to use [builder](http://search.cpan.org/perldoc?Moose::Manual::Attributes#Default_and_builder_methods) and [handles](http://search.cpan.org/perldoc?Moose::Manual::Delegation) and [method modifiers](http://search.cpan.org/perldoc?Moose::Manual::MethodModifiers) and [roles](http://search.cpan.org/perldoc?Moose::Manual::Roles) and all that other cool Moose stuff that I like.

The really interesting thing about Moo is that if you read some of the (non Moo namespaced) modules in the package you'll find that at it's core Moo is really just a handy code generation library. Don't believe me? Run the test suite with the environment variable SUB\_QUOTE\_DEBUG set and read the handy generated constructors and accessors!

I am hoping to actually go through the codebase for Moo and do something with it. I don't want to promise anything yet, but I have some fun ideas that I may start as early as this week, so stay tuned!
