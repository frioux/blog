---
title: Concurrency and Asyncrony in Perl
date: 2014-07-29T10:34:10
tags: ["perl", "async", "io-async", "IO::Async", "POE", "AnyEvent", "AE"]
guid: "https://blog.afoolishmanifesto.com/posts/concurrency-and-async-in-perl"
---
Lately I've been in situations where I need to write some event driven, parallel
code.  Most people call that "async" and I'll stick to that for now.

What I've been doing is writing a little TCP service that can accept any number
of clients at the same time (though typically only one) and interact with the
clients in a single process and with no multithreading.  As surely many have
remakred before, this is to some extent the future of computing.  I vaguely
mentioned [Node.JS] in [one of my previous posts] as it has become [super
popular] for doing this kind of stuff "from the start."

That's another post though.  For now, I'd like to discuss the various ways the
major async frameworks in perl do concurrency.  For communication purposes, I'm
going to use (what I think is) CSP terminology that I've gathered over time from
playing with Go stuff.  So basically that means:

Parallelism is multiple things happening at once.

Concurrency is things communicating to each other.

As an aside, these two things are actually orthogonal and treating them as such
can yield a much better understanding of a given system.

With that aside, what this post is about is *concurrency*.  At this point I've
used two of the three major Perl async frameworks professionally.  I'd not
consider myself any kind of expert, but I think that I can make some reasonable
comparisons.

An aside about the code snippets; I've shown and discussed the code included in
this post with Rocco Caputo, Paul Evans, Marc Lehmann, Peter Rabbitson, and
Sawyer X.  They all gave feedback that ended up with the code included here.  I
did write it myself and there is some advice that I did not take because I felt
that it would diminish what I'm trying to communicate here, so I take fault for
any mistakes included within.

## AnyEvent

The framework I first did async work in perl with was AnyEvent.  (Well actually
I did a tiny bit of POE in the distant past of 2006, but I didn't understand
what I was doing so we'll ignore that.)  AnyEvent is really easy to jump into
and tends to work fairly well.  The fundamental way that AnyEvent works is just
with normal perl variables and what are called `condvars` which are basically a
weirdly named Future, or Promise.

The basic goal of the code in this post is to create an echo server that
also periodically prints ping to the connected client.  While this may be
obviously a toy, it is enough to demonstrate the various ways to connect
