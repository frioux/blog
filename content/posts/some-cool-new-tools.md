---
title: Some Cool New Tools
date: 2018-07-17T07:30:10
tags: [ golang, perl, frew-warez, tool, toolsmith ]
guid: 6d73f291-df84-4ff8-9340-fef2b2285a7c
---
I've written (and ported) some new tools and thought others might find them
useful or inspiring.

<!--more-->

[In my ongoing project to write little tools in
Go](/posts/benefits-using-golang-adhoc-code-leatherman/) I have made a lot of
progress lately.  [One fun little tool is
`replace-unzip`](https://github.com/frioux/leatherman/blob/b26e89fb37c40aa120fc75b55132e87a651ecac9/replaceUnzip.go#L49),
which reimplements the `unzip(1)` command but does not extract `.DS_Store`,
`__MAXOSX/`, and extracts to a new directory if the files in the zipfile don't
already have a common root.  This was originally Perl, but I ported it to go
because the `Archive::Zip` module on CPAN is not core perl.

## `rss`

I've been meaning to start reading RSS again since December.  One of my goals is
not to add new places to check (inboxes) but instead to bend things to my
workflow.  So instead of firing up an RSS client or finding a hosted one, I
wrote a commandline client.  It takes the url to check and a filename to store
state:

``` bash
$ rss https://blog.afoolishmanifesto.com/index.xml afm.json
[Announcing shellquote](https://blog.afoolishmanifesto.com/posts/announcing-shellquote/)
[Detecting who used the EC2 metadata server with BCC](https://blog.afoolishmanifesto.com/posts/detecting-who-used-ec2-metadata-server-bcc/)
[Centralized known_hosts for ssh](https://blog.afoolishmanifesto.com/posts/centralized-known-hosts-for-ssh/)
[Buffered Channels in Golang](https://blog.afoolishmanifesto.com/posts/buffered-channels-in-golang/)
[C, Golang, Perl, and Unix](https://blog.afoolishmanifesto.com/posts/c-golang-perl-and-unix/) 
```

The state is simply a JSON list of GUIDs that the tool has seen before.  I wrote
a little vim command that lets me just type `:RSS` and my new RSS items will
just show up as links in the current document. This is built around [my notes
system, discussed here](/posts/a-love-letter-to-plain-text/).

A handy side effect is that because I'm just running a simple program I can
easily add more intelligence.  For example, I enjoy [LWN](http://lwn.net/), but
I could not care less about new kernel releases, so I can filter them out
trivially:

``` bash
$ rss https://lwn.net/headlines/newrss .rss/lwn.js |
      grep -Piv 'kernel (update|prepatch)'
```

Writing this highlighted to me, again, that the Go ecosystem is not mature yet.
The RSS modules I found all force the user to implement part of the various
specifications instead of doing the obvious work out of the box.  Here's an
example: RSS allows the link itself to be treated like the GUID, but none of the
modules I found would put the link in the GUID if the GUID was missing.  There's
more than just that, but that's a really simple improvement that would help
almost everyone using the module.

## `dump-mozlz4`

In a similar fashion to the above, I wanted to be able to insert links to all of
the current tabs I have open.  This assists me in "swapping out" such that the
only thing open is stuff I actually am doing at the moment.  I spelunked my
Firefox profile directory and finally found a file that would have the data I
was interested in.  Here's what I found:

``` bash
$ file sessionstore-backups/previous.jsonlz4
sessionstore-backups/previous.jsonlz4: data

$ xxd sessionstore-backups/previous.jsonlz4 | head -3
00000000: 6d6f 7a4c 7a34 3000 d48e 0300 f221 7b22  mozLz40......!{"
00000010: 7665 7273 696f 6e22 3a5b 2273 6573 7369  version":["sessi
00000020: 6f6e 7265 7374 6f72 6522 2c31 5d2c 2277  onrestore",1],"w
```

So clearly it's got some kind of header `mozLz40` and then some other bytes
before what is presumably `lz4` compressed data.  I tried using some `lz4`
compression cli tool but it errored saying incorrect magic number, which I
expected.  I also figured that the other bytes were probably a length and
probably 4 bytes long.

I found [a rust tool on github](https://github.com/badboy/jsonlz4cat) that
confirmed my suspicions above.  After that it was a matter of research, and I
was able to build a [mozlz4 package](https://github.com/frioux/mozlz4) to
assist in decompressing these files in the future.

Armed with this package and a [very basic CLI
wrapper](https://github.com/frioux/leatherman/blob/b26e89fb37c40aa120fc75b55132e87a651ecac9/dumpMozLz4.go#L13)
I am now able to get a list of all the pages that are open in Firefox:

``` bash
$ dump-mozlz4 sessionstore-backups/recovery.jsonlz4 |
   jq -r '.windows[].tabs[] | .entries[.index - 1] | " * ["+.title+"]("+.url+")"'
```

I found it interesting that I had to use `.index` in the above; without it you
will get the wrong entry when you press back.

---

I have long thought that one of the super powers of software engineering is that
our world is so much more mutable than others, and that we can build tools to
solve our problems in ways that simplify our lives and reduce friction.  I hope
this post inspires you to do the same.

---

Nearly all of the code in this post is Go.  If you want to learn Go, you should
read
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book that I recommend is
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=cecea11ea25b6635dd78601d2ec1abef">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It goes through the motions of creating wrappers tools and tools afresh, diving
into some of the operating system details that assist the toolmaker so much.
