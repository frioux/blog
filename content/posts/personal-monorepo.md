---
title: Personal Monorepo
date: 2021-01-23T13:00:14
tags: [ "monorepo", "golang", "frew-warez" ]
guid: 4cb45f94-225d-4fcc-952b-649966093439
---
Today I completed my long-standing project to merge all of my open source Go
repositories into a single repo.

<!--more-->

At some point I drank the koolaid that monorepos are better than poly-repos.  I
don't really want to go into all of the various reasons for that, but I will
say there are a couple clear benefits for my own code:

 1. I can easily change code across all callers if everything is in a single repo.
 2. I benefit from whatever automation I set up for all of my projects.

I've written about leatherman here plenty of times before, so I won't go into
too much depth in this post.  In short: I already built github actions based
CICD for my leatherman, have nice little test libraries, etc.  I also tend to
have the leatherman binary handy everywhere (hence the name.)

[In December I
migrated](https://github.com/frioux/leatherman/commit/a5334a27a53da7d2c0a69c27df14b919299be878)
[my notes software
`zine`](https://blog.afoolishmanifesto.com/posts/zine-software-for-managing-notes/)
to leatherman.  That wasn't too hard.  The main difficulty was finding a non-C
implementation of SQLite so I can avoid cgo ([which I found,
absurdly](https://pkg.go.dev/modernc.org/sqlite).)

That was *mostly* pretty easy because it's pretty simple, young software.  The
other major software I wanted to merge in [was
amygdala](https://blog.afoolishmanifesto.com/posts/amygdala/), a notes system
(of course) built around SMS and deployed to Heroku.

To merge it I took the following steps:

 1. Fetched the Amygdala history from a leatherman checkout: `git fetch
    git://github.com/frioux/amygdala`.
 2. Made a branch of that code where I'd re-arrange the code before trying to
    use `git merge`: `git checkout -b pre-merge FETCH_HEAD`
 3. I made a commit where [I moved things around](https://github.com/frioux/leatherman/commit/a4e3c79ef843031e9ae03259d60b60b26dbc0085)
    (like main.go from the root of the repo to where it'd be post proper-merge)
 4. After that [I did a proper git merge](https://github.com/frioux/leatherman/commit/8c7880b68ceecf3ceac7f9644a1407a05c022d9a#diff-09652b9e0e31e7f54204363a9d2a0c8f2c4ed0cf044fb567636781fa054768ce),
    which included *actually* building amygdala into the leatherman binary.

Finally I updated Heroku and Twilio.

---

Now that this is done I expect to make [the `leatherman notes`
tool](https://github.com/frioux/leatherman/tree/5d81f1c1898f6f53966b4b2b05a26882abf12060/internal/tool/notes)
support more, or even all, of the stuff Amygdala can do.  The SMS interface is
useful but obviously very limited.  Having access to a full web interface is
preferable.

Comically I now have three notes related systems in my leatherman:

 * `notes`: a stateless web interface that runs on a rasbperry pi and interacts with files over dropbox
 * `zine`: a rich web interface that runs on a laptop and interacts with local files.
 * `amygdala`: a stateless SMS interface that runs on heroku and interacts with files over dropbox.

I would like to merge notes and zine, such that they are just different modes
of the same thing.  I'd like amgydala to be an SMS oriented subset, rather than
a weird vestigal alternate path.

`zine` rebuilds an SQLite database on demand with basically no persistence.  I
think that's a good default; for `notes` what I want to do is to read all of
the files from dropbox at startup and build an in memory SQLite database and
update the database when files change.  I already have a pretty good file-watch
interface for dropbox.  The risk though is that somehow I miss changes and get
out of sync, so maybe daily or hourly I reload everything and track unexpected
changes.

---

(Affiliate links below.)

Recently <a target="_blank"
href="https://www.amazon.com/gp/product/0136820158/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136820158&linkCode=as2&tag=afoolishmanif-20&linkId=6a3d6adabe2966efd8a3b13205d9e0c9">Brendan
Gregg's Systems Performance</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136820158"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" /> got its second edition released.  [He wrote about it
here](http://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html).
I am hoping to get a copy myself soon.  I loved the first edition and think the
second will be even more useful.

At the end of 2019 I read
<a target="_blank"
href="https://www.amazon.com/gp/product/0136554822/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136554822&linkCode=as2&tag=afoolishmanif-20&linkId=9b27a122197fb141065f7276321e4c43">BPF
Performance Tools</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136554822"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.
It was one of my favorite tech books I read in the past five years.  Not only
did I learn how to (almost) trivially see deeply inside of how my computer is
working, but I learned how *that* works via the excellent detail Gregg added in
each chapter.  Amazing stuff.
