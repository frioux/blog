---
title: Linux Containers and Docker pstree
date: 2016-08-12T07:30:21
tags: [docker, pstree, perl, linux, toolsmith, angst, computer-h8, axel]
guid: 299F9190-5E47-11E6-A2DB-FE7FA7D0809E
---
Once in a while I find myself wanting to see the state of a container from a
bird's eye view.  My favorite way to do this is with a special tool I wrote
called `docker-pstree`.  Here is how it works.  (Stay tuned for angst at the
end.)

<!--more-->

Typically in a virtual machine or in a container there is one root process which
all other processes descend from.  On a traditional system this is `init(1)`,
but in containers it is often simply your application.

The problem comes when one uses `docker exec` to run a process within a
container:

```
$ docker exec -it w.pl /bin/sh -c 'ps ; echo "---"; pstree'
PID   USER     TIME   COMMAND
    1 1000       0:00 {w.sh} /bin/sh /bin/w.sh KBIX KSMO
   43 1000       0:00 /bin/sh
   67 1000       0:00 sleep 600
   82 1000       0:00 /bin/sh -c ps ; echo "---"; pstree
   87 1000       0:00 ps
---
w.sh---sleep
```

(note that the pstree does not include the current process, but ps does.)

The cause is that pstree (at least in busybox, which is what is used in this
example) [starts at pid 1 and walks from
there](https://git.busybox.net/busybox/tree/procps/pstree.c?id=6b5abc95969caf270d269ae640bb64e6bf8a7996#n379)
and when you use `docker exec`, the new process is not under the "init" of the
container, it's under some other thing (the docker daemon, to be precise.)

Containers in linux are simply attributes on processes, set by modifying files
under cgroupfs.  The defacto location would be something like
`/sys/fs/cgroup/pids/$cgroup/tasks`, where you add the pid to that file.  So it
makes perfect sense that a process could be in a container but not run
by one of the other processes in the container.


## `docker-root-pids`

There's a fairly easy fix for this.  The first is a tool I wrote to find "root"
processes of a docker container:

```
#!/usr/bin/env perl

use 5.24.0;
use warnings;

my $target = shift;

my $container = `docker inspect --format {{.Id}} $target`;

my %pids;

# build hash to map pid->ppid of all procs in container
for my $line (map s/^\s+//r, grep m/\Q$container/, `ps -ww -eo pid= -o ppid= -o cgroup=`) {
   my ($pid, $ppid) = split /\s+/, $line;
   $pids{$pid} = $ppid;
}

# find ppids that aren't in the hash and dedup
my %result = map { $_ => 1 } grep !$pids{$_}, values %pids;
say $_ for keys %result;

```

And then I have a super simple wrapper around `pstree` called `docker-pstree`:

```
#!/bin/dash

docker-root-pids "$1" | xargs -n1 pstree "${2:--U}"
```

This uses the host pstree, instead of the container pstree, which means that the
pstree implementation is more powerful.  I could reimplement all of the tooling
to run inside the container without a lot of effort, but I'd end up rewriting
the perl script since many of my containers have no scripting language at all
except for dash.  Oh and some of my containers might not have pstree either.

I tend to run the above with `watch -n 0.3 docker-pstree w.pl`.

## `nsenter` and solving problems

There's a more generic tool than `docker exec` called `nsenter` that comes with
util-linux, which includes such venerable tools as `cfdisk`, `more`, `reset`,
and `dmesg`.  [I have blogged about `unshare`
before](/posts/pid-namespaces-in-linux/), which is sortav a micro Docker that
ships with util-linux.  `nsenter` is a micro `docker exec`.  I find it useful to
use if only to see how it works:

```
nsenter -m -u -i -n -p -t "$(docker inspect --format '{{.State.Pid}}' w.pl)" /bin/sh 
```

When a process is created by `nsenter` the core system calls (verified by
calling `strace` on `nsenter`) are `setns` and `clone`.  Here is the meat of the
trace:

```
# 6968 is the pid of w.sh
open("/proc/6968/ns/ipc", O_RDONLY)     = 3
open("/proc/6968/ns/uts", O_RDONLY)     = 4
open("/proc/6968/ns/net", O_RDONLY)     = 5
open("/proc/6968/ns/pid", O_RDONLY)     = 6
open("/proc/6968/ns/mnt", O_RDONLY)     = 7

# These each corespond with one of the flags passed to nsenter
setns(3, CLONE_NEWIPC)                  = 0
close(3)                                = 0
setns(4, CLONE_NEWUTS)                  = 0
close(4)                                = 0
setns(5, CLONE_NEWNET)                  = 0
close(5)                                = 0
setns(6, CLONE_NEWPID)                  = 0
close(6)                                = 0
setns(7, CLONE_NEWNS)                   = 0
close(7)                                = 0
clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0x7f849eb56ad0) = 38559
```

The frustrating thing here is that it doesn't work with the tooling I created
above!  The problem is that containers in linux are complicated.  I mentioned
before that they are basically membership of cgroups.  Well they are also
membership of namespaces.  `nsenter` merely enters the namespaces of the docker
container, and doesn't do anything with the cgroups.  I wrote a little script to
enter the cgroups of a container:

```
#!/usr/bin/env perl

use 5.22.0;
use warnings;

use IO::All;

my $pid = shift;

my @cgroups = map {
   chomp;
   my ($id, $subs, $cgroup) = split /:/;
   my @subs = map s/name=//r, split /,/, $subs;

   map "$_$cgroup", @subs;
} io->file("/proc/$pid/cgroup")->slurp;

io->file("/sys/fs/cgroup/$_/tasks")->append("$$\n") for @cgroups;

exec @ARGV;
```

So now, if for some reason you wanted to use `nsenter` instead of `docker exec`,
you could do this:

```
PID="$(docker inspect --format '{{.State.Pid}}' w.pl)"
sudo \
  cgenter $PID \
  nsenter -m -u -i -n -p -t $PID \
  /bin/sh
```

It's not perfect, but it's interesting!

## The Inevitable Angst

To some extent I feel like this whole `nsenter` side-trip is evidence that the
ad-hoc nature of Linux containers does end up leaving something to be desired.
Without something like docker or LXC to tie the disparate pieces together, it
just ends up being a hassle.

What I find even weirder is that while namespaces and cgroups, taken together,
make containers, they act pretty differently.  One is controlled with the
magical cgroupfs filesystem and the other is controlled with system calls.
There's a handy, clear manpage for namespaces (`namespaces(7)`) while cgroups
are documented in the not typically installed kernel documentation
([`/Documentation/cgroup-v1/`
specifically](https://www.kernel.org/doc/Documentation/cgroup-v1/).)  I can see
the cgroups for a process as a user with `ps`, as above, but to see the pidns (or
presumably other namespaces) I have to be root. Why aren't they more similar?

---

At the very least, my tooling works, and I could make it use namespaces if I end
up being willing to run it as root.  The easiest and most robust option will
probably involve rewriting the perl script in shell and implementing
`docker-pstree` and a gnarly `docker exec` call.  I might do that if I ever end
up using this tool for more than my containers on my laptop.  While the situation
is frustrating, the tooling still ends up being fairly straightforward and useful.
