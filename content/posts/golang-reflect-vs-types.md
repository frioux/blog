---
title: "Go's reflect packages vs types package"
date: 2019-10-22T20:00:55
tags: [ golang ]
guid: 5b7dbc9d-a93b-4c44-ae6c-3d747b947e60
---

I'm attempting to migrate some code that uses `reflect` to instead use
`go/types` and I have some thoughts.

<!--more-->

I'm attempting to migrate [the `easyjson` tool]() from being `reflect` based to
being `go/types` based.  The main reason is so that it won't take so long on our
repo when we do `go generate`.  Here are some random takeaways from this
project, so far.

First off, for my purposes `reflect` has one relevant entrypoint function
(`TypeOf`) and a single god type (`Type`.)  You pass the value you have to
`reflect.TypeOf`, get back a `reflect.Type`, typically look at it's `Kind`
method, maybe the `Implements` method, and then based on those you can inspect
from there.  If the kind is a Map, for example, you'll be able to look at the Key
method and the Elem method to find out the inner types.

The `go/types` interface, interestingly, feels much more "Go" than `reflect`.
Instead of switching on a `Kind` field and avoiding the wrong methods (because
they'll panic) you do a type switch on the "surface" interface (`types.Type`)
and then get a concrete type that only has the methods you can use.  It's safer
to use, but you have to know more to use it.

While `reflect` only requires you to pass in a value to give you a
`reflect.Type`, to get a `types.Type` you *probably* have to somehow parse Go.
Typically you'll do this with `go/ast`.  (There's another package that wraps both
`go/ast` and `go/types` called `golang.org/x/tools/go/packages`, which makes
things easier.)

The biggest hassle for me so far (because I hadn't fully digested what
`types.Info` makes available) has been naming.  `reflect.Type` has both Name
and PkgPath methods.  This means that it's cake to just get the name of the type
you had.  `types.Type` on the other hand, will only have a Name (and PkgPath) if
it's a `*types.Named`; if you got one of those (and indeed even if you didn't)
you can then access the Underlying method to get at the actual type.  If you
*didn't* get a `*types.Named`, chances are you are just doing something wrong.
I was accessing the Types field in the Info struct and should have actually been
accessing the Defs field.  There are other ways to get at this data, but
some will have names and some won't.

Hopefully I can blog again soon about the results of this!


---

(The following includes affiliate links.)

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
