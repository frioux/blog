---
title: A Custom Supervisor to Solve Weird Problems
date: 2019-04-25T19:15:52
tags: [ golang, c, zr, supervisors ]
guid: bf75e2ef-0b4a-4376-8674-09f2a244ccef
---
Tuesday at work I finished work on a very specialized supervisor that I started on
Monday.

<!--more-->

At [work](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) we have a logging
tool, originally written by Ripta Pasay, that reads from both output streams
(stdout and stderr) of a process and writes them to disk.  It ensures that the
total amount written doesn't go over a certain amount, handles rotation, and
wraps with JSON if a line doesn't start with a `{`.  [The last major change I
made to tsar was to write a little C wrapper to make tsar end up as the child of
the persistent process, rather than the parent](/posts/c-golang-perl-and-unix/).

Late last week Ripta and I discovered a disconcerting bug: we were losing the
logs when we'd run little test programs with tsar.  This is a huge deal; we've
spent a ton of effort implementing tsar and our entire logging pipeline (nearly
all of 2018 for me!) such that we never lose logs and [can detect even the loss
of *a single line.*](/posts/log-loss-detection/)  Here's how we were testing our
program:

```
rm /vol/log/tsar/ls-*
docker run -v /vol/log/tsar:/vol/log/tsar --rm $image tsar -- ls
ls /vol/log/tsar/ls* && cat /vol/log/tsar/ls*
```

The above *should* print a json line per file that `ls` prints.  We saw it
printing *nothing*, and in fact there was almost never an `ls-` prefixed file,
though very rarely there was one.  We did `strace` on the outside of the
container; I fired up [`execsnoop` and even
`opensnoop`](https://github.com/iovisor/bcc) to detect what was happening inside
the container.  None of it helped to clarify the situation.

Finally the answer hit us like a bolt of lightning.  The following fixed the
problem:

```
docker run -v /vol/log/tsar:/vol/log/tsar --rm $image tsar -- sh -c 'ls; sleep 2'
```

To understand this you need to understand a critical detail of containers (or
really pid namespaces:) *the first process is init in the container*.  Here's a
snippet from `pid_namespaces(7)`:

> The first process created in a new namespace [...] is the "init" process for
> the namespace [...]

> If the "init" process of a PID namespace terminates, the kernel terminates all
> of the processes in the namespace via a SIGKILL signal. 

To be absolutely clear, `tsar` runs, forks off the child process which
`exec`s the actual logging process, then execs `ls`, which writes to stdout, and
exits.  This happens so quickly that the logger doesn't have a chance to create
the logfile and write the output before the kernel kills it, due to `ls`
exiting.  My assumption was that we'd have to make a weird supervisor, maybe by
interacting with the logger via a pipe or something, but I decided to sleep on
it over the weekend and bring it up Monday.

Monday rolls around and I raise this issue between meetings with Aaron Hopkins
and he pointed out that we really just need to watch for SIGCHILD to know when
either the logger or the main process exit.  At this point we are talking about
a very basic supervisor, with the main requirement that it give the logger a
little bit of time to flush it's buffers before exiting.

Monday afternoon I spent about ninety minutes building the initial version but
wasn't able to complete before the day ended.  Tuesday I spent about thirty
minutes in the morning fixing obvious bugs in my code and got it to work.  Then
I had Hopkins and Ripta review the code and they both found a few subtle (or
just stupid) bugs that would have shown up in prod eventually.

The meat of it is this function, triggered on SIGCHILD:

```c
// if we have to exit with something other than the service wstatus we exit 127
int svc_wstatus = 127;

static void sigreap(int _) {
   DEBUG("checking for reap");
   pid_t died;
   int wstatus;

   do {
        died = waitpid(-1, &wstatus, WNOHANG);
        if (died == tsarpid) {
           tsardied = true;
        } else if (died == svcpid) {
           svcdied = true;
           svc_wstatus = WEXITSTATUS(wstatus);
        }
    } while (died > 0);
}
```

And this part of main:
```c
   handle_signal(SIGCHLD, &(struct sigaction){.sa_handler = sigreap, .sa_flags = SA_NOCLDSTOP});

   while (1) {
       DEBUG("entering loop");
       if (tsardied) {
           DEBUG("tsar-child died, killing svc");
           maybe_kill(svcpid, SIGTERM);
           exit(0);
       } else if (svcdied) {
           DEBUG("svc died, killing tsar after 2s");
           // sleep 2 seconds, giving up if tsar dies.
           struct timespec t, r;
           t.tv_sec = 2;
           t.tv_nsec = 0;

           int ret = 0;
           do {
              ret = nanosleep(&t, &r);
              t = r;
           } while (ret == -1 && errno == EINTR && !tsardied);
           maybe_kill(tsarpid, SIGTERM);
           exit(svc_wstatus);
       }
       pause();
       DEBUG("unpaused");
   }
```

Very little of this is magic, but the `pause(2)` function from the standard
library is a nice and neat little helper that let's you just block till you get
a signal.

All this came together pretty nicely, I thought.  A reasonable understanding of
the process model in unix, some basic knowledge of C, and helpful coworkers
solved this weird problem!

---

I am going to take a step back from recommending related books, because I have
to wrack my brain for relevant works.  Instead, I'm just going to recommend some
good books that may or may not be relevant.  These ones are not relevant:

(The following includes affiliate links.)

Are you interested in how people lived their lives in the past, but don't want
to read a book that's specifically about history?  You should read
<a target="_blank" href="https://www.amazon.com/gp/product/0385040253/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0385040253&linkCode=as2&tag=afoolishmanif-20&linkId=ccd28030f89b5864dc8e0a90bb786bb1">The Ashley Book of Knots</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0385040253" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a weird format but it's awesome.  Also if you want to learn about knots
read it.  That too.

You might also want to read
<a target="_blank" href="https://www.amazon.com/gp/product/0316486094/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0316486094&linkCode=as2&tag=afoolishmanif-20&linkId=bef3399d43c700cc6115a01ee93541ba">The Terror</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0316486094" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's vaguely historical fiction, mostly accurate with some bits that are wildly
inaccurate.  Strongly recommend.
