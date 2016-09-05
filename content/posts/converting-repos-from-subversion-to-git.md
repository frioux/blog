---
aliases: ["/archives/1541"]
title: "Converting repos from Subversion to Git"
date: "2011-05-18T03:00:18-05:00"
tags: [frew-warez, cpan, git, git-svn, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1541"
---
I have now converted something like 25 repositories from svn to git. I can fix undetected merges, correctly import tags, and clean up ugly (svk) commit messages.

With this knowledge I hope to write a small, non-free eBook (7.50 USD I think.) But first I'd like a chance to convert your repository! The more repositories that I convert the more ground the ebook can cover. I've converted a number of repos for CPAN modules and I'd love to do more. My first thought was to convert the modules in [the Catalyst repo](http://dev.catalystframework.org/svnweb/Catalyst), but sadly I'm not sure which ones I should do.

So if you are interested in having your repo converted, I am totally willing to do it. All I need from you is an email, comment, ping, etc saying you are interested and I need to you be willing to check the converted repo to ensure that it's good. I've gotten pretty good at this but I'm not perfect and I'm not taking the blame if you miss something :-)

If you'd like to try your hand at doing this, I put all my [conversion scripts online](https://github.com/frioux/Git-Conversions), so feel free to take a peak.

---

If you're interested in learning more about Git, I cannot recommend
<a  href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=73f85964b6ab98ea870583701b7e77aa">Pro Git</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
enough.  It's an excellent book that will explain how to use Git day-to-day, how
to do more unusual things like set up Git hosting, and underlying data
structures that will make the model that is Git make more sense.
