---
aliases: ["/archives/1574"]
title: "Getting More Done"
date: "2011-08-02T02:01:51-05:00"
tags: [frew-warez, cpan, perl, planning]
guid: "http://blog.afoolishmanifesto.com/?p=1574"
---
Today I purchased [59 Seconds](http://www.amazon.com/59-Seconds-Change-Minute-Vintage/dp/0307474860), recommended by Jeff Atwood. I struggle with procrastination as much as anyone else so I'm willing to spend 10 bucks to try to get more done. The author recommends four things to attain a given goal:

- plan well
- reward yourself
- focus on benefits
- tell people

I've kinda slacked off with Open Source stuff the past year (see the graph at [metacpan](https://metacpan.org/author/FREW)) and I'd like to remedy that.

# Goal: Participate more

My overall goal is to participate more (more blogging, more patches/pull requests, more releases and bug fixes for my own modules, etc.)

The book recommends breaking the overall goal into five for fewer distinct subgoals that are measurable and whatnot, so here are my subgoals:

## Subgoal 1: Do two, public, permanent code related things a week

For example submit a patch or release a distribution. Pushing to github isn't permanent :-)

I think this is pretty feasible. I have a huge backlog of things to do (which I'll post, semi-prioritised at the end of this post) and I already set aside time on Mondays and Fridays to get stuff done.

To get this done I'll work on stuff 2-3 hours on Monday night and 2-3 hours Friday night (assuming nothing is going on.) I also might do stuff Tuesday or Wednesday, but time is scarce with wedding planning. I'll work on the most important things first, and after that's done I'll work on the most fun stuff; the idea being that I can get two things done in a week that way.

I'll count this as achieved (though I don't want to stop) after I've done two public things a week for two months straight. I'll post weekly progress reports every Monday when I start hacking about the previous week.

My reward for finishing this is to buy myself a new car stereo.

## Subgoal 2: Post two tech related posts to my blog twice a week

Again, this sounds reasonable. I have a long list of half finished posts that I should just clean up and post. These should keep me busy for a while.

I'll have a similar plan for this as I do for Subgoal 1; instead of Monday and Friday I'll do Tuesday and Sunday. I'm a little nervous about those days as the are mostly booked for the foreseeable future, but what I hope to do is use remaining time on Mondays and Fridays to work on blogging.

I'll count this as achieved after I've done two tech blog posts a week for eight weeks straight. Weekly progress shouldn't be necesary :-)

My reward for finishing this is to buy myself new car speakers.

## Subgoal 3: Get used to using some bug tracker for Open Source work

Currently I am not very good about using a bug tracker for anything other than work. I've used Google's bug tracker, github's issue tracker, RT, and am currently toying with ticgit. I need to pick something, get good at it, and stick with it.

I think I can do this. It mostly takes discipline to pull this off. I need to just add stuff to whatever bug tracker **every** time I am going to add a new feature, fix a bug, clean stuff up, whatever. I think I'm gonna use ticgit for now since I don't want to write my own bug tracker yet.

I'll count this achieved after every single one of the things from Subgoal 1 that are my own modules use the bugtracker I've chosen.

My reward for finishing this is to buy myself an amp for my car stereo.

## Benefits

In the book he says you should state three benefits that you would get from finishing your goal. My three benefits are: I would be more respected in the community; my life would be easier as I'd have the things that I've been wanting for a while; and lastly, I could get more organized and more quickly ramp up on doing things.

# TODO list

- DBIx-Class-Helpers - Jnap's stuff
- DBIx-Class - Date Math stuff
- <strike>Log-Contextual - subclassable importer</strike>
- DBIx-Class-Helpers - StateHook
- DBIx-Exceptions - Plan out remaining bits to get done
- DBIx-Class-Shadow - Plan out remaining bits to get done
- Git-Conversion-Book - Table of Contents
- Git-Conversion-Book - Each Chapter (x10?)
- Object-Exporter - Plan out remaining bits to get done
- Log-Location - Plan out remaining bits to get done
- HTML-Zoom-Widgets - Plan out remaining bits to get done
- Catalyst-ActionRole-PseudoCache - Optionally use a real cache
- DBIx-Class-Schema-Auth - Plan out remaining bits to get done
- Net-Goodreads - Plan out remaining bits to get done
- Data-Dumper-Concise - DwarnOnly
- DBIx-Class - Logger Configuration
- DBIx-Class - Logger Console Width
- DBIx-Class - Non-Result based FilterColumn
- DBIx-Class - Instance Based Relationship Helpers
- DBIx-Class - Join Args
- DBIx-Class - ResultSet Components
- DBIx-Class-DeploymentHander - code cleanup
- DBIx-Class-DeploymentHander - various doc patches
- DBIx-Class-Helpers - Fix remove columns
- DBIx-Class-Helpers - Work way to make SQLMaker helper
- DBIx-Class-Helpers - ReadOnly
- Log-Contextual - NullLogger ?
- git-super-status - More Filters
- git-super-status - More Sorts
- git-super-status - Configurable Columns
- git-super-status - Configurable Colors
- git-super-fetch - get it started?
- SQL-Translator - Finish SQL-Server cleanup
- teatime - Convert 100% to REST
- try-awesome - We have plenty exception generating frameworks, now we need a catching one
- Log-Contextual-P6 - Port LC to P6
- Log-Contextual-JS - Port LC to JS

# Pending Blog Posts

- <strike>Event Loops are better than while(1)</strike>
- <strike>Powerful benchmarking with Perl and ab</strike>
- Commercial Cross Platform Git
- Alternatives to Sub::Exporter
- Cool things you can do with Sub::Exporter
- Why Exceptions are here to Stay
- The Problem with Exceptions
- Refactoring dispatch tables into objects
- Emacs vs Vim
- Simple Perl Proxy for Productivity
- Sweet Code, thanks to Moose and Catalyst
- Keep track of failing tests
- Revised OpenID post (or not)
- Write Code to be Cargo Culted
- The Toolsmith: Vim, zsh, IRSSI, XMonad, etc etc
- Filtering out things
- On Syntactic Arcana
