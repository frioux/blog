---
aliases: ["/archives/1386"]
title: "git-svn for the win"
date: "2010-07-27T02:39:21-05:00"
tags: [mitsi, git, power-tools]
guid: "http://blog.afoolishmanifesto.com/?p=1386"
---
I have been using git more and more. I use it in all of my CPAN modules. I'm using git to the point where I expect everything else (that is, svn) to be just as powerful and fast. Unfortunately that just is not the case, and I'm still stuck with it for all but one project at work.. For example, the other day I wanted to find the last commit that my coworker made. With git it would just be git log --author wes -1. I couldn't seem to figure out a way to do it with svn. Maybe I'm just dumb? Add on to that the fact that git log is mega fast but if you do svn log You Have Made a Mistake. Also the colors! Who doesn't like the fact that git has colors out of the box?

To sum up the previous paragraph: [I need to learn to use git-svn](http://www.kernel.org/pub/software/scm/git/docs/git-svn.html). Lets get started:

First off, you need to make a users file. At my company that's pretty easy since there are like, 12 people who have commit access to svn. This is what it looks like:

    david = David B.
    fred = Fred K Beckhusin
    frew = Arthur Axel "fREW" Schmidt

Put it in a file named "users" in the current directory. All this does is substitute the svn names (on the left) for the git names (on the right.) Next up, check out your repository:

    git svn clone --stdlayout --authors-file=users svn://reposerver/foo/bar

This assumes that /foo/bar has subdirs /trunk, /branches, and /tags. If yours is different you'll want to do something like the following:

    git svn clone --trunk='/Developer' --tags='/Releases' --authors-file=users svn://reposerver/foo/bar

Of course you might need to do some tweaking there.

Now, we have three other svn:externals repositories in our repo. This is the most ghetto part of all of this, and it's probably just because I haven't done the appropriate research. Again, if you know better, just tell me. (Normally with git you'd do this with a submodule, but we aren't going to do that because we want to directly check the "submodule" out from svn so we can commit back easily. If you don't know what a submodule is, ignore this :-) )

    git svn clone --stdlayout --authors-file=users svn://reposerver/svnexternal1 $to_name

This will check out the svnexternal1 repo to a folder called $to\_name. If you need to check it out to a separate subdir either cd into that dir or change $to\_name.

You don't want to check that into svn because your coworkers already have an svn:externals for that. Normally this would be done with .gitignore, but we won't use that because your coworkers don't want a .gitignore file in their repository. Instead you'll use .git/info/exclude, which is the same thing but not inside of the repo. Just put $to\_name on a single line in that file and it won't show up in your available changes when you need to commit.

Speaking of commiting, how do you commit? Normally your workflow should be the way it is with git. You commit often and when you are ready for a feature to go to the team you push it out. I usually rebase and clean up commits before I push, but that's up to you. The main difference is that you don't do git push ... Instead you'll do

    git svn rebase && git svn dcommit

git svn rebase actually checks out the new changes from svn and puts them in your repository before the changes you've already committed. If there are conflicts you'll have to deal with those of course, but otherwise it will just pull in the changes and then use dcommit to submit new changes. You should not have any uncheckedin changes when you do this (it will complain if you do) because dcommit actually does a different kind of rebase after checking in changes. It changes your commits to include the svn id so that the git commits match up with the svn commits.

In general that's all there is to it. At some point I'd like to do a post about how I use git rebase fairly often in my workflow, but this I think is a lot more important. Oh and [here](http://mislav.uniqpath.com/2010/07/git-tips/) are some cool new git features I learned today. Enjoy :-)
