---
title: unproductive
date: 2018-07-12T07:47:08
tags: [ frew-warez, golang, perl, productivity ]
guid: 35689003-1493-45d7-9cf0-0cbfcfb0671b
---

I've always wanted to carefully measure my activity on the computer and recently
[built a tool called `unproductive`](https://github.com/frioux/unproductive) to
make it happen.

<!--more-->

One of the things I value most in my life is my time.  There's very little you
can do to get more time, other than work less, drive less, or sleep less.  I am
interested in how I can more carefully use my time and to do that it helps to
measure how I spend my time.

I have always thought it'd be interesting to actually know what I spend my time
doing on the computer, since that's the easiest to measure.  On a lark I decided
I could pretty simply do this by simply logging the title of the currently
selected window and then building reports around that.

## `unproductive`

The suite of tools I built starts with the recorder, `unproductive`.  The tool
simply writes tab separated lines of the seconds since the epoch, the wifi
access point you are connected to, whether a vpn is running, and the window
title.  Here's an example of what I just recorded:

```
1531371241      Station false   work:zsh:/home/frew/Dropbox/notes
1531371242      Station false   work:zsh:/home/frew/Dropbox/notes
1531371243      Station false   unproductive/bin at master · frioux/unproductive - Mozilla Firefox
1531371244      Station false   vim:/home/frew/.vvar/sessions/wnotes
1531371245      Station false   vim:/home/frew/.vvar/sessions/blog
1531371246      Station false   work:zsh:/home/frew/Dropbox/notes
```

The above works on Linux with a few assumptions: you'll be using `openvpn` as
your vpn software and (much less likely) you'll be using `i3lock` as your
screensaver (it doesn't write anything if the screensaver is running.)

My friend [Shannon Barrett](http://www.numbersforletters.com/) even wrote and
submitted a compatible tool in Powershell, so you can record on windows.  I'm
hoping an enterprising OSX dev will be able to make an Applescript version to
round out the support of this part.

## `filter`

The next step is to filter the lines.  This lets you filter based on time,
access point, and vpn state.  So if I wanted to look into my personal usage when
working from home I might do:

```bash
$ filter --vpn --ssid Station --time 7d < ~/activity-log.txt
````

## `retitle`

The next tool, which I'm really proud of as a model but have some reservations
about, is called `retitle`.  It takes the raw string written by `unproductive`
and converts it to a simple JSON list.  At the most basic you might create broad
categorizations like "Work" or "OSS" or "Chat".  You can get far more fine
grained though creating nested heirarchies to allow you to report on chat at
work down to the slack channel, for instance.

Fundamentally for this to work you have to create a heirarchy.  Heirarchies are
easy to understand but tend to be brittle over time.  I am interested in
migrating this to a more flat "tag-like" structure, but don't have ideas on how
that might be done yet.

`retitle` is intended to be implemented by each user basically, as I don't see a
one-size-fits all solution to be that useful.

## `report`

Finally, `report` consumes the JSON lists from `retitle`.  This was an
interesting one for me because I wrote it in Go for the sole reason that it was
easier for me to think about in Go rather than Perl, which was a first.  If I
were to convert `retitle` to be a tag based system it would have to be informed
by a useful, related tag based `report`.  `report` is inspired by the venerable
`du`.  Here's a quick usage of it from the past few minutes:

```bash
$ <~/activity-log.txt filter --time 1h |                                                         10:18:31 pm
 retitle |
 report -show-percents -show-durations |
 sort -n

14      (6%)    14s     Fun
14      (6%)    14s     Fun/Project
14      (6%)    14s     Fun/Project/Unproductive
35      (16%)   35s     Strategy
35      (16%)   35s     Strategy/Notes
35      (16%)   35s     Strategy/Notes/Writing
48      (22%)   48s     Firefox
120     (55%)   2m0s    vim:/home/frew/.vvar/sessions/blog
217     (100%)  3m37s
```

## Infrastructure

Most of this is really easy for me because I basically use two or three
programs:

 1. A web browser (it doesn't matter which, really)
 2. A terminal (with title set by `tmux`)
 3. A terminal (with title set by my vim session selection tool)

It's really easy to then parse the titles of these things into something
meaningful.  [I documented the configuration I had to do to make this
happen](https://github.com/frioux/unproductive#tips).

---

This was a fun little project that took a little over a week.  I haven't yet
built habits around checking the time usage, but I expect to check weekly.  I
was immediately surprised at how much time I spent on Slack that I would not at
all consider wasted; just more than I had thought.

---

If you are interested in being more productive, I suggest checking out
<a target="_blank" href="https://www.amazon.com/gp/product/0143126563/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0143126563&linkCode=as2&tag=afoolishmanif-20&linkId=9af568a80c4d523e4fb32a82de4e2351">Getting Things Done</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0143126563" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a system that you can extend or simplify in many ways and I have found it
very helpful in remaining both organized and "afloat" in this busy world.

If you have some spare time you might use it to [roast coffee like I
do](/posts/diy-coffee-roasting-and-coffee-setup/); if you want to roast coffee
better, you should check out
<a target="_blank" href="https://www.amazon.com/gp/product/B01FGOH0AW/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B01FGOH0AW&linkCode=as2&tag=afoolishmanif-20&linkId=8a1c8e7bf1b92c417b0690f0ff57589e">The Coffee Roaster's Companion by Scott Rao</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B01FGOH0AW" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's brief but very dense, with tons of information and eye opening details
about roasting coffee.
