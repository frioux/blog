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

You can iterate through the locations with [the `:cnext` command]() and [the
`:cprev` command]().  You can show a window of the locations with the `:copen`
command; in the window, simple pressing `<Enter>` on one of the lines will open
the file in one of your existing windows.

You can use [the `:make`
command](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:make) to run a
compiler and populate the quickfix with various locations of your inevitable
mistakes.  There are approximately ten thousand little settings that allow you
to customize this behavior.  For example, you can set [the `makeef`
option](http://vimdoc.sourceforge.net/htmldoc/options.html#'makeef') to control
where the error file goes, which can be useful for slow compilations.  A handy
feature my friend Meredith showed me was that you can define [a BufReadPost
autocommand](http://vimdoc.sourceforge.net/htmldoc/autocmd.html#BufReadPost) to
make your quickfix more attractive.  In some of mine I use this to hide all but
the comment:

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

This produces a quickfix like this (for this blog:)

```
  1 2020-10-10 Useful Vim Features
  2 2020-09-21 Logorrhea
  3 2020-05-13 Mixer Post Mortem
  4 2020-05-08 Improve Git Diffs for Structured Data
  5 2020-05-05 Go Subtest Tips
  6 2020-04-27 Adding Autoreload to srv
  7 2020-04-07 context Deadlines in Go
  8 2020-03-24 I Avoid Named Pipes
  9 2020-02-27 Zine: Software for Managing Notes
 10 2020-02-14 Testing Perl Clients and Go Servers
[Quickfix List] :cgetexpr system('bin/quick-chrono') | cwindow
```

Sometimes you want to wire functionality into the quickfix but don't want to
have to go through all of the effort of defining a new make program, a new
error format, etc.  I find [the `:cgetexpr`
command](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:cgetexpr) useful
for this.  As
an example, sometimes I want to be able to iterate over all of the hunks in a
diff.  I have [a perl
script](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:cgetexpr) that
formats diffs in the default quickfix format, and I defined a command to parse
it into the quickfix:

```vim
command! Gdiffs cexpr system('git diff | diff-hunk-list')
```

One last little handy tip: vim maintains the last ten quickfix lists, so if you
accidentally blow away your quickfix, you can get back to the previous one with
[the `:colder`
command

# Game, Set, Match

Vim is full of obscure commands, and one that can be useful is `:match`.  One
thing I (Rob) use it for is highlighting end-of-line whitespace:

```vim
" Define a highlight group for things that annoy me
highlight Annoyance ctermbg=236 " a dark grey
" I hate end of line whitespace...highlight it
match Annoyance /\s\+$/
```

...and another is for highlighting lines that are too long:

```vim
autocmd FileType c 2match Annoyance /\%>78v./    " Match characters beyond column 78
autocmd FileType perl 2match Annoyance /\%>78v./
```

You can see these two in action here - I changed the highlight color to cyan to make it more apparent what's going on:

![example of using match to highlight end-of-line whitespace](/static/img/vim-match-eol.png "Example of using match to highlight end-of-line whitespace")

![example of using match to highlight long lines](/static/img/vim-match-long-lines.png "Example of using match to highlight long lines")

Another way I've used `:match` in the past is to highlight similar - but
distinct - variables.  For example, last year I was working on a problem for
[Advent of Code](https://adventofcode.com/) that was doing "fun" stuff in a 3D
space, so I had variables like `posX`, `posY`, `posZ`.  To help myself keep them
separate, I defined some match rules to color them differently:

```vim
highlight XCoord ctermbg=4 ctermfg=15 " white on blue
highlight YCoord ctermbg=2 ctermfg=0  " black on green
highlight ZCoord ctermbg=1 ctermfg=15 " white on red

match XCoord /\<\i*X\>/
2match YCoord /\<\i*Y\>/
3match ZCoord /\<\i*Z\>/
```

This ends up looking like this:

![example of using match to distinguish variables](/static/img/vim-match-coords.png "Example of using match to distinguish variables")

I know that in certain circles, syntax highlighting isn't very popular, but I
find that color really helps my brain process large chunks of text (whether
that's just how my brain works or it's how it has changed after years of using
syntax highlighting, I'm unsure).

---

This article was a collaboration between [Neil Bowers](), [Rob Hoelz](https://hoelz.ro),
([you??]()), and myself (Santa Monica) as part of 2020 Hacktoberfest.
