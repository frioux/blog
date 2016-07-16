---
aliases: ["/archives/1349"]
title: "DBIx::Class has migrated to git!"
date: "2010-06-04T00:10:12-05:00"
tags: ["cpan", "dbix-class", "git", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1349"
---
# Woohoo! git!

I am so happy to announce that [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) has migrated to git!

If people latch on well, this should benefit is in a number of ways. The first thing is that most people should appreciate is the ability to check in to source control without needing to commit to the remote repository. Not only does this make things way faster, it also means that you can work sanely offline. A lot of people did this before with SVK, but SVK is slow and a hassle (I think) to install and setup.

Another thing that this should help is our history. I don't mean to point out a specific person, I did this all the time with svn (it's just the nature of the beast,) but [take a look](http://dev.catalystframework.org/svnweb/bast/log/DBIx-Class/0.08/branches/extended_rels) at some of these commit messages. The SVK merge messages are pretty obnoxious, but that's not what I'm referring to. The ones that bother me are the: "Oops," "Typo," "Thinko," etc. With git those can be cleanly squashed into another commit. In fact, I would recommend cleaning up your history before you push every time. This is how I do that:

    git rebase --root --onto master --interactive

That will rebase your current branch (all of it) onto master, and give you an editor that will let you fix commit messages, merge commits, and more. If people do not do this I fully intend to do it myself before I merge a branch in, if I do. And that brings me to the next point which we shall discuss.

# Workflow

We toyed with the idea of setting up git such that everyone would just use github or gitorious or whatever and ribasushi and I would be in charge of merging remote branches into the DBIC master, but mst veto'd the idea in favor of a more communal approach. Basically the workflow we will use looks like the following:

1. Get a commitbit (liberal policy)
2. Clone the repo (dbsrgits@git.shadowcat.co.uk:DBIx-Class.git)
3. Make a topic branch based on what you are doing, do work on it, whatever
4. Push branch to repo
5. Ask a fellow DBIC'er to review the branch, that includes me, ribasushi, Caelum, and really anyone else with a commitbit
6. If the reviewer thinks everything is sane, **the reviewer** will merge the branch in; to be a bit more clear, you should not merge your own branch into master, that is the reviewer's job
7. Delete your branch locally and remotely after everything is merged in, and work on other stuff!

A note about merges, don't merge master into your branch. It makes for yucky history. Instead, rebase your branch onto master. Currently the thought is that **anything** except for master can be rebased. Of course if you and another dev are working in the branch you might want to keep that to a minimum, but at the very least you should be rebasing to squash silly commits before you push, and then when you do the final merge into master you should rebase first, so that history remains sane. Of course, the best time to rebase to fix silly history is before you push, and the best time to rebase to make it so that you are fastforwarding master is right before the final merge, so try to only do that then.

At some point I plan on writing a DBIx::Class::Manual::Contributing in the spirit of [Moose::Manual::Contributing](http://search.cpan.org/perldoc?Moose::Manual::Contributing), but ours will be significantly more lax. In the meantime, just swing by #dbix-class, get your commitbit, and help out!
