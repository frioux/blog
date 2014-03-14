---
aliases: ["/archives/1509"]
title: "Catalyst Git Conversion"
date: "2011-02-12T08:53:03-06:00"
tags: ["catalyst", "cpan", "git"]
guid: "http://blog.afoolishmanifesto.com/?p=1509"
---
Hello All!

Some of you already know that I am working on converting the Catalyst repository to git. I am happy to announce that I am closing in on completion!

The current state of the git repo: <https://github.com/frioux/Catalyst> The script to convert it: <https://github.com/frioux/Git-Conversions/blob/master/cat-convert>

The only things I know of that we must have before we finalize this conversion is:

- Is it correct that the svn user rjk is Ronald J Kimball: rjk AT linguist DOT dartmouth DAWT edu ?
- who is svn user didls?

Also, if you'd like to help ensure the sanity of the repo it would be great if you looked at it! Here are a few tools I use to try to get a feel for the quality of the final export:

    gitk --all

Perusing the repo with gitk is good; another great thing to do is to View -> Edit View and click "Strictly sort by date". This is helpful for finding duplicate commits. Note that there are some commits that look duplicate in this repo but actually aren't; people decided it would be best to edit multiple branches in a single commit instead of just dealing with that at merge time.

    git shortlog -s

This will make it clear if I misspelled your name.

Also looking at blames of files can be handy.

Hopefully this helps!

**Update:** hobbs found confirmation for rjk and identity for didls, so we are good to go assuming no one finds any issues.

(I hope to have a long blog post soon explaining some of the techniques I used to get this all working. Be prepared though, I'm not as smart as [Haarg](http://blogs.perl.org/users/graham_knop/), so mostly it's a manual process :-) )
