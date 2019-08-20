---
title: Distraction Free Slack
date: 2019-08-19T19:17:05
tags: [ golang, slack, frew-warez, super-powers ]
guid: a72d2dec-be24-448c-a36a-7659822c8ad7
---
I have gotten to the point where I can *almost* use Slack with zero
distractions...

<!--more-->

We use Slack [at work](https://www.ziprecruiter.com/hiring/technology); it's
definitely useful for collaboration, but it tends to feel like an attention
monopolizer, rather than a force multiplier, much of the time.  [I've written
about this before](/posts/tyranny-of-easy-things/#slack); I suggest reading at
least that section of my post to see why I do this.

The following sections are in order of effectiveness.

## Just Don't

The main way to avoid wasting time in Slack is to leave it closed until you need
to turn it on.  I personally try to get work done before meetings, which for me
tend to start between 9am and 10am, so I will work for an hour or two before
meetings, then after the meetings are over I typically fire up Slack to see if
anyone has reached out.  What this means is that often I am not in Slack till
the afternoon.  This is fine.

## Deaddrop

Sometimes I need to send someone a message on Slack but I don't need
acknowledgement.  In this case I'll use
[slack-deaddrop](https://github.com/frioux/leatherman#slack-deaddrop), which
allows me to send a single message to any channel, group message, or direct
message, from the commandline.  It's less convenient than using the normal slack
interface, but I don't get tempted to look at the other outstanding messages to
me.

## Focus Mode

Often I need to have a specific conversation in a specific channel.  Maybe I am
stuck on something, or need to make sure that a team member agrees with some
implementation choices, or whatever.  For this, I have cobbled together a "Focus
Mode" for slack.  This is built with (at the moment) three tools:

I use [uBlock](https://github.com/gorhill/uBlock) to hide most of the sidebar
with the following cosmetic filter: `app.slack.com##.p-workspace__channel_sidebar`.

I use
[favicon-customizr](https://addons.mozilla.org/en-US/firefox/addon/favicon-customizer/)
to prevent the favicon from showing red or white, which tells me that I have
some outstanding message.

And finally I use
[slack-open](https://github.com/frioux/leatherman#slack-deaddrop) to go straight
to the channel or direct message that I want to interact with.

The title of the tab still shows characters (like `!`) that imply activity, but
it's subtle enough that I don't notice it, which is what I really care about.
At some point I hope to replace both the first two addons with a
[tampermonkey](https://www.tampermonkey.net/) script, but until [issue
700](https://github.com/Tampermonkey/tampermonkey/issues/700) is resolved I
can't even start on that.

---

If you're at all interested in the system I use for my notes, it's based on
<a target="_blank" href="https://www.amazon.com/gp/product/0143126563/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0143126563&linkCode=as2&tag=afoolishmanif-20&linkId=37ab814736ab4a3ead2bff3dc5bb7b56">Getting Things Done</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0143126563" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
and I've found it pretty helpful.

If you are inspired by all these tools that I've built, I suggest reading
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=7320143b3b25493a297e134aa6fc0846">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
