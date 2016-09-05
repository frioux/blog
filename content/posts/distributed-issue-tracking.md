---
aliases: ["/archives/1557"]
title: "Distributed Issue Tracking"
date: "2011-07-07T04:00:38-05:00"
tags: [frew-warez, bugs, bugs-everywhere, git, git-case, git-issues, issues, ticgit]
guid: "http://blog.afoolishmanifesto.com/?p=1557"
---
Ever since I heard about [SD (Simple Defects)](http://syncwith.us/sd/) I've been enamored with the idea of distributed issue tracking. Unfortunately SD is mostly unmaintained, undocumented, slow, and has lots of deps. I could probably get over the latter two, but the first two are deal breakers.

Fast forward eighteen months and I saw [genehack's](http://www.genehack.org/)
[App::GitGot](https://metacpan.org/module/App::GitGot). It's a little sluggish
(1.35s to merely list repos on my SSD) but it's exciting because it can easily
list my repos that are dirty or ahead by X commits. genehack is very receptive
to changes, so this gave me an idea. First, what if we also listed how many
unmerged brances there were? Next, what about unclosed issues? Obviously both of
these ideas require some basic configuration, but it's totally worth it.

I figured that step one would be to make a minimalist bug tracker, storing the information in the current git repo. The idea being that if I have a git tracker I can easily keep track of what I have to do next, so I won't forget what else to do. I've been working on it every day a little bit since YAPC and it's been pretty fun! The only thing is that there are already a few other implementations of what I am doing. I might as well list and evaluate them now.

## [git-issues](https://github.com/jwiegley/git-issues)

First off, it's implemented in Python, which is an immediate deal breaker, as I don't have python installed everywhere I have git installed. On top of that it uses XML, which is not exactly easy to parse and modify. Finally it is basically dead, so it's unlikely to get more features added in the future.

## [ticgit](https://github.com/jeffWelling/ticgit)

Implemented in Ruby, which is a problem, just like with git-issues. It is extremely full featured, so if you are working on a Linux system all the time I'd say this is the route to go. Unfortunately it uses rubygems; unless something has significantly changed in the past couple years that means it's gonna be a little sluggish for a CLI app.

## [bugs everywhere](http://docs.bugseverywhere.org/)

Again this is a Python app. It seems very full featured like ticgit, so maybe it has the same benefits as ticgit. It seems like it has some really neat features, but I just don't like the python dep.

## [git-case](https://github.com/bartman/git-case)

This is implemented in bash, so it immediately jumped out at me as something that is going to work anywhere that I have git installed. Unfortunately it is unmaintained for about three years now. I emailed the author to see what's up, so we'll have to see what happens there.

# The Dilemma

So my current dilemma is this: should I start afresh with a Perl app, possibly modelling after or even making it compatible with some of these other apps (be or ticgit) or should I pick up where bart left off with git-case? Before you jump to the former, realize that I don't want to use any CPAN modules because I want this to be super simple to use anywhere one uses git; that is, all I should dep on is 5.8 and Git.pm (which is mostly useless.)

Currently I'm leaning towards git-case, maybe with a name change as I probably want to make some backwards incompatible changes. Any ideas? Hopes? Dreams?

---

If you're interested in learning more about Git, I cannot recommend
<a  href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=73f85964b6ab98ea870583701b7e77aa">Pro Git</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
enough.  It's an excellent book that will explain how to use Git day-to-day, how
to do more unusual things like set up Git hosting, and underlying data
structures that will make the model that is Git make more sense.
