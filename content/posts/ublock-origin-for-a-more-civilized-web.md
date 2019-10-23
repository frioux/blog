---
title: uBlock Origin for a More Civilized Web
date: 2019-04-17T22:15:00
tags: [ ublock, firefox ]
guid: 6d573e27-36b8-46a8-8d39-aed0d3739c28
---
I set up some dynamic uBlock filters to fix a broken website.

<!--more-->

I like how, when it comes to the internet, I am in control of the client
rendering the content I'm viewing.  I take advantage of this any time I am
annoyed at how a page is rendered.  So far, I've exclusively been using [uBlock
Origin](https://github.com/gorhill/uBlock) to achieve this task.  Here are some
examples of how I make it happen:

## Comments

Almost universally, comments are a wasteland.  With that in mind, whenever
comments are either overly negative or so voluminous that they make the page
appear much longer than it should be, I hide them.  This is trivial to do,
basically you add `<somedomain>##<some-css-selector>` to "My filters" to hide
whatever is the comments.  So for example, with [LWN](https://lwn.net/) you
might have the rule `lwn.net##.CommentBox`.

The [documentation for the filter syntax is
here](https://github.com/gorhill/uBlock/wiki/Static-filter-syntax).

## Nonsense

Some domains show nonsense that I find, generally speaking, useless, and they
take up a non-trivial portion of the rendered page.
[Hackaday](https://hackaday.com/), on top of an absurd amount of comments, has a
footer that's nearly half the height of the screen.  I hide it by adding
`hackaday.com##footer` to "My filters".

## Slack

Slack has settings that let you hide channels that have no activity.  Slack also
lets you hide muted channels.  Annoyingly, if a channel is muted but has
activity, it is still visible.  I wrote the following rule to hide such channels
from my left toolbar: 

```
ziprecruiter.slack.com##div > .p-channel_sidebar__channel--unread.p-channel_sidebar__channel--muted.p-channel_sidebar__channel.c-link
```

There is still a giant empty spot between hidden channels and direct messages,
but I don't care.  This still makes my life better.

## Four Short Links

For quite a while, [four short
links](https://www.oreilly.com/feed/four-short-links) has had a bug (in Firefox)
where when you right-click or middle-click a link, it opens the link, even if
you just wanted to open the page in a separate tab.  This kills me.  The author
is aware but I don't think it's in his control to fix.  But it is in our
control!  Here's how I fixed it:

```
www.oreilly.com * 1p-script block
www.oreilly.com * 3p-script block
www.oreilly.com * inline-script block
```

The above goes in "My rules", rather than "My filters".

This disables all scripts on O'Reilly's website.  There's no reason for a site
that's nearly all text to run scripts anyway!  I do the same thing on Medium and
the site is *just fine*.

I am somewhat frustrated that I can keep filters in a textfile on github, but I
can't keep a set of rules there.  My guess is because rules don't compose
together as well, but I really don't know.

[The documentation for the rule syntax is
here](https://github.com/gorhill/uBlock/wiki/Dynamic-filtering:-rule-syntax).

---

(The following includes affiliate links.)

I don't really know what you could read to learn more about the above.
<a target="_blank" href="https://www.amazon.com/gp/product/1449393195/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1449393195&linkCode=as2&tag=afoolishmanif-20&linkId=a2a48387aa5187d947d0d50dd307451d">Maybe a CSS Book?</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1449393195" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

<a target="_blank" href="https://www.amazon.com/gp/product/0399527257/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0399527257&linkCode=as2&tag=afoolishmanif-20&linkId=d54fe2dd740427b89ac43cd6637a52f3">I have no idea what else would help.</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0399527257" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
