---
title: Vim Session Workflow
date: 2016-06-09T23:58:43
tags: [frew-warez, vim, session]
guid: "https://blog.afoolishmanifesto.com/posts/vim-session-workflow"
---
[Nearly a year ago I started using a new vim workflow leveraging
sessions.](https://github.com/frioux/dotfiles/commit/93d7d433)  I'm very pleased
with it and would love to share it with anyone who is interested.

<!--more-->

# Session Creation

This is what really made sessions work for me.  Normally in vim when you store a
session, which almost the entire state of the editor (all open windows, buffers,
etc) you have to do it by hand, with the `:mksession` command.  While that
works, it means that you are doing that all the time.  Tim Pope released a
plugin called [Obsession](https://github.com/tpope/vim-obsession) which resolves
this issue.

When I use Obsession I simply run this command if I start a new project:
`:Obsess ~/.vvar/sessions/my-cool-thing`.  That will tell Obsession to
automatically keep the session updated.  I can then close vim, and if I need to
pick up where I left off, I just load the session.

Lately, [because I'm dealing with stupid kernel
bugs](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1576764), I have been
using `:mksession` directly as I cannot seem to efficiently make session
updating reliable.

# Session Loading

I store my sessions (and really all files that vim generates to function) in a
known location.  The reasoning here is that I can then enumerate and select a
session with a tool.  I have a script that uses
[dmenu](http://tools.suckless.org/dmenu/) to display a list, but you could use
one of those hip console based selectors too.  Here's my script:

```
#!/bin/zsh

exec gvim -S "$(find ~/.vvar/sessions -maxdepth 1 -type f | dmenu)"
```

That simply starts gvim with the selected session.  If the session was created
with Obsession, it will continue to automatically update.

---

This allows me to easily stop working on a given project and pick up exactly
where I left off.  It would be perfect if my computer would stop crashing;
hopefully it's perfect for you!

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
