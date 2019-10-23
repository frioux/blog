---
title: Go Interfaces
date: 2019-01-23T08:30:03
tags: [ golang, programming, programming-languages ]
guid: 7a23bd20-d454-4384-bf0e-b5ccddf85833
---
I did some work recently that depended on Go interfaces and I found it both
straightforward and elegant.

<!--more-->

Interfaces are one of the features of Go that I think are subtle and
undervalued.  If you don't know what they are, the short version is that they
aproximate a statically typed version of "duck typing."  The critical
difference, is both that the full method signature is part of the interface and
that the interface can contain more than just a single method, which is rare
(though perfectly doable) in the duck typing pattern.

In practice I've seen this used in at least two ways, each of which I'll give
examples of:

 * To allow polymorphism
 * To allow values to inject their own "hooks" into more central parts of the
     language

## Polymorphism

The example I have in mind ([which is what I was working on that spurred me to
write this
post](https://github.com/asticode/go-astilectron-bundler/commit/6cf585e0ac075996c50636c2812d2a3c4f6f39ee))
is Go's `flag` package.  Nearly all major programming languages (at least that get
used in Unix) are going to have some for of flag parsing library implemented
atop the tokenizing that the shell does for you.  In my experience flag parsing
systems are a kind of pop-culture, going in and out of fashion, so whatever
ships with the language is going to be used sometimes and not at other times.

Go forces this issue more than many because of the bizarre plan9 focus of the
flag parsing (and standard tooling for that matter.)  To be clear, the
popular GNU style flag parsing (often called "getopt") might look like this:

```
create-user --name frew -Hs /bin/zsh
```

In the made up example above, `--name` takes a string, `-H` is a short name for
something (in my mind it was to disable creation of a homedir), and `-s` takes a
string.  Many tools would let you express the above as `-Hs/bin/zsh`.  Go
doesn't support any of that, instead just supporting something like this:

```
create-user -name frew -H -s /bin/zsh
```

So you only get one type of flag, and it takes a single dash instead of two.
This post isn't about that, but my point is that people have already implemented
a ton of flag parsing libraries to replace the standard one.  Thankfully due to
interfaces, code remains decoupled and should be able to work with both the
standard `flag` package and other ones.

The idea is: you define a custom data type and want to be able to have the
`flag` package be able to interact with it.  While on the surface it seems like
each type needs to be defined in the `flag` package directly, that's not the
case.  Instead, you just define two methods on your type:

 * `String() string`
 * `Set(string) error`

The first method is relatively obvious (though somewhat comical in what it's
used for in the `flag` package.)  The second method is the one that provides the
useful interface.  All you need to do to support flags in your custom type is
allow modifying your values by calling Set.  Here's a silly example:

```golang
type name struct {
	n []string
}

func (n *name) Set(s string) error {
	n.n = append(n.n, s)
	return nil
}
```

With the above code, you could now (assuming you added a `String()` method) do
the following:

```golang
var n name
flag.Var(n, "personName", "Name of person")
```

And then run your program with:

```bash
find -personName fREW -personName fROOH -personName fRUE
```

Now the `n` variable would include the contents `[]string{"fREW", "fROOH",
"fRUE"}`.  It's weird and a little annoying because it forces key value pairs
where I would rather be able to pass pre-tokenized lists, but it's definitely
composeable and can express whatever you need to express.

## Hooks

I think the case above is more or less the typical way one would implement
traditional interfaces in, for example, Java.  There is another much more subtle
way I see interfaces used in Go; specifically to allow optional or more
efficient behavior.

(One could say that this is really just another kind of polymorphism, but it's
distinct at the very least because it is typically done by checking if the value
in question conforms to *another* interface, rather than implementing a method
within the main interface.)

A concrete example is `io.Copy`; this is a simple function that almost seems
like a nearly worthless helper function when you first come across it.  If you
read the source you would find that it's not as basic as you initially may have
expected.  `io.Copy`'s full signature is
`io.Copy(dst io.Writer, src io.Reader) (written int64, err error)`; it copies
the data from `src` to `dst`, basically.  `io.Reader` must have a `Read` method
and `io.Writer` must have a `Write` method.

The implementation has two clever optional features though: if `src` has a
`WriteTo` or `dst` has a `ReaderFrom` those methods are called.  In a
more traditional programming language this would be done with subclassing, or
maybe a role/mixin that overides the base class behavior.

This is actually how Go allows kernel space copies from one socket to another in
Linux:

> The net package now automatically uses [the splice system
call](http://man7.org/linux/man-pages/man2/splice.2.html) on Linux when
> copying data between TCP connections in
> [TCPConn.ReadFrom](https://tip.golang.org/pkg/net/#TCPConn.ReadFrom), as
> called by [io.Copy](https://tip.golang.org/pkg/io/#Copy).  The result is
> faster, more efficient TCP proxying. 

([Go 1.11 Release Notes](https://tip.golang.org/doc/go1.11#performance))

These *optional* hooks in Go allow you to get the same benefit, but without the
mental overhead of subclassing.  Furthermore, because it's just a method you
implement, you can conform to any number or interfaces, so again you don't have
the issues with multiple inheritance.  And finally, your code is completely
decoupled from the code that defines the interface, because your code simply
implements methods with a given signature; there is no necessary actual usage of
the defined interface anywhere.

---

The two use-cases above are not unsolved by other languages; polymorphism is
typically solved with an inheritance heirarchy. More robust OO systems (like
what Moose provides) allow you to do this with explicit roles, but without care
these can end up just as hard to deal with as inheritance heirarchies.  Hooks
are easy to implement either by using duck typing, or by having empty default
implementations.

What I think Go provides here is a solution these problems that reduces overall
complexity.  Instead of creating a baroque type system and then a relatedly
baroque set of types, Go forces simplicity in the overall system.  This forces
complexity in parts of the implementation (see the code for `io.Copy`) but
allows much of the rest to be simply implementing to an interface.

There are drawbacks of course.  If you misspell the implementation of a method
that allows you to get higher performance, you'll never know unless you notice
that it's too slow, or you write some form of test.  I haven't run into this yet
but it seems almost inevitable.

---

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
