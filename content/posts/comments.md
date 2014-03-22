---
title: "Static Site Comments?"
date: "2014-03-25T08:01:58-05:00"
tags: ["meta", "blog"]
guid: "https://blog.afoolishmanifesto.com/posts/comments/"
---
[A week ago](/posts/hugo) I blogged about how I ditched WordPress for Hugo.  One
of the (at least temorary) casualties to that conversion was the loss of
comments.  I did export the comments for later inclusion into the site somehow,
but I have yet to see an option I can live with for hosting them.

Here I'll discuss the two obvious options.

## Disqus

My original plan was to start using Disqus immediately.  But then, maybe
luckily, I stumbled across a website that uses Disqus while adblock was
disabled.  What I found was "[Promoted
Discovery](http://help.disqus.com/customer/portal/articles/666278-introducing-promoted-discovery-and-f-a-q-)",
or what I'd rather call: ads.

I've never had ads on my blog before and I don't want to any time soon,
especially if the income just exists to host comments.

## Discourse

A friend of mine is crazy excited for [Discourse](http://www.discourse.org),
certainly more than is warranted, but after he showed me, and [Atwood
mentioned](http://blog.codinghorror.com/please-read-the-comments/) the use of
Discourse for commments, and I'd decided against Disqus, I figured I might as
well look into it.

While I was perusing the [installation
documentation](https://github.com/discourse/discourse/blob/master/docs/ADMIN-QUICK-START-GUIDE.md)
I saw this line: "If your forum is expected to grow at all, be sure you have at
least 2 GB of memory available to your Discourse instance. You might be able to
squeak by with less, but we don't recommend it, unless you are an expert." While
that's couched in unclear, non-technical terms, the message is clear: less than
2 gigs of memory isn't supported.

My Linode as a total of 1G (and currently still 512M since I haven't rebooted it
in 353 days!)  Unless someone close to the Discourse team were to tell me that
less than 512M will work for a relatively stable (10 comments a week?) blog,
there's no way that's going to work.

So I'm back at square one.  I could do some weird thing where I use ikiwiki + an
iframe for comments until Hugo gets comment parity.  Alternatively I could try
to write some kind of OSS Disqus, or maybe help hack on Discourse and make
enough features disablable that it can be nice and light.

But I'm not super likely to do any of that any time soon. Comments and even
community is not the goal of my blogging.  If you have ideas on how I can easily
regain commenting on my blog you can always [tweet at
me](https://twitter.com/frioux), but in the meantime I'll keep at blogging.
