---
title: Extensibility in Go
date: 2019-08-14T19:11:39
tags: [ golang ]
guid: d0da5559-e2c9-424e-9435-21dd7e634c47
---
Recently I've come across some code that allows extesibility in some ways
that are limiting.

<!--more-->

Interfaces in Go are simply a set of methods that a type happens to implement.
[I went over a couple of major use cases for them
before](/posts/go-interfaces/); in this post I want to clearly point out where
they've either been perverted or underused.

## [`spf13/pflag`](https://github.com/spf13/pflag)

The first perversion is `pflag`.  In general `pflag` is fine; it allows the much
more common GNU style flags, like `--help` instead of `-help`.  In theory this
allows collapsing single flag arguments together, like with `ls -hal`.  That has
some issues but they are inevitable, so I am not going to discuss those.
Instead, I'll point out [the Value
interface](https://godoc.org/github.com/spf13/pflag#Value):

```golang
type Value interface {
    String() string
    Set(string) error
    Type() string
}
```

It's just like the original `flag.Value`, except there's a `Type()` method that
returns a string.  This method isn't documented in the code anywhere, so I
spelunked and found that this is, as far as I can tell, only used for the `Get`
family of methods ([such as
GetFloat32](https://godoc.org/github.com/spf13/pflag#FlagSet.GetFloat32)).  This
adds a userspace type assertion (by returning a string from a Type method,)
which can result in `panic`s based on real type assertions, for people who are
using the `flagset` as a container.  All of this is bad.  I am almost of a mind
to fork `pflag` and remove all of this stuff, but I'll just stick with `flag`
and it's oddities.

## [`mitchellh/mapstructure`](https://godoc.org/github.com/mitchellh/mapstructure)

`mapstructure` (used by
[`cobra`](https://godoc.org/github.com/spf13/cobra)) "exposes functionality to
convert an arbitrary `map[string]interface{}` into a native Go structure."
Useful!  So how does it work?  It requires the user to implement hook functions
like this:

```golang
converter := func(from reflect.Kind, to reflect.Kind, value interface{}) (interface{}, error) {
   ...
}
```

While making `reflect` part of your API is kinda gross, it's not the end of the
world.  What kills me is that, as I said before, `cobra` uses this.  So we
decode our config into structs, which have types on each field, and end up
having to maintain a central list of hook functions.

If this code were better factored, it would *literally* use the `flag.Value`
interface and we'd have a user extensible framework that works for CLI
arguments, env vars, and config files out of the box.  But as it stands now we
have to maintain that in our core config package.  Boo.

---

Fundamentally I feel like this is due to people writing Go as if it were a
language like Perl or Python where, due to not having types, people are used to
just returning values, rather than modifying values that are passed in.  I
understand that the `flag.Value.Set` interface method is weird, but it's
flexible and works perfectly well.

---

If you are interested in learning Go, this is my recommendation:

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
