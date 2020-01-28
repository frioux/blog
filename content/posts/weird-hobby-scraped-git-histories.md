---
title: "Weird Hobby: Scraped Git Histories"
date: 2020-01-28T06:58:30
tags: [ git, golang, perl, coffee ]
guid: 59d24347-127e-4eb9-9c42-fa502264dff4
---
I have discovered a silly new hobby: creating git repos of the data in certain
websites.

<!--more-->

[I already told y'all](/posts/ordering-green-coffee-with-golang-and-jq/) about
how I scrape [sweetmarias](https://www.sweetmarias.com/) so I don't have to
deal with their slow website.

This weekend I decided to go further and start managing a git repo of the
export, complete with images!  I am not comfortable putting it on github (yet)
but I'll go through the few tools I am using to manage it.

## Most importantly, [`sm-list`](https://github.com/frioux/leatherman#sm-list)

`sm-list` extracts the entire inventory and emits json.  Without that tool the
rest wouldn't be possible.  It's about 250 lines of Go with a couple tests to
verify the scraping works (and happily allows adding fields to the scraper
without much work.)  [Most of the code is
here](https://github.com/frioux/leatherman/tree/a744ac4/pkg/sweetmarias).

## `bin/sync`

Here's the tool I use to commit to the git repo; it refuses to manage a file
that's newer than one day:

```bash
#!/bin/sh

set -e

cd ~/Dropbox/sm-export/

[ -e all.js ] && younger-than all.js m 1d && exit

sm-list > all.js.tmp
< all.js.tmp jq -S . > all.js
rm all.js.tmp

# if this is unchanged, don't even do the rest
if [[ -z "$(git status --porcelain ./all.js)" ]]; then
   exit
fi

< all.js |
  jq -r '.Images[]' |
  bin/sync-photos

git add -A photos/ all.js

git ci -m 'sync'
```

Relatively straightforward, but an important bit of glue nontheless...

## `bin/sync-photos`

`sync-photos`, if you are reading closely, receives images on standard in and
ensures those (and only those) images are in `./photos/`.  It's a relatively
straightforward perl script:

```perl
#!/usr/bin/perl

use strict;
use warnings;

use autodie;

use File::Basename;
use LWP::UserAgent;

my $ua = LWP::UserAgent->new(agent => "sm-syncer; abuse\@<domain>.com");

# %new contains list of urls we might need to download.
my %new = map { chomp; my $f = basename($_); $f => $_ } (<STDIN>);

# %on_disk contains all the files already on disk.
my %on_disk = map { my $f = basename($_); $f => $_ } glob './photos/*.jpg';

# intersection is where we're up to date.  Remove those.
for my $key (keys %new) {
   if ($on_disk{$key}) {
      delete $on_disk{$key};
      delete $new{$key};
   }
}

# The remainining stuff in %new needs to be downloaded.
for my $key (keys %new) {
   my $resp = $ua->get($new{$key}, ':content_file' => "./photos/$key");
   if (my $d = $resp->header('X-Died')) {
      die "$d\n"
   }

   if (!$resp->is_success) {
      die "$key - " . $resp->status_line . "\n"
   }
}

# The remaining stuff in %on_disk needs to be deleted.
for my $key (keys %on_disk) {
   unlink $on_disk{$key}
}
```

---

None of this stuff is amazing, but put together I can:

 * notice the addition of new coffees
 * discover the actual any coffees were added
 * and even refer to their photos with my own weird custom interface

I'm sure I'll talk about that interface some time too...

---

(The following includes affiliate links.)

If you want to learn more
about programming Go, you should check out <a target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.  It is one of the best programming books I've read.
You will not only learn Go, but also get some solid introductions on how to
write code that is safely concurrent.  **Highly recommend.**

Perl is definitely not fashionable these days.  On the other hand fashion has
nothing to do with quality or fitness for purpose.  Functional programming is
much more popular these days than when I first learned to program.  If you want
a great functional programming book, I highly recommend
<a target="_blank" href="https://www.amazon.com/gp/product/1558607013/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1558607013&linkCode=as2&tag=afoolishmanif-20&linkId=9f479431b1bcf08d898213d2ea4372a9">Higher-Order Perl</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1558607013" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's using Perl, which is offensive to modern palates, but is definitely sweeter,
syntactically speaking, than lisp.  Give it a shot.
