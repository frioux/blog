---
title: The Evolution of The Minotaur
date: 2019-01-14T07:33:50
tags: [ perl, golang, ziprecruiter, mitsi, meta, toolsmith ]
guid: 4e448322-1f08-4749-b8c2-607aac3dd5e4
---
I have a tool called The Minotaur that I just rewrote for the third time, and I
think, maybe, it's done.

<!--more-->

The Minotaur is a tool I wrote at [mitsi](http://mitsi.com/) in 2014 to
automatically restart services on my server when I modified relevant code.  Many
web frameworks have something like this, but the tooling tends to be built in to
frameworks instead of being general.

The first few versions ([visible
here](https://github.com/frioux/dotfiles/commits/master/bin/minotaur)) were all
variants on the same theme: restart one or more (runit) services when a file in
a tree changed.  Fairly soon after creating the tool I added debouncing, which
means that when a bunch of things change in quick succession they are bundled
into a single event, instead of triggering an event per change.  This is
important since text editors save files in multiple stages to prevent data loss.
I used this tool for a little under a year before moving on to ZipRecruiter.

About a year after I started at
[ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) I replaced the
built in Plack autorestart with The Minotaur.  Part of the reason for doing this
is that Plack preloads a bunch of Perl modules, so when it reloads the
application it doesn't reload those, since they are already in memory.  One
critical difference between The Mitsi Minotaur and The ZR Minotaur is that the
latter *is* a supervisor instead of communicating with another one.  I don't
love this, but it made it easier to add it to people's workflows.

While The Minotaur has been in use at ZipRecruiter it has gained a handful of
interesting features.  Here's a brief list:

 * `--check-script`: this script would receive the files that changed and exit 0
     or 1 to tell The Minotaur if it should restart the supervised service or not.
 * `--restart-script`: this script runs after restarting the supervised service
     to allow restarting other, ancillary services.
 * `--post-ready-script`: this allows you to delay the run of the restart
     script till the supervised script is running successfully.

There were also a number of interesting bug fixes, involving Epoll and sharing
the Epoll filedescriptor with Starman, and event loop and inotify interactions
causing dropped events.  I got help from Ben Grimm, Andrew Ruder, and James
Messrie for both the features and fixes above.  Thanks!

We are now working towards running production in Kubernetes, and part of that
means giving developers a way to work with their code that is similar to
production.  Docker development workflows vary, and only time will tell if this
one turns out well or not, but the idea is that The Minotaur runs outside of the
containers and reaches into the container to restart, recompile, or test the
actual code.

Because it needs to run on laptops or inside of containers (that might have
very minimal runtimes) requiring Perl and an event framework seemed the wrong
way to go about it.  Furthermore The Minotaur has only worked on Linux for ages due
to the direct use of Inotify, which would keep it from working on either OSX or
Windows.

So I decided I'd try my hand at reimplementing The Minotaur in Go, but
simplifying where I could.  Because it cannot be the parent process of the
restarted script anymore, I can remove the all the supervision code, which is
significant.

My initial thought was that I could get by with *just* the check and restart
scripts.  As I wrote the code I realized that the restart script runs right
after the check script (I hadn't gotten around to implementing post ready yet)
and that basically it would work just as well if I *only* ran the restart
script, but passed it the arguments so it could exit early if the relevant files
haven't changed.

With the model simplified so much, the interface becomes much simpler, at the
expense of a more complex (but more flexible) script.  Furthermore the script
doesn't have to deal with threading or asynchrony, so it's less likely to have
bizarre bugs.  [You can see the current code
here](https://github.com/frioux/leatherman/blob/d6ee85ce916e053ba7011a5eae4dd43dee3f9130/internal/tool/minotaur/minotaur.go).
Here's an example of how I have it set up while working on [the
`leatherman`](https://travis-ci.org/frioux/leatherman):

```bash
minotaur . -- ./internal/build-test
```

And then the script is:

```bash
#!/bin/sh

set -e

for arg in "$@"; do
   echo "$arg"
done | grep -E '\.go$'

go test ./...
go build ./cmd/leatherman/...
echo "Built new leatherman at $(date)"
```

I mentioned the more complex Minotaur that is currently in place at
ZipRecruiter; here's a script that could tie the pieces together (untested:)

First off we have these scripts that already work well:

 * `any-perl`: if any one of the scripts passed is perl, exits 0
 * `ready-devserver`: when the server is up and ready to serve traffic, exits 0
 * `restart-devserver-support`: restarts other services that support the dev
     server

Also I'm handwaving a `restart-devserver`, which would do something as simple as
`service devserver restart`, but inevitably be more complicated because
computers.

So these can be combined simply like this:

```bash
#!/bin/sh

set -e

any-perl "$@"
restart-devserver
ready-devserver
restart-devserver-support
```

The Minotaur also has the option to `-ignore` or `-include` directories based on
regular expressions.  Includes happen first, then ignores.  The default include
is everything, and the default ignore is stuff in a `.git` directory.  Out of
the box The Minotaur is quiet, only reporting on errors that cause a crash.  You
can pass `-verbose` to get more output.

The following would include any path that contains `pkg` but not any that
include internal, even if `pkg` is in the full path:
```bash
minotaur -include pkg -ignore internal -verbose . -- ./run-tests
```

Of course depending on your needs you could do some really interesting things
with the script, for example you might do something like this to avoid a slow,
expensive webserver restart:

```bash
#!/bin/sh

set -e

any-perl "$@"

files-compile "$@"
relevant-tests-pass "$@"

restart-devserver
ready-devserver
restart-devserver-support
```

And `files-compile` might look like this:

```perl
#!/usr/bin/perl

for (@ARGV) {
   my (undef, $file) = split /\t/, $_, 2;
   system $^X, '-c', $file
      or exit $?;
}
```

That exits non-zero if perl fails to compile any of the passed files.  I would
write the relevant scripts that The Minotaur runs in either the language being
supported (perl scripts for perl code, python scripts for python code) or shell
to ease bootstrapping.

---

I'm sure that there are plenty of file system watch tools out there, but in my
experience they tend to accrete features and bugs (like my own did!)
Maintaining a simple interface will hopefully prevent this.  Hopefully it lasts
another three years!

---

(The following includes affiliate links.)

Have you read <a target="_blank" href="https://www.amazon.com/gp/product/020161622X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=020161622X&linkCode=as2&tag=afoolishmanif-20&linkId=cd3192557c0d9cefe2e7cd4e8a0af0ba">The Pragmatic Programmer</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=020161622X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />?
It's one of the few tech books I've read all the way through and refer back to
once in a blue moon.  I strongly suggest checking it out, especially if you are
early in your carerr.

Another interesting book, which I intend to read solely based on authorship, is
<a target="_blank" href="https://www.amazon.com/gp/product/020161586X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=020161586X&linkCode=as2&tag=afoolishmanif-20&linkId=5aa3aa5ee9b868cf85aba4ac5258d003">The Practice of Programming</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=020161586X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
by Kernighan and Pike.  It might be a little dated with the focus of C and C++
but much of the concepts should apply everywhere.
