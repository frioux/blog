---
title: I Avoid Named Pipes
date: 2020-03-24T07:34:34
tags: [ unix, covid-19 ]
guid: 8ee3dff5-fa6f-4295-90f4-0756dedc5e68
---
I recently, finally decided to (almost) never use named pipes anymore.

<!--more-->

I use regular pipes all the time in Linux.  I use them on the command lines and
I use them in scripts.  If you somehow don't know how these work, here's the
short version:

 1. The shell creates a pipe
 2. Sets the write end of the pipe as the first command's output
 3. Sets the read end of the pipe as the second command's input

This is usually as simple as:

```bash
$ ls | grep x
```

Here, `ls(1)` doesn't have to know it's printing to a pipe, it just writes data
to standard out and it magically ends up at the input to `grep(1)`, which also
doesn't have to know a pipe is involved.  Awesome!  Programs that are written
in a normal fashion just continue to function.  I love it.

A *named* pipe, also known as a FIFO (first in first out,) allows the same
behavior, but you are responsible for creating the pipe... and finding it...
and some other stuff.  Here's how you can use named pipes to log the output
from a server without needing a shell to stick around and babysit the pipe:

```bash
# create the fifo
mkfifo /tmp/log-fifo

# read from the pipe, logging to a timestamped file, in a background process
( </tmp/log-fifo tai64n | /usr/sbin/rotatelogs -l /var/log/some_log.%Y%m%d 3600 & )

# redirect our standard out to the pipe
exec >/tmp/log-fifo

# change our stderr to also go to the pipe
exec 2>&1

# remove the pipe, since it's open
rm /tmp/log-fifo

# now run the actual service, no shell needed.
exec some command here
```

I used the above in production for years and it works fine.  This is, in my
understanding, the only good reason for a pipe: where you want a shell-like
pipe but you want to not have a shell.

Aside: reasons to avoid the shell are mostly so that you have clear semantics
around signals.  If you run services and the pid of the service is actually a
shell, bad things will happen when you need to stop the service, in my
experience.

## The Wrong Tool for The Job

Named pipes are great for, well, pipelines.  They make stdin and stdout
magically more flexible.  Awesome.  2015 fREW thought to himself: "I can use
named pipes as a way to have multiple processes write to a central one!"

The idea was I'd have a single process own the state of my blink(1), and
multiple processes feed into it.  At the time I had the red triggered by any
audio out, green enabled by certain people being active in slack, and blue
enabled by a reminder to stretch.  Let's build a basic version of this so you
can see the problems.

You should be able to try this at home.

First, make your pipe with `mkfifo /tmp/my-named-pipe`.

Next, in one terminal, run the central reader of the pipe:

```bash
$ perl -e'while (<STDIN>) { print $_ }' < /tmp/my-named-pipe
```

It should start off silent.  Next, create a little writer:

```bash
$ while true; do echo "printing" 1>&2; echo "woo"; sleep 1; done > /tmp/my-named-pipe
```

This should write `woo` to the pipe once a second.  You should now see the
first process writing `woo` every second as well.  Great!  Everything works
perfectly!

OK now let's pretend this is the real world and bad things happen.  Go ahead
and kill the client with ctrl-c (or even just close the terminal.)

Note that the server didn't just start blocking, *it went away.*  This is
because when writer count goes to zero the server receives an EOF.  Annoying.
When I first ran into this I just hacked around it.  I hacked wrong, but I'll
come back to that:


```bash
$ perl -e'while (1) { while (<STDIN>) { print "$_' } }' < /tmp/my-named-pipe
```

If you run the above and play with killing the client, you'll see it works
again.  But there's another, more subtle problem.  Try running this:

```bash
$ perl -e'while (1) { print "outer loop\n"; while (<STDIN>) { print "$_' } }' < /tmp/my-named-pipe
```

When I wrote the above, I expected it to print `outer loop`, then block on
stdin.  But when client count goes to zero stdin *always* returns EOF, so you
get a CPU burning loop.  In preparation for this blog post (and as suggested by
my friend Mark Jason Dominus) I looked at the FIFO section of (affiliate link:)
<a target="_blank" href="https://www.amazon.com/gp/product/0321637739/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321637739&linkCode=as2&tag=afoolishmanif-20&linkId=beccb02b477b44e8b135aadcccd2e6f3">Advanced Programming in the UNIX Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321637739" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
known as merely "Stevens" by many.  Regarding this exact issue the book says:

> [I]f the server opens its well-known FIFO read-only (since it only read s
> from it) each time the number of clients goes from 1 to 0, the server will
> read an end of file on the FIFO. To prevent the server from having to handle
> this case, a common trick is just to have the server open its well-known FIFO
> for read–write.

I could do that, but at this point we're no longer just reading from stdin and
writing to stdout and letting the environment wire everything together.  This
is not worth the hassle anymore.

## The Inevitable Angst

This whole thing was caused by fREW of Christmas Past striving for code that is
extremely decoupled.  All components can be different programming languages, as
long as they write the (very simple) wire format.  This is a laudable goal, but
nothing is free.  Of all of the various goals one might choose to strive for in
a software project, the most expensive in my experience is that of flexibility.
And worse, it tends to go unused!

Flexibility is great if you are making a scriptable system like a video game,
or a web browser, or some kind of tool that will be customized by an end user.
But the *vast* majority of code I've interacted with professionally never needs
this stuff.  It can merely be modified when a change is required.

I rewrote the above described system with a single process, singled threaded
program that just polls the audio system.  When I need to add another color
input, *I'll just change the program.*  If I find that I want to avoid polling,
I'll revisit; but I definitely will not use a FIFO.  I'll either use another
thread via goroutines, or I'll use TCP/IP and Sockets.

If I may continue wallowing in woe for a couple more paragraphs, I have found
myself moving from decoupled, late bound solutions to tightly coupled, early
bound solutions over the past few years.  I think generalized solutions are
awesome, and when they exist and meet my needs they are a soothing balm when
most software is just salt in my wounds.  Consider SQL and embedding SQLite;
it's like a magical force multiplier.

On the other hand, pretending that I can be the one to casually make such
powerful abstractions for software that only I will ever use is just laughable.
And even further, it seems to me that there is less *opportunity* for general
abstractions.  I curse every time someone invents a query language, instead of
letting me just use the SQL I've known and loved for decades.  The more general
abstractions that exist, especially if they are similar to each other, the less
value they have.

---

Thanks to John SJ Anderson, Eric Weinstein, and Thomas Sibley for review.

---

(This section contains more Affiliate Links.)

In addition to
<a target="_blank" href="https://www.amazon.com/gp/product/0321637739/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321637739&linkCode=as2&tag=afoolishmanif-20&linkId=beccb02b477b44e8b135aadcccd2e6f3">Stevens</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321637739" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
<a target="_blank" href="https://www.amazon.com/gp/product/1593272200/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593272200&linkCode=as2&tag=afoolishmanif-20&linkId=d1b81485a8c6ef02ead0f7e2d568594b">The Linux Programming Interface</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593272200" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
has a whole chapter dedicated to Pipes and FIFOs.  Some of the same ground is
covered, and the basic suggestion ends up the same: open the pipe using a
special flag.  Every time I look at either of these books I just want to take a
break and read a section or chapter.  There's great information here that is
relevant to my professional work, but I have to know it exists at least.
