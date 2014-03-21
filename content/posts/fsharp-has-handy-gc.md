---
title: "F# has Handy GC"
date: "2014-03-20T18:28:53-05:00"
tags: ["fsharp", "gc", "garbage-collection"]
guid: "http://blog.afoolishmanifesto.com/posts/fsharp-has-handy-gc/"
---
As mentioned [previously](/posts/fsharp-has-weird-oo) I was recently learning
about F#, a neat mostly functional language for the .NET vm.

One of the things I was really impressed with was that it allows the user
to take advantage of timely destructors.  I was under the impression that
except for reference counted GC (perl, cpython, and I think C++) timely
destructors were impossible and that the user is instead required to close
their filehandles, database handles, or whatever other cleanup they need to
do, within a `finally` block.

When reading the [Book of F#](http://www.nostarch.com/fsharp) I realized
that C# and other .NET langauges can probably do this as well, since the
[IDisposable](http://msdn.microsoft.com/en-us/library/system.idisposable%28v=vs.110%29.aspx)
interface is how it's referenced.

Unlike perl, for example, where a destructor, when defined, is **always**
called when the object goes out of scope, in F# it's up to the user to decide
that it's important to call it immediately.  So for example, the user might
know that it's ok if a file is closed later than the block ending because
it's some kind of one off logging, but a database handle must be closed
immediately for a transaction to complete or something.

## `use`

F# gives the user two ways to do this.  The first is with the `use` keyword, or
binding type.

    type DisposableHuman (name : string) =
      do printfn "Creating person: %s" name
      member x.Name = name
      interface System.IDisposable with
        member x.Dispose() =
          printfn "disposing: %s" name

    let testDisposable() =
      use root = new DisposableHuman("outer")
      for i in [1..2] do
        use nested = new DisposableHuman(sprintf "inner %i" i)
        printfn "completing iteration %i" i
      printfn "leaving function"

    testDisposable ()

The output is:

    creating: outer
    creating: inner 1
    completing iteration 1
    disposing: inner 1
    creating: inner 2
    completing iteration 2
    disposing: inner 2
    leaving function
    disposing: outer

So check this out, if the user does **not** use `use` and instead opts to use
`let`, the more typical binding, the destructors **never** get called:

    type DisposableHuman (name : string) =
      do printfn "Creating person: %s" name
      member x.Name = name
      interface System.IDisposable with
        member x.Dispose() =
          printfn "disposing: %s" name

    let testDisposable() =
      let root = new DisposableHuman("outer")
      for i in [1..2] do
        let nested = new DisposableHuman(sprintf "inner %i" i)
        printfn "completing iteration %i" i
      printfn "leaving function"

    testDisposable ()

and that output is:

    creating: outer
    creating: inner 1
    completing iteration 1
    creating: inner 2
    completing iteration 2
    leaving function

Of course in that case the user is at fault for not calling dispose by hand,
like this:

    type DisposableHuman (name : string) =
      do printfn "Creating person: %s" name
      member x.Name = name
      member x.Teardown() =
        printfn "disposing: %s" name
      interface System.IDisposable with
        member x.Dispose() = x.Teardown ()

    let testDisposable() =
      let root = new DisposableHuman("outer")
      for i in [1..2] do
        let nested = new DisposableHuman(sprintf "inner %i" i)
        printfn "completing iteration %i" i
        nested.Teardown ()
      printfn "leaving function"
      root.Teardown ()

    testDisposable ()

And then the output we get is what we saw the first time:

    creating: outer
    creating: inner 1
    completing iteration 1
    disposing: inner 1
    creating: inner 2
    completing iteration 2
    disposing: inner 2
    disposing: outer
    leaving function

## `using`

Alternately, if the user has a more decomposed task, they can use the
`using` binding, which as far as I can tell uses function scoping instead
of block scoping.

    type DisposableHuman (name : string) =
      do printfn "Creating person: %s" name
      member x.Name = name
      member x.Teardown() =
        printfn "disposing: %s" name
      interface System.IDisposable with
        member x.Dispose() = x.Teardown ()

    let testDisposable() =
      let root = new DisposableHuman("outer")
      for i in [1..2] do
        let nested = new DisposableHuman(sprintf "inner %i" i)
        printfn "completing iteration %i" i
        nested.Teardown ()
      printfn "leaving function"
      root.Teardown ()

    testDisposable ()

And then, the output:

    Creating person: outer
    Creating person: inner 1
    disposing: inner 1
    got name inner 1
    Creating person: inner 2
    disposing: inner 2
    got name inner 2
    leaving function
    disposing: outer

I'm not completely sure about the difference here, but I believe the real
difference is that `using` is functional while `use` is not really.

I'm actually pretty interested in this.  I've felt for a long time that timely
destructions (aka [RAII](https://en.wikipedia.org/wiki/RAII)) is important
and weirdly missing in some newer languages.  This is pretty encouraging that
it's not as rare as I thought.  On the other hand much more of the onus is
put on the user, which is unfortunate, but a compromise I think is probably
worth making.
