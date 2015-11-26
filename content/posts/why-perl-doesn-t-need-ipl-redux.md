---
aliases: ["/archives/355"]
title: "Why Perl Doesn't Need IPL: redux"
date: "2009-03-03T15:11:52-06:00"
tags: ["develrepl", "ipl", "irb", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=355"
---
Jeff Atwood claims that comments are a [required
ingredient](http://www.codinghorror.com/blog/archives/000538.html) for a blog.
How true! There have been some comments recently on [my original
post](/archives/68) about an interactive perl shell. My post mostly centered
around writing one liners with your regular shell.

Well, **brunov** replied and mentioned **Devel::REPL**, which is excellent! It
has all kinds of great features and really does everything that you would expect
a modern language shell to do. It's a surprising hassle to get to work with
ActiveState perl in windows, but in Linux it works like a charm!

**G** briefly mentioned **perl -de0**, which is alright, if you want something
out of the box, but if given a choice between perl -de0 and perl -E, I'd choose
the latter, as at the very least I get the latest 5.10 features that way. Unless
I missed something you can't even do things on multiple lines in perl -de0. But
I'm sure plenty of people dig it.

Anyway, hope that helps someone!
