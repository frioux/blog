---
title: Getting Carried Away
date: 2019-06-10T19:50:08
tags: [ frew-warez, golang, lua, awesome ]
guid: 6a004360-7567-4925-bac2-52a9e8f4c93e
---
This weekend I spent probably ten hours trying to make something work a hard way
and Monday at work Rob pointed out a solution that worked in about five minutes.

<!--more-->

One of the widgets I'm trying to set up for my window manager is a calendar with
a daily agenda underneath.  The idea is that I often peak at my calendar and
opening a browser tab takes time.  More importantly, even looking at the browser
is often a distraction, since it contains lots of other time wasters.

My plan was to first build the AwesomeWM widget, then to get the relevant
calendar events from my Google Calendar.  I did the first part (which I'll blog
about in another post) over the course of a few idle evenings after the kids
went to bed.

For the calendar I weighed authenticating to Google via oauth2 and accessing the
private iCalendar URL from Google Calendar.  I immediately reached for the
latter.  I assumed I could write a little tool in my leatherman that would use
an existing Go library to simply grab the events for the next eight hours and
print them.

I was disappointed to discover that all of the iCalendar parsers I found were
insufficient.  The first one only supported timestamps in UTC.  Another didn't
support all day events.  Worst of all, none of the ones I looked at supported
recurring events.  Every single lacking feature was discovered by looking at *my
own weekly calendar.*  These are not esoteric, rarely implemented features; they
are common and widely used (at least at work.)

So I eyeballed my iCalendar export and figured: "How hard could this be?"

---

I implemented enough to parse start dates, end dates, summaries, and the initial
stab parsing [recurrance
rules](https://tools.ietf.org/html/rfc5545#section-3.3.10).  My parser works for
some of the examples I threw at it, but I am aware of lots of unsupported
features (anything monthly, anything yearly, and limiting based on count are the
ones I had planned on doing.)

I was resigned to building the rest of this, especially since I was making
pretty good progress, till I was complaining about it this morning at work and
Rob said:

> ooc, what made you decide to do that rather than use something like gcalcli?

`gcalcli` was mentioned by another coworker at some point in the past month but
I'd forgotten about it.  It's not perfect, but after Installation (via
`apt-get`, so trivially) I was able to simply run the following command:

```
$ gcalcli --calendar fREW agenda "Mon Jun 10" "Mon Jun 11" | cut -b 13-                 

10:00am  Build/Deploy
10:30am  New Core Weekly
12:30pm  OOO
 3:00pm  ZipAlerts AB testing migration

```

---

The takeaway here, for me anyway, is that I need to be more willing to take a
step back and consider what I'm trying to accomplish.  I could have definitely
finished building the iCalendar parser; I might even still, if I need it.  But
code is generally a liability and adding a big, complex corpus of code for
something as simple as this should give you pause.

---

(The following includes affiliate links.)

I don't know how to teach you to take a step back and look at the big picture,
but I can recommend a book I have found helpful for general organization.
<a target="_blank" href="https://www.amazon.com/gp/product/0143126563/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0143126563&linkCode=as2&tag=afoolishmanif-20&linkId=40e2932c2a6e6c3cf3c78a8fcdd4dcc0">Getting Things Done</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0143126563" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
recommends a sort of state machine that you can use to stay on top of stuff.  I
have found it very helpful in the ca. three years that I've been using it.
Maybe it will work for you too.

I wish I could link to more books that elaborate on the spirit of owning your
environment the way I prefer to.  I find it empowering and enjoyable.  A good
option, if a bit low level, is
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=c31b506ba8b502dfc0baa71133044cda">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
Even if you've been using Unix for decades, this book has some good nuggets.
