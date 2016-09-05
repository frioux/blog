---
aliases: ["/archives/1547"]
title: "Nicer git remote URLs"
date: "2011-05-25T01:17:41-05:00"
tags: [frew-warez, git]
guid: "http://blog.afoolishmanifesto.com/?p=1547"
---
Most open source git repositories that I interact with are hosted at [git.shadowcat.co.uk](http://git.shadowcat.co.uk). A few typical repo urls (read/write) hosted here looks like:

      dbsrgits@git.shadowcat.co.uk:DBIx-Class.git
      catagits@git.shadowcat.co.uk:Catalyst-Runtime.git
      p5sagit@git.shadowcat.co.uk:Devel-Declare.git
      gitmo@git.shadowcat.co.uk:Moose.git

A handy trick is to make a file at ~/.ssh/config with the following in it:

    host catagits
         user catagits
         hostname git.shadowcat.co.uk
         port 22
         identityfile ~/.ssh/id_dsa

    host dbsrgits
         user dbsrgits
         hostname git.shadowcat.co.uk
         port 22
         identityfile ~/.ssh/id_dsa

    host p5sagit
         user p5sagit
         hostname git.shadowcat.co.uk
         port 22
         identityfile ~/.ssh/id_dsa

    host gitmo
         user gitmo
         hostname git.shadowcat.co.uk
         port 22
         identityfile ~/.ssh/id_dsa

Now that that's done the repos before are simply:

      dbsrgits:DBIx-Class.git
      catagits:Catalyst-Runtime.git
      p5sagit:Devel-Declare.git
      gitmo:Moose.git

I actually did that for my work and github stuff too, since I just don't have the time to type those stupid domains all the time.

Enjoy!

---

If you're interested in learning more about Git, I cannot recommend
<a  href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=73f85964b6ab98ea870583701b7e77aa">Pro Git</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
enough.  It's an excellent book that will explain how to use Git day-to-day, how
to do more unusual things like set up Git hosting, and underlying data
structures that will make the model that is Git make more sense.
