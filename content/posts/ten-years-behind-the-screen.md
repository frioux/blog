---
title: Ten Years Behind the Screen
date: 2017-07-03T06:11:15
tags: [ meta, blog, perl, self ]
guid: 5D98CF2C-5DE5-11E7-A65B-F6C6F9C3370F
---
I started this blog ten years ago today!

<!--more-->

Ten years ago, when I was spending a summer in Honduras, I published
[the very first article on this blog][first].  I have been writing on and off since
and I think improving almost everything I care to on the blog.

[As I've mentioned][2] [before][3] I have been using [Hugo][4] for (wow!) over
three years now.  One of the things I'm especially proud of is my blogs tooling
and self-containedness.  The only thing you need, theoretically, to publish my
blog is a working hugo binary (or [docker wrapper][5]), an s3cmd binary (or
[docker wrapper][6]) and [make][make].

The tools that I have blogged about before are Perl, SQL, and some basic shell.
Previously I have always leaned on the original post to share the tool, but that
is always going to be a little out of date.  So to commemorate the ten years of
blogging I am publishing both the source of the posts and the source of the
tools and all of the associated configuration that I store in the git
repository.

See the [LICENSE][license] if you are interested in using any of it.  Not that the
license restricts the use to these purposes, but the idea is that if someone
wanted to study the corpus or test some alternate renderer or something like
that they could.  The license allows you to simply republish all of the content
wholesale but I think that's kinda stupid (though it has been done with my
articles before and long before this point.)

---

While maybe only barely related, the fundamental tools that implement this blog
are written in Go, Perl, and as mentioned before, highly composeable commandline
tools.  With those in mind I would recommend reading <a
target="_blank"
href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=cecea11ea25b6635dd78601d2ec1abef">The
Unix Programming Environment</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />, as a glorious example of how Unix tools can be built.

If you are interested in learning Go, <a target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=8f70cf088a620f391bd4dd01ab18bad2">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" /> is a great book to start with.

Finally, if you read this blog you probably already know Perl, so maybe instead
of learning how to program Perl, you instead learn some functional programming
wizardry by reading <a target="_blank"
href="https://www.amazon.com/gp/product/1558607013/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1558607013&linkCode=as2&tag=afoolishmanif-20&linkId=9f6d14417fed8ac38b01ab852d22fcaf">Higher-Order
Perl</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1558607013"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" /> by my friend and coworker, [Mark Jason
Dominus](http://www.plover.com/).

[first]: /posts/on-the-validity-of-taking-nine-credit-hours-in-half-a-summer/
[2]: /posts/hugo/
[3]: /posts/hugo-unix-vim-integration/
[4]: https://gohugo.io/
[5]: https://github.com/frioux/hugo.dkr
[6]: https://github.com/frioux/s3cmd.dkr
[license]: https://github.com/frioux/blog/..
[make]: http://pubs.opengroup.org/onlinepubs/9699919799/utilities/make.html
