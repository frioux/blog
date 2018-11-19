---
title: "go generate: barely a framework"
date: 2018-11-19T07:20:59
tags: [ golang ]
guid: fd338831-8f40-4b03-8bf6-144833a1112d
---
I've been leaning on `go generate` at work a lot lately and, when discussing it
with friends, found that they had trouble understanding it.  I figured I'd show
some examples to help.

<!--more-->

A few years ago the go authors [posted about `go
generate`](https://blog.golang.org/generate).  I remember reading it and being
super confused.  I also tried using
[genny](https://github.com/cheekybits/genny), which is `go generate` based
generics, and the (relatively minimal) magic obscured the simplicity of `go
generate`.

So let's be clear: `go generate` is almost literally the following shell script:

```bash
grep '^//go:generate' -r . -h | cut -d ' ' -f2- | bash
```

There's a little more to it, but not much.  It chdir's into each package dir
before running the listed command, and sets a handful of environment variables.
Oh and I guess the order is well defined, but in any case there's not a whole
lot to it.

This isn't a criticism, just to clarify what's going on.  So how can you use
this?  Here are two examples:

At work we have a thing that uses
[go-astilectron](https://github.com/asticode/go-astilectron).  We wanted the
binary that was built to have version metadata (which git commit it was built
from, what time it was built, etc.)  Normally you would do this with `go build
-ldflags "-X 'main.compiledAt=whatever'"`, but it was not clear how, or even if,
the `go-astilectron` build system exposed a way to set flags like that.  One
solution is to use `go generate`.  I made a simple toy example of this [in a
repo](https://github.com/frioux/geneg) in case someone wants to see it and play
with it.

Another thing I made at work was to avoid needing access to our monorepo when
code is actually running.  I needed to find and maintain a list of Dockerfiles.
I could do it by actually walking the dirs at runtime but our monorepo is huge
and if this is supposed to run in production it's not supposed to have access to
git.  Solution: build the list with `go generate`:

```
#!/bin/sh

cd "$(dirname "$0")/../.." || exit

exec >aws/expiration-date/listing_generated.go

echo "package main"
echo ""
echo "var apps = map[string]bool{"
find . -name Dockerfile | sort | cut -b3- | sed 's/^/	"/;s#/Dockerfile$#": true,#'
echo "}"
```

There's one caveat to point out with both of the examples above though: the Go
authors explicitely want users of `go generate` to commit the results of their
work so that clients do not need to run `go generate` etc.  I think that in the
world of OSS this is right and good.  At work instead want to make sure that our
CI system can run `go generate`, which is easier to manage if we simply never
check in generated code.

I hope these much simpler examples make it clear what `go generate` is actually
doing, and what it's not doing.  If anything I feel like the important part of
`go generate` is the explicit blessing of the Go team, rather than the tooling
around the feature.  It sounds silly, but the idea that, at the very least, we
have a standard way to express these things is totally useful.

---

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.

