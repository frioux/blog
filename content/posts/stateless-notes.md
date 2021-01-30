---
title: Stateless Notes
date: 2021-01-30T15:22:50
tags: [ "frew-warez", "notes" ]
guid: 00c7b0e4-5a5e-4a60-bdd0-7b348a93201b
---
I made my stateless, Raspberry Pi hosted notes service have an in-memory SQLite
for more features and better performance.

<!--more-->

[As I alluded to last week](/posts/personal-monorepo/) I was able to
effectively merge `notes` and `zine` over the past few days.  Here's a quick
rundown of how they differed before:

 * `notes`: runs on a Raspberry Pi and renders markdown, synchronously loading
   files from Dropbox as part of rendering the page.  Thanks to [tailscale](https://tailscale.com/)
   it's basically always available to me.

 * `zine`: [I've blogged about this
   before.](/posts/zine-software-for-managing-notes/) Runs on my laptop and
   renders markdown to static files.  Builds up an in-memory SQLite database
   both to allow slicing and dicing the notes but also to allow notes to use
   SQL to refer to other notes.

`zine` is great but since I don't have it on a server it tends to only be
accessible from my laptop.  That's a hassle.

Now I've fixed that.  Here's an overview of how the system works now:

 1. [At startup the `notes` tool loads all (~250) of the notes from dropbox in
    parallel.](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/db.go#L88)
    This takes about 6 seconds on my Raspberry Pi.

 2. [After that's done it inserts the notes into an in-memory SQLite
    database.](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/db.go#L142)
    This takes less than 100 milliseconds.

 3. [(Nearly)
    all](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/notes.go#L99)
    [interactions with the
    tool](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/notes.go#L117)
    use the database, not dropbox.  This means the latency is hidden and pages
    can be much richer, using the database to render extra information.

 4. [To keep the database up to date, I have a longpoll against the Dropbox
    API.](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/db.go#L76)
    [When files change I reload them from dropbox and modify the database
    appropriately.](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/db.go#L15)

 5. [After the database changes are committed, I close a channel](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/db.go#L82),
    [which triggers a message to be sent to all open pages,](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/autoreload.go#L49)
    [which causes all open pages to be refreshed](https://github.com/frioux/leatherman/blob/39948119bd647547dbf9ec179038fa267c29761d/internal/tool/now/autoreload.go#L130),
    so no browsers should show the old data.

I feel pretty good about it!  It's one or two orders of magnitude more responsive and
I enjoy the richer pages.

I am *a little* nervous that this system is inherently brittle because it will
hide errors behind a background task.  I have a couple of ideas to make that
less risky:

 1. Completely reload the database every now and then, and track "unexpected"
    changes, so I can debug issues.
 
 2. When things go wrong, increment a counter and render it within the UI.  I
    am hoping this will help me notice when things are broken.

We'll see how it goes.

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
