---
title: Code Search for Go
date: 2019-06-03T07:10:45
tags: [ golang, shell, perl ]
guid: 2c0933dc-de2a-47b0-bce7-49b91033debc
---
For a long time I've been disappointed by github's code search functionality and
the disappearance of other tools that used to do the same thing.  This weekend I
came up with a scrappy solution that meets my needs.

<!--more-->

I like to find examples of code to learn both how things work and how libraries
are used in real life.  I suspect that if github allowed very simple regular
expressions or even restricting to exact matches, I'd be able to get what I want
from github.  Sadly I have been unable to find a way to get it to work reliably,
or even well for that matter.  It would be easy to list some of the obvious and
stupid issues with github, but I would rather talk about solutions than problems
in general.

My primary goal with code search is to find real world examples of how to use
some code.  Recently I wanted to see how one would use
[`golang.org/x/tools/go/ast/astutil`'s `Apply`
function](https://godoc.org/golang.org/x/tools/go/ast/astutil#Apply).  My guess
was that an example would help me to understand the docs more quickly than
reading all of the docs twice.

If you pay close attention, you'll know that [godoc.org](https://godoc.org)
actually surfaces the packages that import the package being documented.  If you
go to [the importers page for
astutil](https://godoc.org/golang.org/x/tools/go/ast/astutil?importers) you'll
see about 200 packages listed.  This is a great start, but diving into each one
and trying to find the relevant code is just too much of a hassle, even though
you can then use github code search pretty easily.

To go the rest of the way I wrote a little tool that will:

 1. get the list of importers
 2. generate a dummy main.go that imports *them*
 3. vendors them as dependencies

Given the above you can then use all the power of `git grep`, `ripgrep`, or
whatever fast and powerful local search tool you prefer.  **It's super
effective.**

I won't show [all the
code](https://github.com/frioux/dotfiles/blob/5b1a4d1ce12f878be441850e759d21bc9d356151/bin/go-splore)
here, but I'll dive into some of the interesting bits.

First, this is how I get all of the importers and render them into main.go:

```bash
curl "https://godoc.org/$pkg?importers" |
   grep -F '<tr><td><a href="' |
   perl -pe 's{.*href="/([^"]+)".*}{$1}' |
   grep -v internal |
   head -$count |
   perl -pe 's/(.*)/\t_ "$1"/'
```

The first grep should really be replaced with something smarter doing html
parsing, but this works for now.  The second one converts those lines to package
names.  The third removes internal packages, since I won't be able to import
those (though I think at some point that might be worth fixing, since I just
want examples.)

After the `main.go` is generated I try to vendor all the modules, removing any
that caused errors:

```bash
while true; do
   out=$(go mod vendor 2>&1)
   finished=$?

   echo "$out"

   if [ $finished -ne 0 ]; then
      # go: github.com/dominikh/go-tools@...: parsing go.mod: shortened
      #     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      busted=$(echo "$out" | perl -pe "m/^go: ([^@]+)@[^:]+: .*/; \$_ = qq(\$1\n)")
      if [ -z "$busted" ]; then
         echo "Couldn't figure out what was wrong, giving up"
         exit 2
      fi
      for pkg in $busted; do
         echo "removing $pkg"
         perl -pe'm(\Q'"$pkg"'\E) && undef $_' <main.go | sponge main.go
      done
      continue
   else
      break
   fi
done
```

The second perl one-liner should probably be replaced with a really simple Go
tool that actually parses the code and removes an import (which would use
`astutil` for sure) but this works for now.

---

Using the above tool I was able to generate a little project with 48 vendored
modules.  Now I can do this: (slightly trimmed to fit on screen better)

```bash
$ git grep -P 'astutil\.Apply\b'
vendor/bitbucket.org/dtolpin/infergo/ad/ad.go: astutil.Apply(method,
vendor/github.com/CanDIG/genny/parse/parse.go: astutil.Apply(file,
vendor/github.com/a8m/syncmap/syncmap.go: astutil.Apply(n, func(c *astutil.Cursor) bool {
vendor/github.com/dave/services/progutils/imports.go: astutil.Apply(ih.file, func(c *astutil.Cursor) bool
vendor/github.com/dave/services/progutils/imports.go: astutil.Apply(ih.file, func(c *astutil.Cursor) bool
vendor/github.com/elliotchance/c2go/transpiler/branch.go: astutil.Apply(e, funcTransformBreak, postFunc)
vendor/github.com/elliotchance/c2go/transpiler/switch.go: astutil.Apply(c, funcTransformBreak, nil)
```

**Perfect.**  I can then use vim, armed with both
[vim-go](https://github.com/fatih/vim-go/) and
[Fugitive](https://github.com/tpope/vim-fugitive/) to run the same search above
but follow types, function calls, etc.

Already with this rudimentary tool I've been able to find really good examples
of how to write tools to transform code.  Pretty neat!

---

If you are interested in learning Go, this is my recommendation:

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
