---
title: Perl, Linux Namespaces, and Pedestrian Problems
date: 2016-09-12T07:36:10
tags: [ perl, ziprecruiter, linux, namespaces, docker ]
guid: 1253CAAE-77D5-11E6-996D-DD58250DE0B1
---
At [ZipRecruiter](https://www.ziprecruiter.com/) we have a problem that I
suspect is fairly common.  We use cronjobs for various tasks and sometimes a
cronjob will fail to clean up after itself and end up filling up a partition.
It's annoying.  I solved this by using some simple but poorly supported Linux
features.

<!--more-->

## The Goal

I want to be able to run a program with `/tmp` as a bindmount to some other
directory, but only for that program.  [Last year I wrote about
`unshare`](/posts/pid-namespaces-in-linux/), and while that tool helped me know
what to do, it's too coarse to reasonably use.  If I were to use it I'd have to
break a single tool (create tmpdir, set up namespace, set up bindmount, exec)
into two programs.  While that would work, especially for this usecase, it would
be useful to be able to set up the bindmount from within a master daemon that
has already preloaded all the libraries for the child worker, for very efficient
memory usage. It seemed like I could do better, so I sought out to do better!

## False starts

The fundamental system call for creating namespaces is `unshare(2)`.  With that
in mind I searched CPAN and found
[Linux::Unshare](https://metacpan.org/pod/Linux::Unshare), which gives a
completely reasonable interface to the `unshare` system call.  Unfortunately it
fails it's tests, and even if you skip them it fails in action the same way.  In
case anyone is Googling, here's the error:

```
Your vendor has not defined Linux::Unshare macro CLONE_NEWNS
```

I didn't look a whole lot closer because I knew that I could call any system
call with a little bit of effort, no XS or C needed.

## Arbitrary System Calls

[There's a legendary post on the packagecloud blog about system calls
](http://blog.packagecloud.io/eng/2016/04/05/the-definitive-guide-to-linux-system-calls/).
I read it a while ago when it made the rounds but the main takeaway was this:

A system call is just a number; it is not magic, and using system calls that
don't already have predefined wrapper functions can be used with fairly minimal
effort.

The generic system call interface in Perl is simple.  First off, [you use the
`syscall` subroutine](http://perldoc.perl.org/functions/syscall.html).  Next you
need the magic numbers that define syscalls and their various flags.  In C you'd
load headers; in Perl there is a [fairly elegant tool called
`h2ph`](http://perldoc.perl.org/h2ph.html) which can parse the headers and
create Perl files that have all the constants baked in.  Here's how you use it:

```
cd /usr/include
h2ph -a syscall.h
```

Chances are you'll need more than just that header, but that's the general
interface.  I initially assumed that `h2ph -a /usr/include/syscall.h` would
work, but the argument needs to be relative to the current directory, so you
need to change into the `/usr/include` directory.

Once the above block of code has been run, in your script you pull in the
constants and then use them (and some others) like this:

```
# normally you'd use POSIX::access for this, but it's an easy example

require 'syscall.ph';

# these headers are mentioned in access(2), that's the only reason I knew to use
# them
require 'fcntl.ph';
require 'unistd.ph';

my $path = shift;
say "$path is writeable"
      if syscall(SYS_access(), $path, W_OK()) != -1;
```

If you were in some weird situation where you couldn't run `h2ph`, as long as
you are on the same architecture I'm pretty sure it would be ok to hardcode the
constants yourself, manually getting them from the C header files, or the `.ph`
files that you have now but won't have later:

```
# constants for amd64

sub SYS_access () { 21 }
sub W_OK() { 2 }

my $path = shift;
say "$path is writeable"
      if syscall(SYS_access(), $path, W_OK()) != -1;
```

Another way to get the values of constants like the one above is to use `strace`
with the `-e raw` flag.  If you already have a working program that makes the
call you're trying to replicate, you'd run something like this:

```
strace -e raw=access SOME-PROGRAM
```

And the call to `access` would have the literal numbers shown (though with
strings it's just not enough information.)

## Creating the Mount Namespace

With the tools and techniques explained above we now have everything we need to
build the temporary bind mount described in the beginning of this post.  The
first thing I did was `strace` `unshare(1)` so that I could figure out what
system calls I'd need to use:

```
$ sudo strace /usr/bin/unshare --mount ls -lh

[ ... ]
unshare(CLONE_NEWNS)                    = 0
mount("none", "/", NULL, MS_REC|MS_PRIVATE, NULL) = 0
[ ... ]
```

The first system call, `unshare`, is the creation of the namespace.  The second
one is probably worth an entire blog post on its own, but for now I'll just say
that you have to do that for the new namespace to actually make any sense in
this situation.  And that's it!  Here's the final program:

```
# We start as root and the drop to $user
my $user = shift;
my @command = @ARGV;

# SYS_* system call ids
require 'syscall.ph';

# CLONE_* flags
require 'linux/sched.ph';

# MS_* flags
require 'sys/mount.ph';
syscall SYS_unshare(), CLONE_NEWNS();

my $none = "none";
my $root = "/";
syscall SYS_mount(), $none, $root, 0, MS_REC() | MS_PRIVATE();

my $tmpdir = File::Temp->newdir();

# bind mount the temp dir, cargo culted from mount --bind
my $tmp = '/tmp';
syscall SYS_mount(), $tmpdir, $tmp, 0, MS_MGC_VAL() | MS_BIND();

my (undef, undef, $uid, $gid) = getpwnam $user;
chown $uid, $gid, $tmpdir, '/tmp';

# From experience I know that sudo does a lot of things I do not want to
# reimplement.  If we were doing the master/worker pattern described above we'd
# need to go through the effort to drop privileges after a fork instead of during
# exec
system qw(sudo -u), $user, '--',  @command;

File::Path::rmtree( $tmpdir )
```

---

That wasn't so hard, and it didn't require Docker koolaid, was efficient, and
was a single simple script.  I am pleased to be able to say that I successfully
achieved the goal mentioned [at the end of my pid namespaces
post](/posts/pid-namespaces-in-linux/).  I hope that this made it clear that
these seemingly esoteric Linux features are well within reach and generally
useful.
