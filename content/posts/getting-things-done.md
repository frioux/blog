---
title: Getting Things Done
date: 2017-07-10T07:17:46
tags: [ life, meta, ziprecruiter, super-powers ]
guid: 933D4D12-6469-11E7-98B8-D41828D191E6
---
(The following includes affiliate links.)

A year ago, when I was on paternity leave, I decided that I needed to be better
at time management.  I think that my inspiration was simply the recommendation
of the book, <a target="_blank"
href="https://www.amazon.com/gp/product/0143126563/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0143126563&linkCode=as2&tag=afoolishmanif-20&linkId=bd0ea26ab8ee7ba0fe99985cb50e1a45">Getting
Things Done</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0143126563"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" /> by [Alfie John][alfie].  Having used the
GTD system for about a year, I feel comfortable writing about it.

<!--more-->

I do not believe that there is a best time management system; I just know what
motivates me and what helps me be more productive.  In the past I would have
said "being more productive means you get more done."  I now take a more nuanced
view.  Specifically, given that I cannot possibly do all of the things I'd like
to, I instead must decide on my goals and priorities and decide, daily, which
tasks will further those.

Also, different styles work for different people.  I have a coworker who is
happy with his own productivity and does almost no planning but instead deals
with either whatever he thinks is important that day or whatever is forced upon
him by circumstances.  I want to stress though, that one thing I really like
about GTD (versus, for example, [The Pomodoro Technique][pomo]) is that it
applies in many more aspects of life, and not simply work as a Software
Engineer.

## Getting Things Done

Based on my reading the fundamental premises of GTD are that:

 1. You cannot get everything done.
 2. You cannot simply rely on your memory.

I agree with both of these; fundamentally part of being productive is being
strategic about what you take on.  While it may be enjoyable to do something
like alphabetize your cookbooks or read twitter for two hours, possibly neither
of them may further you in your personal goals.

## The Artifacts

Core to GTD are a few artifacts or repositories of information.  How this works
for different individuals varies, so if this sounds remotely worth considering
to you, get the book and you may go a different way.  The repositories are:

 1. The Inbox
 2. A set of unprioritized lists, called "Next Actions," that are basically todo
    lists
 3. A list called "Waiting" of things you are blocking on (or in my system, want
    to track)
 4. Project Plans which include their own Next Actions and reference
 5. An Incubator, for long term plans or ideas
 6. A reference system

For me all of these (except for physical mail) are digital and in two very
simple text files.  Here is a tiny example of some of each section:

`Notes.otl`:

```
IN
	R studio
	R's tidyverse
	Regexp::optimizer
	blog how to commit to open source
	blog vim debugging
	New tubing for carbonator
		mid:3F.9D.13896.E2DFC195@twitter.com
		https://twitter.com/CookingIssues/status/865020970842673152?s=09
	blog re abstractions
	blog re splitter
	Good, Short talks
		http://confreaks.tv/videos/bangbangcon2017-i-got-the-computer-to-find-words-with-good-anagrams-and-throw-away-the-boring-ones
		https://youtu.be/vm1GJMp0QN4?t=17m45s

Next Actions
	*
		Read Stevens Chapter 4
	Agendas
		Catherine
	Laptop
		https://hackernoon.com/lighting-by-hand-2-stitching-lines-together-24edc9f819bf#.nlkfarb7u
		Add ODBC on Linux testing to DBICH
	Lots of Time
		100 Ideas! [100:10:1]
		Earthquake Plan (2h?)
			http://lcamtuf.coredump.cx/prep/
	Work
		big-homes
			mid:20170707140609.39DCF20A10@batch1.ziprecruiter.com
		Update Reaper
			Create ticket
			reduce max times
			email seodev, searchdev, tech
			Create "would have reaped" report

Waiting
	Fogbugz tickets
		/candidate speed-up
			bugzid:36471
			https://logsearch.prod.ziprecruiter.com/goto/ecf76f022165dae7e25a1ea91f9f6144
	Kickstarter Stuff
		Paradise Lost
			https://www.kickstarter.com/projects/1183462809/paradise-lost-first-contact
			Backed Dec 2013
			Estimated Dec 2014
	To Ship

Project Plans
	Learn plant names
		Next Steps
			Start using book
			Identify plants not in book
	Physical Filing System
		Next Steps
			Make scanning easier to avoid system

Incubation
	Books
		Fiction
			Anna Karenina
				https://twitter.com/neilbowers/status/846078996907470848?s=09
			Arthur C Clarke's against the fall of night/the city and the stars
				Recommended by Zach 22Oct2016
			A Canticle for Lebowitz
				Recommended by Lee
			A Cry Like a Bell
				Melinda
		Non-fiction
			Advanced UNIX Programming by Rochkind
			Advanced Data Structures
			Art of R Programming: A Tour of Statistical Software Design (Humble)
			Kon-Tiki
			xchg rax,rax
	Comedies
		Brooklyn 99
		Master of None (S2)
	Dramas
		The Path
		Hannibal
		Deadwood
```

The actual file is *much* longer (about three thousand lines) and the reference
file is not shown at all.  I'll go over each section.

### The Inbox

Here's how the inbox works for me: step one, which I try to do throughout each
day but most especially Friday morning, is to get to "inbox zero" in my email,
"tab zero" in my browser, and basically not use such systems as a way to
represent undone tasks at all, and instead place them in my one true inbox.  For
tabs this is trivial, as I just place the link there if there is work to be
done, or close it if not.  For emails I use [a custom URI schema, `mid:`][mid]
that allows me to treat email the same way.

After all other defacto inboxes are cleared, I spend a few minutes migrating
things from the inbox to the other repositories.  So for example if the link is
simply some page about some module I want to remember, I file it away in the
reference section.  If it some task I need to do at work, I move it to the
`Work` Next Actions section.  The goal is to have the inbox basically always be
empty; mine is a mess right now.

### Waiting

I find this incredibly useful.  The idea is that if I order something I place it
in the `To Ship` section of waiting, and if I need to follow up or anything I
have a link to the confirmation email, the order number, and whatever other
information might be helpful.  Similarly I have a dedicated section for tickets
at work that I want to track.  There are lots of things I am waiting on that are
not shown here, but this should make it clear how I use it.

### Project Plans

Typically a project is any multi step process.  So for instance `Update Reaper`
in the `Work` Next Actions repository should really be a Project, but I was too
busy coming up to speed at work to correctly file it away.  I do not use
Projects as much as I would like to, and when I reread GTD I suspect I will
start using them more.  I *do* use them as a way to have reference for projects,
often with various links to extra information and whatnot, but there were no
examples I could show that would be useful out of context.

### Incubation

This section, while maybe less useful than the others in day-to-day use, was
actually something I did before I started using GTD.  I use it as a place to
keep ideas for future projects, books I want to read, movies I want to watch,
etc.  Because the system is well structured I tend to track where the idea came
from, so that if a person recommended a book I can follow up and thank them if I
liked it.

### Reference

What it says on the tin.  I have listings of Guitar Tabs, various links to Linux
stuff, commands I can never seem to remmeber, the rules for parking in Santa
Monica, and lots of other random bits and bobs.

### The Calendar

I didn't mention the calendar section before, even though it's part of GTD.  I
currently am pretty bad at using my calendar.  When I reread GTD I would like
to add to my current (very basic) software so that things get enqueued to the
inbox automatically on a given day, as well as get into the habit of reviewing
my calendar every Friday when I review the rest of my stuff.

For what it's worth, I think part of my problem with the calendar is that Google
Calendar is pretty bad.  If I could figure out a way for Google Calendar to hide
all other calendars by default it might be useful to me, but every time I look
at my calendar I end up having to reconfigure it.  Maybe I should look at other
software to integrate with it, but that sounds terrible.

Maybe I just need to write some extremely simple software for interacting with
the calendar, even though I really do not want to.

## The Process

For me the process boils down to keeping the above mentioned repositories of
information populated (usually twice a day, at dawn and after lunch) and then
picking from the currently appropriate Next Actions section.  At work it's
generally easy.  At home I may use the `Catherine` Agenda to discuss something
with my wife that I wanted to remember, or if the kids are down for a nap I will
likely look at the `Lots of Time` section.

Unless it is Friday morning I typically only look at `Next Actions`; but on
Friday morning I will check the `Waiting` sections, ensure nothing already done
is in `Next Actions`, peruse the `Project Plans` to see if I need to migrate any
of their respective `Next Actions` to the central `Next Actions`, and then if
for some reason I have boatloads of time or feel like it, go through
`Incubation`, though that is rare.

I mentioned that I have software to automate some of this.  I had high hopes for
a really powerful tool to automate a ton of this, but as it stands today it
allows me to add items to `IN` or specific parts of the incubator by sending a
text message to a certain number.

For example if I send `q in start taxes` a `start taxes` line will get added to
the end of `IN`.  That honestly is almost completely sufficient, but the other
sections actually predated `IN` so I kept them.  To be clear I can also send `q
drama Hannibal` and it adds `Hannibal` to the `Drama` section. [There are many
other things I can enqueue][q], but honestly I think that less is more when it
comes to software helping you automate this kind of thing.

If I could spend my time making the perfect time management software, it would
likely be some kind of AI that would limit my consumption of information more
than anything else.  As attractive as that idea sounds, I think that a better
option is to just stop consuming uncurated information (Facebook, Twitter) and
read a book or whatever.

---

I do not know if you could say that I am more productive than others because of
this system.  I am confident, though, that my system has fewer holes in it.  As
far as I can tell I stay on top of my email (all of it) and no one else I work
with does.  This does not make me more efficient, it just means that I am more
aware of the various things going on.

This system may sound boring to you, but for me I find that having all of this
information available at my fingertips very exciting.  Sometimes I will find
myself feeling uninspired, and I can simply dive into the `Inspiration` section
in my incubator and find all kinds of miscellaneous links to just that.  If this
system doesn't sound like something for you, that's fine, but if it does, <a
target="_blank"
href="https://www.amazon.com/gp/product/0143126563/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0143126563&linkCode=as2&tag=afoolishmanif-20&linkId=bd0ea26ab8ee7ba0fe99985cb50e1a45">buy
the book!</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0143126563"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />

[alfie]: https://www.alfie.wtf/
[pomo]: /posts/the-pomodoro-technique/
[mid]: /posts/custom-uri-schemata-on-linux/
[q]: https://github.com/frioux/Lizard-Brain/blob/430804de4340c952a0c02e4fc65629dc5f1563db/tasks/note#L95
