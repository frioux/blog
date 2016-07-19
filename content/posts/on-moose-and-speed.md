---
aliases: ["/archives/1124"]
title: "On Moose and Speed"
date: "2009-09-02T02:02:17-05:00"
tags: [frew-warez, moose, object-oriented-programming, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1124"
---
Today the question was asked: "[To Moose or Not to Moose?](http://perlhacks.com/2009/09/moose-or-no-moose.php)" The article is fairly well written, but it seems to me that the comments are not exactly educated. Here is the main one this is in response to:

> I'd try Mouse too. Unless you're doing something funky I'd be surprised if it's more than a 1 letter change to your source code.

First off, here is a quote from the POD:

> Moose is wonderful. Use Moose instead of Mouse.

The author recommends not to use Mouse. That's a big deal to me. Also, enjoy the following quote:

> The original author of this module has mostly stepped down from maintaining Mouse. See
>
> <http://www.nntp.perl.org/group/perl.moose/2009/04/msg653.html>
>
> . If you would like to help maintain this module, please get in touch with us.

He's also given up on it. Moral of the story, don't use it.

### Now for the good news!

Today I started working on [mst](http://www.shadowcat.co.uk/blog/matt-s-trout/)'s plan for MX::Antlers, which is a way to use the actual Moose, with the speed of Mouse, without persistence or anything like that. Great for CGI and whatnot.

Now I'm a little fuzzy on the implementation, but if I understand correctly this will "compile" Moose into a single file. It will not include [Class::MOP](http://search.cpan.org/perldoc?Class::MOP), so you won't be able to use ->meta, but generally for basic modules don't need it, so no big deal really. What I am working on is updating the existing Moose test-suite to disable the tests for ->meta. My current plan is to use an environment variable, but whatever I do it will be a function so that we can change it to some other methodology if we need to.

So! Get excited! Depending on the code we may be able to abstract it to apply to other heavy frameworks (Catalyst?) to make them sufficiently fast as well. Once I have some basic stuff in the public repo (hopefully a couple before Friday) I'll put up a post or two explaining how to get the work done, and then we can parallelize the work. Who's with me?
