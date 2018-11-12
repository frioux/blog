---
title: Go Doesn't Have Generics
date: 2018-11-12T09:37:49
tags: [ golang, psa ]
guid: 602effcf-b9e9-4e13-afb8-4a08907b3ead
---
Go doesn't have generics.  This isn't news, but it's more foundational than many
might realize.

<!--more-->

It is widely known that Go does not have generics.  I've known this since I
started with Go, but I recently found that the types, even when using type
assertions, are a little stricter than I expected.  Let me explain.

## `interface{}`

Go has interfaces, which are sort of like Java interfaces, except that your code
automatically matches them, as opposed to opting into them.  There's a thing
where you define an empty interface (`interface{}`) which means every type
satisfies the interface and thus can be used in place of those types.  Here is
an example:

```golang
var foo interface{}
foo = "frew"
fmt.Printf("%#v\n", foo);
foo = 1
fmt.Printf("%#v\n", foo);
foo = true
fmt.Printf("%#v\n", foo);
foo = []int{1, 2, 3}
fmt.Printf("%#v\n", foo);
```

Ok great.  So the next interesting thing is that you can use type-assertions to
get the underlying, typed value out.  Here's what I mean:

```golang
var foo interface{}
foo = 3
var bar int = foo.(int)
fmt.Println(bar)
```

Without the `.(int)` on the third line the above would fail to compile.  This
gets interesting with complex types (slices, maps, etc.)

While you can put an `int` in an `interface{}`, you *cannot* put a
`map[string]int` in a `map[string]interface{}`.  The following fails to compile:

```golang
var foo map[string]interface{}
foo = map[string]int{}
```

Fundamentally, in Go the type system only ever goes two layers deep, the type of
the variable, and the type of the underlying value.  So in the above the
variable is a `map[string]interface{}`, which is a distinct type from
`map[string]int`.  The fact than you can have an `interface{}` variable holding
an `int` value does not mean that you can have a *type* containing an
`interface{}` match a distinct *type* containing something else.

Anyway, all of this is just to say that you need to be especially careful with
`interface{}` in complex types.

As a side note I am not looking forward to Go getting generics.  Much of what
keeps the language simple today is the fact that people just cannot build
super-abstract code without interfaces.  I suspect that once we get real generics
Go code on the internet will stop being the simplicity focussed code it is today
and instead become abstraction behemoths.  I hope I'm wrong.

---

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.

