---
title: "New Blog Engine: Hugo"
date: "2014-03-15T01:30:01-05:00"
tags: ["meta", "blog"]
---
Nearly a year ago I started to sour on WordPress, the blog engine I've been
using since 2007.  I have thought for a long time that a plaintext based system
would be better, easier to manage, and that I could do more remotely (ie
offline) with such a system.

At the time I looked around and the best option I saw was
[ikiwiki](http://ikiwiki.info/).  For what it's worth, as with pretty much any
blog engine it can be themed to be pretty, and it has a ton of plugins, and hey,
it's written in [perl](/tags/perl), so I could hack on it if need be.

I hacked on my [conversion
script](https://github.com/frioux/export-wordpress-to-ikiwiki) for
a **long time**, totalling in nearly a year, on and off of course.
Part of the problem is that WordPress uses a mixture of HTML and plain
text formatting.  For example, newlines are converted to linebreaks,
some characters are autoescaped for you, and sometimes you get to write
raw HTML.  I leveraged an existing [wiki conversion
framework](https://github.com/frioux/HTML-WikiConverter-Markdown/tree/ikiwiki)
after doing some preprocessing of the above.

I was about ready to pull the trigger about a week ago (March 7, 2014) but I was
frustrated that rebuilding my blog of about 300 posts took between thirdy
seconds and a full minute, depending on settings.  I went to bed that night a
little frustrated, but as I was reading I had the idea of a Go based static site
generator, which could be fast, modern, easily distributable, etc.  Before
falling asleep I did a quick Google and found [Hugo](http://hugo.spf13.com).

## Enter Hugo

Hugo is relatively young at this point.  The first commit
was just over eight months ago (September 4th, 2013.)  The
[documentation](http://hugo.spf13.com/overview/introduction) is pretty
good, and as expected (and indeed promised) it's blazing fast.  I can
regenerate my entire blog in less than half a second.  That's two orders
of magnitude faster than ikiwiki was!

Currently Hugo lacks a few features I'd like to have.  One of them, Pagination,
is acknowledged by Steve Francia, the main developer.  If I can level up my Go
I'll see about helping out with that feature, but I'm not super hopeful at this
point (I'm not good at Go at all.)  I can live with this because I have an
alternate, ghetto index of my site via the [tags](/tags).  I can live with that
for the time being.

The other feature, which I don't need but which seems like kindav a no-brainer
to me, is more index customizability.  I'd love to have a paginated root node,
but then also some kind of easy view of all the posts ever, so just a page with
a huge list of links.  Additionally, if I wanted to generate a google sitemap or
two different feeds (RSS and Atom?) this feature is a must.

I mentioned this on the list but got
[warnocked](https://en.wikipedia.org/wiki/Warnock%27s_Dilemma).  Not a huge
deal, I can live without that kind of thing probably indefinately.

## Whence Comments?

ikiwiki has a built in commenting system using cgi which, while I find it a
little gross, is certainly functional.  Part of my original conversion was to
convert comments, but with hugo I'd have to somehow manually mash the comments
into the posts.  I was recommended to just go straight to Disqus for comments
since they can apparently import wordpress comments already.  So when I get
another few hours and interest I'll go ahead and do that,
but I'm not in a huge rush.  Generally [comments are a
wasteland](https://twitter.com/AvoidComments), though I've been lucky
enough to [avoid success](http://www.scottlondon.com/blog/archives/75)
and thus have not really gotten attention from anyone too negative.

I hope that I can bring myself to post more often like the good old days of
2009, with the blog being so incredibly easy to post to.  Enjoy!
