---
aliases: ["/archives/1518"]
title: "Git 1.7.5.1 from git on ubuntu"
date: "2011-03-02T02:56:31-06:00"
tags: [git, ubuntu]
guid: "http://blog.afoolishmanifesto.com/?p=1518"
---
I really like git. It has an excellent suite of tools bundled with it from the start and it gets lots of updates and active development. Today I was looking at the latest git version (1.7.4) because I was installing it on a new machine and, as usual with new versions of things, I perused the [release notes](http://www.kernel.org/pub/software/scm/git/docs/RelNotes/1.7.4.txt). What really caught my eye was this:

```
 * "git log -G<pattern>" limits the output to commits whose change has
   added or deleted lines that match the given pattern.
```

I don't know about you guys, but I fake that feature 2 or 3 times a month by just doing git log -p | grep foo -C50. It's not nearly as nice as it catches other things, breaks color, etc. Anyway, I decided that instead of waiting for my already non-standard ubuntu repo to catch up, I'd just build it.

First, I checked out git with my installed git:

    git clone git://git.kernel.org/pub/scm/git/git.git

That will take a while, so while that's going on install

    build-essential
    autoconf
    asciidoc
    libcurl4-openssl-dev
    gettext

Note that asciidoc tries to pull in a ton of TeX junk. Don't let it, you don't need that at all.

Once that's done do something like the following:

    make configure
    ./configure --prefix=/opt --with-libpcre
    make -j5 all
    make doc html
    sudo make install install-doc install-html

I used the prefix because I'd rather not install on top of my existing stuff; you might want to install to home.  `--with-libpcre` lets you use perl compatible regular expressions in `git grep`.  For some reason you can build the code in parallel (`-j5 all`) but not the docs (`doc html`).

Anyway, after doing that ensure that $prefix/bin is in your path and enjoy a brand new git!

---

(The following includes affiliate links.)

If you're interested in learning more about Git, I cannot recommend
<a  href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=73f85964b6ab98ea870583701b7e77aa">Pro Git</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
enough.  It's an excellent book that will explain how to use Git day-to-day, how
to do more unusual things like set up Git hosting, and underlying data
structures that will make the model that is Git make more sense.
