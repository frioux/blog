---
aliases: ["/archives/1538"]
title: "New Stuff in DBIx::Class::DeploymentHandler"
date: "2011-04-13T20:21:49-05:00"
tags: ["cpan", "dbix-class", "dbixclassdeploymenthandler", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1538"
---
I'm just releasing my first new release of [DBIx::Class::DeploymentHandler](http://search.cpan.org/perldoc?DBIx::Class::DeploymentHandler) in six months! For the most part the release is just a few doc tweaks, but it **does** have one important new feature, the "\_any" version.

If you didn't already know, DBICDH has a handy little directory structure for how your deploys work. If you haven't seen it, [take a look](http://search.cpan.org/~frew/DBIx-Class-DeploymentHandler-0.001004/lib/DBIx/Class/DeploymentHandler/DeployMethod/SQL/Translator.pm#DIRECTORY_LAYOUT). This new release allows you to use \_any in place of a version or version set, which will run the given files no matter what version you are deploying to.

Enjoy!
