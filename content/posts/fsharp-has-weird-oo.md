---
title: "F# has Weird OO"
date: "2014-03-17T18:11:25-05:00"
tags: [mitsi, fsharp, object-oriented-programming]
guid: "http://blog.afoolishmanifesto.com/posts/fsharp-has-weird-oo/"
---
A little while back I was learning about F#.  For the most part F# is a cool
language.  It's based on ML and is an impure functional language.  Here is how
you can do some things with F#:

Define a function:

    foo a b = a + b

Call that function:

    let x = foo 1 2

There is a lot more, like currying, powerful type inference, etc.

But I was learning F# because at work we were integrating with a .NET SDK and I
am not super interested in writing C#.  I did that in school and briefly during
an internship and while you can certainly do good work, I'm just not super
interested in writing C# if I can avoid it.

I purchased the early edition of [Book of
F#](http://www.nostarch.com/fsharp) and for the most part I was really
happy with it.  I haven't re-read it since they released another version
with a few more chapters, but even the edition I read was very good.
If you are interested in coding F# I highly recommend it.

The problem came when I started doing the object oriented code.  In Perl you
might do some OO code like this:

    sub foo {
       my $friend = shift;
       die "that's not a valid friend!" unless $friend->isa('Human');
       ...
    }

The above code simply dies if `$friend` is not an object based on the Human
class.  This will not die if you pass in an object based on a subclass of Human.
Now let's take it a tiny step further:

    sub foo {
       my $friend = shift;
       die "that's not a valid friend!" unless $friend->isa('Human');
       print $friend->as_string;
    }

This will print out whatever was returned from the `as_string` method defined on
the class that $friend was defined as.  So if $friend is a Human, we get the
default `as_string`, but if it's a subclass and `as_string` was defined in the
subclass, it calls it on the subclass.

To be perfectly clear:

    package Human;
    use Moo;
    has name => ( is => 'ro' );
    sub title { 'human: ' . shift->name }

    package CEO;
    use Moo;
    extends 'Human';
    sub title { 'CEO: ' . shift->name }

    package main;
    use 5.14.0;
    sub print_title {
       my $human = shift;
       die "that's not a valid human!" unless $human->isa('Human');
       say $human->title;
    }

    print_title(Human->new(name => 'frew'));
    print_title(CEO->new(name => 'frew'));

should print

    human: frew
    CEO: frew

Now maybe perl is weird here, but as far as I know this
makes perfect sense.  Child isa Human ([Liskov Substitution
Principle](https://en.wikipedia.org/wiki/Liskov_substitution_principle))
and calling the most specific method makes sense since otherwise how
does polymorphism work at all?

Well, in F# OO is totally not like this.

Here is the same program in F#:

    type Human(nombre: string) =
       member x.Name = nombre
       member x.Title() = sprintf "human: %s" nombre

    type CEO(name) =
       inherit Human(name)
       member x.Title() = sprintf "CEO: %s" name

    let print_title (p : Human) = printfn "%s" (p.Title ())

    print_title (Human("frew"))
    print_title (CEO("frew"))

**This** prints

    human: frew
    human: frew

The reason is that the `p : Human` type constraint basically does a cast.  If
you wanted to run the actual implemented method you can't actually use OO at
all.  I'm really not sure why this is; I suspect it's a limitation of the .NET
platform because a coworker tells me that in C# the same thing happens.

**UPDATE (2014-03-19)**: Some
[nice](https://twitter.com/t0yv0/status/445912680117706752)
[people](https://twitter.com/lazydev/status/445913011413598208) on
[twitter](https://twitter.com/frioux) informed me that I was missing something.
Here is code that does what I actually want:

    type Human(nombre: string) =
       member x.Name = nombre
       abstract member Title: unit -> string
       default x.Title() = sprintf "human: %s" nombre

    type CEO(name) =
       inherit Human(name)
       override x.Title() = sprintf "CEO: %s" name

    let print_title (p : Human) = printfn "%s" (p.Title ())

    print_title (Human("frew"))
    print_title (CEO("frew"))

The difference, if it is unclear, is that the base method is defined as
`abstract` with a `default` implementation and the subclass is defined with
`override`.

On the other hand, here is a cool(ish) thing.

F# lets you define interfaces on objects, which is like what Moo(se) users might
call a crippled role.  An interface basically requires a certain set of methods
following a certain interface to be defined.  The interesting thing is that a
user can define methods of **The same name** under different interfaces.  So for
example, check this out:

    type IHasName =
       abstract member Name : unit -> string

    type IHasNickName =
       abstract member Name : unit -> string

    type Human(nombre) =
       interface IHasName with
          member x.Name() = nombre
       interface IHasNickName with
          member x.Name() = nombre + "y"

    printfn "name %s" ((Human("frew") :> IHasName).Name ())
    printfn "nickname %s" ((Human("frew") :> IHasNickName).Name ())

The above prints

    name frew
    nickname frewy

So it gets the string from the huamn that implements IHasName and then calls the
Name method on it, and then it gets the string from the human that implements
the IHasNickName interface and calls the Name method on it.  A little weird, but
I can see when that would be nice.  The Trait based solution to this (renaming
the method) is pretty hacky, this would always work, though certainly ends up a
bit syntactically clunky.
