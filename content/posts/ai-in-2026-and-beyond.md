---
title: AI in 2026 and Beyond
date: 2026-04-03T23:25:20
tags: [ "ai" ]
guid: f47aee9d-7d83-4350-8215-47b13a947bfd
---
No one needs another AI think piece. I'm writing this for myself. I wish I’d
started writing about AI in 2023. This is a cataclysmic shift in the world and
I wish I’d preserved my thought process so I could look back on it and see how
it changed over time. With that in mind this is written to my future self, and
includes what’s going on now and some predictions about what’s coming in the
future.


<!--more-->

AI has been interesting to laymen since late 2023 when ChatGPT came out. For
the first couple of years it was interesting, not too bad, could generate
reasonable programs, but had problems guessing (aka hallucinating) APIs that
didn’t exist etc.

The next big step function was AI deeply integrated into IDEs. This was mostly
Cursor, though Windsurf and VSCode were other options. A lot of this stuff was
interesting to me but I was too busy with a huge work project to play with it
enough to really deeply engage.

In late November of 2025, we lost a large group of engineers at work via an
office closure. We were struggling to figure out how to proceed, given our
already tight deadline, loss of headcount, and lack of progress in places we
expected to be done.  Between a couple of meetings I used Cursor to research
the issue. “Where is the client for service X?” Sane, correct answer. “Can we
interact with service X in language Y?” Plausible answer. “Please migrate from
the status quo to X in language Y.”  The code it generated looked right. I
sheepishly mentioned this in the next big meeting that we should see how far
off this code was. It was close enough that the commit I generated ended up on
main and saved us (predicted) 2 months of work.

Shortly after that I was able to play with Claude Code. Cursor was a
traditional IDE with AI baked in. Claude Code is a much more pure AI agent:
basically an LLM that can use tools to ground itself in reality, and bypass
many of the “guessing” problems it had in the past. A wrong guess with an API
immediately gets caught and addressed.

I have done a lot with Claude Code but what caused me to decide that I need to
write down what’s happening was the three things I did in the past week.  Here
they are.

## Emulator Fix

I like playing old school games. I was trying to play Vagrant
Story on a PlayStation 1 emulator and it was mostly working but there was a
very frustrating graphics quirk where I basically couldn’t see the screen
during cut scenes. I have always wanted to fix emulator bugs but it’s so far
out of my wheelhouse that I never got up the gumption to try.

I took a save state right when the issue was about to happen, I downloaded the
repo for the “core” (the emulator,) and asked Claude to build a harness that
would allow us to quickly iterate on the code and fix the issue. It took
probably 2 hours total, but the end result was [a
PR](https://github.com/libretro/beetle-psx-libretro/pull/947) that fixed an
OpenGL issue in an emulator that’s over 10 years old. 

## Org Chart Tool

For years I’ve had a stupid little json export of our org chart, and to get a
list of people with a given title or whatever I’d use `jq`. After the
experience above I thought “I can do better and make a tool that will benefit
everyone, not just me.”  I had Claude create a nice web based interface that
would draw the org chart, both by reporting structure and by team name
(different, it’s complicated.) A key requirement was being able to quickly copy
the email addresses of everyone in a group. Cake.

Next I had it build a stupid little search engine. It allows regular string
matching and matching within fields, so I can write title:”Senior Staff” and
find all the engineers with that title, then copy all of their email addresses.
Perfect.

Finally, I wanted this tool to make maintaining the org chart easier. Typos
creep in or teams don’t get a name or whatever, so I added a special edit mode.
This mode stores modifications into local storage. You can export your
modifications (it’s human readable changes) but you can *import them back as
well.* This means that I can easily suggest changes to my local HR partner, or
for bigger surgery I can share the proposed changes to my VP or CTO.

## Dependency Graph

The increase in AI has meant an increase in production incidents. I have not
seen evidence that it is due to worse code being published (slop) but more that
it is due to more code being published (velocity, same quality as before.) In
an effort to build a strategic investment that would help with this, I had
Claude generate a Python script that would materialize which of our services
talk to each other. I also had it generate another script that would
materialize which services had permissions to talk to each other. The results
looked good, but just like with the org chart, json and `jq` is not a scalable
solution.

I had Claude create a design which I carefully critiqued and worked with till I
was happy, then I had Claude generate all of the new system over the course of
a few hours.  It’s only the beginning of this plan, but it is a huge step
forward.

## Casual Rewrites

Just a couple more stories, these are not mine but coworkers did this earlier
this year.

One was suffering with a decade old Java codebase, regularly bumping into
problems, and theorized that an LLM could rewrite the whole thing in Go and
give us a clean slate.  He did that, had the Go version run in parallel with
the legacy version.  Whenever results differed, he had the AI figure out why,
and if it was a material difference he had the AI fix it.  The whole thing was
done in a sprint or two (depending on if you include the AB test or not.)

Another coworker was dealing with a memory problem (Java again) and our CTO
said maybe we should just have Claude rewrite the whole thing in Go.  This
coworker couldn’t bring himself to do that, but he did, out of curiosity, have
Claude generate a Go version of this code.  He ran a load test and noticed that
the memory problem wasn’t there.  He asked Claude why the Java version had this
memory issue, Claude pointed out that a certain database flag was being passed
in the Java version but not in the Go version.  My coworker wouldn’t (or at
least didn’t) have the idea to ask Claude “why is this thing using so much
memory?” (We were sure it was just the cost of scale.)  Instead, my coworker
found a one line bug with a disposable rewrite.  What a world.

I could easily share a dozen more stories, but these are recent, visceral, and
things I was directly invovled with.

---

## Predictions

I have a bunch of predictions.  I am not generally a predictor but I think that
they show my perspective and will help show how everything is going.

Today the internet is dominated by giant websites: Facebook and twitter (X)
spring to mind.  I am hopeful that because you can vibe up some little thing in
a few hours there will actually be more competition; you don’t need to pay
engineers salaries the way you do for something like Facebook, so maybe we’ll
have more weird small stuff.  It’ll be buggier, but that’s fine, we shouldn’t
expect perfection anyway.

A lot of people are worried there won’t be software engineer (or even white
collar) jobs.  I think that’s false and that there will be plenty of jobs,
*but* I do think that the next 2-7 years will be messy and there will be a lot
of people who have trouble keeping up.

A friend recently mentioned that foundations are the most important thing.
I disagree.  I think the lowest levels are now the least valuable, and that
AI basically solves the "small stuff."

Design is still worthwhile, at least currently.  I think it will be for at
least a year but I wouldn't be surprised if in 5 years the level of design I do
now is considered a waste of time.  Basically I'll have Claude generate a
design and go over it with a fine toothed comb.  I'll have Claude update the
design until I am satisified, and then I'll have Claude generate each little
piece of the design while I have lunch or whatever.  I love this, it's
cathartic, but it feels like the design version of coding by hand.  My
intuition is that it won't last.

Implicit in the design info above is that breaking systems down into smaller
pieces is still valuable; I think that will last a long time, and in fact it's
a mere part of what much of our jobs will include in the future: risk
mitigation.  I'm less worried about AI generating bugs (engineers did that just
fine since 1970.)  I am more concerned about finding ways for the risk to be
limited.  This is not new, but engineers have been casual about this in the
past by using that terrible process of "being careful."  We'll need to be more
grownup about this going forward.  Obvious tactics will include tests, type
systems, interfaces and decomposition.  I am skeptical manual code review will
survive.

In the past ideas were basically worthless; ideas now have real value, especially
to an engineer who can build them in a couple of hours.

Strategy is still very valuable; simply building a ton of stuff won't be as
effective as building things that strategically interlock and provide
multiplicitave value.

Current pricing for frontier LLM usage (Claude, OpenAI) range from $20/mo
(teaser rate) to $200/mo.  My understanding is that the usage price for the
same amount of tokens is about 10x this, so up to $2k/mo.  Companies won't bat
an eye at paying this price, but I think free models and a free harness will
allow pretty good LLM usage at the cost of your own electric bill.  My hunch is
that someone makes an acceptable harness for Qwen 2.5 or similar before EOY and
it's good enough for students and weirdos (I say this as a recovering weirdo.)

---

This post is too long, but since I started it major things
([eg](https://sockpuppet.org/blog/2026/03/30/vulnerability-research-is-cooked/))
have already started happening, and I'd rather get this out and write
followups.  
