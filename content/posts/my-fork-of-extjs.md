---
aliases: ["/archives/1505"]
title: "My Fork of ExtJS"
date: "2011-02-09T00:25:37-06:00"
tags: ["extjs", "fork", "gpl", "open-source", "sencha"]
guid: "http://blog.afoolishmanifesto.com/?p=1505"
---
[Sencha](http://www.sencha.com/) has been pretty slow at [fixing](http://www.sencha.com/forum/showthread.php?122175-Record-acts-destructively-on-its-default-data) [bugs](http://www.sencha.com/forum/showthread.php?89462-DISCUSS-Don-t-require-boolean-for-RESTful-store-stuff-%28or-maybe-other-places%29) for [the company where I work](http://mitsi.com/). We not only pay for usage but also for forum support. I've decided to personally (that is, me, not my company) fork ExtJS and maintain a set of patches on top of it. Those patches will be licensed as GPLv3 (because they must, because ExtJS is licensed as GPLv3) and Sencha can take them and merge them into core whenever they want.

I've tried to deal with this with overrides, but that is a hassle as you must manually check to see if you missed something, where this is much more of a natural process, since I'll just rebase my changes regularly. Also, some things are **impossible** to override. For example, see the first link above; without completely duplicating the definition, we can't easily fix that issue.

Please [fork it](https://github.com/frioux/ExtJS-frew) and help out!
