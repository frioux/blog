---
title: Vim Debugging
date: 2017-09-08T07:45:05
tags: [ vim, debugging ]
guid: 197A6C98-9255-11E7-B3C9-8178868F3B27
---
I use Vim quite a bit and fairly heavily, so I run into a good amount of bugs.
I'll share a couple tricks I've learned that help debug vim.

<!--more-->

## Bisection

Fundamentally this debugging technique is bisection.  It's more complicated than
that, because often you will find that you need multiple parts to reproduce a
bug, but nonetheless that is the general idea.

If you are unfamiliar with bisection, the general idea is that you have a big
pile of stuff, and you take one half of it, check if what you are looking for is
in that half, and if it is, you split in half again etc.  If it isn't, you start
looking in the second half and recurse.

The above assumes that in your pile of stuff there is exactly one thing you are
looking for.  In my experience this is very rarely true with Vim bugs.
Typically issues are a combination of your own `.vimrc` and a plugin, or two or
more plugins put together.

## Reproduction

You have to be able to reproduce the problem consistently.  Usually I can do
this without a lot of effort, though I did have a problem recently where GVim got
slower and slower while using a `GTK3` version of GVim, which was a huge hassle
to track down.  Here's a trick one of my coworkers showed me for when the plugin
in question causes slowdowns:

```
$ time vim some/file/thats.md +quit
```

This will show how long it took vim to start up, read the file, and then exit.

## Plugins vs Config

So the first step is to check that it's not simply your own config.  In this
post I will be discussing `pathogen`, but other plugin managers should fit in
pretty much the same.

If your `.vimrc` looked like this, you would want to comment out the `pathogen`
lines (commented out with the `"` character), to avoid loading any plugins:

``` vim
" runtime bundle/pathogen/autoload/pathogen.vim
" call pathogen#infect()
augroup vimrc
   autocmd!
   au VimEnter * set vb t_vb=
   au FileType perl let b:dispatch = 'perl %'
   au FileType perl setlocal formatprg=perltidy
   au FileType help setlocal nolist
   au BufWritePre /tmp/* setlocal noundofile
   au BufWritePre /run/shm/* setlocal noundofile
augroup END

set nocompatible
set conceallevel=2
set undofile
set history=10000
set matchpairs+=<:>
set showcmd
filetype on
filetype plugin on
filetype plugin indent on
syntax enable
set autoindent
```

If you can still reproduce the problem, bisect your own config till you find the
line that causes it.  Then I'd [read related docs][docs], ask [the mailing
list][ml], or ask [the irc channel][irc] (results may vary.)

That's pretty rare though.  Next is to comment out all of your own config, and
allow the plugins to be loaded:

``` vim
runtime bundle/pathogen/autoload/pathogen.vim
call pathogen#infect()

" augroup vimrc
"    autocmd!
"    au VimEnter * set vb t_vb=
"    au FileType perl let b:dispatch = 'perl %'
"    au FileType perl setlocal formatprg=perltidy
"    au FileType help setlocal nolist
"    au BufWritePre /tmp/* setlocal noundofile
"    au BufWritePre /run/shm/* setlocal noundofile
" augroup END
" 
" set nocompatible
" set conceallevel=2
" set undofile
" set history=10000
" set matchpairs+=<:>
" set showcmd
" filetype on
" filetype plugin on
" filetype plugin indent on
" syntax enable
" set autoindent
```

If you do not reproduce your problem, you need to load a plugin and some config.
My first step in this case would be to leave all plugins loaded and bisect to
the line (or lines) that trigger the problem.

Next you can unroll the plugins.  For fugitive I do it like this:

``` vim
:read! ls /home/frew/code/dotfiles/vim/bundle --color=never
```

This populates my current buffer (presumably the `.vimrc`) with my plugins.  I
then highlight the results (with `v`) and type:

``` vim
:normal Iset rtp+=~/code/dotfiles/vim/bundle/
```

Using `:s` would work too and would likely be faster, but I tend to use
`normal` more often.  Once you have done this, ensure that you can still
reproduce the problem.  Your `.vimrc` should look something like this:

``` vim
set rtp+=~/code/dotfiles/vim/bundle/commentary
set rtp+=~/code/dotfiles/vim/bundle/eunuch
set rtp+=~/code/dotfiles/vim/bundle/fugitive
set rtp+=~/code/dotfiles/vim/bundle/grepper
set rtp+=~/code/dotfiles/vim/bundle/polyglot
set rtp+=~/code/dotfiles/vim/bundle/sleuth

augroup vimrc
   autocmd!
   au VimEnter * set vb t_vb=
   au FileType perl let b:dispatch = 'perl %'
   au FileType perl setlocal formatprg=perltidy
   au FileType help setlocal nolist
   au BufWritePre /tmp/* setlocal noundofile
   au BufWritePre /run/shm/* setlocal noundofile
augroup END

set nocompatible
set conceallevel=2
set undofile
set history=10000
set matchpairs+=<:>
set showcmd
filetype on
filetype plugin on
filetype plugin indent on
syntax enable
set autoindent
```

Note that if, after unrolling your plugins like this, you are suddenly unable to
reproduce your problem, you will need to dive into the source code of your
plugin manager.  When I had to do this recently I found that after all plugins
were loaded `pathogen` does:

``` vim
filetype off
filetype on
```

I have no idea why, but it was critical to reproducing my bug, so I pasted it
into my `.vimrc`.

Now, once you have reproduced the problem you start bisecting away plugins.
Just like before you may discover that you comment out half of your plugins and
the problem goes away entirely, but when you comment out the *other* half, the
problem is also gone.  This is the frustrating situation where there is a plugin
in both halves causing the problem.

Eventually you will be able to minimally reproduce the problem.  When [this
happened to me recently][bug] I decided to report it to the maintainer most
likely to know what to do next.  (Very much a hard call though, since Tim Pope
is likely to be too busy to look at it.)

---

I hope this helps!  This technique can be used for other tasks too, like finding
out where a weird feature comes from, or even digging into a
[`--startuptime`][sup] report.

---

(The following includes affiliate links.)

If you'd like to learn more about vim, I can recommend two excellent books.  I
first learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.

[docs]: https://vimhelp.appspot.com/
[ml]: https://groups.google.com/forum/#!forum/vim_use
[irc]: irc://irc.freenode.net/vim
[bug]: https://github.com/tpope/vim-sleuth/issues/43
[sup]: https://vimhelp.appspot.com/starting.txt.html#--startuptime
