---
aliases: ["/archives/1620"]
title: "Git aliases for your life"
date: "2011-08-17T06:59:18-05:00"
tags: ["aliases", "git"]
guid: "http://blog.afoolishmanifesto.com/?p=1620"
---
I only use a handful of git aliases, but the ones I do I really like. First off, the basic ones:

    [alias]
       ci = commit
       co = checkout
       st = status
       br = branch

Also, another handy tip, as pointed out by [a commenter](/archives/1616#comment-2597) is aliasing g to git (alias g=git) so that after you do the above instead of git ci you can merely do g ci. Neat.

Those are all very obvious and I'd bet nearly everyone has the first couple. The next ones are more in depth but I totally dig them.

I use [zsh](http://www.zsh.org/) which has a huge number of glob expansions; what that means for me is that often when I try to run a git command it conflicts with the zsh globbing and I end up getting "zsh: no matches for ^foo". So that's what my first alias solves:

    alias git='noglob git'

Once I put that in my [.zshrc](https://github.com/frioux/dotfiles/blob/2b44e672f0302bb9a80d5bd890c9af7ca9d9202c/zsh/rc/S50_aliases#L149) that problem went away entirely, which is nice.

I have the same problem with gitk, but also I always want gitk to be backgrounded, since it's a gui tool. I wrote a tiny wrapper function and an alias to handle that:

    function g_tk() { /usr/bin/env 'gitk' "$@" & }
    alias gitk='noglob g_tk'

That's excellent. Now instead of 'gitk ...' or 'gitk ... &' just 'gitk ...' works.

Often when running gitk I don't really want to see the entire history of the project. What I typically want is just what's in the current branch, but not master. I made the following alias for that:

    alias grr='noglob g_tk ^origin/master HEAD'

My main repo at work has eight submodules, and updating submodules is really an obnoxiously long command, so I aliased it too:

    alias gosu='git submodule update --init'

Lastly, I rebase my code regularly onto the latest master, so I made the following alias:

    alias gre='git rebase --root --onto origin/master -i --autosquash'

Another tiny tool I've made for less painful merges is what I call "handymerge" or hm.

    #!/bin/bash

    gitk $(cat .git/MERGE_HEAD) $(cat .git/ORIG_HEAD) "$@" &

I put that in ~/bin and named it git-hm, so now when I'm merging if I want to look at the commits from both side I just run 'git hm'. If I just want to see commits to file A I run 'git hm A'. Pretty cool huh?
