---
aliases: ["/archives/1485"]
title: "Why I Won't Use Your Programming Langauge"
date: "2010-12-14T04:31:17-06:00"
tags: [frew-warez, cpan, perl, programming-languages]
guid: "http://blog.afoolishmanifesto.com/?p=1485"
---
I keep running into people at parties or whatnot who mock me for using Perl and
claim that "only .NET is a real programming language" (sic.) Most of the time
they are trolling, but I figure I might as well make measurements for what I
think of as a reasonably useful programming language. I'll break this up into
two groups of things. The first group is stuff that I want when programming at
home for fun. The second is stuff that must be there if I am to use the language
seriously at work; the second group contains the first group.

Note that if you have some neat thing to play with for a weekend, that's fine. I
had a good time playing with Factor but I don't know of it meets all of these
requirements. I wouldn't do a big project with it or use it at work though.

# Stuff Needed For the Language To Be Reasonably Fun

## Anonymous Subroutines

Functions and objects are not the only abstractions that I need to get stuff
done. If your langauge doesn't have anonymous subroutines (anonymous classes
**do not** count) I don't want to hear about your language.

## Dynamic Scope

[Dynamic Scope](http://en.wikipedia.org/wiki/Dynamic_scope) is a powerful tool.
You shouldn't use it unless you really need it, but there are such times.

## Thriving OSS Community

Are there open source, community maintained Web Frameworks, ORM's, and other
commonly needed tools in your language? If such tools must be bought or only
come from a single source (that is, a very small community) then it isn't good
enough.

## Extension Distribution Framework

If I cannot run a command (or maybe some GUI tool) and install new libraries (or
packages or whatever they are called in your language) and their dependencies
you are asking too much of me as a developer. If you don't respect my time I
don't respect your langauge. Get out.

## Strong backwards compatibility

Does your language try hard to maintain backwards compatibility? If your
langauge breaks my code (no matter how bad the code is) every two or three years
you (again) don't respect my time as a developer.

# Stuff Needed For the Language To Be Useful At Work

## A Good ORM

Your ORM should support the big databases out there: MySQL, PostgreSQL, Oracle,
SQL Server, and SQLite (for development.) I should be able to deploy the
database from the ORM and also generate ORM files from the database. I should be
able to automatically deploy serious stuff like foreign key constraints and
unique constraints. As much as possible should be able to be overridden. I
should be able to add some extension to a given table to automatically populate
certain columns or whatever. I should also be able to make predefined searches
that I can extend without going crazy.

## A Good Web Framework

This isn't hard. I use [a pretty powerful web
framework](http://search.cpan.org/perldoc?Catalyst), but you don't even need all
of that. I need reasonably flexible dispatching, a well-defined "flow" (so I can
hook in at different levels and do validation or whatever else,) sensible MVC
helpers, and a development server so I don't need to install a server on my
laptop get work done.

There's more depending on what you do. For example if you do a lot of event
driven programming you need a solid framework (or at least language level
programming.)

# Obvious Stuff

## Cross Platform

I can't think of a lot of languages that violate this, but I might as well put
it down.

## Garbage Collection

My time is worth more than the computer's. I don't want to waste time with
memory allocation.

What languages (aside from Perl and Javascript) support these features that you
use?
