---
title: C, Golang, Perl, and Unix
date: 2018-05-01T07:14:18
tags: [ golang, unix, perl, c ]
guid: 7f5012a4-e609-439a-949c-b02649dd2ee7
---

Over the past couple months I have had the somewhat uncomfortable realization
that some of my assumptions about *all programs* are wrong.  Read all about the
journey involving Unix, C, Perl, and Go.

<!--more-->

## Unix Process Model Foundations: `fork(2)` and `execve(2)`

Before going into any of this I need to make sure that you understand the Unix
Process Model.  The main detail I want to communicate is how `fork` and `exec`
can be used in conjunction.

If you've never used `fork` before you will likely find it incredibly alien.  To
anyone who uses high level languages it seems like it should take a code
reference or something.  After you call `fork` your process has branches into
the child and the parent.  The child sees a `0` as the return code from `fork`
and the parent sees some other number, which is the process id of the child.
(This ignores the error case, which does not add to the discussion here.)

``` perl
my $pid = fork();
if ($pid == 0) {
   # this is a child process
} else {
   # this is the parent
}
```

After `fork`ing, *almost everything* is the same.  In fact, the documentation
for `fork(2)` (at least on Linux) primarily documents what is *not* the same.
All the files that were open in the parent are open in the child.  All the
signal handlers are still in place.  In fact even the memory is the same, but
it's not shared.  There are more inherited things I've not had to (gotten to?)
play with.

When you run a totally new program you use `exec` after `fork`ing.  The `exec`ed
process does not have the memory of the parent, but does have the file
descriptors and some of the signal handlers.

You can see some of the effect of this with snippets like this:

In the following code, `cat` (or any child process) would ignore a `SIGHUP`:

``` perl
$SIG{HUP} = 'IGNORE';
system q(cat /proc/self/status | grep '^Sig');
```

Compare the output of the above to simply running
`cat /proc/self/status | grep '^Sig'` in your shell.

In the following code we open `/etc/passwd` and we can see that `ls` also has it
open:

``` perl
use Fcntl;
open my $fh, '<', '/etc/passwd'
  or die "open: $!";

# ensure that the log doesn't get closed on exec
fcntl $fh, F_SETFD,
  fcntl($fh, F_GETFD, 0) &~ FD_CLOEXEC;

system q(ls -l /proc/self/fd);
```

Super quick note about the file descriptors above, only because it will be a
little relevant later: STDIN, STDOUT, and STDERR are simply file descriptors 0,
1, and 2 (respectively.)  Supposedly those constants can change from system to
system, so you might want to use whatever constant your compiler has.  Here's a
way to see the fact that 0, 1, and 2 are just the normal file descriptors:

```
$ ls -l /proc/self/fd </etc/passwd 2>/dev/null
total 0
lr-x------ 1 frew frew 64 Apr 28 22:28 0 -> /etc/passwd
lrwx------ 1 frew frew 64 Apr 28 22:28 1 -> /dev/pts/7
l-wx------ 1 frew frew 64 Apr 28 22:28 2 -> /dev/null
lr-x------ 1 frew frew 64 Apr 28 22:28 3 -> /proc/135798/fd
```

You can see that `0` (STDIN) is reading from `/etc/passwd` instead of the tty,
and `2` (STDERR) is writing to `/dev/null`.  We leave STDOUT alone so we can see
the output.

### Neat Applications

There are a lot of cool ways you can take advantage of this.  One obvious, very
basic way is to open a log file in append mode.  All newly forked child
processes will inherit the file descriptor and be able to atomically append
(depending on size of your `write(2)`s and capabilities provided by your OS.)

Another use of inheriting file descriptors is UCSPI, which [I wrote about a
couple of years ago](/posts/ucspi/).  Really though, a huge amount of the modern
[djb inspired init systems](/posts/supervisors-and-init-systems-2/) leverage
these details to allow simple tools (the Unix philosophy) to function within the
Unix Process Model (or the Unix Environment.)

### Bizarre Bugs

On the other hand, these behaviours can be surprising if you are not aware of
them.  A couple of years ago at work we had a really bizarre bug.  The cause was
that our web server (which does a bunch of stuff before forking off a few dozen
workers) was connecting to memcache before the fork, and the children were
*inheriting the socket.*  Honestly, I don't even know all of the implications of
this.  I know that (at least in Perl) database wrappers typically detect a fork
and reconnect because things will not go well for you if you keep using the same
file descriptor (which is a shared TCP socket.)

I suspect this can work for very simple, single `write(2)`, line based protocols
where interleaving with the other children is not possible, but even then I'm
not sure how the children would get the response from the other end.

## Pomotimer and My "hesitating at the angles of stairs" Moment

As discussed a couple times now I am working to [port some of my personal kit to
Go.][lm]  One of the tools I ported recently is called `pomotimer`.  [I
originally used this tool][pt1] [when I was doing the pomodoro technique][pt2].
While I have both [abandoned the pomodoro technique][pt3] and [completely
reimplemented the set of tools I used before][pt4], `pomotimer` is still a
really convenient tool.

`pomotimer` takes a duration (as in `3m20s`) and updates a "remaining time" view
every second.  Every thirty seconds it updates the tmux title, so if you aren't
looking right at it the window will be called something like `PT5:30`.  You can
press `!` to abort the timer, `p` to pause it, and `r` to reset it entirely.

Originally the tool was written with [IO::Async][ia] in Perl.  Migrating to Go,
despite being written in a totally different style, was not hard... Except for
the tmux title feature.  In Perl (and many other languages) you can set the
process title (see `setproctitle(3)`) with a simple assignment to `$0`:

``` perl
$0 = "program name"
```

The benefit is that under `ps(1)`, `top(1)`, and in this case, `tmux(1)` itself,
the program will show up with the name you choose.  I have used this trick in
web servers so that the workers show which URL they are servicing when you look
at `ps`.  Pretty handy!

Go does not have a built in `setproctitle(3)` mechanism, but people have built
[libraries][gspt] to do it as well as [written simple snippets][snippet].  When
I ported `pomotimer` to Go I figured I would simply use one of the above and be
on my way.  The hard part is the timer and keyboard interaction, right?

Wrong.  I found that sometimes setting the title worked, and sometimes it
didn't.  When I looked closely, it appeared to be because Go was scheduling the
`prctl(2)` code to run in one of the threads.  This meant that while the thread
got named, the main process did not.  Go specifically reserves the right to
reschedule your goroutine onto other OS threads, so bouncing from one thread to
another does happen.  (The linked library uses a different, hackier, but more
reliable method.)

What I realized when all this was happening is that Go is not a simple "client
Unix language," exposing various system calls and abstractions to the
programmer.  Go is far stranger, in the world of Unix.  What I didn't realize
was how much I had taken for granted the fact that Perl, my daily driver for
decades, is nestled close to both Unix and C with respect to memory model and
process model.

I am not sure if I would have noticed this if it weren't for [Mike Conrad's post
about Perl][hp].

[lm]: /posts/benefits-using-golang-adhoc-code-leatherman/
[pt1]: /posts/the-pomodoro-technique/
[pt2]: /posts/the-pomodoro-technique-three-years-later/
[pt3]: /posts/getting-things-done/
[pt4]: /posts/a-love-letter-to-plain-text/
[ia]: /posts/concurrency-and-async-in-perl/#io-async
[gspt]: https://github.com/ErikDubbelboer/gspt
[snippet]: https://stackoverflow.com/a/14943149
[hp]: https://opensource.com/article/18/1/why-i-love-perl-5

### The Right Tool for the Job

Languages are built with use-cases in mind.  Whether you like Perl or not, it is
fairly clear that it is optimizied more for one-liner commandline scripts than
almost anything else, except `sed(1)` and `awk(1)`.  I remember reading in
either 
<a target="_blank" href="https://www.amazon.com/gp/product/0596004923/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0596004923&linkCode=as2&tag=afoolishmanif-20&linkId=7fadf4094e0bbda6293e4b61dc671f5a">The Camel Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0596004923" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
or
<a target="_blank" href="https://www.amazon.com/gp/product/1491954329/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1491954329&linkCode=as2&tag=afoolishmanif-20&linkId=c43bdc7818561a127b01304f6499fe0b">The Llama Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1491954329" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
about twenty years ago: "if you
implement your favorite sort algorithm in Perl and then find that it is slow, do
not be surprised.  That's like using a violin as a hammer."

Go is no exception here.  Go is built to be fast, simple, and concurrent.  Go is
not built to match the Unix and C semantics.

---

## Tsar

At work we have this tool called `tsar`; it exists to capture STDOUT and STDERR,
unmerged, and log them to datestamped files.  You could think of it as a
[multilog][ml] on steroids.  Unlike `multilog`, `tsar` handles running the
actual service in question, so that it can easily maintain separate pipes for
STDERR and STDOUT.  Unfortunately we found that it is very difficult to follow
both STDOUT and STDERR, bubble up error codes, and forward signals, without race
conditions.

Instead of spending hours trying to fix the actual problems, we decided to
vastly simplify `tsar`...

[ml]: https://cr.yp.to/daemontools/multilog.html

### Iconoclastic `fork`/`exec`

If you have code that runs another program, almost universally the pattern is
as follows (likely abstracted:)

``` perl
my $pid = fork();
if ($pid != 0) {
   # parent waits for child to return
   waitpid(...)
} else {
   # child runs whatever program
   exec('/bin/ls', '/home')
}
```

(As before, error handling left out for clarity.)

But you don't have to `exec` in the child!  If you `exec` in the parent, you can
create a child process of an unsuspecting parent.  Imagine we want to capture
the output of some third party program.  You can arrange to receive STDOUT and
STDERR on a couple of pipes, fork, exec the child (like `tsar`) *and in the
parent, `exec` the third party program*.

## The C That Worked

Because Go is implemented as a runtime executing code across multiple threads,
calling `fork(2)` will not work the way that we would need to do the above.
`fork(2)` splits a single thread in two, not a VM in two.  Furthermore, you
cannot call `exec(2)` on any thread other than the main one.  So ultimately
implementing this pattern directly in Go (such that the child process does not
have to be `exec`'d, to be clear) ends up with a single threaded runtime as the
child.  (Note: for kicks [I *did* actually implement][fork] a forking thing in Go and
was not able to break the child process in ways I expected.)

[fork]: #forking-go

Perl would work, because Perl is a relatively thin layer on C, when it comes to
this kind of thing.  We decided to write it in C to avoid forcing containers to
have Perl installed.  I wrote it in C and it compiled, ran, and worked without
flaw the first try.  I will forever be proud of this surprising twist of fate.

Here's the meat of the C, slightly simplified:

``` c
int main (int argc, char **argv) {
  const int READ = 0;
  const int WRITE = 1;
  int pid, oldpid;
  int errpipefd[2];
  int outpipefd[2];
  char errenv[16];
  char outenv[16];

  oldpid = getpid();

  do_pipe(outpipefd);
  do_pipe(errpipefd);
  
  pid = fork();
  if (pid > 0) {
      // service
      do_close(errpipefd[READ]);
      do_close(outpipefd[READ]);
      do_dup2(errpipefd[WRITE], STDERR_FILENO);
      do_close(errpipefd[WRITE]);
      do_dup2(outpipefd[WRITE], STDOUT_FILENO);
      do_close(outpipefd[WRITE]);
      do_exec(service);
  }

  // tsar-logger
  do_close(STDIN_FILENO);
  do_close(errpipefd[WRITE]);
  do_close(outpipefd[WRITE]);
  
  sprintf(errenv, "%d", errpipefd[READ]);
  sprintf(outenv, "%d", outpipefd[READ]);
  
  setenv("TSARERRFD", errenv, 1);
  setenv("TSAROUTFD", outenv, 1);
  setenv("TSAR_RUNNING", "1", 1);
  
  execv("tsar-logger");
  
  fprintf(stderr, "tsar wrapper: exec %s failed: %s (%d)\n", argv[0], strerror(errno), errno);
  
  kill(oldpid, SIGTERM);
  
  exit(2);
}

static void
do_close(int fd) {
    if (close(fd) == -1 ) {
        fprintf(stderr, "tsar wrapper: close(%d) failed: %s (%d)\n", fd, strerror(errno), errno);
        exit(2);
    }
}
```

All of the `do_` methods follow the general pattern above.  Most of the error
handling is left out of the above.  If the `tsar-logger` fails to `exec(2)` we
are in a particularly tough spot, where if the service doesn't check the return
value when it writes to `STDOUT` or `STDERR` it will just keep running forever.
In an effort to maintain simplicity but also protect against this, we send a
`TERM` signal to the parent.  If it ignores `TERM` or *that* fails... oh well,
there's only so much you can do, right?

### Basic Logger Examples

Here are a couple simple loggers I made to test the code above.  I only handled
one pipe at a time, but with Go it should be trivial to follow both.  With Perl
it could be done without a ton of effort with `select(2)`.  Here's the Perl
version:

``` perl
open my $stdout, '<&', $ENV{TSAROUTFD}
   or die "couldn't open TSAROUTFD: $!\n";

while (<$stdout>) {
   print localtime . " --> $_"
}
```

And here's the Go version:

``` go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"time"
)

func main() {
	fd, err := strconv.Atoi(os.Getenv("TSAROUTFD"))
	if err != nil {
		fmt.Printf("Couldn't parse TSAROUTFD: %s\n", err)
		os.Exit(3)
	}
	outPipe := os.NewFile(uintptr(fd), "outPipe")

	scanner := bufio.NewScanner(outPipe)
	for scanner.Scan() {
		fmt.Println(time.Now().Truncate(time.Second), "-->", scanner.Text())
	}
}
```

---

I really enjoyed this little adventure.  I've only written C professionally a
couple of times, and this was a rewarding and interesting little project.  I
also very much enjoy the mental shifts when I realize that something I have been
taking for granted is actually false.

---

There is so much that you can read to learn more about all of this stuff, aside
from your friendly local manpages.  As I've mentioned before, to learn more
about Go, I strongly recommend
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=7a70d548d8d1ab0e0baf86848938c69a">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's one of the best language oriented programming books I've ever read, and one
of the best on it's own.  I suggest reading it even if you already know Go in
and out.

For the Unix stuff discussed here,
<a target="_blank" href="https://www.amazon.com/gp/product/0321637739/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321637739&linkCode=as2&tag=afoolishmanif-20&linkId=7bd3c2f425b028d35421efcca702aaaa">Advanced Programming in the UNIX Environment (aka Stevens)</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321637739" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
is the canonical resource.  It can be a bit slow but will definitely help fill
in the various gaps you may have in your mental model.

## Forking Go

This worked for me; would be interested in hearing where it breaks for others:

``` go
package main

import (
	"fmt"
	"golang.org/x/sys/unix"
	"os"
	"os/exec"
	"syscall"
	"time"
)

func main() {
	pid, _, err := unix.RawSyscall(syscall.SYS_FORK, 0, 0, 0)
	if int(pid) == -1 {
		fmt.Println("Failed to fork:", err)
		os.Exit(1)
	}

	if pid == 0 {
		child()
	} else {
		parent(int(pid))
	}
}

func parent(childPid int) {
	fmt.Println("I'm the parent")
	unix.Wait4(childPid, nil, 0, nil)
	fmt.Println("baby returned")
}

func child() {
	fmt.Println("I'm the baby, gotta love me!")
	time.Sleep(1 * time.Second)
	out, err := exec.Command("date").Output()
	if err != nil {
		fmt.Println("failed to run date:", err)
		os.Exit(1)
	}
	fmt.Printf("The date is %s\n", out)

	ch := make(chan bool)
	go func() {
		<-ch
		fmt.Println("in a goroutine!")
	}()
	ch <- true
}

```
