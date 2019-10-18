---
title: "Go's Reflect Package is Mostly Read-Only"
date: 2019-10-17T19:30:13
tags: [ golang ]
guid: ce65dce2-6e4c-490e-8b1b-b8fbddc850a7
---

Today, after playing with [the `reflect`
package](https://golang.org/pkg/reflect/) I discovered that you can't use it as
a construction kit.

<!--more-->

For reasons that I hope to get into another time, I was trying to create
`reflect` values by hand today.  Imagine that you have this struct type:

```golang
type Person struct {
   Name string
   Born time.Time
}
```

My intention was, without the code above, to create the same value I would have
gotten back if I'd done something like:

```golang
var p Person
personType := reflect.TypeOf(p)
```

Here's what I ended up with:

```golang
fields := []reflect.StructField{{
   Name: "Name",
   Type: reflect.TypeOf(string("")),
}, {
   Name: "Born",
   Type: reflect.TypeOf(time.Now()),
}}
personType := reflect.StructOf(fields)
```

Sadly, that's insufficient.  The second example above is an anonymous struct
of `Name string, Born time.Time`.  It would work in many cases, but not all.
Fundamentaly, from a user's perpective, the distinction is that the first
example has a name (Person) and that the latter is anonymous.

The ultimate implication here is that, while `reflect` can be used for inputs to
packages (even though it generally shouldn't) you can't use it as a general
interface.  You just can create `reflect` values of types that you don't have in
your running process.

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
