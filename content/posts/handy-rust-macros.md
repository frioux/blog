---
title: Handy Rust Macros
date: 2016-02-06T14:34:13
tags: [frew-warez, rust, macro]
guid: "https://blog.afoolishmanifesto.com/posts/handy-rust-macros"
---
I've been writing some Rust lately and have been surprised at the dearth of
examples that show up when I search for what seems obvious.  Anyway, I wrote
a couple macros that I've found very handy.  The first seems like it should
almost be core:

```rust
macro_rules! warn {
    ($fmt:expr) => ((writeln!(io::stderr(), $fmt)).unwrap());
    ($fmt:expr, $($arg:tt)*) => ((writeln!(io::stderr(), $fmt, $($arg)*)).unwrap());
}

// Examples:
warn!("This goes to standard error");
warn!("Connected to host: {}", hostname);
```

This allows you to trivially write to standard error, and it panics if it fails
to write to standard error.  If it weren't for this final detail I'd actually
submit it as a pull request for Rust itself.  For my code, being able to print
to the standard filehandles is critical, so crashing if STDERR is closed makes
sense, but there are many situations where that is not reasonable.

The next example is the more interesting one, a macro that uses an environment
variable at compile time to modify what it does:

```rust
macro_rules! debug {
    ($fmt:expr) => (
        match option_env!("HTTPD_DEBUG") {
            None => (),
            Some(_) => warn!($fmt),
        }
    );
    ($fmt:expr, $($arg:tt)*) => (
        match option_env!("HTTPD_DEBUG") {
            None => (),
            Some(_) => warn!($fmt, $($arg)*),
        }
    );
}

// Examples:
debug!("This goes to standard error");
debug!("Connected to host: {}", hostname);
```

`debug!` works just like `warn!`, but if the `HTTPD_DEBUG` environment variable
is unset at compile time it is as if nothing was even written.  Sorta handy, but
what's more important is the general pattern.

I hope to be blogging more about Rust in the future.  I hope this helps!
