---
aliases: ["/archives/1497"]
title: "New Stuff in Data::Dumper::Concise (Devel::Dwarn)"
date: "2011-01-21T01:15:52-06:00"
tags: [frew-warez, cpan, data-dumper-concise, devel-dwarn, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1497"
---
I just released a new [Data::Dumper::Concise](http://search.cpan.org/~frew/Data-Dumper-Concise-2.020/lib/Data/Dumper/Concise.pm). There are new features!

In [Devel::Dwarn](http://search.cpan.org/~frew/Data-Dumper-Concise-2.020/lib/Devel/Dwarn.pm) we have two new features:

## Ddie

This function dies on Dwarn, which has super handy for tests and stuff.

    Ddie {
       frew => 1,
    };

## DwarnF

This is like [Log::Contextual's](http://search.cpan.org/perldoc?Log::Contextual) Dlog methods. So you now can do the following:

    DwarnF { "user: $_[0]\n session: $_[1]" } $user, $session;

## DumperObject

Apparently people needed this. It's part of [Data::Dumper::Concise](http://search.cpan.org/perldoc?Data::Dumper::Concise). Basically you can call DumperObject to get the underlying Data::Dumper object.

Hopefully you guys can use this!
