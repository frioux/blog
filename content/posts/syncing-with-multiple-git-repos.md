---
aliases: ["/archives/1344"]
title: "Syncing with Multiple Git Repos"
date: "2010-05-23T06:55:36-05:00"
tags: ["community", "git", "github", "perl"]
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
