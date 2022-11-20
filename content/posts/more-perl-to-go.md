---
title: More Perl to Go Conversions
date: 2022-11-19T22:53:19
tags: [ "golang", "perl", "frew-warez" ]
guid: f81f26e7-ef3e-4dea-b55e-a626284ed5db
---
As time goes by I have less and less patience for ecosystems that demand my
time.  Typically this is in the form of breaking changes in either a language
or the modules that language uses.  This morning I ported a relatively simple
tool from Perl to Go to escape this kind of tax.

<!--more-->

[A few years ago I built a tool to automatically bust the CloudFlare
cache](/posts/busting-cloudflare-cache/) for posts that have changed.  Just
over a year ago I [got around to setting up github
actions](https://github.com/frioux/blog/commit/5d12ad34b9c92017e46146a146c60d31ddef176c)
so that any push to my blog repository would automatically deploy changes.

I really appreciate being able to simply accept PRs to fix typos and that fix
get deployed without me having to do anything.  Generally the system is much
more reliable than depending on whatever software and libraries I have installed
on my laptop.  Sadly, some time last week I got a failed build with this error:

```
purging https://blog.afoolishmanifesto.com/resume.pdf
599 Internal Exception
IO::Socket::SSL 1.42 must be installed for https support
Net::SSLeay 1.49 must be installed for https support

make: *** [Makefile:19: push] Error 1
Error: Process completed with exit code 2.
```

I know how to fix this, I just need to install a couple Perl modules.  But for
years now my line for Perl use has been "only use core modules."  Not because
they are especially good, but because I don't want to deal with any instability
within the ecosystem.  This was especially annoying to me because this code
doesn't directly use any non-core libraries; the TLS libraries get pulled in at
runtime as a fun surprise.

I spent about 40 minutes this morning [migrating the code from Perl to
Go.](https://github.com/frioux/blog/commit/89659c5ee31c9e4deac6793d0448528ef5278a65)
This is a simple tool so compilation is fast.  I run it with `go run
./bin/busted-urls`.  I didn't especially want to port this to Go, but I am
grateful that Go has solid JSON and HTTP (including TLS) libraries. so that
I can make this kind of tool without much effort or care.

---

I'm interested in hearing any other porting stories!  Tell me about your migrations on mastodon
at [@frew@mastodon.social](https://mastodon.social/@frew)
