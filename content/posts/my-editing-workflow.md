---
title: My Editing Workflow
date: 2020-02-03T07:18:26
tags: [ golang, vim, shell, frew-warez ]
guid: 74a76205-de4f-40af-8faa-cb7ba604acfa
---
I recently considered that my day-to-day editing cycle might be of some
interest, so here it is.

<!--more-->

## Vim's quickfix

I have been using [quickfix in anger for many
years](/posts/iterating-over-chunks-of-a-diff-in-vim/).  The gist of it is that
given a simple (but configurable if you absolutely must) format of filenames,
cursor positions, and extra text, you can create a list that vim can help you
easily iterate over.  I often use it with
[fugitive](https://github.com/tpope/vim-fugitive/)'s `:Ggrep` functionality, to
iterate over lines matching a pattern, but it's really easy to wire into
*anything else.*

I have a little command to run all of our Go tests and add any error positions
(usually compilation failures but they could be actual failing tests) to the
quickfix.  It's this easy:

```vim
command! -nargs=* GoTest execute 'cexpr system("go test ' <args> '")'
```

I can run `:GoTest` (or often `:GoTest ./...` to test all packages).

Any lines that look like this will be added to the list:

```
some/file:123:23: busted code here
other/file:312:2: more code here
```

Then you can use `:cnext`, `:cprev` to go forward and back, or `:copen` to show
the window... Or best, use
[unimpaired](https://github.com/tpope/vim-unimpaired/) which maps `[q` and `]q`
to the next or previous item in the quickfix list.

Awesome!  With this I can now bounce back and forth between all these errors.

## minotaur

It's great to be able to iterate over all the changes you need to make, but I
want a faster feedback cycle.  With [my tool
`minotaur`](https://github.com/frioux/leatherman/tree/c2676d25c#minotaur) I can
easily test my code on each save to disk.  The most direct usage is:

```bash
$ minotaur . -- sh -c 'go test ./...'
```

(`go test` is wrapped with shell because `minotaur` passes the changed files to
the script, which `go test` doesn't understand, so we wrap to ignore.)

That works great, and I use that pattern *all the time* to automate little
scripts based on file events.  It works on all three major operating systems
and the interface [is about as simple as it could
get](/posts/the-evolution-of-minotaur/).

## gotest

[I have a thin
wrapper](https://github.com/frioux/dotfiles/blob/9c8b135/bin/gotest) atop
`minotaur` though to get slightly nicer output.  Here's all the code, since it has some neat tricks:

```bash
#!/bin/bash

test() {
   echo ========== $(date) ==========

   # unpack GOTESTARGS back into $@
   eval "$GOTESTARGS"
   set -- "${s[@]}"

   go test "$@"
   echo ==================================================
}

if [ "$1" = "test" ]; then
   shift
   test
else
   # Serialize into string
   GOTESTARGS=$(
      s=("$@")        # temporary array
      set | grep ^s=  # `set` serializes a named array
   )
   export GOTESTARGS

   # reexec the current script; this works from minotaur and
   # ensures the reexec code is working on the first run
   "$0" test
   leatherman minotaur . -- "$0" test
fi
```

This code does a few interesting things:

 * It serializes all arguments into a single string, so they can be passed via env var
 * It deserializes those args back into `$@`
 * It reëxec's itself immediately so the user running it sees output at startup

(I have to mention here that I wouldn't have been able to figure this out
without help from my friend Ingy döt Net.)

I think being able to do this serialize/deserialize trick is really powerful,
since keeping args as a list of tokens is really useful in Unix systems.

## ...but [then I got nervous](/posts/staring-into-the-void/#then-i-got-nervous)

While writing the above I considered:  am I proud of the above because I solved
real problems, or because I solved problems of my own doing?  With a few added,
trivial features in `minotaur` the above code becomes:

```bash
#!/bin/sh

exec minotaur -report -run-at-start -suppress-args \
        . -- go test "$@"
```

And if I get real and just change `minotaur` such that the common case is
default, it's even simpler:

```bash
#!/bin/sh

exec minotaur -report . -- go test "$@"
```

In theory the other interface is as simple as it gets, which means it is
maximally composeable.  That's great, but these extra little features (about 30
more lines of code in total) make working with `minotaur` easier to use...


---

When I rewrote `minotaur` last I was striving for something that would be able
to limit script runs based on which files changed.  I still think that's worth
doing, but in general it's vastly more work than it is to just eat the time.

For many years I've tried to have interfaces that do *exactly one thing.*  A
part of me still thinks that's the best abstraction, but a growing part of me
thinks that if an abstraction does exactly one thing it's not even really an
abstraction, it's a wrapper.

[One of my favorite abstractions of all time is
SQL](/posts/hugo-unix-vim-integration/#unix-style-tools).  If SQL were written
in these terms it would be an inscrutable, inefficient pipeline.  I love being
able to throw together little ad-hoc systems, but if these things are so
off-the-cuff, shouldn't they be easy and fun?  Should they really require knowledge
of how to serialize lists of tokens in bash?

And for things that are not ad-hoc, for things that are built to last, surely
they should be written in a style that is not weird or surprising.  When are
thin wrappers actually appropriate?  I don't know.  I am coming around to the
idea that interfaces should generally have lots of functionality.

---

I recently read <a target="_blank" href="https://www.amazon.com/gp/product/1732102201/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1732102201&linkCode=as2&tag=afoolishmanif-20&linkId=25f61ccbee6f99d0038e283dd551a943">A Philosophy of Software Design</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1732102201" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I really enjoyed it and will likely have a whole blog post about it, but in short
it has informed some of the opinions above.  I suggest reading it.

Totally unrelated but another book I recently read was
<a target="_blank" href="https://www.amazon.com/gp/product/0136554822/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136554822&linkCode=as2&tag=afoolishmanif-20&linkId=9b27a122197fb141065f7276321e4c43">BPF Performance Tools</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136554822" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I intensely enjoyed this book and will *definitely* publish an article about it.
It may not be for everyone, but if you are interested in deep visibility of
software on Linux, this is a great set of tooling to invest in.
