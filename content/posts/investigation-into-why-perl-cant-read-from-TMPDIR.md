---
title: "Investigation: Why Can't Perl Read From TMPDIR?"
date: 2016-06-30T00:33:10
tags: ["investigation", "perl", "ld.so", "linker", "TMPDIR"]
guid: 636c24f2-8466-4739-8b99-e856d33097ea
---
On Wednesday afternoon my esteemed colleague [Mark Jason
Dominus](http://blog.plover.com) ([who already blogged this very story, but from
his perspective](http://blog.plover.com/tech/tmpdir.html)), showed me that he had
run into a weird issue.  Here was how it manifested:

```
$ export TMPDIR='/mnt/tmp'
$ env | grep TMPDIR
TMPDIR=/mnt/tmp
$ /usr/bin/perl -le 'print $ENV{TMPDIR}'

```

So to be clear, nothing was printed by Perl.

<!--more-->

Another strange detail was that it happened in our development sandboxes, but not
in production.  I quickly reproduced it in my sandbox and verified with `strace`
that the env var was being set: (reformatted for readability)

```
$ strace -v -etrace=execve perl -le'print $ENV{TMPDIR}'
execve("/usr/bin/perl", ["perl", "-leprint $ENV{TMPDIR}"], [
  "HOME=/home/frew",
  "LANG=en_US.UTF-8",
  "LC_ALL=en_US.UTF-8",
  "LESSCLOSE=/usr/bin/lesspipe%s %"...,
  "LESSOPEN=| /usr/bin/lesspipe %s",
  "LOGNAME=frew",
  "LS_COLORS=rs=0:di=01;34:ln=01;36"...,
  "MAIL=/var/mail/frew",
  "NODE_PATH=/usr/lib/nodejs:/usr/l"...,
  "PATH=/usr/local/sbin:/usr/local/"...,
  "PWD=/home/frew",
  "SHELL=/bin/bash",
  "SHLVL=1",
  "SSH_AUTH_SOCK=/tmp/ssh-bbEAG2701"...,
  "SSH_CLIENT=10.30.1.183 22976 22",
  "SSH_CONNECTION=10.30.1.183 22976"...,
  "SSH_TTY=/dev/pts/2",
  "STARTERVIEW=/var/starterview",
  "TERM=screen-256color",
  "TMPDIR=/mnt/tmp",
  "USER=frew",
  "_=/usr/bin/strace"
]) = 0
```

It should be obvious that `TMPDIR` **is** included in the `execve` call above.
I knew that there had been a [recent security
patch](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-2381) related to environment
variables, so I ran `apt-get upgrade` in my sandbox and it fixed the issue!  But
in mjd's sandbox he had the same exact version of Perl (verified by running
  `sha1sum` on `/usr/bin/perl`.)  My sandbox is a local docker machine and his is
an EC2 instance, so *maybe* something there could be causing an issue.

My next idea was to ask around in #p5p; the channel where people who hack on the
core Perl code hang out on irc.perl.org.  I'm crediting the people who had the
first idea for a given thing to check.  There was a *lot* of repetition, so I'll
spare you and only list the initial time something is mentioned.

Lukas Mai aka Mauke chimed in quickly saying that I should:

 * print the entire environment (`perl -E'say "$_=$ENV{$_} for keys %ENV"'`)
 * use the perl debugger (`PERLDB_OPTS='NonStop AutoTrace' perl -d -e0`)
 * use ltrace

The first two of those were non-starters.  Nothing interesting happened.  Here
is the unabbreviated `ltrace` of the issue in question:

```
$ ltrace perl -le'print $ENV{TMPDIR}'
__libc_start_main(0x400c70, 2, 0x7fff1fa24e88, 0x400f30, 0x400fc0 <unfinished ...>
Perl_sys_init3(0x7fff1fa24d7c, 0x7fff1fa24d70, 0x7fff1fa24d68, 0x400f30, 0x400fc0) = 0
__register_atfork(0x7fad644a3c10, 0x7fad644a3c50, 0x7fad644a3c50, 0, 0x7fff1fa24ca0) = 0
perl_alloc(0, 0x7fad6440efb8, 0x7fad6440ef88, 48, 0x7fff1fa24ca0) = 0x2551010
perl_construct(0x2551010, 0, 0, 0, 0)               = 0x2558f60
perl_parse(0x2551010, 0x400eb0, 2, 0x7fff1fa24e88, 0 <unfinished ...>
Perl_newXS(0x2551010, 0x40101c, 0x7fad64550f80, 0x7fff1fa24b90, 0x7fad645532c0) = 0x2571b28
<... perl_parse resumed> )                          = 0
perl_run(0x2551010, 0x2551010, 0, 0x2551010, 0
)     = 0
Perl_rsignal_state(0x2551010, 0, 0x2551288, 0x2551010, 0x7fff1fa24c50) = -1
Perl_rsignal_state(0x2551010, 1, -1, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 2, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 3, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 4, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 5, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 6, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 7, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 8, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 1
Perl_rsignal_state(0x2551010, 9, 1, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 10, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 11, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 12, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 13, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 14, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 15, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 16, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 17, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 18, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 19, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 20, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 21, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 22, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 23, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 24, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 25, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 26, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 27, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 28, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 29, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 30, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 31, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 32, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = -1
Perl_rsignal_state(0x2551010, 33, -1, 0x7fad6408a1b5, 0x7fff1fa24cb0) = -1
Perl_rsignal_state(0x2551010, 34, -1, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 35, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 36, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 37, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 38, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 39, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 40, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 41, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 42, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 43, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 44, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 45, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 46, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 47, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 48, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 49, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 50, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 51, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 52, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 53, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 54, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 55, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 56, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 57, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 58, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 59, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 60, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 61, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 62, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 63, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 64, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 6, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 17, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 29, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
Perl_rsignal_state(0x2551010, 31, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
perl_destruct(0x2551010, 0, 0, 0x7fad6408a1b5, 0x7fff1fa24cb0) = 0
perl_free(0x2551010, 0xffffffff, 0x2551010, 0x7fad6440b728, 0x7fad6478e0c0) = 2977
Perl_sys_term(0x7fad6440b720, 0, 0x7fad6440b778, 0x7fad6440b728, 0x7fad6478e0c0) = 0
exit(0 <unfinished ...>
+++ exited (status 0) +++
```

I still have yet to have `ltrace` actual help me with debugging.  More on that
later.

Next Ricardo Jelly Bean Signes mentioned that I should try diffing the
environment.  As expected the only differences were `TMPDIR` being missing, and
`_` being `/usr/bin/perl` or `/usr/bin/env` respectively.

Dominic Hargreaves looked closely at the patch (which he had ported to the
version of Perl in question) and verified that it shouldn't be causing what we
were seeing.

At this point I decided to attempt to bisect a build of Perl to figure out the
cause of the problem.  Here's what I did:

```
git clone git://anonscm.debian.org/perl/perl.git -b wheezy
make -f debian/rules build
```

I ctrl-c'd the tests, since I knew Perl was built at that point.  When I did
`TMPDIR=foo ./perl -E'say $ENV{TMPDIR}'` it "worked" and printed `foo`.  I
tried this both on a proper virtual machine, on my docker based sandbox, and on
the metal of my laptop.  None reproduced the problem.  Bummer.  I went home
frustrated, without any answers.

The following morning I mentioned my progress in #p5p to see if anyone had any
other ideas.

Todd Rinaldo verified that I wasn't running perl under [taint
mode](http://perldoc.perl.org/perlsec.html#Taint-mode).  I wasn't, but that's a
great question.  If you don't know about taint mode, read the above.  It could
reasonably cause something like this.  He also had me verify that env vars like
`TMPDIRA`, `TMPHAH`, etc didn't have the same issue (they did not.)

Matthew Horsfall had me compile and run the following code, to ensure that it
worked like `env`.  It did.

```
#include <unistd.h>
#include <stdio.h>

extern char **environ;

void main(void) {
  int i;

  for (i = 0; environ[i]; i++) {
    printf("%s\n", environ[i]);
  }
}
```
Matthew also verified what shell this happened under.  I confirmed that it
happened under both the GNU Bourne-Again Shell and the Debian Almquist Shell.

Next Andrew Main, more commonly known as Zefram, asked if I had a
`sitecustomize.pl`.  I did not.

Zefram next said I should try using `gdb` to inspect the running process.  I
needed some hand holding, but basically I did the following:

```
# install gdb
$ apt-get install gdb

# install debug headers
$ apt-get install libc6-dbg

$ gdb --args /usr/bin/perl -E 'say $ENV{TMPDIR}'
(gdb) break main
Breakpoint 1 at 0x41ca90
(gdb) run
Starting program: /usr/bin/perl perl -Esay\ \$ENV\{TMPDIR\}
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, 0x000000000041ca90 in main ()
(gdb) p environ[0]
$1 = 0x7fffffffe4df "XDG_SESSION_ID=c2"
(gdb) p environ[1]
$2 = 0x7fffffffe4f1 "TERM=screen-256color"
(gdb) p environ[2]
$3 = 0x7fffffffe506 "DISPLAY=:0"
[ etc etc ]
```

I iterated over the entire array (till I got to an empty entry) and there was no
`TMPDIR`.  Zefram then had me verify that [my EUID and my
UID](http://linux.die.net/man/7/credentials) matched.  I used both `id` and
`perl -E'say "$<:$>"'` to show that they did match.  Zefram then asked if
`LD_LIBRARY_PATH` had the same problem as `TMPDIR`, and it did!

```
11:00:12      Zefram | something is cleansing the environment for security reasons
```

Andrew Rodland commonly known as hobbs linked me to [a bug detailing and
explaining the issue](https://bugzilla.redhat.com/show_bug.cgi?id=129682#c1).

The subtle reason why Dominus didn't figure this out in the beginning is, unlike
the issue above, the binary here is not actually `setuid`.  Instead, it has what
Linux calls [capabilities](http://linux.die.net/man/7/capabilities), which are
sortav root privileges broken down into discrete pieces.  Sadly that means
`ls -l` does not show them.  In fact there is no flag to pass to `ls` to show
them, so they are easily missed.

In our developer sandboxes we add a capability to `/usr/bin/perl` to allow it to
listen on low ports, so that developers can access their web application without
needing to run Apache or some other proxy.  We have plans to add a proxy for
performance reasons in development anyway, but in the meantime I plan on adding
some rules with `iptables` and removing the capability, to resolve this issue.

Here's a funny side note to all of this: this capability has been added to our
binary since 2013.  Dominus ran into a problem with it Wednesday.  *Another*
coworker also ran into it two days later, for totally different reasons.

## One more layer

One important thing I learned in this investigation is that there is this mostly
invisible and unspoken layer: the dynamic linker.  I vaguely knew that there was
this thing that wires together binaries and their dynamic libraries, but I never
really considered that there was more to it than that.  [The manpage of the
dynamic linker](http://man7.org/linux/man-pages/man8/ld.so.8.html) has lots of
details, but in this case the important section is:

```
   Secure-execution mode
       For security reasons, the effects of some environment variables are
       voided or modified if the dynamic linker determines that the binary
       should be run in secure-execution mode.  This determination is made
       by checking whether the AT_SECURE entry in the auxiliary vector (see
       getauxval(3)) has a nonzero value.  This entry may have a nonzero
       value for various reasons, including:

       *  The process's real and effective user IDs differ, or the real and
          effective group IDs differ.  This typically occurs as a result of
          executing a set-user-ID or set-group-ID program.

       *  A process with a non-root user ID executed a binary that conferred
          permitted or effective capabilities.

       *  A nonzero value may have been set by a Linux Security Module.
```

I have spent a little time while writing this post reading that manpage and
playing with some of various options.  This is kinda cool:

```
$ LD_DEBUG=all /bin/ls
```

The amount of output is significant, so I'll leave running the above as an
exercise for the reader.

## Useful and (maybe?) not useful abstractions

The other thing that this investigation reinforced is my belief that not all
abstractions and layers are important and useful.  I have used `strace`
countless times and almost every time I use it it tells me what I need to know
("what port is this program listening on?", "where is this program's config
file?", "What is this program blocking on?") `strace` shows what system calls
are being executed.  To learn more read either [some blog posts about
strace](http://jvns.ca/) or read [the
manpage](http://www.man7.org/linux/man-pages/man1/strace.1.html).

Contrast that with `ltrace`.  `ltrace` shows what library functions are being
called.  Bizarrely (to me) depending on the version of `ltrace` being run it can
be either just a little bit shorter than the output of `strace` (that's what
happened while debugging above) or hugely more (on my laptop right now `ltrace
/usr/bin/perl -E'say $ENV{TMPDIR}' 2>&1 | wc -l` is over six thousand, while the
`strace` version is not even three hundred.)  Maybe it depends on what debug
symbols are installed?  I don't know. While it may be helpful to some to see
this:

```
memmove(0x1e14e10, "print $ENV{TMPDIR}\n", 19)            = 0x1e14e10
__memcpy_chk(0x7ffd946385a1, 0x1e14c28, 5, 256)           = 0x7ffd946385a1
strlen("%ENV")                                            = 4
memchr("%ENV", ':', 4)                                    = 0
malloc(10)                                                = 0x1e16150
```

I suspect it is not important to most.

This is not to say that `ltrace` is worthless; it just is much more niche than
`strace`.  I would argue that `strace` is a tool worth using while writing code
for almost any engineer.  Yet in a decade of professional problem solving I have
not been helped by `ltrace`.

---

I hope you enjoyed this.  It was fun to experience and to learn about `ld.so`.
Thanks go to all the people mentioned above.  If you liked this but haven't
already read [the post linked above, authored by
MJD](http://blog.plover.com/tech/tmpdir.html), go do that now.
