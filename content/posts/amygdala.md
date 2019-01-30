---
title: Amygdala
date: 2019-02-05T07:12:26
tags: [ golang, perl, amygdala ]
guid: bca651f1-8ba4-4f18-9efe-b4b869f7bedc
---
This past weekend I started re-creating a tool I used to have, using new tools,
techniques, and infrastructure.  The tool allows, at least, adding to my own
todo list via SMS.  It's working great!

<!--more-->

From January of 2016 till October of 2017 I had an app that let me manipulate my
todo list, and all of my notes for that matter, over SMS.  For the most part it
worked ok, but Dropbox deprecated their API and the module I was using for
Dropbox was overly abstract and couldn't be easily refactored for the new
version.

About the same time this happened [I redid my notes
entirely](/posts/a-love-letter-to-plain-text/#notes) and mostly removed the need
for code to interact with the notes, because I could open the files on Dropbox
directly.  I was recently inspired to recreate the most basic functionality
(adding to the todo list) and found that it is much easier and more reliable now
both because of my new notes system and because I'm willing to just implement
what I need instead of using modules from the internet.

The old system would [download a single large, nested list](https://github.com/frioux/Lizard-Brain/blob/master/tasks/note#L28),
[insert an item](https://github.com/frioux/Lizard-Brain/blob/master/tasks/note#L37), and
[reupload that same file](https://github.com/frioux/Lizard-Brain/blob/master/tasks/note#L60).  I was
able to make my code reliable, but the race conditions that were caused by
modifying the file via the API and my laptop around the same time were really
annoying.

With the new system there are [as many files as I
want](https://github.com/frioux/notes-example/tree/master/content/posts), and
any file with the `inbox` tag is treated like part of my todo list.  The upshot
of this is that instead of read/modify/upload, I just unconditionally write new
files, and allow Dropbox to do (incredibly unlikely) duplication handling.

On top of a more flexible storage format, my viewpoint has changed in a few
ways.  Most practically, I was writing Perl and using a module on CPAN.  The
module in question had become over abstract, such that updating it to support
the new Dropbox interface was a very difficult task.

I'm writing Go now, but I am also more wary of public modules.  [I wrote my own
package to handle dropbox
interaction.](https://github.com/frioux/amygdala/blob/ee0a6efc409d75b15c444ad1d8489bca668c3c87/internal/dropbox/dropbox.go)
It contains a single exported function that takes a handful of arguments.  If I
need to add support for another Dropbox endpoint, I'll just do that.

Another major viewpoint change of mine is a willingness to relax certain
dogmatic constraints.  The original Lizard Brain was comprised of [standalone
unix tools that *only* spoke over standard input, standard out, and standard
error](https://github.com/frioux/Lizard-Brain/tree/master/tasks).  While this
meant I could write those little programs in whatever language I wanted, it also
meant that I had to have a complicated dispatcher that would run *all* of those
programs to find out which one was supposed to handle the input in question.

Amygdala is a [straightforward HTTP
server](https://github.com/frioux/amygdala/blob/ee0a6efc409d75b15c444ad1d8489bca668c3c87/cmd/amygdala/main.go#L48),
with a [CLI tool
(brain-stem)](https://github.com/frioux/amygdala/blob/ee0a6efc409d75b15c444ad1d8489bca668c3c87/cmd/brain-stem/main.go)
that I can use to experiment with the relevant functionality.  While Amygdala is
unlikely to ever have the flexible inputs Lizard Brain had (Twitter, SMS, CLI) I
admit that I basically only ever used one of the inputs anyway and it didn't
justify the extreme decoupling.

---

Since starting this post I have improved the system in various obvious ways and
have added functionality to extract random items from [one of my long
lists](https://frioux.github.io/notes/posts/inspiration/).  I'll likely do more
similar commands, but the structure is coming together.  The only functionality
that's missing is a way to schedule an event in the future ("remind me of $x in
$y minutes".)  I can't figure out how to do that well without a full VM, which
isn't worth it, even though Google's reminder service is often late or drops
reminders.

---

Overall it's a fun project and works much more reliably than the original did
for just a few reasons (simpler implementation, better underlying data model,
and statically typed code.)  I want to write at least some basic unit tests, if
only to gate my deployments on CI/CD, but that's pretty easy.

---

<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=01cde3ac7bf536c84bfff0cc1078bc56">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is one of the most inspiring software engineering books I've ever read.  I
suggest reading it if you use UNIX either at home (Linux, OSX, WSL) or at work.
It can really clarify some of the foundational tools you can use to build your
own tools or extend your environment.

<a target="_blank" href="https://www.amazon.com/gp/product/159327890X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=159327890X&linkCode=as2&tag=afoolishmanif-20&linkId=c2992c1f31293d69ce3789aea236e799">Impractical Python Projects</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=159327890X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
might be inspiring to you, if only to get your hands dirty writing code that's
not just a small cog in a big system at work.  You could obviously write the
programs it discusses in any language.
