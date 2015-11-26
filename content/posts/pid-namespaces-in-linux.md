---
title: PID Namespaces in Linux
date: 2015-11-25T20:32:03
tags: ["linux", "namespaces", "cgroups"]
guid: "https://blog.afoolishmanifesto.com/posts/pid-namespaces-in-linux"
---
One of the tools I wrote shortly after joining
[ZipRecruiter](https://www.ziprecruiter.com) is for managing a Selenium test
harness.  It's interesting because there are a lot of constraints related to
total capacity of the host, desired speed of the test suite, and desired
correctness of the codebase.

Anyway one of the major issues that I found was if I stopped a test prematurely
(with Ctrl-C, which sends a SIGINT) I'd end up with a bunch of orphaned workers.
My intial idea was to just forward along any signal that the process received to
the child workers (minus some obvious ones like CHLD and WINCH) but that ended
up causing problems, because the workers had many children of their own and they
did not handle the situation correctly either.

There are a couple ways to do this.  The first way is I *think* portable across
unices; this involves giving the main process a TTY of it's own.  This will send
all child processes (recursively, I think) a SIGHUP (as in the TTY hung up) when
the main process exits.  Here's the code, it's pretty easy to do in Perl, though
I have not gone through the effort to figure out how to do it with vanilla
shell.

```
use IO::Pty;

my $pty = IO::Pty->new;
$pty->make_slave_controlling_terminal;
```

The other way, which you may have guessed if you read the title of this post, is
using a Linux PID namespace.  In a PID namespace you basically start a process
and it sees itself as PID 1 (aka init).  All child processes are in the
namespace as well and will have similarly "low" PIDs themselves.  This is not
really interesting for our use case.  The interesting thing is, if PID 1 of a
Linux PID namespace exits, all children get a SIGKILL.  Unlike SIGHUP, SIGKILL
cannot be ignored, and the processes will definitely go away, and it will be
immediate (unless they are in uninteruptable sleep I guess.)

PID namespaces have been around for like, forever (2008, which at this point is
nearly eight years.)  The problem is you can only create one as root, which is a
hassle to say the very least.  Now if you create a user namespace you do not
need root, but that requires Linux 3.8, which is from 2013; pretty recent!
Here's an example of how to start a program in a PID namespace:

```
unshare --pid --user --mount --mount-proc --fork ./my-app
```

The first two flags should be obvious.  The mount related flags are so that the
processes inside of the namespace can read from `/proc` and find out about
whatever details they might need to know.  If you are sure your processes never
read from `/proc` you can safely elide those flags. The fork flag is because
creating the pid namespace around a running process doesn't really work.

`unshare` comes from the [util-linux](https://en.wikipedia.org/wiki/Util-linux)
package, which any real (read: non-embedded) Linux distro ships with.  To be
clear: the above command is *really* light weight.  The meat of it clocks in at
two system calls (`unshare` and `clone`.)  The whole thing adds about 5ms to
runtime.  I think of `unshare` as a much more powerful `fork`.  At some point I
would like to make using it from within a language as easy as `fork`.

If you want to try this out, I've [written more including some test scripts on
github](https://github.com/frioux/container-play/).
