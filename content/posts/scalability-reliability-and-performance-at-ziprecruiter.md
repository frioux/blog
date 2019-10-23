---
title: Scalablity, Reliability, and Performance at ZipRecruiter
date: 2017-07-05T07:31:13
tags: [ yapc, ziprecruiter, perl ]
guid: E24DE4CC-5FF3-11E7-950A-C020B2E056DD
---
I did a talk at [YAPC][yapc] this year, and while I am really proud of it and
think that it went well, I think it could have gone better.  This post is a
retrospective on what I could do better next time.

<!--more-->

Before you start reading, if you haven't already, you should [watch the
talk][talk].  [The slides are here][slides].

The overall structure of the talk was the general (starting with no silver
bullet) to the specific (ending with a discussion of our bakeoff and what we
will tackle next.)  It might have made more sense to interleave the two, but
it's hard to say.

I wish I had emphasized the no silver bullet point harder, but I don't want
people to think that this is impossible, just that there are no prescriptions
that will work for everyone.

Now on to the specifics.

## Capacity Caches

I didn't define Capacity Caches well enough in the talk.  Afterwards I realized
this and I should not have used a no-true-scottsman to define the term, but so
it goes.  For the record, I would define a capacity cache today as a cache that
allows you to serve more users, as opposed to a (latency) cache that allows you
to serve the same number of users faster.  The tricky bit is that the latter can
silently transform into the former if you don't keep an eye on it.

Someone (Henry Vanstyn I think) asked if we had had an outage due to this and
while we had not, I didn't realize till after the fact that we *did* have a
slowdown.  I think I should have had examples prepared.

## Timeouts / Reapers

I felt like this section of the talk went really well.  I am especially pleased
with the "wow" moment from when I showed the reaper report for the S3 outage.
The one major improvement I would make to this, and my main regret for the talk
as a whole, was that while the application of this advice to ZR, Booking, and
maybe GSG is clear, it is *not* clear how it can apply to smaller applications.

I think I should have explained that a reaper could be made to work even in a
single server situation and indeed in that situation may even be more critical.
I did in fact explain this to some friends when we discussed how my talk went,
but that idea should come with the talk.

The other nuance that I didn't explain, which only barely belongs in the talk,
is that while reaping and timeouts sound scary, ultimately you are foolish not
to implement a really generous one at the minimum, because the client will
eventually time out.  So while you may think "but the user has been waiting five
minutes!" really their browser probably gave up two minutes ago and you are just
wasting resources.

## Aurora

There were a lot of details I didn't go into related to Aurora, and I think
that's ok.  As I said at the beginning of the talk, I didn't want to dive into a
bunch of detail no one cares about.  I left out the cruel irony about how Aurora
is implemented in such a way that at it's heart is a capacity cache that is
insufficient for ZipRecruiter.  I maybe shouldn't have left that out.

## RWSplitter

I wish I had blogged about the splitter ahead of time, if only to be sure to
have lots of details to refer to like I can for some of the other topics.  I am
planning on blogging about it soon anyway if only so that people can learn more
later.

I also somewhat wish that I mentioned that the splitter sometimes feels like a
capacity cache in that bugs are introduced and we don't notice very easily.
I'll save in depth discussion of that for the blog post.

## Table Refactor

This information I think was mostly useful in demonstrating the different values
of a small and large application.  With a small team and stack that must be on
one or two servers, using lots of different software is a liability, but in our
case depending on a single service for lots of different workloads is also a
liability.

## Performance Monitoring

I don't feel thrilled about this section of the talk even though I am really
proud of this monitoring.  I think I should have, just like with the reaper,
explained how a small application could implement this without all of the
incredible overhead of ElasticSearch, fluentd, and Kibana.  In short: if you
were to simply log json and then build a small frontend, or even just use
[jq][jq], you could have a lot of the benefits that we got with almost none of
the pain.

## Memory Work

I thought that I was clear enough here, but afterwards Jim Keenan approached me
and asked if I would be willing to clarify our issues to the Perl maintainers in
the hopes that the issues could be resolved or even just improved.  I will do
that and to some extent wish I had reached out sooner.  We'll see what happens
though; I am hopeful but do not have any expectations.

## nginx vs Apache

There's not a lot to say here.  I thought this went perfectly fine and was
applicable to almost everyone there.

## Bakeoff

I didn't have much time to prepare for this slide, and in fact only added it
shortly before the talk because the bakeoff concluded while I was travelling to
YAPC.  I should have included some of the statistics from the actual bakeoff but
really, the point is not what was faster, but what engineers could make fast on
their own.

---

I am more proud of this talk than any of the others I have done.  Aside from my
[AWS IAM][iam] talk which I only gave to [LA.pm][lapm] it is one of the only
talks I've done in recent memory that is not only cross-language but also not
about a specific library.  While it could have been improved greatly with some
of the ideas above, I still think it went really well.

---

(The following includes affiliate links.)

If you want to be a better big systems engineer (like the stuff above) I
recommend the <a target="_blank"
href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=4b86e6727c75c8f819664e07f5fdf970">Site
Reliability Engineering</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" /> book by "Google."  Some parts of it are frustrating in the
almost posturing academic style, but there are some *great* gems that make it
worth the slog.

Not specifically related to this talk but related to my job I recently picked up
<a target="_blank" href="https://www.amazon.com/gp/product/1593272200/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593272200&linkCode=as2&tag=afoolishmanif-20&linkId=efa24a0d6cd5c7b06e9f62b129b1da79">The Linux Programming Interface</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593272200" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I felt like I needed to fill in some blanks, and this book looked to be the best
tool for the job.  My only complaint is that a lot has happened in the
intervening seven years and I would have liked to get an improved foundation for
`cgroups` and `namespaces`; neither appear in the index.

I wish I had some resources to recommend regarding preparing and delivering
talks.  I have been doing it for over a decade so my advice is likely to be as
unhelpful as a FAQ written by a veteran user.  If there is a resource I *should*
know about, please point me to it; I am happy to improve.

[yapc]: http://www.perlconference.us/tpc-2017-dc/
[talk]: https://www.youtube.com/watch?v=WHKQ2JfTaIM
[slides]: https://frioux.github.io/srp-at-zip/
[jq]: https://stedolan.github.io/jq/
[iam]: /posts/aws-iam-at-ziprecruiter/
[lapm]: http://losangeles.pm.org/
