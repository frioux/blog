---
title: Making My Notes Easier to Reference
date: 2019-07-15T19:11:04
tags: [ frew-warez ]
guid: 7d00a492-a8f3-400c-b760-7eae981c4ec3
---
I made a `man`-like tool to reference my notes.  It's great.

<!--more-->

I am a big fan of online documentation.  I prefer using `man` to Google,
`perldoc` to search on CPAN, and `go doc` to [godoc.org](https://godoc.org).  A
big part of this is because it "feels" closer to me.  There's no internet to get
in the way; as long as I have the right software installed, I should be able to
see all the reference material.

With that in mind, I recently got annoyed that looking at [my own
notes](https://frioux.github.io/notes/) either meant reading the source in vim,
(which is easy, just open the persistent notes window and type something like
`:Epost markdown`) or look at it in my browser (similarly easy, as the rendered
data is in the sole persistent tab pinned to my browser.)

In any case, I wanted something that would fit into my workflow a little better.
With that in mind I "built" (more like assembled) `note`.  Here's the entire
source, right now:

```bash
#!/bin/sh

pandoc -s -f markdown -t man ~/code/notes/content/posts/$1.md |
   man -l -
```

Running `note markdown` produces a document something like this:

```
Markdown()                                                              Markdown()

   · reference (https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

   Image:

          ![alt text](https://url.png "Logo Title Text 1")

                                 2019-02-27T19:08:30                    Markdown()
```

The header and footer are a little annoying, but as it stands it serves the
purpose and works just fine.  On top of that I added autocompletion; here's the
source of `$HOME/.zsh/fn/_note`:

```zsh
#compdef note

local curcontext="$curcontext" state line
_arguments -C '*:: :->options'

case $state in
  (options)
      local -a notes
      local dir=$HOME/code/notes/content/posts
      notes=($dir/*(N))

      notes=( ${notes#$dir/} )
      notes=( ${notes%.md} )
     _describe -t notes "notes" notes
  ;;
esac
```

And here's what it produces:

```
$ note m«tab»
notes
machine-learning  manual            meta              misc-tech
management        markdown          misc
```

I have to be honest that I cargo culted this from some of my own autocompletion
code that I wrote years ago.  I understand most of it, but the `_arguments` bit
is not at all obvious to me.

---

(The following includes affiliate links.)

If you're interested in diving deeper than is probably wise in writing shell
scripts, you should check out
<a target="_blank" href="https://www.amazon.com/gp/product/1590593766/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1590593766&linkCode=as2&tag=afoolishmanif-20&linkId=6fa6aef84b017be180f16a769c947a10">From Bash to Z Shell</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1590593766" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The book has in depth coverage of all of the major POSIX shells and their
non-POSIX features.

<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=01cde3ac7bf536c84bfff0cc1078bc56">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is one of the most inspiring software engineering books I've ever read.  I
suggest reading it if you use UNIX either at home (Linux, OSX, WSL) or at work.
It can really clarify some of the foundational tools you can use to build your
own tools or extend your environment.
