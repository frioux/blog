---
title: Prometheus Conveniences
date: 2019-04-10T19:00:16
tags: [ prometheus, ziprecruiter ]
guid: 52ca6e00-8297-4d02-8baa-087ab72a8251
---
At [ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) we are working
towards migrating to a Prometheus as a more modern monitoring solution.  I have
found it pretty pleasant, so far.

<!--more-->

Prometheus is a monitoring and alerting tool (or maybe more a suite of tools.)
Since I've been at ZR we've used a combination of Icinga (to periodically poll
things) and statsd (one of the older TSDBs) for alerting.  Testing the old setup
was frustrating since the software is complicated managed by even more
complicated software.  I don't really want to get into how they work so I'll
just discuss how Prometheus works.

For starters, if you are writing a threaded language, like Go or Java, you
expose the metrics you would to Prometheus over an HTTP handler.  If you want to
verify that your metrics are being exposed as you intend you either point your
web browser (or `curl`) at `http://localhost:8080/metrics`.  Already this is
great; in the past we had engineers implement a variety of ways to capture the
stats that our apps would send so that they could ensure things were working as
intended.

If you are using a process oriented language, like Perl or Python, you have more
work to do.  Chances are you will use either `statsd_exporter` or maybe the
Prometheus pushgateway.  I haven't interacted with those as much myself, but I
am aware of how they run and again, they are trivial to run locally so you can
play with them and get comfortable with how things are functioning.

Next you probably want to experiment with writing alerts.  There are two ways to
do this; the first, which I would suggest, is to just run Prometheus locally,
scraping your app, and experimenting with alertrules directly.  It's a single go
tool with a basic web interface that you can use to see how things are
functioning.  If you want to do something more complex or you don't want to
somehow break your app to see your alerts fire, you can use `promtool`, which
ships with Prometheus, to test various inputs to queries to ensure that they
would fire as intended.

It's interesting to me that in this world where things are migrating to HTTP/2,
where nothing is simple anymore, that such a simple monitoring system is
flourishing.  I for one find it refreshing.

I hope to write about our automation around deploying new alertrules soon, but
even before we get there I am very pleased with how this is shaping up.

---

If you want to learn more about prometheus, you might check out
<a target="_blank" href="https://www.amazon.com/gp/product/1492034142/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1492034142&linkCode=as2&tag=afoolishmanif-20&linkId=278532d1c97806594ebd0c4fcfa13ac0">Prometheus: Up &amp; Running</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1492034142" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.

Another option, which I have only glanced at so far, is
<a target="_blank" href="https://www.amazon.com/gp/product/B07DPH8MN9/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B07DPH8MN9&linkCode=as2&tag=afoolishmanif-20&linkId=2b4f2f0a6875da783935182c302d73c5">Monitoring with Prometheus</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B07DPH8MN9" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.

I have only spent a little time glancing at these two books and both of them
have good stuff in them.
