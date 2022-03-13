---
title: Reliably Cross Compiling Go using Zig
date: 2022-03-13T16:08:00
tags: [ "golang", "zig", "frew-warez" ]
guid: e51fd024-1f5f-4064-91d8-b8d5c423704b
---
Do you ever need a C library to cross compile in Go?  I got something to work
this week that makes me feel better about my cross-compilation setup.

<!--more-->

*Note: I'm trying to reduce the amount of time I spend writing and editing blog
posts.  If the change in style bothers you (or delights you!) I'd be happy to
hear it.*

Historically I have preferred writing pure Go to cgo, because once you use cgo
you have many of the issues you get from C.  I have this Go based multitool
([leatherman](https://github.com/frioux/leatherman)) that I compile for a few
targets but use with Linux on amd64 and arm.

Sadly, at some point when I compiled my Go from CICD I ended up with a binary
that wouldn't run due to a libc mismatch.  I vaguely recall that to resolve
this problem I ended up moving away from SQLite to a [bizarro SQLite compiled
from C to Go](https://modernc.org/sqlite), which then of course gets compiled
to machine code.  It works surprisingly well!

But this makes me nervous.  SQLite is great, but it has a closed source
component: the rigorous tests that it undergoes, which this port does not have.
With that in mind, I was thinking it'd be cool to try switching back to cgo,
but build a static binary instead...

I had seen [Zig Makes Go Cross Compilation Just
Work](https://dev.to/kristoff/zig-makes-go-cross-compilation-just-work-29ho)
and wanted to try it for this purpose.  As of Go 1.18 (currently in beta) the
instructions mostly work, but there's a little bit of unaddressed complexity.

As a quick demo, here's me building my code (after swapping back to [cgo
SQLite3](https://github.com/mattn/go-sqlite3) and updatting my connection
code) with regular go build and inspecting the binary:

```bash
$ GOOS=linux GOARCH=amd64 go build                                          
$ ldd ./leatherman
        linux-vdso.so.1 (0x00007ffc88fb3000)
        libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f7626a9d000)
        libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f7626a97000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f76268a5000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f7626ae5000)
$ ls -lh ./leatherman
-rwxrwxr-x 1 frew frew 24M Mar 12 22:35 ./leatherman
```

And for arm:

```bash
$ GOOS=linux GOARCH=arm go build
$ scp leatherman pi@raspberrypi:x; ssh pi@raspberrypi ldd ./x
leatherman
        not a dynamic executable
$ ls -lh ./leatherman           
-rwxrwxr-x 1 frew frew 19M Mar 12 22:36 ./leatherman
```

Interestingly (I honestly am not sure why) the arm binary is statically linked
(and thus probably does not need the below treatment) but the amd64 binary is.
I *have* run into situations where I can't run leatherman because the libc
versions are mismatched.  With that in mind, let's soldier on:

Here's using [zig](https://ziglang.org/):

```
$ CGO_ENABLED=1 GOOS=linux GOARCH=amd64 CC="zig cc -target x86_64-linux-musl" CXX="zig c++ -target x86_64-linux-musl" go1.18beta2 build
$ ldd ./leatherman
        statically linked
$ ls -lh ./leatherman
-rwxrwxr-x 1 frew frew 40M Mar 12 22:42 ./leatherman
```

And using the same compiler for arm:

```
$ CGO_ENABLED=1 GOOS=linux GOARCH=arm CC="zig cc -target arm-linux-musleabihf" CXX="zig c++ -target arm-linux-musleabihf" go1.18beta2 build
$ scp leatherman pi@raspberrypi:x; ssh pi@raspberrypi ldd ./x
leatherman
        statically linked
$ ls -lh ./leatherman                                                                                                                      
-rwxrwxr-x 1 frew frew 34M Mar 12 22:44 ./leatherman
```

Note that the above target on zig must be musleabihf.  I could swear I saw some
documentation for go that documents that GOARCH=arm means hard float arm, but I
can no longer find it.  That was the main hassle involved here.

(I can also compile a binary for windows using zig with no surprises.  No
static linking but honestly maybe that's not a thing on windows, I dunno.)

It's the tiniest bit annoying that when I try to build for OSX I get a ton of
(what look like) linker errors.  I'd be more annoyed, but it seems like
building for OSX without signing the binaries is not going to work much longer,
so I'll probably stop building OSX binaries (or, at some point, buy a signing
key.)

---

I haven't fully migrated the leatherman to the cgo SQLite, but I am pretty sure
it's the right move.  I had wanted to also try with librdkafka for this post
but getting it to cross compile was harder than I expected.  I might try again
and make a follow up post.

---

[If you are interested in high quality coffee at low cost, check out my guide
on roasting your own!](https://frew.gumroad.com/l/coffee)
