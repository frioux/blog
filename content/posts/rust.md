---
title: Rust
date: 2016-02-09T09:34:13
tags: [frew-warez, rust, community, documentation, error messages]
guid: "https://blog.afoolishmanifesto.com/posts/rust"
---
I've really enjoyed writing Rust, lately.  [I posted
yesterday](/posts/announcing-cgid/) about what I'm doing with it.  In the
meantime here are some immediate reactions to writing Rust:


### Documentation

[The documentation is pretty
good.](https://doc.rust-lang.org/1.6.0/std/process/struct.Child.html#method.kill)
It could be better, like if every single method had an example included, but it
could be a lot worse.  And the fact that a lot (though not all for some reason)
of the documentation has links to the related source is really handy.

### Language Itself

The languages feels good.  This is really hard to express, but the main thing is
that type inference makes a lot of the type defintions feel less burdensome
than, for example, Java and friends.  It also feels stratospherically high
level, with closures, object orientation, destructuring, handy methods on basic
types like strings, and much more.  Yet it's actually pretty low level.

### Community

The community is awesome!  I have **never** had as many friendly and willing
people help me as a total noob before.  Maybe it's because Rust has a code of
conduct or maybe it's because Mozilla are nice people.  I appreciate that there
are people who actually know what is up answering questions at all hours of the
night; they also generally assume competence.  While assuming competence may make
the total amount of questions asked greater, it makes the entire exchange much
mroe pleasant. More of this please!

### Error Messages

The error messages are very good.  For example, check this out:

```
$ rustc httpd.rs
httpd.rs:84:42: 84:43 error: unresolved name `n`. Did you mean `v`? [E0425]
httpd.rs:84             Ok(v) => { *content_length = n },
                                                     ^
httpd.rs:84:42: 84:43 help: run `rustc --explain E0425` to see a detailed explanation
error: aborting due to previous error
```

They all give some context like that, and then have an error code (the
`--explain` thing) that lets you get a more complete description of what you
did and how you can fix it.  Sometimes the errors can be pretty inscrutable for
a new user though:

```
$ rustc httpd.rs
httpd.rs:216:31: 219:7 error: the trait `core::ops::FnOnce<()>` is not implemented for the type `()` [E0277]
httpd.rs:216     let mut c_stdin = f.stdin.unwrap_or_else({
httpd.rs:217         warn!("Failed to get child's STDIN");
httpd.rs:218         early_exit("500 Internal Server Error");
httpd.rs:219     });
httpd.rs:216:31: 219:7 help: run `rustc --explain E0277` to see a detailed explanation
error: aborting due to previous error
```

### Searchability

Searching for examples of stuff online is surprisingly hard.  I don't know if
that's because Rust is a popular video game or if it's just because the language
is fairly new.  I hope to help remedy this in general.

### Etc

There is certainly more, like the included [package management
system](https://crates.io) or other interesting language features.  I may post
more about those later, but the above is stuff that I ran into during my week
long foray into Rust.  Hope this helps!
