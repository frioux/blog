---
title: Some Code I Deleted
date: 2018-02-20T21:24:41
tags: [ perl, python, oss, email ]
guid: 09ab019b-20a4-40eb-86ca-b4281ce71751
---

I recently deleted a couple non-trivial scripts from my dotfiles and I'm proud
of that.
<!--more-->

As I have been [porting some of my scripts to
go](/posts/benefits-using-golang-adhoc-code-leatherman/) I have tried to be
careful to avoid spending effort on scripts that are not worth porting.  Here
are a couple examples that I recently avoided porting by deleting entirely.

## `live-email`

I try my best to stay in a terminal at all times.  My text editor is vim, I use
a console based slack and irc client, and [my email is handled with
mutt](/tags/email/).  Unfortunately though, my local view of my email can be a
minute behind when I am connected to the internet.  This means that if I need to
reset a password or fill in a token that was emailed to me I need to just wait.

I don't like waiting, so I wrote
[`live-email`](https://github.com/frioux/dotfiles/blob/e0fea7bdfcc4eef1a445df1b351f79e3f6938a89/bin/live-email).

The general idea behind `live-email` is that you want to be able to immediately
list what's in your inbox and then examine the contents.  I figured because it
was basic it would be fast and thus useful.  I did use it a few times, but
sadly due to [a bug in the Python standard
library](https://bugs.python.org/issue11416), it was rendered almost worthless,
because it could only work for one of my two google hosted email addresses.
Furthermore it's not fast because IMAP is generally not fast.

I was looking forward to fixing this while migrating to Go (ignoring the fact
that all of the Go based netrc parsers have the exact same bug as the Python
one.)  I considered how I might improve on the original `live-email` interface,
which was basically one-shot commands that print to standard out.

My idea was to write the emails downloaded via IMAP to a directory and
immediately invoke mutt, pointed at the directory.  Sounds pretty great; it'd be
fast after the initial download and the interface would be pretty much what I'm
used to.

But then I rememered that mutt has built in IMAP support.  Why write code to
sync IMAP, surely with bugs, and no documentation, and no tests, when something
that already works exists?

So I did a little research and [added a parameterized mutt profile to do IMAP
based
email](https://github.com/frioux/dotfiles/commit/2195e92bfa265c59d8002e00c987c4cdbc73f625).
I also [added a little wrapper
script](https://github.com/frioux/dotfiles/commit/2195e92bfa265c59d8002e00c987c4cdbc73f625#diff-000447be3fb9ad62076b89ced5c11f40)
so that I could just run `imap-mutt` to see a live view of my inbox.  *Far
superior*.

## `graph-by-date`

Another tool I made, over half a decade ago at this point, is something that
will [graph data by
date](https://github.com/frioux/dotfiles/blob/22b2dcf399e3397c41fc6be0e03e273a142a9680/bin/graph-by-date).
I don't use it super often but I do use it; here's an example invocation
(against [this blog](https://github.com/frioux/blog)):

``` bash
$ git log --pretty=%ai |
  sort |
  cut -f1-2 -d' ' |
  group-by-date -d |
  graph-by-date -i '%F %T'
```

And the resulting graph:

![Commits per day](/static/img/graph-by-date-01.png)

Now on the one hand, this script works well.  Impressively the underlying graph
library, which pulls in something like three dozen libraries on CPAN, has never
been hard to build and I don't think has ever failed tests.  That's awesome.  On
the other hand it's 70 lines of barely documented, untested Perl.  [Given my
recent flirtations with gnuplot](/posts/gnuplot-super-handy/), I decided to just
deleted it and [document some gnuplot
boilerplate](https://frioux.github.io/notes/posts/gnuplot/).

Using the boilerplate mentioned above I wrote this gnuplot script:

``` gnuplot
#!/usr/bin/gnuplot

reset
set terminal png

set xdata time
set timefmt "%Y-%m-%d"
set format x "%Y"

set xlabel "Time"
set ylabel "Commits"

set title "Commits per Day"
unset key
set grid

plot "./out.csv" using 1:2
```

and this shell script:

``` bash
$ git log --pretty=%ai |
  sort |
  cut -f1-2 -d' ' |
  group-by-date -d -o %F |
  sed 's/,/\t/' > out.csv
$ gnuplot example.plot > foo.png
```

And the resulting graph:

![Commits per day 2](/static/img/graph-by-date-02.png)

Honestly I can't call either graph clearly better, but the latter one uses a
purpose built tool that requires less than a quarter of the lines of code to get
something more or less just as good.

---

[One of my friends is fond of saying "no code is better than no
code"](http://featherweight.io/philosophy/#code).  I tend to agree.  Code is fun
to write, but it's such a liability, especially if you have less time than when
you initially wrote it.  This is why I think so much time can be spent on
automation or documentation; because it helps out future me.  But the most
foolproof way to win is to just not play, given the option.

---

(The following includes affiliate links.)

<a target="_blank" href="https://www.amazon.com/gp/product/020161622X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=020161622X&linkCode=as2&tag=afoolishmanif-20&linkId=dc76fdfd2668e223cab2a5d319283bd5">The Pragmatic Programmer</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=020161622X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is a book that has this kind of philosophy in it.  I've mentioned this book
before.  I can't stress enough that, for people who are early in their
career or even just stuck, this book is a great resource.

It's hard to recommend a programming book that shows how to delete code.  I
would humbly suggest
<a target="_blank" href="https://www.amazon.com/gp/product/1590593766/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1590593766&linkCode=as2&tag=afoolishmanif-20&linkId=87387ff5d03c3cebbc00643523c4bf7e">From Bash to Z Shell</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1590593766" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
if only because shell is so flexible and, when written well, can reduce huge
amounts of code by reusing much more well specified individual pieces.
