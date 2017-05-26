---
title: Vim Slow Buffers
date: 2017-05-26T06:55:41
tags: [ vim, axel, ziprecruiter, debugging ]
guid: 02469472-4041-11E7-ADF6-A36DA63EEB95
---
[On Monday I wrote about how QuickFix and friends are
slow](/posts/vim-file-lists/).  I was legitimately chasitized [on
reddit](https://www.reddit.com/r/vim/comments/6cnsvh/vim_file_lists_comparing_the_quickfix_argument/dhw3gkb/)
for giving up too soon in trying to find a solution, so I did some more digging.

<!--more-->

This was not the first time in recent memory that I have been told that I did
not properly find the root cause of a problem, so I decided to treat this like
an exercize and actually find the cause.  The first thing I did was to create a
way to reproduce the issue and send an email to the Vim mailing list.  You might
want to finish this post before [reading
it](https://groups.google.com/forum/#!topic/vim_use/m7t32w_n6wc), as it includes
(some) resolutions.

## Rocky Start

Here is where I made my first, critical mistake.  This is how I reproduced the
issue:

``` sh
mkdir -p ~/.vim/ftdetect
echo 'autocmd BufNew,BufNewFile,BufRead *.md :set filetype=markdown' >  ~/.vim/ftdetect/markdown.vim
mkdir testing
cd testing
touch {1..500}.md
vim
```

And then in vim:

```
:args *
```

I was unclear in my email and expected the Vim maintainers to read my mind; the
fast version that I did not share was to use `~/.vim/filetype.vim` and put
something like this in the file, which came straight from [the vim
documentation](https://vimhelp.appspot.com/filetype.txt.html#new-filetype):

``` vim
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile *.md set filetype=markdown
augroup END
```

The documentation is a mess, in my opinion.  It first shows ftdetect files, but
then later in the paragraphs marked with a `C` says that if your file type can
be detected by name you should use a `filetype.vim` script.  I still haven't
gotten a straight answer on this one and what the right thing to do is.

## Digging

First I attempted to bisect the issue by building older versions of Vim.  I
couldn't bisect it because I never found a version that didn't have the problem.

Next I profiled the actual problem.  Vim has some rudimentary profiling built in
and I copied [some
mappings](https://github.com/bling/minivimrc/blob/30810cb1705d36828fb0ba815bf9d6994e48a874/vimrc#L28-L31)
to assist in such endeavours.  So I profiled both versions of my code by doing
the following in Vim:

```
\DD
:args *
\DQ
```

If you are interested in the profiles [you can inspect them
here](https://groups.google.com/d/msg/vim_use/m7t32w_n6wc/wQ6gt7q5BwAJ).  The
problem is pretty clear though; the markdown support files are getting sourced
for each buffer, instead of just once.

Bram Moolenar, the author and maintainer of Vim, suggested that I crank of the
verbosity of vim (by starting it with `vim -V10`) and see if that helps.  That
might have helped except I could not figure out how to extract the information
from `:messages`.

Next I tried to see if this was limited to markdown or if all filetypes have
this problem.  I tried having `*.md` map to both `perl` (an existing filetype)
and `sillybonk` (a non existant filetype.) **Neither exhibited the problem.**

With this information in hand I decided I'd bisect the files that were sourced
O(n) times.  Because I couldn't extract the information from `:messages` I just
used `strace` to see what all files vim read.  Here's how I did that:

`strace` to a file, only logging `open` system calls, to the `strace.log` file:

``` sh
strace -etrace=open -ostrace.log vi
```

Then, after reproducing the problem, I would extract the file list with counts:

``` sh
$ cat strace3.log | grep -v ENOENT | grep -vF 'open("."' |
      grep -v O_DIRECTORY | cut -d'"' -f2 |
      sort | uniq -c | sort -n

    502 /usr/share/vim/vim80/syntax/vb.vim
    502 /usr/share/vim/vim80/syntax/markdown.vim
    502 /usr/share/vim/vim80/syntax/javascript.vim
    502 /usr/share/vim/vim80/syntax/html.vim
    502 /usr/share/vim/vim80/syntax/css.vim
    502 /usr/share/vim/vim80/ftplugin/markdown.vim
    502 /usr/share/vim/vim80/ftplugin/html.vim
    502 /home/frew/code/dotfiles/vim/bundle/splitjoin/ftplugin/html/splitjoin.vim
      7 /usr/share/vim/vim80/filetype.vim
      6 /home/frew/.cache/ctrlp/mru/cache.txt
      5 /usr/share/vim/vim80/syntax/syncolor.vim
      4 /home/frew/code/dotfiles/vim/ftdetect/tt.vim
    ...
```

A coworker thought it was weird that html, css, javascript, and vb were being
loaded, but I assumed it was because markdown is typically implemented as an
overlay on `html`.  I checked [and I was
correct.](https://github.com/tpope/vim-markdown/blob/a7dbc314569aa85db80c106d73b1664e385b6ae7/syntax/markdown.vim#L15).

So with this information in hand I decided I'd try to figure out which of the
eight files above was causing issues.  My first step was `vb`, which is loaded
from `html`, I think because IE supports (supported?) a weird thing called
`VBScript` when they wanted their own variant of JavaScript.

I tried deleting and emptying the `syntax/vb.vim` file but got errors, so after
some dinking around with it I replaced the contents with

``` vim
let b:current_syntax = "vb"
```

**And the problem went away.**

## Wasting Time

I sent an update to the Vim Mailing List about this and I was mostly brushed
aside as not knowing what I was talking about.  I reproduced the problem in a
fresh environment, and decided to let it be at that point because I had a
solution and I could live with it.

Shortly after I sent my update Antony Scriven replied to my email pointing out
that my `ftdetect` hook was using `BufNew` and probably shouldn't be.
Frustratingly, when I'd made my `filetype.vim` I'd left that out.  So that
explained my first mystery, why `ftdetect` and `filetype.vim` acted differently:
because I put different stuff in them.

I never should have had `BufNew` in the `autocmd`.

The problem, Antony explained, is that when you load, for example, 500 files,
using `:args *` (or many other similar commands) is that you allocate 500
buffers, and each of those allocations triggers all of the `BufNew` autocommands
immediately, where `BufRead` won't happen to you actually load that buffer.  To
see it for yourself, set up a test like I did in my [rocky start](#rocky-start)
but before you do `:args *` run

``` vim
:autocmd BufNew  *.md echo 'markdown  new'
:autocmd BufRead *.md echo 'markdown read'
```

---

Overall this was frustrating to me.  I have no idea where the `BufNew` came from
in my command ([though it looks like I am not
alone](https://github.com/search?p=1&q=language%3Avim+BufNew&type=Code&utf8=%E2%9C%93),)
but at least removing `BufNew` speeds up things that should not be slow.
Interestingly, I tried this with [NeoVim](https://neovim.io/), and while it
still had the speed issue, it was **significantly** reduced.  From 19s to 5s, to
be precise.  That kind of improvement alone might make me consider using it for
terminal editing.

I hope at the very least some of the debugging examples above are helpful.
Clearly they did not help me, but they may have sped up the process some.

---

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
