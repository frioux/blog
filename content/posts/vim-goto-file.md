---
title: "Vim: Goto File"
date: 2016-06-21T00:23:40
tags: [vim]
guid: "https://blog.afoolishmanifesto.com/posts/vim-goto-file"
---
Vim has an awesome feature that I think is not shown off enough.  It's pretty
easy to use and configure, but thankfully many languages have a sensible
configuration out of the box.

<!--more-->

Vim has this feature that opens a file when you press
[gf](http://vimdoc.sourceforge.net/htmldoc/editing.html#gf) over a filename.  On
the face of it, it's only sort of useful.  There are a couple settings that make
this feature incredibly handy.

## `path`

First and foremost, you have to set your
[path](http://vimdoc.sourceforge.net/htmldoc/options.html#%27path%27).
Typically when you open a Perl script or module in vim, the path is set to
something like this:

 * `$(pwd)`
 * `/usr/include`
 * `$PERL5LIB`
 * And Perl's default `@INC`

It's a good idea to add the path of your current project, for example:

```
:set path+=lib
```

So on a typical Linux system, you can type out `zlib.h` and press `gf` over it
and pull up the zlib headers.  The next feature is what really makes it
powerful.

## `suffixesadd` and `includeexpr`

The more basic of the two options is
[suffixesadd](http://vimdoc.sourceforge.net/htmldoc/options.html#%27suffixesadd%27).
It is simply a list of suffixes to attempt to add to the filename.  So in the
example above, if you `:set suffixesadd=.h` and then type `zlib` and then press
`gf` on the word, you'll pull of the header files for zlib.  That's too basic
for most modern programming environments though.  Here's the default
[includeexpr](http://vimdoc.sourceforge.net/htmldoc/options.html#%27includeexpr%27)
for me when I open a perl script:

```
substitute(substitute(substitute(v:fname,'::','/','g'),'->*','',''),'$','.pm','')
```

Let's unpack that to make sure we see what's going on.  This may be subtly
incorrect syntax, but that's fine.  The point is to communicate what is
happening above.

```
to_open = v:fname

# replace all :: with /
to_open = substitute(to_open,'::','/','g')

# remove any method call (like ->foo)
to_open = substitute(to_open,'->*','','')

# append a .pm
to_open = substitute(to_open,'$','.pm','')
```

With the above we can find the filename to open.  This is the default.  You can
do even better, if you put in a little effort.  Here is an idea I'd like to try
when I get some time, call a function as the expression, and in the function, if
the fname contains, `->resultset(...)` return the namespaced resultset.  I'd
need to tweak the
[ifsname](http://vimdoc.sourceforge.net/htmldoc/options.html#%27isfname%27) to
allow selecting weird characters, and maybe that would be more problematic than
it's worth, but it's hard to know before you try. Could be really handy!

Even if you don't go further with this idea, consider using `gf` more
often.  I personally use it (plus `CTRL-O` as a "back" command") to browse repos
and even the Perl modules they depend on.

---

If you'd like to learn more, I can recommend two excellent books.  I first
learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.
