---
title: CloudFront Migration Update
date: 2016-03-26T14:32:22
tags: ["cloudfront", "aws", "hugo", "meta"]
guid: "https://blog.afoolishmanifesto.com/posts/cloudfront-migration-update"
---
[When I migrated my blog to
CloudFront](/posts/migrating-blog-to-cloudfront/)
I mentioned that I'd post about how it is going in late March.  Well it's late
March now so here goes!

First off, I switched from using the `awscli` tools and am using
[`s3cmd`](http://s3tools.org/s3cmd) because it does the smart thing and only
syncs if the md5 checksum is different.  Not only does this make a sync
significantly faster, it also reduces PUTs which are a major part of the cost of
this endeavour.

Speaking of costs, how much is this costing me?  February, which was a partial
month, cost a total of $0.03.  One might expect March to cost more than four
times that amount (still couch change) but because of the `s3cmd` change I made,
the total cost in March so far is $0.04, with a forecast of $0.05.  There **is**
one cost that I failed to factor in: logging.

While my full blog is a svelte 36M, just the logs for CloudFront over the past
36 days has been almost double that; and they are compressed with gzip!  The
logging incurs additional PUTs to S3 as well as an additional storage burden.
The free tier includes 5G of free storage, but pulling down the log files as
structured (a file per region per hour gzipped) is a big hassle.  I had over
five thousand log files to download, and it took about an hour.  I'm not sure
how I'll deal with it in the future but I may periodically pull down those logs,
consolidate them, and replace them with a rolled up month at a time file.

## Popular Pages

Because the logs were slightly easier to interact with than before I figured I'd
pull them down and take a look.  I had to write a little Perl script to parse
and merge the logs.  Here's that, for the interested:

```
#!/usr/bin/env perl

use 5.20.0;
use warnings;

use autodie;

use Text::CSV;

my $glob = shift;
my @values = @ARGV;
my @filelisting = glob($glob);

for my $filename (@filelisting) {
  open my $fh, '<:gzip', $filename;
  my $csv = Text::CSV->new({ sep_char => "\t" });
  $csv->column_names([qw(
      date time x_edge_location sc_bytes c_ip method host cs_uri_stem sc_status
      referer user_agent uri_query cookie x_edge_result_type x_edge_request_id
      x_host_header cs_protocol cs_bytes time_taken x_forwarded_for ssl_protocol
      ssl_cipher x_edge_response_result_type
  )]);
  # skip headers
  $csv->getline($fh) for 1..2;
  while (my $row = $csv->getline_hr($fh)) {
    say join "\t", map $row->{$_}, @values
  }
}
```

To get all of the accessed URLs, with counts, I ran the following oneliner:

```
perl read.pl '*.2016-03-*.gz' cs_uri_stem | sort | uniq -c | sort -n
```

There are some *really* odd requests here, along with some sorta frustrating
issues.  Here are the top thirty, with counts:

```
  27050 /feed
  24353 /wp-content/uploads/2007/08/transform.png
  13723 /feed/
   8044 /static/img/me200.gif
   5011 /index.xml
   4607 /favicon.ico
   3866 /
   2491 /static/css/styles.css
   2476 /static/css/bootstrap.min.css
   2473 /static/css/fonts.css
   2389 /static/js/bootstrap.min.js
   2384 /static/js/jquery.js
   2373 /robots.txt
    966 /posts/install-and-configure-the-ms-odbc-driver-on-debian/
    637 /wp-content//uploads//2007//08//transform.png
    476 /archives/1352
    311 /wp-content/uploads/2007/08/readingminds2.png
    278 /keybase.txt
    266 /posts/replacing-your-cyanogenmod-kernel-for-fun-and-profit/
    225 /archives/1352/
    197 /feed/atom/
    191 /static/img/pong.p8.png
    166 /posts/concurrency-and-async-in-perl/
    155 /n/a
    149 /posts/weirdest-interview-so-far/
    144 /apple-touch-icon.png
    140 /apple-touch-icon-precomposed.png
    133 /posts/dbi-logging-and-profiling/
    126 /posts/a-gentle-tls-intro-for-perlers/
    120 /feed/atom
```

What follows is pretty intense navel gazing that I suspect very few people care
about.  I think it's interesting but that's because like most people I am
somewhat of a narcissist.  Feel free to skip it.

So `/feed`, `/feed/`, `/feed/atom`, and `/feed/atom/` are in this list a lot,
and sadly when I migrated to CloudFront I failed to set up the redirect header.
I'll be figuring that out soon if possible.

`/`, `/favicon.ico`, and `/index.xml` are all normal and expected.  It really
surprises me how many things are accessing `/` directly.  A bunch of it is
people, but a lot is feed readers.  Why they would hit `/` is beyond me.

`/wp-content/uploads/2007/08/transform.png` and
`/wp-content//uploads//2007//08//transform.png` (from [this
page](/posts/transform-into-a-car/)) seems to
be legitimately popular.  It is bizarrely being accessed from a huge variety of
User Agents.  At the advice of a friend I looked more closely and it turns out
it's being hotlinked by a Vietnamese social media site or something.  This is
cheap enough that I don't care enough to do anything about it.

`/wp-content/uploads/2007/08/readingminds2.png` is similar to the above.

`/static/img/me200.gif` is an avatar that I use on a few sites.  Not super
surprising, but as always: astounded at the number.

`/robots.txt` Is being accessed a lot, presumably by all the various feed
readers.  It might be worthwhile to actually create that file.  No clue.

`/static/css/*` and `/static/js/*` should be pretty obvious.  I would consider
using those from a CDN but my blog is already on a CDN so what's the point!  But
it might be worth at least adding some headers so those are cached by browsers
more aggressively.

`/posts/install-and-configure-the-ms-odbc-driver-on-debian/`
([link](/posts/install-and-configure-the-ms-odbc-driver-on-debian/)) is
apparently my most popular post, and I would argue that that is legitimate.  I
should automate some kind of verification that it continues to work.  I try to
keep it updated but it's hard now that I've stopped using SQL Server myself.

`/archives/1352` and `/archives/1352/` is [pre-hugo
URL](/posts/hugo/) URL for [the announcement
of
DBIx::Class::DeploymentHandler](/posts/announcing-dbix-class-deploymenthandler/).
I'm not sure why the old URL is being linked to, but I am glad I put all that
effort into ensuring that old links keep working.

`/keybase.txt` is the identity proof for [Keybase](https://keybase.io/) (which I
have never used by the way.)  It must check every four hours or something.

`/posts/replacing-your-cyanogenmod-kernel-for-fun-and-profit/`
([link](/posts/replacing-your-cyanogenmod-kernel-for-fun-and-profit/)) is a
weird post of mine, but I'm glad that a lot of people are interested, because it
was a lot of work to do.

`/static/img/pong.p8.png`, `/posts/weirdest-interview-so-far/`
([link](/posts/weirdest-interview-so-far/)), and
`/posts/dbi-logging-and-profiling/` ([link](/posts/dbi-logging-and-profiling/))
were all on `/` at some point in the month so surely people just clicked those
from there.

`/posts/concurrency-and-async-in-perl/`
([link](/posts/concurrency-and-async-in-perl/)) and
`/posts/a-gentle-tls-intro-for-perlers/`
([link](/posts/a-gentle-tls-intro-for-perlers/)) are more typical posts of mine,
but are apparently pretty popular and I would say for good reason.

`/n/a`, `/apple-touch-icon.png`, `/apple-touch-icon-precomposed.png` all seem
like some weird user agent thing, like maybe iOS checks for that if someone
makes a bookmark?

## World Wide Readership

Ignoring the seriously hotlinked image above, I can easily see where most of my
blog is accessed:

```
perl read.pl '*.2016-03-*.gz' cs_uri_stem x_edge_location  | \
  grep -v 'transform' | cut -f 2 | perl -p -e 's/[0-9]+//' | \
  sort | uniq -c | sort -n
```

Here's the top 15 locations which serve my blog:

```
  21330 JFK # New York
   9668 IAD # Washington D.C.
   8845 ORD # Chicago
   7098 LHR # London
   6536 FRA # Frankfurt
   5319 DFW # Dallas
   4568 ATL # Atlanta
   4328 SEA # Seattle
   3345 SFO # San Fransisco
   3137 CDG # Paris
   2991 AMS # Amsterdam
   2966 EWR # Newark
   2339 LAX # Los Angeles
   1993 ARN # Stockholm
   1789 WAW # Warsaw
```

I'm super pleased at this, because before the migration to CloudFront *all* of
this would be served from a single server in DFW.  It was almost surely enough
but it'd be slower, especially for the stuff outside of the states.

---

Aside from the fact that I have not yet set up the redirect for the old feed
URLs, I think the migration to CloudFront has gone very well.  I'm pleased that
I'm less worried about rebooting my Linode and that my blog is served quickly,
cheaply, and efficiently to readers worldwide.
