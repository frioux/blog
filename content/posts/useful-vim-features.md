---
title: Useful Vim Features
date: 2020-10-10T08:45:51
tags: [ "vim" ]
guid: dd45eae1-6b2b-4e5d-9786-a2958b7abf97
---
Some friends and I collaborated on some interesting features in vim.

<!--more-->

## QuickFix (fREW)

One of the most powerful general features in vim is the quickfix.  [I have
written about it before](/posts/my-editing-workflow/) but it bears revisiting
and expanding.  [The
quickfix](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#quickfix) (and
the related [location
list](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#location-list)) is a
built in vim feature that allows defining lists of locations (filename, line
number, and column) along with some extra text.

You can iterate through the locations with [the `:cnext`
command](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:cnext) and [the
`:cprev` command](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:cprev).
You can show a window of the locations with [the `:copen`
command](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:copen); in the
window, simple pressing `<Enter>` on one of the lines will open the file in one
of your existing windows.

You can use [the `:make`
command](http://vimdoc.sourceforge.net/htmldoc/quickfix.html#:make) to run a
compiler and populate the quickfix with various locations of your inevitable
mistakes.  There are approximately ten thousand little settings that allow you
to customize this behavior.  For example, you can set the `makeef` option to
control where the error file goes, which can be useful for slow compilations.
A handy feature my friend Meredith showed me was that you can define [a
BufReadPost
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

*Editor: you can also use Control-f from the command or search prompt to jump
into these saved histories.*

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

![example quoted string](/static/img/vim-inner.png)

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

## Game, Set, Match (Rob)

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

## Insert Mode Completions (Rob)

Did you know that Vim has its own completion system that you can invoke from
Insert mode?  I don't know how many people know about this functionality, but
I've found it invaluable in saving myself keystrokes and time!

You enter into completion mode via `Ctrl-x`, and from there you enter Ctrl plus
another key to select which mode of completion you want.  There are quite a few
modes - here are the ones I find myself using most often:

### `Ctrl-X Ctrl-N`: Keywords in `complete`

This has two convenient shortcut in the forms of `Ctrl-N` and `Ctrl-P`, which
select the next and previous found keywords, respectively.  "Found" here is
defined by the 'complete' option, which you can set to have the completion
search the current buffer, all open buffers, `tags` files, and much, much more
- check out `:help 'complete'` for a full listing!

I use this most often to complete variable or function names that I've typed
already, but are long enough to be annoying to type, or contain certain
character combinations that I find difficult to type.

### `Ctrl-X Ctrl-F`: Filename completion

I use this one _all_ the time!  If you're typing a path to a file, you can
generate completions for that path while you're typing it.

### `Ctrl-X Ctrl-K`: Dictionary completion

I use this one occasionally when writing prose - it does exactly what it says!
It's handy for completing long words like "respectively" - my only complaint
about it is that it presents _way_ too many results by default, and they're
ordered alphabetically, rather than by something like general frequency or
frequency in the current context.  The "too many results" problem could
probably be rectified by using a different dictionary for completions, but the
ordering problem would probably require a plugin of some sort.

### `Ctrl-X Ctrl-L`: Whole line completion

I admit - when I first read about this mode, I thought to myself "who would
ever use that?" - and now I find myself using it way more than I thought I
would!  I think I mostly use it when writing YAML for Kubernetes manifests -
like if I have a complete manifest open in another buffer and I want to
complete `apiVersion: ` or something.  It's also handy for copying a line
currently on your screen - let's say you want to copy a line 17 lines above the
cursor.  You _could_ do `<escape> 17k yy 17j p`, or `:-17t .`, but I've found
it's quick and easy to type a short prefix and then use `Ctrl-X Ctrl-L`.

### `Ctrl-X Ctrl-O`: Omni-completion

I saved the most flexible one for last - omni-completion!  Omni-completion is
Vim's term for one of its forms of user-customizable completion - you'll most
often see it used for things like language-aware completions.  For example, if
you're writing Go and you're using one of the Go support plugins, or if you're
using a plugin that hooks into the Language Server Protocol, using `Ctrl-X
Ctrl-O` will tell Vim to ask for completions for things like "what variables
are currently in scope?" or "what methods are present on this variable?".

*Editor: I wrote a little bit about [defining your own omni-completion
here](/posts/hugo-unix-vim-integration/#tag-completion).*

## Other modes

I've only the few modes that I've actually used in practice - there a quite a
few more, so I suggest checking out `:help ins-completion` to see if any of the
others listed there give you ideas for improving your Vim workflow!

---

This article was a collaboration between [Neil
Bowers](http://neilb.org/index.html) in Marlow, [Rob Hoelz](https://hoelz.ro)
in Waukesha, and myself in Santa Monica as part of 2020 Hacktoberfest.
Originally at least Rob and I had planned on submitting various pull requests
to projects we care about, but after [the rules
changed](https://hacktoberfest.digitalocean.com/hacktoberfest-update) Neil
suggested this as a better path forward.  Hope you enjoyed it!
