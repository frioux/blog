---
aliases: ["/archives/1643"]
title: "New Stuff in Catalyst::ActionRole::PseudoCache 1.000001"
date: "2011-08-23T02:32:17-05:00"
tags: [mitsi, annoucenemnt, catalyst, cpan, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1643"
---
I'm excited to announce a new version of [Catalyst::ActionRole::PseudoCache](https://metacpan.org/module/Catalyst::ActionRole::PseudoCache).

New in the [current release](https://metacpan.org/module/FREW/Catalyst-ActionRole-PseudoCache-1.000001/lib/Catalyst/ActionRole/PseudoCache.pm) of Catalyst::ActionRole::PseudoCache is that it can now use [Catalyst::Plugin::Cache](https://metacpan.org/module/Catalyst::Plugin::Cache) as the underlying cache mechanism. The main reason was that the existing architecture didn't work for multiple servers, which is how our system works. Plus this is just better overall.

In the long term I will be removing the old "Pseudo" cache. It might be a good idea to make a separate package with a better name at some point, but that will be for the next release. Enjoy!
