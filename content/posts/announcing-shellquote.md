---
title: Announcing shellquote
date: 2018-07-05T07:30:13
tags: [ golang ]
guid: e93ec1ff-c62b-4685-afa4-cb88e65d5781
---

In my effort to [port certain tools to
go](/posts/benefits-using-golang-adhoc-code-leatherman/) I've authored another
package: `github.com/frioux/shellquote`.

<!--more-->

Imagine you are generating a shell script based in part on input from a user.
In this theoretical example the user might be passing a list of files and you
are generating a command that they can tweak and re-run later.  You could assume
that their filenames are "normal" but eventually someone will have a space in
the filename.

The first obvious solution is to just wrap each filename in single quotes (`'`).
Then of course users cannot have quotes in their filenames.  This module
generically solves this problem.

## `github.com/frioux/shellquote`

Here's an example of usage:

``` golang
package main

import (
	"fmt"
	"os"

	"github.com/frioux/shellquote"
)

func main() {
	quoted, err := shellquote.Quote(os.Args[:1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Couldn't quote args: %s\n", err)
		os.Exit(1)
	}
	fmt.Println("#!/bin/sh")
	fmt.Println("")
	fmt.Println("cool-command", quoted)
}
```

The other use-case I know of is for generating `ssh(1)` commands.  To correctly
run a remote command via ssh actually requires shell quoting *twice*; once for
the local machine and once for the remote machine.  This can get confusing
pretty quickly.  [The included `shellquote` example shows how you can use it to
generate ssh commands](https://github.com/frioux/shellquote#example):

``` golang
package main

import (
	"fmt"
	"os"

	"github.com/frioux/shellquote"
)

func main() {
	fmt.Println("#!/bin/sh")
	fmt.Println("")
	quoted, err := shellquote.Quote(os.Args[1:])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Couldn't quote input: %s\n", err)
		os.Exit(1)
	}
	// error won't happen if the first input didn't error
	doublequoted, _ := shellquote.Quote([]string{quoted})
	fmt.Println("ssh superserver", doublequoted)
}
```

This is a module I don't find myself needing much, but the cases do come up and
it's great to have a real solution.

The logic of this module originally came from the similarly named Perl module:
[String::ShellQuote](https://metacpan.org/pod/String::ShellQuote)

---

Writing this was pleasant.  Thankfully the Perl version came with a pretty solid
test suite that I was able to port over.  It's simpler than the original version
both because Go doesn't have exceptions and because I suspect that a "best
effort quote" function is probably broken.

---

If you want to learn more about Go I strongly recommend
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
by Donovan and Kernighan.  I've mentioned it many, many times on this blog
before.  It's one of the best programming books I've ever read and I read the
entire thing.

Another helpful book, if you like writing shell scripts, is
<a target="_blank" href="https://www.amazon.com/gp/product/1590593766/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1590593766&linkCode=as2&tag=afoolishmanif-20&linkId=435ec5c4ed19be44802bb788f3d61a13">From Bash to Z Shell</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1590593766" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
This book goes over powerful features in the most popular shells nowadays: bash
and zsh.  While I write programs in POSIX shell (aka Bourne Shell) I do use zsh
interactively and take advantage of many features to save typing.  This book is
one of the few technical books I've taken with me over multiple moves.
