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

# Insert Mode Completions

Did you know that Vim has its own completion system that you can invoke from
Insert mode?  I don't know how many people know about this functionality, but
I've found it invaluable in saving myself keystrokes and time!

You enter into completion mode via `Ctrl-x`, and from there you enter Ctrl plus
another key to select which mode of completion you want.  There are quite a few
modes - here are the ones I find myself using most often:

## `Ctrl-X Ctrl-N`: Keywords in `complete`

This has two convenient shortcut in the forms of `Ctrl-N` and `Ctrl-P`, which
select the next and previous found keywords, respectively.  "Found" here is
defined by the 'complete' option, which you can set to have the completion
search the current buffer, all open buffers, `tags` files, and much, much more
- check out `:help 'complete'` for a full listing!

I use this most often to complete variable or function names that I've typed
already, but are long enough to be annoying to type, or contain certain
character combinations that I find difficult to type.

## `Ctrl-X Ctrl-F`: Filename completion

I use this one _all_ the time!  If you're typing a path to a file, you can
generate completions for that path while you're typing it.

## `Ctrl-X Ctrl-K`: Dictionary completion

I use this one occasionally when writing prose - it does exactly what it says!
It's handy for completing long words like "respectively" - my only complaint
about it is that it presents _way_ too many results by default, and they're
ordered alphabetically, rather than by something like general frequency or
frequency in the current context.  The "too many results" problem could
probably be rectified by using a different dictionary for completions, but the
ordering problem would probably require a plugin of some sort.

## `Ctrl-X Ctrl-L`: Whole line completion

I admit - when I first read about this mode, I thought to myself "who would
ever use that?" - and now I find myself using it way more than I thought I
would!  I think I mostly use it when writing YAML for Kubernetes manifests -
like if I have a complete manifest open in another buffer and I want to
complete `apiVersion: ` or something.  It's also handy for copying a line
currently on your screen - let's say you want to copy a line 17 lines above the
cursor.  You _could_ do `<escape> 17k yy 17j p`, or `:-17t .`, but I've found
it's quick and easy to type a short prefix and then use `Ctrl-X Ctrl-L`.

## `Ctrl-X Ctrl-O`: Omni-completion

I saved the most flexible one for last - omni-completion!  Omni-completion is
Vim's term for one of its forms of user-customizable completion - you'll most
often see it used for things like language-aware completions.  For example, if
you're writing Go and you're using one of the Go support plugins, or if you're
using a plugin that hooks into the Language Server Protocol, using `Ctrl-X
Ctrl-O` will tell Vim to ask for completions for things like "what variables
are currently in scope?" or "what methods are present on this variable?".

## Other modes

I've only the few modes that I've actually used in practice - there a quite a
few more, so I suggest checking out `:help ins-completion` to see if any of the
others listed there give you ideas for improving your Vim workflow!

---

This article was a collaboration between [Neil Bowers](), [Rob Hoelz](),
([you??]()), and myself (Santa Monica) as part of 2020 Hacktoberfest.
