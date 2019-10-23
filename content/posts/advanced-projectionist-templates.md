---
title: Advanced Projectionist Templates
date: 2017-10-16T07:50:15
tags: [ vim, projectionist, blog, meta, frew-warez ]
guid: 55EFD114-B27A-11E7-A12C-5A916688AF9B
---
This week I migrated some of the vim tooling I use for [my blog][blog] from
[UltiSnips][ultisnips] to [projectionist][projectionist].  The result is a
lighter weight and a more user friendly (for me) interface.

<!--more-->

[When I bloged about my vim plugins][plugins] I mentioned that I use `UltiSnips`
solely for writing new blog posts.  It always felt weird to use this incredibly
powerful snippit tool to generate the boilerplate for a single file by typing
`fmatter<tab>` every time.

`Projectionist`, which I also blogged about in my [vim plugins][plugins] post,
is generally useful for me in navigating well known parts of a project.  One
feature of Projectionist that I'd never used before was its templating.
Basically with Projectionist you define a path and you can easily open files
based on it.

For this blog I have a file like this:

``` json
{
   "content/posts/*.md": {
      "type": "post"
   }
}
```

I can run the command `:Epost station` and it will open the file at
`content/posts/station.md`.  It supports tab completion out of the box and other
very handy features that make more sense when programming.

Back to templates; if you run the above command and the file does not exist, a
template can fill in some boilerplate for you.  You define the template in the
JSON as follows:

``` json
{
   "content/posts/*.md": {
      "type": "post",
      "template": [
         "---",
         "title: ",
         "date: ~~CURDATE~~",
         "tags: ",
         "guid: ~~GUID~~",
         "---"
      ]
   }
}
```

It's a little noisy, but the result is that when you first open a fresh post
with `:Epost some-post` it will have the above filled in:

```
---
title: 
date: ~~CURDATE~~
tags: 
guid: ~~GUID~~
---
```

Of course there is one major setback.  With `UltiSnips` you can trivially insert
commands in the template.  Their output is then seamlessly interpolated.

[I proposed as much to Tim Pope][bug] and he didn't seem to like the idea.
After a few months of pondering on it I struck upon the idea of using an
autocommand to postprocess the generated content.  Here was my first version:

``` json
{
   "content/posts/*.md": {
      "type": "post",
      "template": [
         "TPLTPLTPL",
         "---",
         "title: ",
         "date: ~~CURDATE~~",
         "tags: ",
         "guid: ~~GUID~~",
         "---"
      ]
   }
}
```

Note especially the use of `TPLTPLTPL` as a signal that a template is to be
processed.

Then I wrote the following vimscript:

``` vim
function! ExpandTemplate()
   if getline(1) == 'TPLTPLTPL'
      %s/\~\~CURDATE\~\~/\=systemlist("date +%FT%T")[0]/ge
      %s/\~\~GUID\~\~/\=systemlist("uuidgen")[0]/ge
      1g/TPLTPLTPL/d
   endif
endfunction

au BufReadPost * call ExpandTemplate()
```

I figured out the autocommand to hook into by [reading the source][src] of
`Projectionist` and the rest is just regular vimscript.

Finally, I decided I could make it slightly simpler with [a patch to
`Projectionist`][patch].  With the patch in place the code simply becomes:

``` vim
function! ExpandTemplate()
   %s/\~\~CURDATE\~\~/\=systemlist("date +%FT%T")[0]/ge
   %s/\~\~GUID\~\~/\=systemlist("uuidgen")[0]/ge
endfunction

au User ProjectionistApplyTemplate call ExpandTemplate()
```

And the `TPLTPLTPL` line can go away.

---

I felt good to finally be able to scratch this itch.  The user interface is
simpler and the code is lighter and I have one fewer plugin that I rarely use.

---

(The following includes affiliate links.)

If you'd like to learn more about vim, I can recommend a few excellent books.  I
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

Third and finally, if you want to really grok the guts of advanced vim, to write
a plugin for example, you should really check out [Learn Vimscript the Hard Way
by Steve Losh][lvsthw].  I expect to reread it two or three more times.  I got
the PDF version so I could read it while offline.

[plugins]: /posts/my-set-of-vim-plugins/
[bug]: https://github.com/tpope/vim-projectionist/issues/76#issuecomment-312517394
[src]: https://github.com/tpope/vim-projectionist/blob/88e84056e2b3bb74356c13789a935a66b121780e/autoload/projectionist.vim#L668
[patch]: https://github.com/tpope/vim-projectionist/pull/81
[blog]: /posts/hugo-unix-vim-integration/
[ultisnips]: https://github.com/sirver/ultisnips
[projectionist]: https://github.com/tpope/vim-projectionist
[lvsthw]: http://learnvimscriptthehardway.stevelosh.com
