---
title: Vim File Lists
date: 2017-05-22T08:04:06
tags: [ vim, toolsmith, blog, meta ]
updated: 2017-05-26T06:55:41
guid: 1284B5BC-3CB3-11E7-8DA0-FFE9DF66A8BE
---
I have recently been working on honing a lot of my tools, and a coworker, Andrew
Ruder, mentioned using Denite.nvim for selecting more than simple directories.
I decided to investigate using it instead of builtin file selection mechanisms.
I was surprised at the result.

**Note:** while this post is still worth looking at for comparing how you can
define various lists for vim, the performance issues turned out to be unrelated.
[See my new post for more details](/posts/vim-slow-buffers/).

<!--more-->

## The Litmus Test

I've [mentioned before](/posts/hugo-unix-vim-integration/) that I have some
integration of vim and my blog.  In this post I am specifically diving into
`:Chrono`, the vim command that gets me a chronological list of posts, to aid in
opening a recent post.  I have about four hundred blog posts, and a
chronological listing of course will be the biggest listing possible, for my
blog.  I have other integrations but this one exercises vim the most.

### QuickFix

This was the original version, mentioned in the post I just linked to.

The script that generates the data is:

```
#!/bin/dash

exec bin/q --sql 'SELECT filename, title, date FROM articles ORDER BY date DESC' \
           --format 'my ($d) = split /T/, $r{date}; "$r{filename}:1:$d $r{title}"' 
```

The vim command is:

```
command QChrono cexpr system('bin/quick-chrono')
```

This works well because there is already lots of built in tooling for working
with the QuickFix.  Problematically, the above is dog slow.  The source script
takes 150ms; vim takes 19s.  That's absurd.

By the way I also tried using the Location List (`lexpr`) in the off chance that
it worked completely differently, despite being the same thing as the QuickFix
really.  It was the same.

### The Argument List

I think I first tried using the argument list, not because I thought it would be
faster, but because using the QuickFix feels a little like overkill because it
includes a line number and I didn't need a line number for this use-case.
Here's how I did it with the argument list:

```
function! AChrono()
  let l:cmd = 'args `bin/q --sql SELECT\ filename\ FROM\ articles\ ORDER\ BY\ date\ desc`'
  exe l:cmd
endfunction
command! AChrono call AChrono()
```

Sadly, this is just as slow as the QuickFix.  As with the QuickFix I tried using
`:argl` (the Local Argument List) and it was just as slow.

### Denite.nvim

So next I tried Denite.  For the unaware, Denite is a second or third generation
fuzzy finder.  I have gone through a few of the fuzzy finder variants and had
even tried Unite, the progenitor of Denite, but I was too bewildered at it to do
more than try the builtin options.

What Denite brings to the table is a very generic framework and an asynchronous
foundation.  That's great for things that might be slow, but it also means you
need either Neovim or Vim 8 with Python 3 support.  Ubuntu 17.04 has Vim 8 with
Python 3, but anything older and you will be out of luck.  If I do start using
Denite for more than the use-case outlined in this post I will likely expend
some effort writing some fallbacks using CtrlP for older vims.

So for Denite I started off by defining a source, called `blog_chrono` and put
it in `rplugin/python3/denite/source/blog_chrono.py`:

``` python3
from .base import Base
import subprocess
from denite.util import abspath


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)

        self.name = 'blog_chrono'
        self.kind = 'file'

    def gather_candidates(self, context):
        out = subprocess.run([
            'bin/q', '--sql',
            'SELECT filename FROM articles ORDER BY date desc'],
            stdout=subprocess.PIPE)

        return [{'word': x, 'abbr': x, 'action__path': abspath(self.vim, x) }
                for x in out.stdout.decode("ascii").split("\n")]
```

And then I define a helper command:

```
command! DChrono Denite blog_chrono
```

It's fast enough that I wasn't able to reasonably be able to time it.  Felt like
about 500ms.

---

So while the built in file listings are easy, concise, and powerful, they are
very slow.  The Denite version is a hassle because, while Python is perfectly
harmless, it's a lot more verbose and has to go in a special weird file, only
works with a brand-new vim, etc etc.  I will definitely use Denite more and
consider this experiment a success.  The main thing I'm worried is about
investing too heavily in it because these fuzzy finder plugins seem to come and
go like JavaScript frameworks.

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
