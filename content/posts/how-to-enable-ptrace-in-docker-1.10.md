---
title: How to Enable ptrace in Docker 1.10
date: 2016-03-18T10:00:23
tags: [ziprecruiter, docker, ptrace, strace, seccomp]
guid: "https://blog.afoolishmanifesto.com/posts/how-to-enable-ptrace-in-docker-1.10"
---
This is just a quick blog post about something I got working this morning.
Docker currently adds some security to running containers by wrapping the
containers in both AppArmor (or presumably SELinux on RedHat systems) and
seccomp eBPF based syscall filters.  This is awesome and turning either or both
off is not recommended.  Security is a good thing and learning to live with it
will make you have a better time.

Normally [`ptrace`](http://linux.die.net/man/2/ptrace), is disabled by the
[default `seccomp`
profile](https://raw.githubusercontent.com/docker/docker/master/profiles/seccomp/default.json).
`ptrace` is used by the incredibly handy
[`strace`](https://en.wikipedia.org/wiki/Strace).  If I can't `strace`, I get
the feeling that the walls are closing in, so I needed it back.

One option is to disable seccomp filtering entirely, but that's less secure than
just enabling `ptrace`.  Here's how I enabled `ptrace` but left the rest as is:

## A handy perl script

```perl
#!/usr/bin/perl

use strict;
use warnings;

# for more info check out https://docs.docker.com/engine/security/seccomp/

# This script simply helps to mutate the default docker seccomp profile.  Run it
# like this:
#
#     curl https://raw.githubusercontent.com/docker/docker/master/profiles/seccomp/default.json | \
#           build-seccomp > myapp.json

use JSON;

my $in = decode_json(do { local $/; <STDIN> });
push @{$in->{syscalls}}, +{
  name => 'ptrace',
  action => 'SCMP_ACT_ALLOW',
  args => []
} unless grep $_->{name} eq 'ptrace', @{$in->{syscalls}};

print encode_json($in);
```

## In action

So without the custom profile you can see ptrace not working here:

```
$ docker run alpine sh -c 'apk add -U strace && strace ls'
fetch http://dl-4.alpinelinux.org/alpine/v3.2/main/x86_64/APKINDEX.tar.gz
(1/1) Installing strace (4.9-r1)
Executing busybox-1.23.2-r0.trigger
OK: 6 MiB in 16 packages
strace: test_ptrace_setoptions_for_all: PTRACE_TRACEME doesn't work: Operation not permitted
strace: test_ptrace_setoptions_for_all: unexpected exit status 1
```

And then here is using the profile we generated above:

```
$ docker run --security-opt "seccomp:./myapp.json" alpine sh -c 'apk add -U strace && strace ls'
2016/03/18 17:08:53 Error resolving syscall name copy_file_range: could not resolve name to syscall - ignoring syscall.
2016/03/18 17:08:53 Error resolving syscall name mlock2: could not resolve name to syscall - ignoring syscall.
fetch http://dl-4.alpinelinux.org/alpine/v3.2/main/x86_64/APKINDEX.tar.gz
(1/1) Installing strace (4.9-r1)
Executing busybox-1.23.2-r0.trigger
OK: 6 MiB in 16 packages
execve(0x7ffe02456c88, [0x7ffe02457f30], [/* 0 vars */]) = 0
arch_prctl(ARCH_SET_FS, 0x7f0df919c048) = 0
set_tid_address(0x7f0df919c080)         = 16
mprotect(0x7f0df919a000, 4096, PROT_READ) = 0
mprotect(0x5564bb1e7000, 16384, PROT_READ) = 0
getuid()                                = 0
ioctl(0, TIOCGWINSZ, 0x7ffea2895340)    = -1 ENOTTY (Not a tty)
ioctl(1, TIOCGWINSZ, 0x7ffea2895370)    = -1 ENOTTY (Not a tty)
ioctl(1, TIOCGWINSZ, 0x7ffea2895370)    = -1 ENOTTY (Not a tty)
stat(0x5564bafdde27, {...})             = 0
open(0x5564bafdde27, O_RDONLY|O_DIRECTORY|O_CLOEXEC) = 3
fcntl(3, F_SETFD, FD_CLOEXEC)           = 0
getdents64(3, 0x5564bb1ec040, 2048)     = 512
lstat(0x5564bb1ec860, {...})            = 0
lstat(0x5564bb1ec900, {...})            = 0
lstat(0x5564bb1ec9a0, {...})            = 0
lstat(0x5564bb1eca40, {...})            = 0
lstat(0x5564bb1ecae0, {...})            = 0
lstat(0x5564bb1ecb80, {...})            = 0
lstat(0x5564bb1ecc20, {...})            = 0
lstat(0x5564bb1eccc0, {...})            = 0
lstat(0x5564bb1ecd60, {...})            = 0
lstat(0x5564bb1ece00, {...})            = 0
lstat(0x5564bb1ecea0, {...})            = 0
lstat(0x5564bb1ecf40, {...})            = 0
lstat(0x5564bb1ecfe0, {...})            = 0
lstat(0x7f0df919e6e0, {...})            = 0
lstat(0x7f0df919e780, {...})            = 0
bin
dev
etc
home
lib
linuxrc
media
mnt
proc
root
run
sbin
sys
tmp
usr
var
lstat(0x7f0df919e820, {...})            = 0
getdents64(3, 0x5564bb1ec040, 2048)     = 0
close(3)                                = 0
ioctl(1, TIOCGWINSZ, 0x7ffea2895278)    = -1 ENOTTY (Not a tty)
writev(1, [?] 0x7ffea2895210, 2)        = 4
writev(1, [?] 0x7ffea2895330, 2)        = 70
exit_group(0)                           = ?
+++ exited with 0 +++
```

## A final warning

The above is not too frustrating and is more secure than disabling seccomp
entirely, but enabling `ptrace` as a general course of action is likely to be
wrong.  I am doing this because it helps with debugging stuff inside of my
container, but realize that for long running processes you can always `strace`
processes that are running in the container from the host.
