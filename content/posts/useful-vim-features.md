---
title: Useful Vim Features
date: 2020-10-10T08:45:51
tags: [ "vim" ]
guid: dd45eae1-6b2b-4e5d-9786-a2958b7abf97
---


<!--more-->

One of the most powerful general features in vim is the quickfix.  [I have
written about it before](/posts/my-editing-workflow/) but it bears revisiting
and expanding.  [The
quickfix](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix) (and
the related [location
list](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#location-list)) is a
built in vim feature that allows defining lists of locations (filename, line
number, and column) along with some extra text.

You can use [the `:make`
command](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:make) to run a
compiler and populate the quickfix with various locations of your inevitable
mistakes.  There are approximately ten thousand little settings that allow you
to customize this behavior.  For example, you can set [the `&makeef` option]()
to control where the error file goes, which can be useful for slow
compilations.  A handy feature my friend Meredith showed me was that you can
define [a BufReadPost autocommand]() to make your quickfix more attractive.  In
some of mine I use this to hide all but the comment:

```vim
augroup hugo
   autocmd!

   au BufReadPost quickfix setlocal nowrap

   au BufReadPost quickfix
     \ if w:quickfix_title =~ "^:cgetexpr system('bin/" |
       \ setl modifiable |
       \ silent exe ':%s/\v^([^|]+\|){2}\s*//g' |
       \ setl nomodifiable |
     \ endif
augroup END
```

Sometimes you want to wire functionality into the quickfix but don't want to
have to go through all of the effort of defining a new make program, a new
error format, etc.  I find [the `:cgetexpr` command]() useful for this.  As
an example, sometimes I want to be able to iterate over all of the hunks in a
diff.  I have [a perl script]() that formats diffs in the default quickfix
format, and I defined a command to parse it into the quickfix:

```vim
command! Gdiffs cexpr system('git diff | diff-hunk-list')
```

One last little handy tip: vim maintains the last ten quickfix lists, so if you
accidentally blow away your quickfix, you can get back to the previous one with
[the `:colder` command]().

---

This article was a collaboration between [Neil Bowers](), [Rob Hoelz](),
([you??]()), and myself (Santa Monica) as part of 2020 Hacktoberfest.
