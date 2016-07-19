---
title: A Few of My Favorite Tools
date: 2014-07-07T08:23:08
tags: [frew-warez, strace, sysdig, yapc]
guid: "https://blog.afoolishmanifesto.com/posts/a-few-of-my-favorite-tools"
---
# `strace`

Recently I've started branching out some in my debugging style.  In the past
it was usually adding print statements, reading docs carefully, reading
logs, etc.  I still mostly add print statements when I'm debugging my own
code, but when trying to figure out why some random program isn't working,
instead of reading docs I go straight to `strace`.

If you don't already know, `strace` traces system calls, so it effectively gets
between the program and the kernel and lists all the system calls being made.
It's surprising how informative something like `strace` can be!  There's another
thing called `ltrace` that does the same thing for libraries, but I've never
used it.

I suspect `strace` is old hat to most, but using it is a habit I haven't been in
until recently.  Usually with a bare `strace` invocation I can see the problem
immediately, IE the thing is trying to read a file that doesn't exist yet, or
listening on some other port.

To use `strace` all you have to do is prefix the command you are running with
`strace`.

So for example, to trace `ls` you merely run:

      strace ls

Of course eventually the output from `strace` is just **too much**, so you need
to filter it.  I just filter by system call, but there are probably other ways
to do it too.  To see just the calls to `open` that ls makes you can do the
following:

      strace -e trace=open

And you can give it multiple syscalls too:

      strace -e trace=open,stat

Oh and one last thing; for some reason I had the misconception that `strace`
requires you run programs "from within" `strace` and thus you can't trace
already running programs.  Fortunately that's false!  The following should work
in general:

      sudo strace -p $(pgrep firefox)

If need be you can reconfigure your system so that you don't need to be root to
trace your own programs, but fortunately I don't need to trace running programs
often enough to need that.

# `sysdig`

After [YAPC](https://blog.afoolishmanifesto.com/posts/youre-awesome-yapc)
this year I decided to go through and watch some of the talks
I'd missed for whatever reason, and I watched Sartak's [DTrace War
Stories](https://www.youtube.com/watch?v=P88qXvU2RUA), despite the fact that
DTrace doesn't work on Linux.  In the talk someone asked about this and
Sartak mentioned [sysdig](http://www.sysdig.org).  I didn't get my hopes
up too much, having tried [SystemTap](http://sourceware.org/systemtap/)
and [many other](https://en.wikipedia.org/wiki/Systemtap#See_also) similar
tracing facilities for Linux I've only been dissapointed.

I decided to take a look nonetheless and what I found was refreshing.  Unlike
`strace`, `sysdig` allows the user to examine much more of the running system
than a single process (or tree of processes, with `-f`.)

`sysdig` was made based on the rich set of tools we have for network captures,
with the goal of making a standard capture format that can later be queried
offline, presumably with gui tools or whatever.  Unlike DTrace and SystemTap,
`sysdig` initially feels like a much louder `strace`.  I ran `sysdig` on my
laptop and after about 2s of running it had written 1.9M of data, when stored to
a plain text file.

I'm not sure it's worth me going over all the cool things about `sysdig`, but I
will mention the one time I've used it so far when `strace` seemed like too much
work (though I think it still could have gotten me what I needed.)  I wanted to
see the trace of all the processes B that had been started by process A.  With
`sysdig` one can use this simple oneliner:

      sudo sysdig proc.pname=daemonproxy

One other neat thing about `sysdig`; the basic "query language" is merely an
expression that is built from a handful of relational operators (`=`, `<`, etc),
booleans (`and`, `or`, etc), and a large list of fields.  That's great for live
capturing or limiting the data you record, but if you want to do more complex
filtering you can use what is called "chisels" which use Lua and can format the
output programmatically, etc.

For those interested in `sysdig` I'd recommend reading [Sysdig vs DTrace vs
Strace](http://draios.com/sysdig-vs-dtrace-vs-strace-a-technical-discussion/)
and [Fishing for Hackers](http://draios.com/fishing-for-hackers/).  Both are
fascinating reads and make it clear what can be done with `sysdig`.

# `daemonproxy`

Finally I'd like to briefly mention `daemonproxy`.  I have three computers I do
about the same stuff on: web browsing, coding, reading email, etc.  Two are work
machines and one is a laptop.  I set nearly all of the settings via [scripts in
my dotfiles repo](https://github.com/frioux/dotfiles/) but one thing that had
been bugging me was that I have a handful of "user services" I need to run all
the time.  I had them running in their own `tmux` session but that means when I
first log in I have to do something like:

      tmux -2 new-session -s services
      offlineimap
      syncthing
      sudo openvpn ...

It's not the worst thing in the world, but `offlineimap` in particular gets hung
pretty regularly and I have to open up the `tmux` session, kill it, and restart
it.  That's where `daemonproxy` comes in.  With the help of the author
silverdirk I've come up with a relatively basic `daemonproxy` setup that runs
all the programs above with logging and very basic supervision.  I can run a
single command that will start all of them, log their output, and restart them
if they go down.  So if `offlineimap` hangs, as it is wont to do, I just
`killall -3 offlineimap` and it will restart automatically.

I'd recommend anyone who is doing anything with daemons at all check out
[silverdirk's lighting talk](http://youtu.be/YJrTaMUvjVA?t=1m26s). It really
clarified how elegantly these things can work, at least for me.
