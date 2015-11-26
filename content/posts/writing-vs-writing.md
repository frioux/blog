---
aliases: ["/archives/1202"]
title: "Writing vs. Writing"
date: "2009-10-29T04:12:21-05:00"
tags: ["blog", "code", "cpan", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1202"
---
I enjoy updating this blog. Part of it is that I like writing, and part of it is
that I kinda feel famous with all these great coders reading the words that I
write. But I like programming better. That is why lately I've been posting less
and [coding[
[more](http://github.com/frioux).]()](http://search.cpan.org/~frew/)

In posting modules to CPAN I've learned a lot of different things. First off,
testing is easy. But before you test you have to set up your test environment.
It's not really hard, mostly it's just a hassle. The obvious good thing about
testing is that when I add features (my coworker asked for one for
[CGI::Application::Plugin::DBIx::Class](http://search.cpan.org/perldoc?CGI::Application::Plugin::DBIx::Class)
just today) I know with pretty good certainty that I didn't mess anything up,
even if it's a trivial change.

One problem I **do** have is that I consistently forget to add dependencies. The
only think I can think to do is to have a vanilla perl install that I always
test the release on. The problem with that though is that it is time consuming.
If anyone has tips on how to deal with that let me know.

Another thing that I've learned is that
[Dist::Zilla](http://search.cpan.org/perldoc?Dist::Zilla) is an invaluable tool
for building releases. I love that it sets my version number, fills in my POD,
sets up all my metadata, and even uploads my module to CPAN for me. It lets me
spend less time learning about my build tool and more coding.
