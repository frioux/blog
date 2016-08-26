---
title: "Docker pstree: From The Inside"
date: 2016-08-15T07:30:17
tags: [frew-warez, toolsmith, docker, linux, strace, pstree, axel]
guid: CE4A040A-619E-11E6-8BA9-E9EDF5F5D69D
---
[I recently posted about my `docker-pstree`
tool](/posts/linux-containers-and-docker-pstree/) and in the post mentioned that
at some point I might port the tool to be 100% "in-container."  Well I couldn't
help myself and figured out how.

<!--more-->

Saturday morning I was tinkering with making `docker-pstree` run from within the
container itself.  Recall that the intermediate goal is to find all "root"
processes in the tree. I started off trying to port `docker-root-pids` to POSIX
sh.  This is difficult because the it relies on a hashmap, and POSIX sh doesn't
even have arrays.  I considered actually doing math to generate a hash (as in
numeric digest) of the keys and then using that to do a seek within a null
terminated string, but that seems crazy and because you are doing a seek you
might as well just seek using the string anyway (because it's O(n).)

## Environment based solution

At some point I realized I could use the environment has a sort of hashmap, and
came up with the following:

```
eval `ps -eo pid= -o ppid= | \
  awk '{
    list=list "A" $2 " ";
    print "A" $1 "=A" $2 "; export A" $1
  };
  END { print "export LIST=\"" list "\""}'`
```

Before I go further, let me break that down:

`ps -e` says to grab all processes, `ps -eo pid= -o ppid=` basically says we
want the process id, the parent process id, and no header.  The awk code
tokenizes the input (so `$1` is the process id and `$2` is the parent process
id.)  The awk code is two blocks.  The first block concatenates A, the parent
process id, and a space, to itself every time, so it's a space separated list of
parent process ids.  Then the main block prints `A$pid=A$ppid; export A$pid`. A
space concatenates in awk, just like in Python and MySQL.  Finally the END block
prints the built up list as `export LIST="$ppids"`.  The output looks something
like this:

```
A1=A0; export A1
A7=A1; export A7
A8=A1; export A8
A9=A1; export A9
A10=A1; export A10
A11=A1; export A11
A12=A7; export A12
A14=A11; export A14
A15=A10; export A15
A16=A9; export A16
A35094=A8; export A35094
A36488=A0; export A36488
A38783=A36488; export A38783
A38784=A36488; export A38784
export LIST="A0 A1 A1 A1 A1 A1 A7 A11 A10 A9 A8 A0 A36488 A36488 "
```

When this is evaluated with `eval` you can then iterate over the parent process
ids like this:

```
for ppid in $LIST; do; echo $ppid; done
```
Or resolve the parent process ids like this:

```
for ppid in $LIST; do eval "echo \$$ppid"; done
```

## `ps` based solution

Then I went on a walk to the farmer's market (where I saw Ted Danson) and
realized, after looking at the output above, that it can be easier:

```
ps -eopid= -oppid= | \
  grep '\s0$' | \
  awk '{ print $1 }'
```

So this prints all processes with a parent process id of zero, and then we can
do this, like in the original `docker-pstree`:

```
ps -eopid= -oppid= | \
  grep '\s0$' | \
  awk '{ print $1 }' | \
  xargs -n1 pstree
```

## `pstree` based solution

But then my pattern seeking brain realized I could do this:

```
pstree 0
```

This is a useful command to run even on a full Linux machine because the kernel
threads do not run under init, and on my system the kernel threads are actually
process id 2 with a parent process id of zero.

## Tradeoffs

The nice thing about this is that it should work in any setup.  If you have a
way to run the docker client, the following should work reliably to get you
complete and accurate pstree output:

```
docker exec -it my-container watch -n 1 pstree 0
```

The bummer is that on a really basic system, `watch` is limited to integers, and
`pstree` can't show arguments (and can't do pretty unicode output.)  To overcome
the former, assuming you are not on windows, you can probably do this:

```
watch -n 0.3 docker exec -it my-container pstree 0
```

The other problem can only be solved by adding a more powerful `pstree` to your
container.  If you are using a traditional base image, like Ubuntu or Debian,
your `pstree` probably came with psmisc and is already good enough.  For
something like [Alpine](http://alpinelinux.org/) which all my containers are based on, you just need to
install psmisc yourself.

## Container Tooling

For a long time I have felt that containers should be as minimal as possible and
should not be "tooled up" to help debugging.  This is motivated by the desire to
create the smallest possible artifact with the lowest attack surface possible. I
have colleagues who I respect who think it's fine and good to put `strace`,
`psmisc`, `bash`, etc into their containers for simpler debugging.  I think that
is definitely the pragmatic path forward, but I have a few ideas that I think
would be superior.

### `rkt`'s Stage 1

In [rkt](https://coreos.com/rkt/docs/latest) there is the concept of a "[Stage
1](https://coreos.com/rkt/docs/latest/devel/architecture.html#stage-1-systemd-architecture)"
which is basically the supervisor and log aggregator for your container.  By
default, this is systemd.  I think it would be interesting to add more tooling
to that image, so if you need to debug a container, you just run it differently
and suddenly have all this extra tooling.  I looked into doing this yesterday
but gave up.

I think that the `rkt` architecture is superior to Docker's because there is no
central daemon.  If the Docker daemon crashes, all the containers go down with
it (by default,) with `rkt` this is not even a problem because there is no
central daemon.  There are other reasons I like `rkt` better but this is the
core reason why.

On the other hand, I can add a user to the `docker` group and the user is thus
fully able to control the docker daemon.  In `rkt` this is impossible without
`setuid`ing the `rkt` binary, which people are reasonably not doing.  So all
that together means that I'm unlikely to switch my stuff to `rkt` just yet.  I
would consider making a super tiny script that just does `rkt run` commands and
`setuid`'ing that.  We'll see.

### `nsenter`

What I would love would be the ability to run a command like this:

```
sudo nsenter --pid --mount --target $pid pstree -Ua 0
```

The idea being that I would be in the pid namespace, and have access to the
container's `/proc`, but sadly the `--mount` namespace is basically `chroot`.
It probably doesn't have to be, but that's how it works with `nsenter`.  Because
it's a `chroot` the `pstree` implementation is the one inside of the container.
Sad.

### Docker Volumes

Docker allows you to mount volumes in a container.  Volumes could be data (or
binaries) from the host, that end up in a specific directory in the container.
For super basic tools this could work, but how many tools work without a
boatload of dependencies?  At some point, going down this route, you'd end up
back in the dependency hell that Docker is supposed to help solve.

### The Magical Overlay

What I really want is a way to bolt on additional tools to a container while
it's running.  Today that means using the host, but I think that container
systems like Docker and `rkt` could provide ways to do this while still using a
managed container.  [The `rkt` fly Stage
1](https://coreos.com/rkt/docs/latest/running-fly-stage1.html) sorta works, as
you get to use a container you made, but running with full host privileges, but
it just sounds so difficult and frustrating to use fly to run gdb to debug
a container.

I *think* all that I would need would be a fresh container that has the
"to-debug" container mounted in /to-debug (or something, it could be
configurable) and has complete access to all of the processes in that container.
I suspect that to allow this containers would need to be more nested than they
are today in Docker and `rkt`, more like how
[`lmctfy`](https://github.com/google/lmctfy#container-names) had child
containers.

I definitely don't think we are there yet when it comes to container debugging,
and I think that there is a pattern yet to be realized that will make container
debugging more effective than even current systems where you simply have root on
a VM.
