---
aliases: ["/archives/1821"]
title: "The Pomodoro Technique"
date: "2013-01-25T00:45:37-06:00"
tags: ["life", "super-powers"]
guid: "http://blog.afoolishmanifesto.com/?p=1821"
---
A couple of weeks ago I was frustrated at my own lack of productivity. I decided
to purchase [Pomodoro Technique Illustrated: The Easy Way to Do More in Less
Time](http://pragprog.com/book/snfocus/Pomodoro-technique-illustrated). I had
actually already attempted the Pomodoro Technique based on what I read on the
internet, but it never seemed to work for me. This short, easy read has made a
noticeable difference in my productivity. But the book is not the point of this
post, The Method is.

# The Pomodoro Technique

The gist of The Pomodoro Technique is that you work for 25 minutes on a given
task and then take a 5 minute break. After four 25 minute sessions (called
pomodoros, or correctly inflected, pomodori) you take a longer break, which
happens to coincide with lunch and tea time for me anyway. Sadly though, the
short version above is missing a **lot** of important details.

## How?

When you work on something you work on that thing exclusively. The way the book
puts it, if you set aside 25 minutes for an issue, and if you finish early, you
"overlearn." That sounds pretty stupid when you are doing anything other than
studying, but when programming I just use that extra time to clean up my design
and consider possible holes in what I initially did. You are certainly allowed
to do more than one thing in a Pomodoro, but you are supposed to plan ahead and
decide what things you will do within a pomodoro. I have found that I can never
do more than two things in a single pomodoro. Apparently tasks that take less
than 12 minutes are very rare :)

The five minute break is supposed to be a total release of mental capacities. Do
not check your email in that five minutes; instead zone out and try to think
about nothing. This is really easy when I work from home, I just go downstairs
and sit in my lazyboy for 4 minutes, then when my timer goes off I get another
cup of coffee, go upstairs, and start another Pomodoro. It sounds strange, but
the cool thing is that it works. When you start a task you have a plan on how to
do it (generally.) The Pomodoro Technique helps you to get into [the
flow](http://en.wikipedia.org/wiki/Flow_%28psychology%29), so you tend to not
realize design mistakes you are making. When you take your five minute breaks
your subconscious comes up with better ideas on ways to do things.

The Pomodoro Technique is mutable. The sizes of the breaks and pomodori are
variable. The data you track (more on that later) is variable. You can do
whatever works best for you. But if you change too much too often you are not
getting a rhythm and are not measuring comparable things and are really just
coming up with something else entirely.

## Why?

The Pomodoro Technique solves the problem of too much multitasking. Because you
can only work on one thing at a time you **will** get more work done. The other
benefit, as mentioned before, is that it helps you get into a flow state. It is
incredible to me that even if a task is boring, as long as it is timeboxed I can
zoom in and get it done, where in the past I would have worked for 5 to 10
minutes, checked my email, worked for 5 to 10 minutes, checked my feed reader,
etc.

Another thing I love about this is that it is timeboxed **effort** not timeboxed
results. The [Get It
Done](http://www.brepettis.com/blog/2009/3/3/the-cult-of-done-manifesto.html)
community is all well and good, but I would not want any of them making the
software running on an airplane. With timeboxed effort you either produce
quality results, or realize that what you are doing is taking longer than it
should so you save what you have done and deal with it another day. I have found
that it also gives me time to work on paying down some of the technical debt in
our software. Because everything is timeboxed I do not run the risk of
accidentally spending 4 hours on something that does not matter, and because I
am actually getting more done I have the luxury to work on such things.

The way the technique is presented in the book is very measurement based. This
means I can say that I "work more" in the same amount of time when I work from
home. (1:1 at worst, 2:1 at best.)

I also track special pieces of data, like when I get timeouts VPN'ing in to
work, which is a worse interruption than someone coming into my office and
talking to me. This guides my motivation that I need to make our software easier
to run on Linux so I will not need to VPN in to work to use a Windows VM :)

## Tips

One of the things that was hard for me at first was ignoring new private
messages, instant messages, and irc hightlights. This was actually easier than I
thought to fix; I just close the console that contains irssi and mutt. It lets
me zoom in and focus on work, and then I will re-open it at large breaks and
sometimes at small breaks (tmux or screen make this easy.) The same goes for
work. When I take a large break I close the console related to my work, so that
I will not be tempted to look at whatever is in that console.

I found that when I first started doing this I was always exhausted. I was not
used to working so consistently all day. After a little over a week I adjusted
to that.

## Problems

The Pomodoro Technique is not the way to get everything done in your life.
Household chores for example are stupid to timebox. When you start doing dishes
you should clean till you are done. The line is fuzzy though. For instance I
started my taxes and have already (somehow) spent two pomodori on it, but I have
started and that makes it incredibly easier to continue.

I am trying to do the Pomodoro Technique after work with my OSS work, but that
tends to be when my wife is at home, and it would be bad if I told her: "wait 12
minutes and then I will respond to your question, I have to finish this blog
post first." I still try to do it when she is not around though and it helps.

I also seem to forget to start my timer. I will work for a while and then check
my watch and see that I forgot to start the timer. I am reticent to get a
kitchen timer (the ticking makes it clear that it has started), but I may do it
nonetheless.

I find that tasks that are much easier than I expected (takes 2 minutes instead
of 20 mintues) are hard to stretch out into a full pomodoro. I have an informal
rule that if something takes less than half a pomodoro I am allowed to modify my
plan for the current pomodoro **within** the pomodoro, which is usually
_verboten_.

The Pomodoro Technique makes scheduling with other humans harder. The coworker I
work closest with is fine with getting back to me in 15 minutes, but do I want
to wait 15 minutes to go to lunch (we all eat together) ? Often people will come
by my office in the morning to discuss something that happened since I last saw
them; it is at least a little awkward to say, "Hey I am working, could this
wait?"

## The Book

I strongly recommend getting the book. It is a very easy, short read with lots
of pictures and examples. It is a little strangely written, presumably because
the author is not a native English speaker (maybe he is, but it does not seem
that way!) The only annoying bit is how much Pragmatic Programmer charges for a
digital copy which is not included with a dead tree edition. If only Valve could
influence book publishers too (receive all platforms at the same time!)

## The Bottom Line

I cannot speak for everyone, but with this technique I am more productive.
Frustratingly, I cannot easily compare before and after, because the two weeks
before I started this were holiday ridden, and the two weeks before that were
not well broken up in our issue tracker. What I can say is that at the current
rate the scheduled issues will all be complete before Feb is over, which is
unheard of in my project.
