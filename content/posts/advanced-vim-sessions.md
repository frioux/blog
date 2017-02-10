---
title: Advanced Vim Sessions
date: 2017-02-10T07:53:31
tags: [ vim, session, toolsmith ]
guid: 7D4A65F2-EF44-11E6-B52A-EB0584F70C31
---
I have blogged before about [vim sessions](/posts/vim-session-workflow/) and how
useful they are.  This post is about a pattern I discovered (though I'm likely
not the first to discover it) at work when frustrated that certain settings were
not stored in the session.

<!--more-->

So here was how my original frustration surfaced; I was using
[Obsession](https://github.com/tpope/vim-obsession), as I've mentioned before,
which automatically updates your session file periodically and saves open files,
window layouts, etc.  One of the things I discovered that it does *not* save is
[the `path`](http://vimdoc.sourceforge.net/htmldoc/options.html#%27path%27).
If you recall, I discussed the incredible value of `path` in [a post about the
`gf` feature](/posts/vim-goto-file/). Because of `gf` I tend to need `path` to
be correctly set all the time.

For a long time I was sure that the `path` was getting correctly saved by
Obsession and that I was just somehow clearing it ([recall that I was having
system stability issues in general](/posts/rage-inducing-bugs/)) but at some
point I was chatting with some coworkers and decided to track it down for sure.
One option is to modify [the `sessionoptions`
setting](http://vimdoc.sourceforge.net/htmldoc/options.html#%27sessionoptions%27).
I think simply doing `set sessionoptions+=options` would work for this case, but
then you may end up persisting a lot more than you want.  I *just* wanted this
one setting.

## Nested Sessions

The idea I came up with was to nest sessions.  I created an outer session, and
it looks like this:

```
set path+=app/lib

source /home/frew/.vvar/sessions/_zr
```

So all it does is set the `path` and then basically loads the inner session,
which enables all of the normal Obsession convenience.

That's super convenient and goes a long way, but yesterday I thought of another
really useful pattern.  You can load plugins or a set of plugins from a session;
so while I almost never need a plugin to syntax highlight
[`jinja`](http://jinja.pocoo.org/), I want one when I am modifying salt
settings.  So here's what I do:

Get some plugins:

```
mkdir ~/code/vim-salt-plugins
cd ~/code/vim-salt-plugins
git clone git://github.com/saltstack/salt-vim
git clone git://github.com/lepture/vim-jinja
```

Load them in the outer session:

```
call pathogen#infect('/home/frew/code/vim-salt-plugins/{}')

source /home/frew/.vvar/sessions/_salt
```

I'm not sure how well the above works with, say, `Vundle`, but I imagine it
could be done.  With this I now have plugins for specific, weird projects that I
don't end up carrying around with my dotfiles all the time.  I love it.

---

I'm really pleased with this pattern.  I expect to use it for more things in the
future.  One idea that springs to mind is plugins that are only appropriate for
one project; just commit the vim script directly and source it from the outer
session.  But for now this is already incredibly convenient for me; I hope it is
for you too!

---

If you'd like to learn more, I can recommend two excellent books.  I first
learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.
