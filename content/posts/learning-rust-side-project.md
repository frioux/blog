---
title: Learning Rust with a Side Project
date: 2021-12-28T09:14:06
tags: [ "rust", "frew-warez" ]
guid: 8916bb93-bd9f-4768-87a2-b9f29997c809
---
I spent some of my time off for the holidays learning Rust.

<!--more-->

In late November [Rob](https://hoelz.ro/) and I decided to learn Rust
"together." Even in school I never knew how to effectively be part of a study
group, so what we did was form a slack channel where we'd casually discuss our
learnings or where we might be stuck.  I might be a moocher because it feels
like I'm the only one who has benefited from the group learnings!

Anyway, I have been reading [the Rust
book](https://doc.rust-lang.org/stable/book/index.html) (mostly [the published
version](https://nostarch.com/Rust2018) but some of the unpublished / free
version) and working on a little side project to help crystallize my knowledge.


## Rust

This is my reaction to my most recent encounters with Rust, mostly guided by
the book, but some of it guided by a side project.  Realize that these
reactions are pretty surface level and uninformed by experience with the
language. I could imagine feeling the opposite about them over time.

These categories are imperfect and have some overlap. What can you do.

### Documentation

The documentation that ships with Rust is pretty impressive.  It reminds me of
the documentation that shipped with Perl, but with more effort spent on
cohesion.  For example, [perllol](https://perldoc.perl.org/perllol),
[perldsc](https://perldoc.perl.org/perldsc), and
[perldata](https://perldoc.perl.org/perldata) are all sorta related, but are
separate documents.

The Rust version is [the collections
documentation](https://doc.rust-lang.org/stable/std/collections/index.html)
which discusses a lot of the included collections, which ones you might use
when, what the various performance characteristics are for these libraries,
etc.  This ships with Rust so you can get guidance that matches the version of
Rust you are using and you'll have access even when you're on a plane.  Other
languages seem to relegate this kind of information to a wiki or even just an
undocumented implementation detail.

### Safety and Machine Efficiency

Rust bends over backwards to make the code you write more efficient and
reliable.  I say these in the same breath because you can have (nearly) the
same safety Rust gives you by using a language with more of a runtime, but
you'll have a less efficient program in the end.  With this in mind Rust seems
to value a reliable and fast program, with the cost being much more complexity
put onto the person implementing the program.

The most obvious and infamous example of this sort of value is Rust's model of
ownership, enforced by the borrow checker.  Most of the time people write about
the borrow checker as a way to ensure correct code, but I'd pitch it as
"Compile Time Memory Management."  You get the benefits of no free/malloc and
don't have to pay the runtime cost (CPU time) and memory overhead (often 2x)
for more traditional garbage collection.  Awesome: way more efficient code,
without loss of performance.  Not awesome: you will be pulling your hair out
getting the most basic code to compile.

I have a mental model of what the Borrow Checker is ensuring, but it's both
hard for me to describe (because it's vague) and likely wrong (because it's so
immature.)  I just know people I trust who are smarter than I am say that
Rust's ownership model has helped them write safer code in other contexts, so
it's not just a nice set of tooling but a way of thinking (like all programming
languages, to some extent.)

Another example of safety (but not efficiency) is that Rust allows you to (and
implicitly encourages you to) specify your variables as **immutable**.  In theory
this means you can reason about your code better because you have confidence
that a given variable won't change after some point.  At least in practice this
is hamstrung by Rust's allowance of shadowing variables in the same scope.

I'm not quite sure where Rust's enums fit in my model of Rust's values, but
they definitely have features related to safety.  The idea is that you can have
an enum where each variant of the enum gets related data, and then when you see
values defined as the enum type you get validation that you checked all of the
variants in the enum.

I could imagine using enums like this for http style
error types; a variant for client errors (400s) a variant for upstream errors
(502) a variant for internal errors (500,) maybe a variant for timeouts (504s.)
Each variant could have a underlying cause ("missing required parameter x!") or
more structured data (max timeout, maybe?)

I have friends who really like this feature.  I think it's nice, but I'm ok
missing out on it.  Normally when I have programs that pick apart values in
this fashion I have reusable functions that I can update if a new variant is
added.  I admit that getting help from the compiler would be nice, but that's a
lot of complexity to take on.  The bigger value to me is the natural relation
of the variants to each other via the enum, or more plainly: free documentation
of what should be in your match statement.

Enums are just the tip of the iceberg here when we think about compiler
assisted exhaustive matches.  For example, you could have a match against the
theoretical errors above, with a different leg of your match statement for
various timeout durations, and be confident you didn't miss one.  I am not sure
how often that would help me make my code more reliable, but again it's a nice
feature.

The last example I have, and this fits much more with efficiency than safety,
but whatever, is macros.  Rust has a relatively rich macro system, where you
can mutate the AST of your program at compilation time with another piece of
Rust code.  This allows really cool features (stuff that in Go was or is still
done in the `go:generate` halfway house) that are effectively first class.  On
top of that the use of macros allows for a simpler language.  For example, in
Rust each function has a constant number of arguments.  The only way to have
variadic arguments is with a macro, and that's fine!  The core language is
simpler, but the compilation model is more complex.

### Expressiveness

Speaking of complexity, Rust gives you a pretty rich type system.  Unlike Go
(or Perl or Python or Ruby, if I recall correctly) the collection types
(vectors, hashmaps, and more) are in fact written in Rust.  This gives users a
lot more flexibility in what they can do or use.  If you wanted, you could make
your own vector type if you thought that the Rust built in version was
pathological for your use case.

On top of generic support, Rust has first class support for traits.  (Weird
fact: traits were, and presumably still are, a big deal in Perl around 2006
when they were made available to the language via Moose.)  Traits are a kind of
interface that your code explicitly implements, and in turn your types can get
added related methods for free, or be used where that trait is defined as the
type you pass to a function or method.  Rust leans into this *hard*.  For
example if you implement [the `std::iter::Iterator`
trait](https://doc.rust-lang.org/stable/std/iter/trait.Iterator.html) you
simply define a single method (`next`) you get nearly 70 methods provided to
you automatically.

All of this stuff is nice, but it's not free.  You as a programmer have all of
this complexity foisted upon you, whether you want to use it or not.
Inevitably there will be engineers or projects that choose to use every single
flavor of iterator, instead of the sturdy old for loop.  I know for a fact that
lots of people love this stuff.  To me it's just so much complexity.

### The Rust Distribution

These other features are less about the Rust language and more about the
compiler itself or the other stuff that ship with the compiler, so it's a bit
of a grab bag.

I mentioned the documentation for collections above.  Even ignoring the docs,
the collections included are great.  For example, resizable arrays and
dictionaries/maps/hashes should be considered table stakes these days, but Rust
includes a B-Tree Map, a much more efficient data structure on modern machines.

Any language created in the past decade should acknowledge the new multi-core
reality, and arguably the same is true when considering memory layout: new
languages should use fewer pointers and more contiguous memory to exploit
locality.  A B-Tree Map is an example data structure built with this constraint
in mind.  Rust didn't invent B-Trees, but they are available in Rust out of the
box, as they should be probably everywhere these days.

On the other hand, the standard library feels really small.  I am disappointed that
none of the following are in the standard library:

 * http support
 * json support
 * any cryptography support

Furthermore, as you peruse the standard library you'll find many parts of the
API that are marked experimental in one way or another.  I approve of the idea
of trying to avoid calling all of the API set in stone and being able to
iterate on it, but I find wading through it annoying.  I wish I could
just hide it from the docs and not think about it.

Going back to the idea of the small standard library, part of the reason Rust
is able to get away with such a small standard library is the excellent module
and system that comes with Rust called Cargo.  Cargo grants access to third
party crates so you can add third party deps easily.  You use cargo to
configure your build and to build your code.  You use cargo to generate docs
(which it does really nicely.)

I mentioned before that modern languages should acknowledge certain details of
our hardware.  A module system is like that, you should probably no longer
assume you can have a successful language without some form of module support.
I think the same goes for automated testing.  Rust comes with tooling to write
and run tests.  This is great.  Not groundbreaking, but solid.

Somewhat annoyingly, there is built in benchmarking but it's one of the
unstable features.  I've read 19 chapters of the 20 chapter Rust book and I
can't tell how you enable or use each experimental feature.  Frustrating.

## Side Project

I got to chapter 16 or 17 of the Rust book and decided that if I actually wanted
to remember how to use Rust I'd need to make a project.

My plan is to make a Rust version of
[PaPiRus](https://github.com/PiSupply/PaPiRus), named PaPiRust (h/t to Rob for
the name, my idea was worse.) PaPiRus is a Python library and cli for managing
one of a few e-paper screens.

After a bunch of research I have found that the original version works like
this:

1. It renders graphics and text to an in memory buffer using
   [pillow](https://python-pillow.org/)
2. It reads the temperature of the e-paper screen using i2c via
   [smbus2](https://pypi.org/project/smbus2/)
3. It writes the image to the screen as raw bits via [a FUSE file
   system](https://github.com/repaper/gratis/blob/master/PlatformWithOS/driver-common/epd_fuse.c),
   using the temperature read before as in input to the FUSE file based commands.

Once I discovered that so much of the functionality was relegated to FUSE (via
C) I figured that using Rust for this is probably silly, but I'll finish it and
discuss it anyway.

As part of my side project I am trying to build code for a Raspberry Pi zero.
I found a [couple](https://rust-lang.github.io/rustup/cross-compilation.html)
[articles](https://chacin.dev/blog/cross-compiling-rust-for-the-raspberry-pi/)
describing how to cross compile in Rust and I gotta say it's not as easy as I
hoped.  As far as I can tell it requires:

 * an (easy to install) extra installation of Rust
 * an extra C toolchain (compiler, linker, etc)
 * configuration to tie these things all together

After setting that up for my project I successfully built a binary... that
wouldn't run because the version of glibc didn't match the target platform.  At
that point I gave up and have been developing directly on the device.  Pretty
great that that is a sensible option (in part due to tailscale and in part due
to the magic of modern hardware being as powerful as it is.)  I could probably
set up CI with a much older glibc and be able to run the binaries on the
device, but that's a lot of effort for hello world.

The next thing I did was verify that I could do the i2c part. That was pretty
straightforward with the
[i2c-linux](https://docs.rs/i2c-linux/latest/i2c_linux/) crate.  I verified
that I could port [this
code](https://github.com/PiSupply/PaPiRus/blob/master/papirus/lm75b.py) to Rust
and run it (from a thousand miles away over SSH+Tailscale) and I was able to
without a ton of effort.  Here's a short chunk of the relevant code, for the
interested:

```rust
use i2c_linux::I2c;

let mut i2c = I2c::from_path("/dev/i2c-1")?;
i2c.smbus_set_slave_address(LM75B_ADDRESS, false)?;
i2c.smbus_write_byte_data(LM75B_CONF_REGISTER, LM75B_CONF_NORMAL)?;
i2c.smbus_read_word_data(LM75B_TEMP_REGISTER)?
// then some math to convert the 16 bit value to celcius
```

The last bit of research was to figure out how to generate an image. I asked in
the Rust discord and got some suggestions
([pixels](https://docs.rs/pixels/latest/pixels/) and
[piston](https://www.piston.rs/)) but neither seemed appropriate for my use
case. Next I did some research with [SDL2](https://docs.rs/sdl2/latest/sdl2/).
I got it building and running but it seemed like overkill and I couldn't find a
monochrome version anyway.

Finally I found a library called
[embedded-graphics](https://docs.rs/embedded-graphics/latest/embedded_graphics/)
that perfectly matches my use case. It even has drivers for some other e-paper
screens to drive directly, which is pretty awesome!

With the research and prototyping done I have the following as an outline of
the project:

1. Make a tool to render the raw bitmap to the screen. This let's me check that
   the python code matches the Rust code while I am away from the device.  I'll
   use the [embedded-graphics
   simulator](https://github.com/embedded-graphics/simulator) for that.
2. Thanks to the FUSE API I can just write to a directory for automated
   testing.

---

I plan on writing another post once I'm done with the above project, broken
down into development stages.  I see lots of good in Rust, but also plenty of
bad.  Many of my complaints will be solved as Rust matures, but there are also
issues that are inherent choices of valuing safety as highly as Rust does.

I understand this perspective, it's an easy choice to make, but safety,
caution, and conservatism have their own costs.  Maybe if you write Rust for a
few months it comes easy and you have leveled up as an engineer that writes
safe code, and the compiler can be considered training wheels that upgrade your
mental model.  Or maybe Rust engineers take 3x longer to write code but the
bugs those engineers no longer inflict upon the world would have taken that
added time to fix, likely after costing some amount of outages, incorrect
results, or just confusion.

But I also think there are a class of programs where these kinds of bugs are
not a real concern.  Consider how much of the world writes untyped code.  We
may prefer types (I certainly do at this point) but I can't universally state
that types pay for themselves in all situations.

---

(Affiliate links below.)

As mentioned above, I read <a target="_blank"
href="https://www.amazon.com/gp/product/1718500440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1718500440&linkCode=as2&tag=afoolishmanif-20&linkId=1eb063b3d79af2f0e23c3d8f6281fef7">The
Rust Programming Language</a> to really understand Rust.  I am not sure I'd
read this book again but it was acceptable for learning the Rust programming
language.

I am working on [a little tool to sell on the side called
`p8recon`](https://frew.gumroad.com/l/p8recon).  It gives you a web interface
to your [Pico-8](https://www.lexaloffle.com/pico-8.php) library.  If you take
a look and have thoughts, please let me know!
