---
title: The fREW Schmidt Interview Experience
date: 2017-02-27T10:16:10
tags: [ interview, ziprecruiter ]
guid: C9967968-FD00-11E6-B2FA-65038CF70C31
---
I keep reading tweets about how interviews should be done, almost entirely from
the job seeker point of view.  Having done (by my coarse count in google
calendar) nearly ninety interviews at ZipRecruiter, I think that I can speak
from a bit more experience than most about the interview process.  I am not
going to expose all of the gory details of the ZipRecruiter interview process,
just how I (and my interview partner) administer it.

<!--more-->

### Coding

The first technical question we ask is almost
[FizzBuzz](https://en.wikipedia.org/wiki/Fizz_buzz#Programming_interviews) level
of simplicity, but it adds a tiny bit extra (some object-orientation, some
testing,) and what I like best: you use a real laptop.  There are a couple major
reasons [Ryan](https://twitter.com/beerbikesbbq) and I decided to switch from
whiteboard, to optional laptop, to required laptop.  First off there were enough
times that handwriting got in the way that I got sick of having to give people a
pass because of that.  I want to know if you will confuse a `{` with `(` in real
life.  Second, I want to see how the candidate struggles with whatever compiler
they have chosen.  Fighting wth the computer is almost all we ever do as
engineers and seeing how a candidate handles the error messages is worth so
much.  That brings us directly to the second technical question.

### Debugging

I came up with this question after a conversation with my wife and brother,
while driving from Ocean Springs to the New Orleans airport and am very pleased
with it.  I took a real-life confusing bug and distilled it down to a simple
Perl web application.

We show the candidate the bug in the application and ask them to figure out the
cause, the fix, and dive a little deeper if they complete it before time runs
out.  Unlike the coding question above, this one requires a lot more experience
running because the candidate spread is so different.

I am super enamored with this question, but I did come up with it myself.  At
some point I'd like to write a system administrator version that has some weird
live configuration or forkbomb situation.

Note again that this uses a real laptop.  While doing the classic "dungeon
master" style of interview for this works, I personally really enjoy seeing the
candidate directly interface with the computer.

### Basic Inversion

The one other thing that we try to do is allow the candidate to ask us questions
at *the beginning* of the interview.  Normally this is reserved for the end, but
the nature of the questions above tend to make candidates nervous so we try to
put them at ease by putting them in the driver's seat for a bit.  I don't think
it works very well.

## Whiteboarding and Tradeoffs

The above probably sounds amazing to most job seekers.  I see so much on twitter
railing against whiteboarding and algorithms and weird puzzles.  The problem is
that the above interview process is a *huge* hassle.  You have to make sure that
the laptop can somehow connect to a shared screen for interviewers to see; you
have to ensure that the language compiler, runtime, and at least a few common
editors are installed.  We allow candidates to use whatever language they want
for the first question so we have the tooling installed for all kinds of popular
languages on the laptop.  It's a good thing we live in the future, because
getting C# support on an OSX laptop would have been much harder just a few years
ago.

On top of the above, even though job seekers will almost universally say they
prefer coding on a laptop to a whiteboard, job seekers underestimate how much
they will be thrown by being given a laptop that is not exactly what they are
used to (operating system, keyboard, etc.)  This is not a major hurdle but it's
another issue that whiteboarding skips entirely.

---

One other, much harder interview style I've seen done, which most engineers
(myself included) are not well equipped to run, is an "expanding dungeon."  The
idea is that you let them design a system on the whiteboard or whatever, and
then dig in asking questions about parts of the system to get a more holistic
view of what the candidate knows.  This works great if your interview is
basically taking an already vetted candidate and finding out which team they
should be a part of, but the interviewer needs pretty good experience to be able
to run it, and it ends up being pretty silly with junior candidates.

Ultimately interviewing is **really hard**.  People love to say: "just let me do
what I'd do at work!"  If the candidate is just graduating from college or
university that's almost surely impossible, as they won't know Perl, and even if
they are a more senior candidate they likely will not know most of our stack.
As with all things in software engineering (and maybe all of life) it is a
question of tradeoffs.

Every interview question you ask is going to be somewhat irrelevant to the
job or somehow ill-suited to the job seeker being interviewed.  As far as I know
there is no magic way around this.  You just have to decide what matters to you
in a candidate and try your best to measure that.
