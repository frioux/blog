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

## Reviewing, refining, and reusing your command history (Neil)

If you're used to working with regular expressions,
then you may find yourself doing hairy searches in vim.
In the past, if I knew I was going to reuse a search,
or perhaps do variants of it, then I might save it in a file.

But it turns out that vim saves your search history.
To see it, enter **`q/`** when in command mode,
and your window will split, with the new buffer containing your search history,
one search per line.
You can move around and edit this in the usual way,
but if you hit return,
vim will close the window and run the search that was under the cursor.

Similarly, **`q:`** will show you your ex command history.

These histories are persistent,
and if you want to remember the last 100 commands,
just put the following in your .vimrc:

    set history=100

If you just want to scroll up through your search history,
hit **`/`** to start the search, and then cursor up repeatedly.
if you start a search with **`/sub`** and then cursor up,
it will only show searches that start with that pattern.

## Inside and Around (Neil)

Many commands in vim take the form &lt;command&gt;&lt;motion&gt;.
So **`dw`** deletes from the character under the cursor
to the start of the next word,
and **`>}`** indents from the current line to the end of the paragraph.

Previously,
if I were in the middle of a paragraph that I wanted to indent,
I'd first use **`{`** to go to the start of the paragraph,
and then use **`>}`** to indent the paragraph.
Mentally that was two commands: a movement, and an indent.

In this situation (somewhere in the middle of a paragraph),
I now use **`ap`** for the motion, which selects the paragraph
around the cursor.
So to indent the current paragraph, I use **`>ap`**.

This is the same number of key presses,
but it's a single action instead of two,
and directly maps from my intention to the action.

Another place to use this approach is when your cursor
is somewhere between a pair of delimeters.
For example, you're in the middle of a double quoted string,
and what to change the whole string:

> ![example quoted string](https://i.imgur.com/V4ZEyQ7.png)

You might press **b** multiple times to get to the start of the string,
or maybe **T"** to move back to the character after the **"**,
and then **ct"** to change up to the matching double quote.

But much more efficiently, you can type **ci"**,
which will remove everything between the matching double quotes,
and put you into insert mode.
And if you want to change from double to single quotes,
then **ca"** will change the string *and* the delimiters.

Other useful things are **cit** to change between a pair of HTML/XML tags,
**ci(** to change inside parens.
=======
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
