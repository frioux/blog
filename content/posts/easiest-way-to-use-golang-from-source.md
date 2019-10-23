---
title: The Easiest Way to Use Go from Source
date: 2019-05-03T19:25:35
tags: [ golang ]
guid: f4abba7c-0020-4aaf-ba31-da79a6fcc0f1
---
Recently I saw someone suggest using the unreleased version of Go, without
the magically easy way to do it.  Here's how.

<!--more-->

First you need to install some version of Go.  Use the version packaged with
your Linux distribution; or if you are using OSX or `RUNNING_IN_HELL` use
[the officially packaged, latest release](https://golang.org/dl).  Next you need
to install `gotip`:

```
go get golang.org/dl/gotip
```

After that you need to tell it to install the current latest version:

```
gotip download
```

The above command takes a while; it downloads and installs everything you need
and builds the latest unreleased version of go, called `tip` (like how the
latest unreleased perl is called `blead`.)

After running the above command you can use `gotip` as if it were `go`.  For
example, if you ran it now you could see docs for the new `errors` package:

```
$ gotip doc errors
package errors // import "errors"

Package errors implements functions to manipulate errors.

func As(err error, target interface{}) bool
func Is(err, target error) bool
func New(text string) error
func Opaque(err error) error
func Unwrap(err error) error
type Formatter interface{ ... }
type Frame struct{ ... }
    func Caller(skip int) Frame
type Printer interface{ ... }
type Wrapper interface{ ... }
```

And you'd use `gotip build`, `gotip test`, and all the other stuff you are used
to using with the `go` tool.

If interested, you can do the same thing for each version of go; [see the docs
here](https://godoc.org/golang.org/dl).  I don't know why I don't see this
mentioned more often.  In the future I'm going to stop extracting the tarball
and exclusively download this way and just create a `~/bin/go` symlink to the
latest version.

---

If you are interested in learning Go, this is my recommendation:

(The following includes affiliate links.)

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
