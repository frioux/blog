---
title: "Benefits of using Golang for ad-hoc code: Leatherman"
date: 2018-01-12T22:11:22
tags: [ golang, cli ]
guid: a81c7e81-f7dd-4cf1-a021-71667cfff3aa
---
I recently stumbled upon a pattern that motivates me to write little scripts in
Go instead of my normal default.  I was surprised at some of the benefits.

<!--more-->

If you can't be bothered to read this whole post, let me frontload the gist:

Building little tools with Go will:

 * supply you with first class libraries
 * supply you with powerful, well supported tools
 * amortize the cost of non-core libraries (to zero)
 * work at runtime on almost any machine you are likely to use
 * support concurrency and parallelism in an intuitive and performant manner
 * encourage and support testing

[I have blogged before about my automated dotfiles
setup](/posts/my-mobile-shell-home/), which I use constantly.  With this setup I
have almost 100 (!!!) little tools at my fingertips included by my dotfiles.
The majority of them are either straight shell or Perl with no dependencies.
Those scripts work well and I do not expect to change them any time soon.

On the other hand, there are a couple dozen scripts with non-core dependencies.
So those scripts either do not work on a remote box or suddently break on my
laptop if I install a new Perl version.

I wanted an excuse to get more experience writing Go, and this seemed like a
possible path forward, except I didn't want to have to pull down two dozen
binaries, as that would almost surely be tens of megabytes.  My coworker Aaron
Hopkins gave me a cool solution to that and I've run with it.

## The Multitool

Instead of building fifteen little tools, each ending up being about a megabyte
or two because of the static linking, I build one giant tool, that acts
differently based on `$0`.  This may sound unusual if you've never heard of it,
but it's actually quite common.  `busybox` is a great example; if you run
`busybox ls` it will run its `ls` applet.  In the same way, if you make an `ls`
symlink to `busybox` and call *that*, it will know to act like `ls`.

So I wrote a tiny little go dispatcher to handle my tools:

``` go
package main

import (
	"os"
	"path"
)

var Dispatch map[string]func([]string)

func main() {
	which := path.Base(os.Args[0])
	args := os.Args

	Dispatch = map[string]func([]string){
		"addrspec-to-tabs": AddrspecToTabs,
		"clocks":           Clocks,
		"csv2json":         CsvToJson,
		"debounce":         Debounce,
		"render-mail":      RenderMail,

		"help":             Help,
		"explode":          Explode,
	}

	if which == "leatherman" && len(args) > 1 {
		args = args[1:]
		which = args[0]
	}

	fn, ok := Dispatch[which]
	if !ok {
		Help(os.Args)
		os.Exit(1)
	}
	fn(args)
}
```

As you can tell, at the time of writing I have migrated four tools
(`addrspec-to-tabs`, `clocks`, `csv2json`, and `render-mail`,) and added a
script that was too hard to keep in my kit before (`debounce`, more on that
one later.)

[The tool is called Leatherman](https://github.com/frioux/leatherman) and I plan
on improving the documentation as I go.

## Unexpected Benefits of Writing "Scripts" in Go

There were a few things that jumped out at me immediately while I pursued this
project.  The first was that the standard library in Go is top notch.  Of course
I am mostly comparing to Perl and Python here, which are both much older than Go
and have far less commercial support.

A good example might be `net/mail` package.  In Perl, I used one module to parse
the email (`Email::MIME`), another module to parse the address headers
(`Email::Address`), and yet another module to parse the Date header
(`Email::Date`.)  None of those perl modules are built in.  In Go these were all
built into the same core package and exposed in an obvious and performant way.

A second, related benefit is that Go has some incredible tooling.  I suspect
that this is due to a combination of having commercial support and because good
tooling was a first class design concern.  A fascinating example can be found in
[this blog post about new trace features in the latest release of
Go][tracepost].  That's really just one of many examples though.  I am not sure
I can catalogue all of the various handy tools, though I have used some of the
ones mentioned in the post above when debugging deadlocks.  Anyone who writes go
probably uses `gofmt`, which arranges source in the canonical format so there
aren't annoying discussions about whitespace.  `gofmt` also has syntax
manipulation for replacing syntax patterns (as opposed to string patterns) in
your entire source tree.

[tracepost]: [https://medium.com/@cep21/using-go-1-10-new-trace-features-to-debug-an-integration-test-1dc39e4e812d]

Another nice benefit of Go, and this could apply to Rust and C/C++ with the
right compiler flags, is that binaries are static, and thus do not need runtime
dependencies (aside from typically libc for resolvers.)  For me this means that
some tools, like `csv2json`, actually work on boxes that are not my laptop; when
it was a Perl script I had to have certain non-core modules installed.

Because of this the binaries produced by Go are actually more portable than many
scripts.  This means that some scripts that tend to depend on either overly new
or rare packages can be rewritten in a way that is more likely to work on less
up-to-date machines.

Another first class feature of Go (and hopefully any other language released in
the current generation) is concurrency and parallelism.  While Perl, Python, and
other common languages can do asynchronous programming for concurrency or
forking (and maybe threading) for parallelism, those features are either not
included in the main language or are haphazardly bolted on.  The combination of
lightweight threads and channels makes parallelism and asynchrony more
integrated and natural. [I've written about the results of this
before](/posts/converting-a-slow-shell-script-to-golang/).

The final benefit I've found is the solid testing infrastructure.  On the one
hand this only feels like a benefit because Go *requires* more ceremony than
Perl or Python; a Perl script written in the Go style is just as testable, but
because Go has to be run this way anyway, Go programs have better testability
out of the box.  Basically with go you can have a file called `${foo}_test.go`
and it has access to all of the private data of the `$foo` file.  Then you
basically write methods called `TestWhatever` and those are run at test time,
able to test private methods.  Very handy.

### On the Other Hand...

Go is definitely not perfect.  I understand that the designers of the language
have an emphasis on simplicity, and I appreciate that, but the lack of generics
is pretty painful.  Go has first class functions, but does not have `Map`,
`Select` or other common functional constructs because of this.

The non-core Go libraries are of very uneven quality.  I suspect that part of
this is because there is no blessed index of Go libraries (like CPAN or PyPI.)
With the CPAN inspired index-based model, people write code, get it to a state
they are happy with, and release it.  The Go model instead assumes that any
Git (or I guess Mercurial or probably Bazaar or Subversion) repository
referenced is OK to use.  The upshot of this is that some modules are great, but
some are incredibly bad.

## Debounce

I mentioned `debounce` before.  Debounce is a tool I have written both in Perl
and in Go.  The Perl version was a hassle to use because it required async deps
that are unlikely to exist universally.  The Go version has worked fine (and
indeed I wrote it [three years ago.](https://github.com/frioux/debounce))

If you have never heard of debouncing before, it is something you have to do to
avoid "chatter" in physical switches.  The use case I tend to run into is that
you want to do something based on a discrete event, but you do not want to do
whatever per event, instead you want to do it after the events stop.  Let me
give a concrete example: you could set up an inotify watcher on file system
events and run tests whenever an event comes through.  You will quickly find
that even a simple `:w` from `vi` triggers multiple events.

So what you do is have `debounce` watch for the lines, and it reads the first
line and waits up to one second until it releases that first line.  Here's how
you do it:

``` bash
inotifywait -mr -e modify,move . | debounce | xargs -I{} make test
```

I have wanted this more than once on a server but it's always been too much of a
hassle to wire up.  With the leatherman I have solved this handily.

## Automate It All

First, [I have TravisCI set up to both build and
deploy](https://github.com/frioux/leatherman/blob/master/.travis.yml) the built
binary to a github release.  It was a little weird because I had to install a
ruby gem to build the linked yaml file, but now that it's set up I don't think
I'll need to do it again for quite a while.  [So there are releases for each
push](https://github.com/frioux/leatherman/releases).  One really cool thing
here is that the CI actually downloads all required libraries, so when you
use the built binary, you need nothing other than libc.

That's great, but it gets even better.  I don't want to have to remember to
download and install the multitool, so in my dotfiles install script [I automated
the downloading and
installation](https://github.com/frioux/dotfiles/blob/ef08bd624f82a94dd39194924f1f76a7480ecac5/install.sh#L128-L135):

``` bash
if test ! -e ~/bin/leatherman || older-than ~/bin/leatherman c 7d; then
   LMURL="$(curl -s https://api.github.com/repos/frioux/leatherman/releases/latest |
      grep browser_download_url |
      cut -d '"' -f 4)"
   curl -sL "$LMURL" > ~/bin/leatherman
   chmod +x ~/bin/leatherman
   ~/bin/leatherman explode
fi
```

So the above will install the leatherman if it doesn't exist, and install the
latest version if it's over a week old.  The leatherman `explode` command
installs all of the relevant symlinks for each tool.

---

I hope demonstrated some of the benefits of using Go for little tools.  I have
enjoyed writing Go for the most part, and intend to continue writing Go when it
makes the most sense.  I hope this post inspires you to use Go, Rust, or any
other modern, compiled language where it makes sense.

---

If you want to learn more about programming Go, you should check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I haven't finished it but intend to once I finish the current tech books I'm
reading.  At the very least it takes a more instructive approach than most
programming books I've read, which is helpful for a language like Go that is so
distinct from most other programming languages.


I have also heard that
<a target="_blank" href="https://www.amazon.com/gp/product/1787125645/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1787125645&linkCode=as2&tag=afoolishmanif-20&linkId=6fafd21a7426645cdcbcafa5ca7bccf1">Go Systems Programming</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1787125645" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is very good, though I haven't read or even purchased it myself.
