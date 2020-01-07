---
title: Five Hundredth!
date: 2020-01-06T22:42:50
tags: [ meta, blog ]
guid: 48d382d0-358f-461d-b74b-2e5c3f3ccc37
---
This is my five hundredth post on this blog!

<!--more-->

## Timeline

As a sort of celebration for this little milestone, here's a timeline
comprising the life of this blog:

 * I first created this blog writing [ruby](/posts/friday-tips-and-tricks/),
   while [in Honduras](/posts/el-salvadorisimo/), on a hosted Wordpress on
   Dreamhost in July of 2007.
 * I made a bunch of [weird comics](/posts/your-possible-super-powers/).  [I think this is my favorite.](/posts/walking-through-walls/)
 * [I got a job](/posts/migrating-from-iis-to-apache/) at [mitsi](https://mitsi.tech/).
 * My boss convinced me to stick with [Perl rather than start using
   Ruby](/posts/using-rails-wisdom-in-perl/) at work.
 * I migrated this blog from dreamhost to linode.
 * [I got engaged](/posts/screen-scrape-for-love-with-web-scraper/) and married.
 * I replaced wordpress with [Hugo](/posts/hugo/).
 * My first son was born.
 * [I got a job](/posts/index-hints-in-mysql-with-dbix-class/) at [ZipRecruiter](https://www.ziprecruiter.com/hiring/technology).
 * My second son was born.
 * I migrated this blog [from Linode to S3+CloudFlare](/posts/migrating-blog-to-cloudfront/).
 * [I published the source of the blog](/posts/ten-years-behind-the-screen/).
 * My boss [convinced me to invest in Go rather than Perl](/posts/gophercon-2018/).

## Popular Posts

I don't have a good way to measure impressions of posts these days.  The best
I have is logs from CloudFront, which is behind CloudFlare.  I have, by and
by, improved the caching of my blog, so the numbers at CloudFront are not even
comparable over time.  With that in mind, I'll just link to the top five posts
for each of the three years I have data for, with a brief discussion for some.

### 2016

 1. [Install and Configure the MS ODBC Driver on
    Debian](/posts/install-and-configure-the-ms-odbc-driver-on-debian/) (2013) -
    It is astounding to me how popular this post is.  [I even wrote a new
    version](/posts/mssql-odbc-client-and-server-on-ubuntu/) that should be
    easier to follow, but it hasn't caught on.
 1. [Building Secure UserAgents](/posts/building-secure-useragents/)
 1. [Open Source Infrastructure and DBIx::Class Diagnostics
    Improvements](/posts/open-source-infrastructure-and-dbix-class-diagnostics-improvements/) -
    This post is always hard for me to read or look at.  What a mess.
 1. **[A visit to the Workshop: Hugo/Unix/Vim
    integration](/posts/hugo-unix-vim-integration/)** - I am incredibly proud
    of this post.  It was a lightbulb moment for me, and a pleasant return to
    SQL after wearing an ad-hoc hairshirt for so long.
 1. [Development with Docker](/posts/development-with-docker/)

### 2017

 1. Install and Configure the MS ODBC Driver on Debian
 1. [Perl, Linux Namespaces, and Pedestrian Problems](/posts/perl-linux-namespaces-and-pedestrian-problems/) (2016)
 1. [Gumbo v1](/posts/gumbo/) (2016) - I had no idea this was so popular!  I love gumbo and am glad to help people make it.
 1. [Email Threading for Professionals](/posts/email-threading-for-professionals/) (2016)
 1. [DIY Coffee Roasting and Coffee Setup](/posts/diy-coffee-roasting-and-coffee-setup/) (2016) - Another non-tech post, which pleases me.  Coffee!

### 2018

 1. Install and Configure the MS ODBC Driver on Debian
 1. [A Love Letter to Plain Text](/posts/a-love-letter-to-plain-text/) - This
    post is sort of a follow-up to the Workshop one above.  Still pleased with
    it, though I feel like I am having trouble expressing what I feel in my
    gut on this topic.
 1. [Go Concurrency Patterns](/posts/golang-concurrency-patterns)
 1. [Investigation: Why is SQS so slow?](/posts/investigation-why-sqs-slow/) (2017) - I forgot about this post!  Curl is so good.
 1. [GopherCon 2018](/posts/gophercon-2018)

### 2019

 1. [Ordering Green Coffee with Go and jq](/posts/ordering-green-coffee-with-golang-and-jq/) - What a fun post to be on top!  Coffee!
 1. Install and Configure the MS ODBC Driver on Debian
 1. [go/types package](/posts/go-types-package/)
 1. [DIY Seltzer, Club Soda, Soda, etc](/posts/diy-seltzer-club-soda/) (2016) - Another fun post to be so well read.  Who doesn't like seltzer?
 1. [Generics in Go, via Contracts](/posts/generics-in-golang/)

## This Post

So this isn't just a "clips episode," I figured I'd share the code I used to
get the above.  It's nothing amazing but it was fun to do.

Before I write any of this I want to say that I absolutely should have just
defined an Athena table first.  I am sure that this was both slower and more
expensive than using Athena for these reports.  Oh well.

First I downloaded all of my CloudFront logs:

```bash
$ aws s3 sync s3://logs.blog.afoolishmanifest.com/cloudfront/ cf/
```

That took like two hours.

Then I built up the following command to find popular posts in a given year:

```bash
$ find . | grep 2016- | xargs zcat | awk '{print $8}' |
           grep '/posts/' | sort | uniq -c | sort -n
```

I am sure I could have had `find(1)` do the filtering and also the running of
`zcat(1)` but I can never remember how to use `find` right, and this works
fine.

Here's the last few lines of that command's output:

```
   5349 /posts/open-source-infrastructure-and-dbix-class-diagnostics-improvements/
   5372 /posts/building-secure-useragents/
  11130 /posts/install-and-configure-the-ms-odbc-driver-on-debian/
```

That took like 30 seconds to run, so I automated the rest:

```bash
for year in 2016 2017 2018 2019; do
   echo "$year"
   find . | grep "\.$year-" | xargs zcat | awk '{print $8}' |
            grep '/posts/' | sort | uniq -c |
            sort -n > "../reports/$year.txt"
done
```

Finally, to get the actual values I cared about, I did this:

```bash
for f in 2016.txt 2017.txt 2018.txt 2019.txt; do
   echo $f
   cat $f | tail -5
done
```

(Useful use of cat if I do say so myself!)

---

I hope this was at least a little interesting to you.  I am pleased to have a
body of work that I can look back on and pin to various major life events, and
indeed be a little proud of.

---

(The following includes affiliate links.)

These books are non-technical but the kind of thing I'd like to be able to
put my name on one day.

<a target="_blank" href="https://www.amazon.com/gp/product/1550228587/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1550228587&linkCode=as2&tag=afoolishmanif-20&linkId=07417d77c5352ddbcd5353159171f092">Overqualified</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1550228587" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is a hilarious and painful novella about trying to find the right job.  I have
read it more than once and I think you should too.

<a target="_blank" href="https://www.amazon.com/gp/product/0826428991/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0826428991&linkCode=as2&tag=afoolishmanif-20&linkId=b29eaa123d216b0d1afe5a8f90b208bc">Master of Reality (33 1/3)</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0826428991" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
by John Darnielle is a book about an angry kid who found solace in Black Sabbath.
Not quite as funny as Overqualified, but still great.
