---
aliases: ["/archives/940"]
title: "July 2009, DFW.p6m"
date: "2009-07-15T03:54:56-05:00"
tags: ["dfw-p6m", "p6m", "perl-6-mongers", "perl6"]
guid: "http://blog.afoolishmanifesto.com/?p=940"
---
Today we had another P6M meeting. There were seven of us despite the fact that three of the regulars were gone at a birthday party, so that was fairly heartening.

As you may already know from the Iron Man Feed, s1n did a talk on [.WALK](http://s1n.dyndns.org/index.php/2009/07/13/walk-this-way/), which is a selector based system for introspecting the methods of a class. One really interesting thing about it is that it (apparently?) isn't actually for dealing with inherited/overridden methods as much as it is for manually tweaking the multiple dispatch that Perl 6 supports.

Just to be clear, multiple dispatch is how Perl 6 chooses what method to run based on the parameters (and invocant) of a method. So you can do something like this:

    class Frew {
       method foo($self: Int $foo, Str $bar) { ... }
       method foo($self: Str $baz) { ... }
    }

And when you call the method it will call the right one based on the params passed to the method. You can even dispatch based on the _value_ of the parameter.

Cool stuff!
