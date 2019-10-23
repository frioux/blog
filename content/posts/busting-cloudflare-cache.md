---
title: Busting the Cloudflare Cache
date: 2019-02-20T07:15:17
tags: [ perl, meta, cloudflare ]
guid: 96139cd2-b350-4d4e-9a6e-045645ba8cdd
---
I automated blowing the cache for this blog.  Read on to see how I did it.

<!--more-->

I currently have complex but reliable and cheap infrastructure for this blog.
All of the content is stored in S3, then hosted publicly via CloudFront (almost
solely to publish `/foo/index.html` as `/foo/`), and then cached via Cloudflare.
It's cheap (typically less than 25¢ per month) and I haven't need to modify it
after I set it up.

On the other hand, because Cloudflare is a cache, it means that sometimes I'll
modify a page and it'll be days before the new version is shown to users.  On
top of that, if I accidentally link to a page before it's published, Cloudflare
may cache the 404.  Huge hassle.

I recently noticed that Cloudflare actually lets you selectively clear the
cache; I decided I'd automate doing that every time I publish.  It was pretty
straightforward.

I publish this blog via `s3cmd` (currently), since it can avoid copying a file
if the md5sum hasn't changed.`s3cmd` prints various output as it's copying the
files, including the full path to the document within s3.  I added a `tee(1)` to
log the `s3cmd` output, built a tool that would read that log and do the cache
busting, and finally, after that exits zero, remove the logfile.

Here's the snippet from [the Makefile][makefile] that orchestrates all of those steps:

[makefile]: https://github.com/frioux/blog/blob/d1db512da13f0ca9ddbbcc28b765506a4efd1970/Makefile

```make
push: build
	git push --quiet
	cd public && s3cmd sync --delete-removed --disable-multipart --no-preserve /pwd/ s3://blog.afoolishmanifesto.com | tee $(log) && set-redirects && . ~/.cf-token && busted-urls $(log) && rm $(log)
```

Here's an example of the output:

```
WARNING: Module python-magic is not available. Guessing MIME types based on file extensions.
/pwd/index.html -> s3://blog.afoolishmanifesto.com/index.html  [1 of 23]
 29459 of 29459   100% in    0s   100.66 kB/s  done
/pwd/index.xml -> s3://blog.afoolishmanifesto.com/index.xml  [2 of 23]
 15475 of 15475   100% in    0s    59.51 kB/s  done
/pwd/page/10/index.html -> s3://blog.afoolishmanifesto.com/page/10/index.html  [3 of 23]
 10866 of 10866   100% in    0s    38.82 kB/s  done
/pwd/page/2/index.html -> s3://blog.afoolishmanifesto.com/page/2/index.html  [4 of 23]
 34683 of 34683   100% in    0s   131.56 kB/s  done
/pwd/page/3/index.html -> s3://blog.afoolishmanifesto.com/page/3/index.html  [5 of 23]
 40086 of 40086   100% in    0s   147.99 kB/s  done
/pwd/page/4/index.html -> s3://blog.afoolishmanifesto.com/page/4/index.html  [6 of 23]
 42420 of 42420   100% in    0s   143.22 kB/s  done
/pwd/page/5/index.html -> s3://blog.afoolishmanifesto.com/page/5/index.html  [7 of 23]
 42412 of 42412   100% in    0s   128.24 kB/s  done
/pwd/page/6/index.html -> s3://blog.afoolishmanifesto.com/page/6/index.html  [8 of 23]
 40512 of 40512   100% in    0s   126.37 kB/s  done
/pwd/page/7/index.html -> s3://blog.afoolishmanifesto.com/page/7/index.html  [9 of 23]
 40142 of 40142   100% in    0s   134.06 kB/s  done
/pwd/page/8/index.html -> s3://blog.afoolishmanifesto.com/page/8/index.html  [10 of 23]
 35460 of 35460   100% in    0s   141.06 kB/s  done
/pwd/page/9/index.html -> s3://blog.afoolishmanifesto.com/page/9/index.html  [11 of 23]
 38056 of 38056   100% in    0s   148.57 kB/s  done
/pwd/posts/index.html -> s3://blog.afoolishmanifesto.com/posts/index.html  [12 of 23]
 60595 of 60595   100% in    0s   163.80 kB/s  done
/pwd/posts/index.xml -> s3://blog.afoolishmanifesto.com/posts/index.xml  [13 of 23]
 357632 of 357632   100% in    0s   797.63 kB/s  done
/pwd/posts/learning-day-1-golang/index.html -> s3://blog.afoolishmanifesto.com/posts/learning-day-1-golang/index.html  [14 of 23]
 10365 of 10365   100% in    0s    42.00 kB/s  done
/pwd/sitemap.xml -> s3://blog.afoolishmanifesto.com/sitemap.xml  [15 of 23]
 134369 of 134369   100% in    0s   389.41 kB/s  done
/pwd/tags/golang/index.html -> s3://blog.afoolishmanifesto.com/tags/golang/index.html  [16 of 23]
 5845 of 5845   100% in    0s    22.23 kB/s  done
/pwd/tags/golang/index.xml -> s3://blog.afoolishmanifesto.com/tags/golang/index.xml  [17 of 23]
 14273 of 14273   100% in    0s    55.81 kB/s  done
/pwd/tags/index.html -> s3://blog.afoolishmanifesto.com/tags/index.html  [18 of 23]
 27017 of 27017   100% in    0s    94.42 kB/s  done
/pwd/tags/index.xml -> s3://blog.afoolishmanifesto.com/tags/index.xml  [19 of 23]
 115544 of 115544   100% in    0s   355.71 kB/s  done
/pwd/tags/learning-day/index.html -> s3://blog.afoolishmanifesto.com/tags/learning-day/index.html  [20 of 23]
 3411 of 3411   100% in    0s    14.21 kB/s  done
/pwd/tags/learning-day/index.xml -> s3://blog.afoolishmanifesto.com/tags/learning-day/index.xml  [21 of 23]
 1105 of 1105   100% in    0s     3.32 kB/s  done
/pwd/tags/meta/index.html -> s3://blog.afoolishmanifesto.com/tags/meta/index.html  [22 of 23]
 5522 of 5522   100% in    0s    17.07 kB/s  done
/pwd/tags/meta/index.xml -> s3://blog.afoolishmanifesto.com/tags/meta/index.xml  [23 of 23]
 15386 of 15386   100% in    0s    55.09 kB/s  done
 Done. Uploaded 1120635 bytes in 6.7 seconds, 163.41 kB/s
```

For my [busted-urls][busted-urls] script I first wrote some perl that could take
that input and call a subroutine with a list of urls (the 30 thing is because
you can only purge 30 urls at a time):

[busted-urls]: https://github.com/frioux/blog/blob/62f00d2ac870823279d8e1284c22bbd2732ad252/bin/busted-urls

```perl
my @a;
while (<>) {
   next unless m(s3://(\S+));
   $_ = $1;
   s(/index\.html$)(/);
   push @a, "https://$_";
   if (@a == 30) {
      purge(\@a);
      @a = ();
   }
}

purge(\@a) if @a;
```

Next I wrote the `purge` subroutine:

```perl

sub purge {
   my ($urls) = @_;

   warn "purging @$urls\n";
   my $resp = $ua->request(
      POST => "https://api.cloudflare.com/client/v4/zones/$zone_id/purge_cache", {
         content => encode_json({ files => $urls}),
      },
   );
   unless ($resp->{success}) {
      warn "$resp->{status} $resp->{reason}\n";
      print "$resp->{content}\n";
      exit 1;
   }
}
```

Testing this was obnoxious and involved me [making][1] [simple][2] [changes][3]
to old posts till I got every little bit reliable, but that only took about
thirty minutes.

[1]: https://github.com/frioux/blog/commit/73a66c3028764c9e780f4fbd5bff032e1b7406e5
[2]: https://github.com/frioux/blog/commit/fe90c9f6fd2741425a95ac1e1a70028d70169708
[3]: https://github.com/frioux/blog/commit/811d5206ce2277af4c51e296d1ee94fdaecfd330

---

The upshot of all of this is that I can be a little more relaxed about
publishing, since I can actually fix errors.  I used to read my posts very
carefully for (inevitable) typos to avoid the embarassment of posts that have
mistakes I can't even fix after receiving a suggested correction.

Furthermore, I used to tune my cache such that posts were cached for eight days
and everything else (rss feed, index, etc) was cached for one day, to allow
people to see new posts.  Now that I blow the cache for just the changed stuff,
I cranked the cache all the way up to a month for everything.  We'll see if that
helps; I'm already serving over 75% of requests and 80% of bytes from the cache
as is.

---

(The following includes affiliate links.)

Perl is definitely not fashionable these days.  On the other hand fashion has
nothing to do with quality or fitness for purpose.  Functional programming is
much more popular these days than when I first learned to program.  If you want
a great functional programming book, I highly recommend
<a target="_blank" href="https://www.amazon.com/gp/product/1558607013/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1558607013&linkCode=as2&tag=afoolishmanif-20&linkId=9f479431b1bcf08d898213d2ea4372a9">Higher-Order Perl</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1558607013" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's using Perl, which is offensive to modern palates, but is definitely sweeter,
syntactically speaking, than lisp.  Give it a shot.

One of the best novels I've read recently was
<a target="_blank" href="https://www.amazon.com/gp/product/B000PAAH3A/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B000PAAH3A&linkCode=as2&tag=afoolishmanif-20&linkId=3ecc9c48d590200c6ecb5c625159c9d4">The Terror</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B000PAAH3A" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's historical fiction about some men who explored the arctic and ran into a
ton of problems.  I'd say it's 70% true; if you read it, I'll know the other
30%.  I liked this book so much that I intend to read much of the books the
author read as research.
