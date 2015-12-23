---
title: "Python: Taking the Good with the Bad"
date: 2016-04-21T14:15:04
tags: [python, perl, generators, postmodernism, prescriptivism]
guid: "https://blog.afoolishmanifesto.com/posts/python-a-critique"
---
For the past few months I've been working on a side project using Python.  I'll
post about that project some other time, but now that I've used Python a little
bit I think I can more reasonably consider it (so not just "meaningful
whitespace?!?")

It's much too easy to write a bunch of stuff that is merely justification of the
status quo (in my case that is the use of Perl.)  I'm making an effort to
consider all of the good things about Python and only mentioning Perl when there
is a lack.  I'd rather not compare them at all, but I don't see a way around
that without silly mental trickery.

Note that this is about Python 2.  If you want to discuss Python 3, let's
compare it to Perl 6.

# Generally awesome stuff about Python

The following are my main reasons for liking Python.  They are in order of
importance, and some have caveats.

## Generators

Generators (also known as continuations) are an awesome linguistic feature.  It
took me a long time to understand why they are useful, but I think I can
summarize it easily now:

What if you wanted to have a function with an infinite loop in the middle?

In Perl, the typical answer might be to [build an
interator](http://hop.perl.plover.com/book/pdf/04Iterators.pdf).  This is fine,
but it can be a lot of work.  In Python, you just use normal code, and a special
keyword, `yield`.  For simple stuff, the closures you have available to you in
Perl will likely seem less magic.  But for complicated things, like iterating
over the nodes in a tree, Python will almost surely be easier.

Let me be clear: in my mind, generators are an incredibly important feature and
that Perl lacks them is significant and terrible.  There are efforts to get
them into core, and there is a library that implements them, but it is not
supported on the newest versions of Perl.

## Builtins

Structured data is one of the most important parts of programming.  Arrays are
super important; I think that's obvious.  Hashes are, in my opinion, equally
useful.  There are a lot of other types of collections that could be considered
after the point of diminishing returns once hashes are well within reach, but a
few are included in Python and I think that's a good thing.  To clarify, in
Python, one could write:

```
cats = set(['Dantes', 'Sunny Day', 'Wheelbarrow'])
tools = set(['Hammer', 'Screwdriver', 'Wheelbarrow'])

print cats.intersection(tools)
```

In Perl that can be done with a hash, but it's a hassle, so I tend to use
[Set::Scalar](https://metacpan.org/pod/Set::Scalar).

Python also ships with an OrderedDict, which is like Perl's
[Tie::IxHash](https://metacpan.org/pod/Tie::IxHash).  But `Tie::IxHash` is sorta
aging and weird and what's with that name?

A Python programmer might also mention that the DefaultDict is cool.  I'd argue
that the DefaultDict merely works around Python's insistence that the programmer
be explicit about a great many things.  That is: it is a workaround for Pythonic
dogma.

## Rarely need a compiler for packages

In my experience, only very rarely do libraries need to be compiled in Python.
So oviously math intensive stuff like crypto or high precision stuff will need a
compiler, but the vast majority of other things do not.  I think part of the
reason for this is that Python ships with an FFI library
([ctypes](https://docs.python.org/2/library/ctypes.html)).  So awesome.

In Perl, even the popular OO framework Moose requires a compiler!

## "protocols"

If you want to define your own weird kind of dictionary in Python, it's really
easy: you subclass `dict` and define around ten methods.  It will all just work.
This applies to all of Python's builtins, I believe.

In Perl, you have to use `tie`, which is similar but you can end up with
oddities related to Perl's weird indirect method syntax.  Basically, often
things like `print $fhobject $str` will not work as expected.  Sad camel.

## Interactive Python Shell

Python ships with an excellent interactive shell, which can be used by simply
running `python`.  It has line editing, history, builtin help, and lots of other
handy tools for testing out little bits of code.  I have lots of little tools to
work around the lack of a good interactive shell in Perl.  This is super handy.

## Simple Syntax

The syntax of Python can be learned by a seasoned programmer in an afternoon.
Awesome.

## Cool, weird projects

I'll happily accept more examples for this.  A few spring to mind:

 1. [BCC](https://github.com/iovisor/bcc) is sorta like a DTrace but for Linux.
 2. [PyNES](http://gutomaia.net/pyNES/) lets you run NES games written in
    Python.
 3. [BITS](http://biosbits.org/) is a Python based operating system, for doing
    weird hardware stuff without having to write C.

## Batteries Included

Python ships with a lot of libraries, like the builtins above, that are not
quite so generic.  Some examples that I've used include a netrc parser, an IMAP
client, some email parsing tools, and some stuff for building and working with
iterators.  The awesome thing is that I've written some fairly handy tools that
in Perl would have certainly required me to reach for CPAN modules.

What's not so awesome is that the libraries are clearly not of the high quality
one would desire.  Here are two examples:

First, the [core netrc library](https://docs.python.org/2/library/netrc.html)
can only select by host, instead of host and account.  This was causing a bug
for me when using [OfflineIMAP](http://www.offlineimap.org/).  I rolled up my
sleeves, cloned cpython, [fixed the
bug](https://github.com/frioux/cpython/commit/5878f8c17944695483ff802087dc6b33ee4c10d0),
and then found that it had been [reported, with a patch, five years
ago](https://bugs.python.org/issue11416).  Not cool.

Second, the builtin email libraries are pretty weak.  To get the content of a
header I had to use the following code:

```
import email.header
import re

decoded_header = str(email.header.make_header(email.header.decode_header(header)))
unfolded_header = re.sub('[\r\n]', '', decoded_header)
```

I'm not impressed.

There are more examples, but this should be sufficient.

Now before you jump on me as a Perl programmer: Perl *definintely* has some weak
spots in it's included libraries, but unlike with Python, the vast majority of
those are actually on CPAN and can be updated without updating Perl.  Unless I
am missing something, that is not the case with the Python core libraries.

## Prescriptive

The Python community as a whole, or at least my interaction with it, seems to be
fairly intent on defining the one-and-true way to do anything.  This is great
for new programmers, but I find it condescending and unhelpful.  I like to say
that the following are all the programmer's creed (stolen from various media):

> That which compiles is true.

> Nothing is True and Everything is Permissible

> "Considered Harmful" Considered Harmful

# Generally not awesome stuff about Python

As before, these are things that bother me about Python, in order.

## Variable Scope and Declaration

Python seems to aim to be a boring but useful programming language.  Like Java,
but a scripting language.  This is a laudable goal and I think Go is the newest
in this tradition.  Why would a language that intends to be boring have any
scoping rules that are not strictly and exclusively lexical?  If you know, tell
me.

In Perl, the following code would not even compile:

```
use strict;

sub print_x { print("$x\n") }
print_x();
my $x = 1;
print_x();
```

In Python, it does what a crazy person would expect:

```
def foo():
   print(x)

foo()
x = 1
foo()
```

The real problem here is that in Python, variables are never declared. It is not
an error to set `x = 1` in Python, how else would you create the variable?  In
Perl, you can define a variable as lexical with `my`, global with `our`, and
dynamic with `local`.  Python is a sad mixture of lexical and global.  [The fact
that anyone would ever need to explain
scoping](http://stackoverflow.com/a/292502/12448) implies that it's pretty
weird.

## PyPI and (the lack of) friends

I would argue that since the early 2000's, a critical part of a language is its
ecosystem.  A language that has no libraries is lonely, dreary work.  Python has
plenty of libraries, but the actual web presence of the ecosystem is crazily
fractured.  Here are some things that both
[search.cpan.org](http://search.cpan.org/) and [MetaCPAN](https://metacpan.org/)
do that PyPI does not:

   * **Include and render all of the documentation for all modules** ([example](https://metacpan.org/pod/DBIx::Class::Helper::ResultSet::CorrelateRelationship))
   * Include a web accessible version of all (or almost all) releases of the code ([example](https://metacpan.org/source/DBIx::Class::Helper::ResultSet::Util), [example](https://metacpan.org/source/FREW/DBIx-Class-Helpers-0.092970/lib/DBIx/Class/Helper/JoinTable.pm))

And MetaCPAN does a ton more; here are features I often use:

   * Parsing Changelogs ([Look at the top](https://metacpan.org/release/FREW/DBIx-Class-Helpers-2.032001))
   * Linking directly to the source repository ([Look on the left](https://metacpan.org/release/FREW/DBIx-Class-Helpers-2.032001))

And there's a constellation of other tools; here are my favorites:

   * [CPANTesters](http://www.cpantesters.org/) aggregates the test results of individuals and smoke machines of huge amounts of CPAN on a ton of operating systems.  [Does your module run on Solaris?](http://www.cpantesters.org/cpan/report/65619be2-03fc-11e6-a6f2-e12f13c359e3)
   * [rt.cpan.org](http://rt.cpan.org/) is a powerful issue tracker that creates a queue of issues for every module released on CPAN.  Nowadays with Github that's not as important as it used to be, but even *with* Github, RT still allows you to create issues without needing to login.

## Documentation

This is related to my first complaint about PyPI above.  When I install software
on my computer, I want to read the docs that are local to the installed version.
There are two reasons for this:

 1. I don't want to accidentally read docs for a different version than what is installed.
 2. I want to be able to read documentation when the internet is out.

Because the documentation of Python packages is so free form, people end up
hosting their docs on random websites.  That's fine, I guess, but people end up
*not* including the documentation in the installed module.  For example, if you
install [boltons](https://boltons.readthedocs.org/), you'll note that while you
can run `pydoc boltons`, there is no way to see [this
page](https://boltons.readthedocs.org/en/latest/architecture.html) via pydoc.
Pretty frustrating.

On top of that, the documentation by *convention* is
[reStructuredText](http://docutils.sourceforge.net/rst.html).  rst is fine, as a
format.  It's like markdown or POD (Perl's documentation format) or whatever.
But there are (at least) two very frustrating issues with it:

 1. There is no general linking format.  In Perl, if I do `L<DBIx::Class::Helpers>`, it will link to the doc for that module.  Because of the free form documentation in Python, this is impossible.
 2. It doesn't render at all with pydoc; you just end up seeing all the noisy syntax.

And it gets worse!  There is documentation for core Python that is stored on a
wiki!  A good example is [the page about the time complexity of various
builtins](https://wiki.python.org/moin/TimeComplexity).  There is no good reason
for this documentation to not be bundled with the actual Python release.

## matt's script archive

As much as the prescriptivism of Python exists to encourage the community to
write things in a similar style; a ton of old code still exists that is just as
crappy as all the old Perl code out there.

I love examples, and I have a good one for this.  My little Python project
involves parsing RSS (and Atom) feeds.  I asked around and was pointed at
[feedparser](https://pythonhosted.org/feedparser/).  It's got a lot of
shortcomings.  The one that comes to mind is, if you want to parse feeds without
sanitizing the included html, you have to mutate a global.  Worse, this is only
documented [in a comment in the source
code](https://github.com/kurtmckee/feedparser/blob/develop/feedparser/api.py#L82-L84).

## Unicode

Python has this frustrating behaviour when it comes to printing Unicode.
Basically if the programmer is printing Unicode (the string is not bytes, but
meaningful characters) to a console, Python assumes that it can encode as UTF8.
If it's printing to anything else it defaults to ASCII and will often throw an
exception.  This means you might have some code that works perfectly well when
you are testing it Interactively, and when it happens to print just ASCII when
redirected to a file, but when characters outside of ASCII show up it throws an
exception.  (Try it and see: `python -c 'print(u"\u0420")' | cat`)  ([Read more
here](https://daveagp.wordpress.com/2010/10/26/what-a-character/).)

It's also somewhat frustrating that the Python wiki complains that [Python
predates Unicode](https://wiki.python.org/moin/StrIsNotAString) and thus cannot
be expected to support it, while Perl predates even Python, but has *excellent*
support for Unicode built into Perl 5 (the equivalent of Python 2.x.)  A solid
example that I can think of is that while Python encourages users to be aware of
Unicode, it does not give users a way to compare strings ignoring case.  Here's
an example of where that matters; if we are ignoring case, "ß" should be equal
to "ss".  In Perl you can verify this by running:
`perl -Mutf8 -E'say "equal" if fc "ß" eq fc "ss"'`.  In Python one must
download a package from PyPI which is documented as an order of magnitude slower
than the core version from Python 3.

## SIGPIPE

In Unix there is this signal, SIGPIPE, that gets sent to a process when the pipe
it is writing to gets closed.  This can be a simple efficiency improvement, but
even ignoring efficiency, it will get used.  Imagine you have code that reads
from a database, then prints a line, then reads, etc.  If you wanted the first
10 rows, you could pipe to `head -n10` and both truncate after the 10th line and
kill the program.  In Python, this causes an exception to be thrown, so users of
Python programs who know and love Unix will either be annoyed that they see a
stack trace, or submit annoying patches to globally ignore SIGPIPE in your
program.

---

Overall, I think Python is a pretty great language to have available.  I still
write Perl most of the time, but knowing Python has definitely been helpful.
Another time I'll write a post about being a polyglot in general.
