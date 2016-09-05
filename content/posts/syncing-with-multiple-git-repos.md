---
aliases: ["/archives/1344"]
title: "Syncing with Multiple Git Repos"
date: "2010-05-23T06:55:36-05:00"
tags: [frew-warez, community, git, github, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1344"
---
This is almost entirely so that I remember how to do this. A big thanks for
[arcanez](http://warpedreality.org/) for showing me this in the first place.

# The Problem

In the Perl community,
[numerous](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=gitmo/Class-C3.git)
[important](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=gitmo/Class-MOP.git)
[git](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/Devel-Declare.git)
[repositories](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/local-lib.git)
are hosted at [shadowcat](http://git.shadowcat.co.uk/gitweb/gitweb.cgi), but of
course if you went to that url you would not be able to see all the work that I
have spent on each of those projects. I like the fact that github has a nice
concise view of my work.

# The Solution

The following is an example of a section from my .git/config in my
DBIx-Class-DeploymentHandler:

    [remote "all"]
       url = dbsrgits@git.shadowcat.co.uk:DBIx-Class-DeploymentHandler.git
       url = git@github.com:frioux/DBIx-Class-DeploymentHandler.git
    [remote "origin"]
       fetch = +refs/heads/*:refs/remotes/origin/*
       url = dbsrgits@git.shadowcat.co.uk:DBIx-Class-DeploymentHandler.git
    [remote "github"]
       fetch = +refs/heads/*:refs/remotes/github/*
       url = git@github.com:frioux/DBIx-Class-DeploymentHandler.git

This lets you push to origin, github, or all. I tend to only pull from origin
and push to all. Hopefully this can at least be a reference for people :-)

---

If you're interested in learning more about Git, I cannot recommend
<a  href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=73f85964b6ab98ea870583701b7e77aa">Pro Git</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
enough.  It's an excellent book that will explain how to use Git day-to-day, how
to do more unusual things like set up Git hosting, and underlying data
structures that will make the model that is Git make more sense.
