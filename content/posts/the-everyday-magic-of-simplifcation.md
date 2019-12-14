---
title: The Everyday Magic of Simplification
date: 2019-12-14T07:01:55
tags: [ golang ]
guid: c00faf7e-7a67-47ef-8d1a-8c8747a19fd3
---
I recently simplified the system I use for RSS.

<!--more-->

I use [my leatherman for rss](https://github.com/frioux/leatherman#rss), but
that's just one piece of the system.  The way it worked before refactoring was
that the `rss` command mapped to a single feed and had a state file for what
items of that feed had been seen.  I stored the state files in my notes system
(which is a git repo) and had a script that ran the tool with GNU parallel.

Here's what it looked like:

```bash
#!/bin/sh

set -e

if [ -n "$(git status --porcelain .rss)" ]; then
   echo "Uncommitted changes in .rss"
   exit 1
fi

cat <<FEEDS | parallel -j 20 | sed 's/^/ * /'
   rss 'https://groups.google.com/forum/feed/pagedout-notifications/msgs/atom.xml?num=15' .rss/po.js
   rss https://programmingisterrible.com/rss .rss/pit.js
   rss 'https://www.scottrao.com/blog?format=RSS' .rss/rao.js
   rss http://www.windytan.com/feeds/posts/default .rss/windytan.js
   rss https://danluu.com/atom.xml .rss/luu.js
   rss https://blog.plover.com/index.atom .rss/mjd.js
   rss http://slatestarcodex.com/feed/ .rss/ssc.js | grep -iv thread
FEEDS

if [ -n "$(git status --porcelain .rss)" ]; then
   git add .rss
   git commit -qm 'Sync RSS'
fi
```

I removed some of the calls to `rss` in the example above, but that's
the general idea.  What I wanted to do was stop picking a state file per
feed, remove the use of GNU parallel, and make the filtering and rendering
more flexible.  The use of sed to prefix bullet points feels wrong; I can
do better.

## Concurrency Examples

[The change to make `rss`
concurrent](https://github.com/frioux/leatherman/commit/0e30ea5ec7af47d7d0a0f06494632b14bd9a926d)
and manage all feeds at once went naturally together.  I want to take a detour to highlight the
path I took to get where I ended up.

In the first version I wrote I'd spin up a goroutine per feed and send data
over a channel.  I had another goroutine to pull data from said channel and
syncronize it with the file on disk (basically print whichever items were new.)

You should be able to tell by the name of the `ugh` struct that I wasn't a fan.

```golang
type ugh struct {
	u   string
	i   []*gofeed.Item
	err error
}

wg := &sync.WaitGroup{}
wg.Add(len(urls))
ch := make(chan ugh) // O(n) goroutines where n is len(urls)

for _, urlString := range urls {
	go func(urlString string) {
		defer wg.Done()
		items, err := loadFeed(fp, urlString)
		if err != nil {
			ch <- ugh{err: err}
			return
		}
		ch <- ugh{u: urlString, i: items}
	}(urlString)
}

go func() {
	for u := range ch {
		if u.err != nil {
			fmt.Fprintf(os.Stderr, "%s\n", err)
			os.Exit(1) // XXX: uhhhh
		}
		if err := syncFeed(state, u.i, u.u, os.Stdout); err != nil {
			fmt.Fprintf(os.Stderr, "%s\n", err)
			os.Exit(1) // XXX: uhhhh
		}
	}
}()

wg.Wait()
```

This version is almost exactly the same as the above, except instead of reading
from the channel in a goroutine, I read from it in the mainline code and close
the channel (which is what tells the code reading from it that it's done) in
a smaller, simpler goroutine.  I was still bothered by the `ugh` struct though.

```golang
type ugh struct {
	u   string
	i   []*gofeed.Item
	err error
}

wg := &sync.WaitGroup{}
wg.Add(len(urls))
ch := make(chan ugh)

go func() {
	wg.Wait()
	close(ch)
}()

for _, urlString := range urls {
	go func(urlString string) {
		defer wg.Done()
		items, err := loadFeed(fp, urlString)
		if err != nil {
			ch <- ugh{err: err}
			return
		}
		ch <- ugh{u: urlString, i: items}
	}(urlString)
}

for u := range ch {
	if u.err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1) // XXX: uhhhh
	}
	if err := syncFeed(state, u.i, u.u, os.Stdout); err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1) // XXX: uhhhh
	}
}
```

In this final version I thought to myself: "I bet I could move the error
handling into an `errgroup`."  This allows us to block on total completion,
as above, but instead we stop the presses when we hit an error.  On top
of that, instead of threading the url into the goroutines and then back,
we just map a goroutine onto a single item in a slice.  Suddenly the `ugh`
struct has evaporated!

```golang
results := make([][]*gofeed.Item, len(urls))
g, _ := errgroup.WithContext(context.Background())
for i, urlString := range urls {
	i, urlString := i, urlString
	g.Go(func() error {
		items, err := loadFeed(fp, urlString)
		if err != nil {
			return err
		}
		results[i] = items
		return nil
	})
}

if err := g.Wait(); err != nil {
	fmt.Fprintf(os.Stderr, "%s\n", err)
	os.Exit(1)
}

for i, items := range results {
	if err := syncFeed(state, items, urls[i], os.Stdout); err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}
}
```

## Back to the System

The next step, before I can use the above, is to refactor the system
to pass more data through.  If you paid close attention in the initial
shell script, you'd notice that I was filtering certain feeds based
on title.  I have long thought that I shouldn't be printing markdown
straight from `rss`, and instead should print JSON.  [So that's what I
did.](https://github.com/frioux/leatherman/commit/fbbcdadea7a2c95b773adfe567b7f31966e72906)

The result was a much neater shell script, decomposed into a couple pieces;
first, the main shell script:

```bash
#!/bin/sh

set -e

if [ -n "$(git status --porcelain .rss.json)" ]; then
   echo "Uncommitted changes in .rss.json"
   exit 1
fi

rss -state .rss.json $(cat .rss-feeds) |
   bin/filter-rss |
   jq -r '" * ["+.title+"]("+.link+")"'

if [ -n "$(git status --porcelain .rss.json)" ]; then
   git add .rss.json
   git commit -qm 'Sync RSS'
fi
```

Now that the feeds are just their url, I can store the list of urls in a
separate file and (hopefully) not modify this script again for a long time.
Note that the rendering into markdown is a simple `jq` invocation at the end of
the pipeline.

I factored the filtering out into a little perl script:

```perl
#!/usr/bin/perl

use strict;
use warnings;

use JSON;

# mute a domain on a given topic
my %domains = (
   '^https?://slatestarcodex.com/' => 'thread',
);

LINE:
while (<STDIN>) {
   my $d = decode_json($_);

   for my $domain (keys %domains) {
      my $topic = $domains{$domain};

      next LINE if $d->{link} =~ m/$domain/i && $d->{title} =~ m/$topic/i;
   }

   print "$_\n";
}
```

The main code there hopefully won't need to be changed as often as the regex
hash at the top.

---

I'm pleased with this change.  It means my RSS feeds load noticably faster
than before, adding a new RSS feed doesn't involve coming up with a new
unique filename, and in theory I could automate the addition of a new feed
by making some kind of default rss mimetype handler for RSS that would add
to my feed list.

(The following includes affiliate links.)

If you want to learn more
about programming Go, you should check out <a target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.  It is one of the best programming books I've read.
You will not only learn Go, but also get some solid introductions on how to
write code that is safely concurrent.  **Highly recommend.**  This book is
so good that I might write a blog post solely about learning Go with this book.

<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=01cde3ac7bf536c84bfff0cc1078bc56">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is one of the most inspiring software engineering books I've ever read.  I
suggest reading it if you use UNIX either at home (Linux, OSX, WSL) or at work.
It can really clarify some of the foundational tools you can use to build your
own tools or extend your environment.
