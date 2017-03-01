---
title: The Great S3 Outage of 2017
date: 2017-02-28T19:42:10
tags: [ aws, outage, ziprecruiter ]
guid: 0CCCA7D0-FE31-11E6-9C33-BD8A8AF70C31
---
At 9:36 am, Los Angeles time, my friend sent me a link about [GCE vs
AWS](https://thehftguy.com/2016/06/15/gce-vs-aws-in-2016-why-you-should-never-use-am).
It all went downhill from there.

<!--more-->

This is not an uncommon topic at work; I work with an ex-Google SRE and another
guy who uses GCE for all of his own personal stuff and I hear that GCE solidly
embodies "[the MIT
approach](https://en.wikipedia.org/wiki/Worse_is_better#The_MIT_approach)" while
AWS seems to go far enough beyond "[Worse is
Better](https://en.wikipedia.org/wiki/Worse_is_better#Description)" that AWS
approaches a [Chaos
Monkey](https://arstechnica.com/information-technology/2012/07/netflix-attacks-own-network-with-chaos-monkey-and-now-you-can-too/)
as a Service.

At the tail end of our conversation, less than ten minutes later, at 9:45:07 am,
I noticed a cronjob failing with the following error: (slightly reformatted)

```
ERROR: Could not access bucket elided.ziprecruiter.com:
ERROR: HTTPSConnectionPool(host='s3.amazonaws.com', port=443):
  Max retries exceeded with url: /elided.ziprecruiter.com/elided.txt (
    Caused by ConnectTimeoutError(
      <botocore.awsrequest.AWSHTTPSConnection object at 0x7f6f22ffcc50>,
      'Connection to s3.amazonaws.com timed out. (connect timeout=60)')
    )
```

Very quickly after that a discussion began in our slack channel dedicated to
production incidents.  Less than a minute after our failed cronjob, [someone
on HackerNews asked "is S3
down?"](https://news.ycombinator.com/item?id=13755673).

What followed was mostly my coworkers and I trying to figure out ways that we
could keep the website up while S3 was down.  The good news is that [as I've
already
written](https://blog.afoolishmanifesto.com/posts/reap-slow-and-bloated-plack-workers/)
we have tooling to keep certain slow requests from taking out the site.  It's
not foolproof but I am confident that without it we would have had a complete
outage after mere minutes.  We mostly cranked down the reaper to reap faster and
also patched in some lower timeouts for uploads to S3 that should be fast.  The
timeouts on S3 weren't there before because they hadn't ever really needed to
be.  Thanks Chaos Monkey!

Meanwhile the internet is aflame as S3 is down and a huge number of dependant
AWS services have gone down as well.  There's this sortav joke with AWS users
where [the AWS status page](http://status.aws.amazon.com/) is permantently green
and the most you ever get is a green check with a tiny little `i` on it implying
that a service is having trouble.  Here is an awesome tweet exemplifying the
feeling:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en"
dir="ltr">Amazon be like <a
href="https://t.co/2PkfjOEOzL">pic.twitter.com/2PkfjOEOzL</a></p>&mdash; Joe
Wegner (@Joe_Wegner) <a
href="https://twitter.com/Joe_Wegner/status/836659046081949697">February 28,
2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Probably the best moment was when Amazon had to tweet that, well, they couldn't
update those little green checkmarks... [because it was inexplicably tied to S3
hosting](https://twitter.com/awscloud/status/836656664635846656).

Another good moment was when the previously mentioned HackerNews post had a
comment by a person who (presumably) works at Y-Combinator saying that [their
**single-core server** couldn't handle the
load](https://news.ycombinator.com/item?id=13756819) that page was putting on
it.  I am not a person who uses HackerNews, but the general culture of
faddishness culminates in a message like that one.

"I wrote a commenting system in a weird version of lisp that I also wrote!
Neat!"

*(years pass)*

"**OH NO I forgot to make it production ready!!**"
