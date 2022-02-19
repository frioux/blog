---
title: Linux Clocks
date: 2016-10-13T16:45:38
lastmod: 2016-10-14T07:10:38
tags: [ linux, ziprecruiter, perl ]
guid: E6D786E2-8C3B-11E6-980F-E48C40D14727
---
At [ZipRecruiter](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) we have an
awesome access log that includes information about each request, like a measure
of the response time, the increase in rss, and lots of other details.  Before I
joined we had a measure of how much CPU was used, but it was a little coarse.
Read about how I increased the granularity here!

<!--more-->

## `times`

Originally we were using the [`times` system
call](https://linux.die.net/man/2/times).  This is especially useful since Perl
has [a builtin for `times`](http://perldoc.perl.org/functions/times.html).  It's
easy, and it gives a pretty good set of information (specifically how much work
was done in kernel, out of kernel, in kernel for child processes, and out of
kernel for child processes.

The only thing that was a little annoying, as alluded to above, is that the time
granularity was low.  To be clear, the minimum time slice was 10ms, or 0.01s.
Peter Rabbitson mentioned to me at some point that `getrusage` would be worth
looking into, because it has higher time precision.

## `getrusage`

So I decided, once we saw that we needed to start focusing on CPU more, to get
more precision by using [`getrusage`](https://linux.die.net/man/2/getrusage).
The following is the data I wanted, documented in the linked man page:

> `ru_utime`: This is the total amount of time spent executing in user mode,
> expressed in a timeval structure (seconds plus microseconds).

[I migrated our Perl code to
`getrusage`](https://github.com/frioux/Plack-Middleware-ProcessTimes/commit/f070050d42be06af6d52071f1584c04af1f77c8a),
but then in the logs I noticed that our times all looked like:

```
 1.123000
21.242000
 2.930000
 2.494000
```

Strange that the microseconds would be getting truncated to milliseconds.  I was
sure that it was a bug in
[Unix::Getrusage](https://metacpan.org/pod/Unix::Getrusage) and tried
[BSD::Resource](https://metacpan.org/pod/BSD::Resource).  It had the same
problem, but I was still confident that they were both marshalling the data
incorrectly.  I decided to write a C program to test the system call directly:

```
#include <stdio.h>
#include <sys/time.h>
#include <sys/resource.h>


int main(void) {

    long int x = 2;
    for (int y = 0; y < 5322332; y++) {
        x = x * 2;
    }

    struct rusage usage;
    struct rusage *p = &usage;
    getrusage(RUSAGE_SELF, p);

    printf("%ld.%06ld\n", usage.ru_utime.tv_sec, usage.ru_utime.tv_usec);
    return 0;
}
```

On my Linux laptop, this program prints out `0.008000`.  I had a friend run it
on OSX and it printed `1.763319`.  So basically the Linux kernel (version 4.8)
does not actually have the fine grained accuracy that is documented!  From what
I gather, older versions of Linux do, but the accuracy was lost with [the
migration to tickless operation](https://lwn.net/Articles/549580/).

## `clock_gettime`

Generally, when I'm doing some kind of ad hoc timing of things in Perl I use
[Time::HiRes](https://metacpan.org/pod/Time::HiRes), which has super fine
grained precision; after a brief source-dive into it I came upon [the
`clock_gettime` system call](https://linux.die.net/man/3/clock_gettime).  It
allows you to request the time for a number of clocks, but in this case the one
that's useful is `CLOCK_PROCESS_CPUTIME_ID`.  I'm not sure why it has `_ID` in
the name; I can only assume that it's an artifact of the history of the syscall,
and related to the fact that glibc used to implement this by reading special
registers directly.

The general usage is as follows:

```
use Time::HiRes qw( clock_gettime CLOCK_PROCESS_CPUTIME_ID );
my $t0 = clock_gettime(CLOCK_PROCESS_CPUTIME_ID);

# do some complicated stuff

my $total_seconds = clock_gettime(CLOCK_PROCESS_CPUTIME_ID) - $t0;
```

`$total_seconds` will have how many seconds (with lots of precision) was spent
on the CPU, both in user code and in kernel code.  If we cared to have them
split apart we'd be stuck with the accuracy discussed before, but this gives us
much finer grained details and really, is as much information as we need.

---

This was a fun little issue to track down, especially the diversion into C.  I
look forward to verifying issues at such a low level in the future.

Addendum: I use precision and accuracy interchangeably above.  Technically all I
mean is higher resolution values.  It is beyond the scope of this article to
discuss accuracy and precision.
