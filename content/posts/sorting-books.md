---
title: Sorting Books
date: 2019-03-21T07:25:18
tags: [ perl, frew-warez ]
guid: 18e35dc0-5e01-4dd2-af7a-9a273134203f
---
I wrote a little program to sort lists of books.

<!--more-->

Over the weekend I was tidying up [my note on books to
read](https://frioux.github.io/notes/posts/books/).  I try to track what I want
to read, who recommended it, and when they recommended it.  I used to just try to
manually keep stuff in alphabetical order but that always eventually got messed
up.  I finally decided that I wanted to sort the lines properly (after
organizing the list into tables instead of nested lists.)

I'm pleased with what I came up with.  First I made a tool called `book-sorter`,
which prepends each line with a normalized version; here it is:

```perl
#!/usr/bin/perl

use strict;
use warnings;

no warnings 'uninitialized';

use feature 'fc';

while (<STDIN>) {
   my $v = $_;
   $v =~ s/^\W+//;
   $v =~ s/^(the|a|an)\b//i;
   $v =~ s/^\W+//;
   $v = fc $v;

   chomp $v;
   print "$v\0$_"
}
```

So this transforms each line in a streaming fashion, stripping non-word
characters, then articles (a, an, or the), and finally any more non-word
characters.  Finally it
[case-folds](https://en.wikipedia.org/wiki/Letter_case#Case_folding) the string
so comparisons will be case-insensitive.  I could have lowercased, but this will
work better with non-ascii.

Next I build a script called `book-sort` that uses `book-sorter`:

```bash
#!/bin/sh

bin/book-sorter |
   sort |
   cut -d "$(printf "\0")" -f2
```

Pretty neat!

---

(The following includes affiliate links.)

If you're interested in diving deeper than is probably wise in writing shell
scripts, you should check out
<a target="_blank" href="https://www.amazon.com/gp/product/1590593766/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1590593766&linkCode=as2&tag=afoolishmanif-20&linkId=6fa6aef84b017be180f16a769c947a10">From Bash to Z Shell</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1590593766" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The book has in depth coverage of all of the major POSIX shells and their
non-POSIX features.

On a completely different note, I recently read
<a target="_blank" href="https://www.amazon.com/gp/product/1250029627/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1250029627&linkCode=as2&tag=afoolishmanif-20&linkId=f625fbf0cea8422dc247e6cbf77b3323">Spy the Lie</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1250029627" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
suggested by [Jess Frazelle](https://blog.jessfraz.com/).  It was fascinating!
I am a little nervous to put any such skills to use, but it's better to know if
someone is lying than to incorrectly assume they are being honest.
