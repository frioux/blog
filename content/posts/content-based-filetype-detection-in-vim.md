---
title: Content Based Filetype Detection in Vim
date: 2017-09-20T08:35:35
tags: [ vim, shell, upstart ]
guid: 735AE5F2-9E0E-11E7-AB05-AC7DC7B86AB0
---
Yesterday I spent a little over an hour finally figuring out how to detect a
file based on its contents in vim.  It's pretty easy!

<!--more-->

I have become convinced that, for programs that you run, extensions declaring a
filetype are wrong.  If you were to think of a program as a black box, including
`.pl`, `.py`, or `.sh` at the end to say what language they are is pointless
extra information.

Vim almost always can detect a file automatically based on the contents of the
file, but sometimes there are rarely used files that need the detection added.

## [`dash`][dash]

I have been using [`dash`][dash], the Debian Almquist Shell, [since about a week
after][1st] [Shellshock][shock] was announced.  I like `dash`; part of the
reason is because it's simpler than `bash` (or `zsh`) and thus has a simpler
surface attack area.  More though, is because it is very fast to start up, and
forces me to write almost strictly `POSIX` shell.  [The manpage is concise and
readable, too.][mandash]

Unfortunately, vim tends to think that `dash` scripts are `conf` files.  Here's
how I fixed it:

 * In `~/.vim/ftdetect/dash.vim`:

``` vim
function! DetectDash()
   if getline(1) =~ '#!\/bin\/dash'
     setfiletype sh
   endif
endfunction

augroup filetypedetect
  au BufRead,BufNewFile * call DetectDash()
augroup END
```

And that's all you have to do, if it's as simple as looking at the shebang.  I
suspect I'll end up making this fancier by improving the regex, but this works
for everything I write.  It is so refreshing to leave off the `# vim: ft=sh`!

## Upstart

[I've posted about upstart][1] [twice before this][2], and despite the fact that
it is a sinking ship, it continues to do the heavy init lifting at work and
likely will for at least another year.  Frustratingly, Upstart detection in vim
is pretty bad.  As far as I can tell it only works if the file is in the
`/etc/init` directory.

I did a lot of Upstart work yesterday (which I'll hopefully post
about soon) and was annoyed that syntax highlighting was broken most of the
time.  I then came up with the following, in the obviously named
`~/.vim/ftdetect/upstart.vim`:

``` vim
function! DetectUpstart()
   let likely=0
   for i in getline(1, 1000)
      if i =~ '\v^(start|stop) on'
         setfiletype upstart
         break
      elseif i =~ '\v^(respawn limit|(end|(pre|post)-start) script)'
         let likely += 2
      elseif i =~ '\v^(set(uid|gid)|env|description|author|respawn)'
         let likely += 1
      endif

      if likely > 4
         setfiletype upstart
         break
      endif

   endfor
endfunction

augroup filetypedetect
  au BufRead,BufNewFile * call DetectUpstart()
augroup END
```

It's weird and heuristic based, but it seems to work pretty well.  Also shows
some vimscript that is not actually that hard to read.

---

I am glad to have finally dug into this.  [The official docs][docs] are somewhat
hard to follow, so I hope the above example can lead people in the right
direction.

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


[dash]: http://gondor.apana.org.au/~herbert/dash/
[1]: /posts/supervisors-and-init-systems-4/
[2]: /posts/supervisors-and-init-systems-6/
[docs]: http://vimdoc.sourceforge.net/htmldoc/filetype.html#new-filetype-scripts
[1st]: https://github.com/frioux/dotfiles/commit/aea7773158f9b05a3b86f652862e9f6ddd40a841
[shock]: https://en.wikipedia.org/wiki/Shellshock_(software_bug)
[mandash]: https://linux.die.net/man/1/dash
