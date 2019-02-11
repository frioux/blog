---
title: graphviz describing multi-stage docker builds
date: 2019-02-11T07:27:10
tags: [ tool, graphviz, docker, ziprecruiter ]
guid: f35be163-f9b1-475b-b4c5-abc0d149bc6f
---
I recently decided I should learn to use Graphviz more, as a great tool for
making certain kinds of plots.  Less than a week later a great use case
surfaced.

<!--more-->

## Graphviz

Graphviz is a neat little tool I've only scratched the surface of.  The syntax
is super simple, the program is easy to install, and it works well.  [There are
some basic examples on
wikipedia that might be helpful](https://en.wikipedia.org/wiki/DOT_(graph_description_language)#Syntax).

## Docker Multistage Builds

In something like 2016 or 2017 docker gained the ability to do "multi-stage"
builds.  The obvious use is to have a build stage that has your compiler, and a
final stage that copies binaries directly from the build stage.  That's a simple
case though; ultimately you can express any DAG by having a `FROM` (your base
image) and various `COPY` statements (pulling binaries from other stages.)

I was explaining this to an engineer [at
work](https://www.ziprecruiter.com/hiring/technology) and how we have built
something of a monster with our base image, in part because we have foundational
tooling written in Go that we want in our base image, but we want to also have a
Go compiler image that is... on top of our base image.  I don't want to include
the whole Dockerfile here since it's 115 lines of basically shell.

But I realized that it would be cool to generate a plot of our Dockerfile, if
only to show what we've done.  I pretty quickly whipped up two scripts that
could produce a diagram of our work, one using sed that only supported the
initial FROM, and the next using Perl to include copies.  Here's the output of
the perl script; dashed lines mean COPY, solid lines mean FROM; the bottom
nodes, with the `-image` suffix, are the final images we push.

![Full Diagram](/static/img/base-full.svg)

The following is the code I used to generate the build:

``` bash
perl -pE '
BEGIN { say "digraph {\n" }

our ($from, $to);
if (m/^FROM (.*) AS (.*)$/) {
   $from = $1;
   $to = $2;
   $_ = qq("$from" -> "$to"\n)
} elsif (m/COPY --from=(.*?)\s/) {
   $_ = qq("$1" -> "$to"[style=dashed]\n)
} else {
   undef $_
}

END { say "}" } 
' base/zr-ubuntu-18.04/Dockerfile |
   dot -Tsvg |
   fx
```

(The above uses [my personal `fx` command][fx] for writing stuff to firefox over
a pipe.)

[fx]: https://github.com/frioux/dotfiles/blob/aa0efc2d9ff318d4cb5e29d3cc54d62cfdb112a7/bin/fx

---

I thought this was pretty cool!  I was able to much more clearly describe what
was going on in a multi-stage docker build than I would have been able to with
words, even in person.  And the result of the multi-stage docker image is also
pretty great; in a single Dockerfile we are producing a mostly-vanilla base
image, an image with all the stuff needed to do typical compilation, and a base
image ready to do basic Go compilation.

---

If you ever build any kind of visualization, do yourself a favor and read
<a target="_blank" href="https://www.amazon.com/gp/product/0961392142/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0961392142&linkCode=as2&tag=afoolishmanif-20&linkId=706fb3325d5cd8df33c3e3852006b5df">The Visual Display of Quantitative Information</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0961392142" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's enjoyable, accessible, and beautiful.  I read it a little over ten years
ago and still enjoy flipping through it every now and then.

Apropos of nothing, I am still reading
<a target="_blank" href="https://www.amazon.com/gp/product/0071771328/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0071771328&linkCode=as2&tag=afoolishmanif-20&linkId=5d865703c4ccd968b719374515836e02">Crucial Conversations</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0071771328" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and still finding the insights helpful.  In an earlier part of my life I would
have called what it says, in brief "act like a mature adult" but obviously
that's not very constructive advice.  Highly recommend.
