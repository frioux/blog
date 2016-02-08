---
title: Announcing cgid
date: 2016-02-08T08:42:34
tags: [cgid, rust, ucspi, cgi, http]
guid: "https://blog.afoolishmanifesto.com/posts/announcing-cgid"
---
This post is an announcement of [`cgid`](https://github.com/frioux/cgid).

Over the past week I developed a small UCSPI based single-file CGI server.  The
usage is very simple, due to the nature of the tool.  Here's a quick example of
how I use it:

```
#!/bin/nosh
tcp-socket-listen 127.0.0.1 6000
tcp-socket-accept --no-delay
cgid
www/cgi-bin/my-cgi-script
```

If you don't know anything about UCSPI, this will look like nonsense to you.  I
have a post that I'll publish later this week about UCSPI, so you can wait for
that, or you can search for it and find lots of documents about it already.

---

### Rust

As a side note, `cgid` was written in Rust.  I have a post about Rust itself in
the queue, but I think discussing the "release process" of a binary tool like
`cgid` at release time is sensible.  The procedure for releasing went something
like this:

```
git tag v0.1.0 -m 'Release v0.1.0'

# release to crates.io
cargo package
cargo publish

cargo build --release
# fiddle with github webpage to put binaries on the release
```

This is a joke compared to the spoiling I've had from
[Dist::Zilla](http://dzil.org/), which is what I use when releasing packages to
[CPAN](https://metacpan.org/).  At some point I'd like to automate Rust releases
as much as [Rik](https://rjbs.manxome.org/) has automated releasing to CPAN.

I'll keep my eye out for more things that deserve to be written in Rust, as I
enjoyed the process, but I expect that ideas which deserve to be written in
Rust are few and far between, for me.  It is pretty cool that basically not
knowing Rust, I successfully implemented a tool that doesn't exist anywhere in
less than two weeks.
