---
aliases: ["/archives/1430"]
title: "zsh for the win"
date: "2010-10-04T03:56:24-05:00"
tags: ["zsh"]
guid: "http://blog.afoolishmanifesto.com/?p=1430"
---
In the past I've only [touched on](/archives/336) the fact that I am a z shell user. I figured I'd make a post about some of the tweaks I made to my config (mostly my prompt) yesterday, in addition to why I use it at all.

First off, what are some features zsh has that make it work using for me?

Various bundled "modules." For example, the zsh-mime-setup module enables me to "run" files with extensions and have the mime setup use the right program to open them. Great for stuff like pdf's or whatever that.

Ridiculous amount of features and options:

auto\_cd: you can type .. or foo or any other path and leave off the cd. Brilliant. auto\_pushd: cd implies pushd, which maintains a stack of directories. What that means is that popd (which I alias mk to) becomes "back" for navigation. no\_case\_glob: simple as pie to allow case insensitive globbing

Oh and **history** is an amazingly powerful feature as well! First off, I save 10,000 lines in my history. That's about a years worth of commands. Or at least it was in college. I think it's probably less now, but still. It's a lot. My history options allow me to leverage that to an extreme extent:

append\_history: don't overwrite my history at the beginning of a session. Append it. various "dups" options: The main takeaway from this is that my history is a \*stack\*, not a list. I can't stand doing ls, cd, ls and the pressing up twice to get back to ls.

Speaking of history, zsh has it's own super configurable line editor, unsurprisingly called ZLE, which I use to bind / and ? (in cmd mode) to searching forward and backward in my history.

On top of that I have super configurable completion. Bash got this a while back, so it's not as exciting. But one really cool thing you can do is fix up the completion such that kill  lists all of your processes with nice levels and everything. It's awesome. You should see it in action.

Of course, everyone has awesome prompts nowadays, and mine is fairly plain compared to many others, but it \*does\* contain the current branch, mode (merge, rebase, etc), and whether or not there are changes or staged changes. Oh and because it uses a generic module to do all of that it works for git, svn, hg, and lots of others.

Anyway, I actually spent a good part of yesterday reorganizing my configuration and adding in the version control bits to my prompt. I did a lot of research and I think it not only looks good but it works fairly efficiently. [Check out my conf if you are interested.](http://github.com/frioux/dotfiles/tree/884b83ecdd0125dcc9ea6eb6da1a187236db3690/zsh/rc)
