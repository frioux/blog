---
title: Log Loss Detection
date: 2018-07-25T20:25:08
tags: [ perl, programming, cpan, logging, ziprecruiter ]
guid: 7a57f8fb-152c-472f-867f-01aa309c9ced
---
We spent hours debugging a logging issue Friday and Monday.  If you use UUIDs in
Perl, you should read this post.

<!--more-->

I've been working on a logging overhaul at
[ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) for more than six
months.  I intend to post a retrospective soon, but there are still some
unknowns that mean I don't actually know that we're there yet.

One of the features of our logging system is built in Log Loss Detection.
Logs at ZipRecruiter are a JSON doc per line.  Logs that are not a JSON doc end
up getting discarded, basically.  If an application wants log loss detection
the application needs to add two fields:

 * `script_exec_id`
 * `script_exec_nth`

`script_exec_id` is meant to be unique for each running application.  There is
nuance there that I will get into after defining `script_exec_nth`.

`script_exec_nth` is meant to be a monotonically increasing integer, starting at
`1` when the application starts.

There are basically two ways to implement this.  For unthreaded languages (at ZR
this means Perl and Python) you generate a new `script_exec_id` when your pid
changes due to a fork and reset `script_exec_nth` to 1.  For threaded languages
(at ZR this means Go and Java) you can have a single `script_exec_id` and use an
atomic increment.

The result is that you have a lot of log lines like this (only a few values
shown here):

```JSON
{"script_exec_id":"a","script_exec_nth":1,"message":"foo"}
{"script_exec_id":"b","script_exec_nth":1,"message":"bar"}
{"script_exec_id":"a","script_exec_nth":2,"message":"xyzzy"}
{"script_exec_id":"b","script_exec_nth":2,"message":"baz"}
{"script_exec_id":"a","script_exec_nth":3,"message":"biff"}
{"script_exec_id":"b","script_exec_nth":3,"message":"bong"}
```

Once the logs have gotten all the way to S3 we can use
[Athena](/posts/using-amazon-athena-from-perl/) to find log
loss:

```SQL
WITH a AS (
SELECT json_extract_scalar(record, '$.script_exec_id') AS uuid,
       json_extract_scalar(record, '$.script_exec_nth') AS nth
  FROM core.prod_unified_logs
  WHERE log_date = 20180725 AND log_hour = 1
)
SELECT uuid, MAX(nth) - MIN(nth) + 1 AS expected_count, COUNT(nth) AS actual_count,
       MAX(nth) - MIN(nth) + 1 - COUNT(nth) AS loss_count
FROM a
GROUP BY 1
HAVING MAX(nth) - MIN(nth) + 1 <> COUNT(nth)
```

This query will return a `uuid`, an `expected_count`, an `actual_count`, and a
`loss_count`.  The actual query is more complicated to assist debugging when
this happens, but this is the gist of it.

The biggest issue we found when we rolled this out was totally ridiculous
`loss_count`s; specifically stratospherically many, or negative numbers.  I dug
into both situations by finding logs that still existed on the original hosts
and examining them, just in case the loss actually occurred in the pipeline.
They were both basically the same issue.  Here's how you get negative numbers
(`-3` in this case):

```JSON
{"script_exec_id":"a","script_exec_nth":1,"message":"foo"}
{"script_exec_id":"a","script_exec_nth":1,"message":"bar"}
{"script_exec_id":"a","script_exec_nth":2,"message":"xyzzy"}
{"script_exec_id":"a","script_exec_nth":2,"message":"baz"}
{"script_exec_id":"a","script_exec_nth":3,"message":"biff"}
{"script_exec_id":"a","script_exec_nth":3,"message":"bong"}
```

So the max is 3, the min is 1, and the total is 6; `3 - 1 + 1 - 6 == -3`.

The above happens if a process forks but for some reason the `script_exec_id`
doesn't change.  Given the same intution, imagine a process that logs very
slowly logging at the same time a process logs quickly.  You might see an hour
window like this:

```JSON
{"script_exec_id":"a","script_exec_nth":1000,"message":"fast logger"}
{"script_exec_id":"a","script_exec_nth":1001,"message":"fast logger"}
...
{"script_exec_id":"a","script_exec_nth":5000,"message":"fast logger"}
{"script_exec_id":"a","script_exec_nth":3,"message":"slow logger"}
```

The max is 5000, the min is 3, the total is 4001; `5000 - 3 + 1 - 4001 == 997`

---

How did we get the duplicate UUIDs?  We read the code carefully and found no
leads.  I spent a lot of time tracking down [this
bug](https://bugzilla.redhat.com/show_bug.cgi?id=1443976).  The short version is
that sometimes glibc caches the results `getpid` and if you bypass syscalls like
`fork` the cache will not get blown.  I tried to find patterns around this
theory, failed, and ended up ignoring it over the weekend.

On Monday my coworker Jeff Moore and I discussed this and it became clear that
it couldn't be the `getpid` being cached, because the pid *was* changing in
other parts of the log line, the `script_exec_nth` *was* getting reset, *just*
the `script_exec_id` was wrong.

Early on I checked to see that the UUID library we were using
[`Data::UUID`](https://metacpan.org/pod/Data::UUID)
didn't immediately produce duplicates:

```bash
$ perl -MData::UUID -E'$u = Data::UUID->new(); fork; say $u->create_str'
3171F728-9090-11E8-AFD5-0ADC68237998
3171FA5C-9090-11E8-9481-0ADC68237998
```

It didn't, but after seeing such evidence, I had to try harder:

```bash
$ perl -MData::UUID -E'$u = Data::UUID->new(); my $parent = $$; $parent == $$ && fork for 1..shift; say $u->create_str' 1000 | sort | uniq -c | grep -v '^\s*1\s'
      2 AE3B7A18-9090-11E8-95F3-3BEC68237998
      2 AE426800-9090-11E8-AAFA-3BEC68237998
      2 AE429604-9090-11E8-AFED-3BEC68237998
      2 AE44C10E-9090-11E8-BEA1-3BEC68237998
      2 AE44CF5A-9090-11E8-B866-3BEC68237998
      2 AE458990-9090-11E8-A8ED-3BEC68237998
      2 AE4C9D3E-9090-11E8-B8E3-3BEC68237998
      2 AE4CC5D4-9090-11E8-BE7D-3BEC68237998
      2 AE4CCFCA-9090-11E8-9268-3BEC68237998
```

Bingo.  I was able to reproduce this on VMs in EC2, on my laptop, friends
reproduced it on OSX, and Windows.  I did a quick search and found
[`Data::UUID::LibUUID`](https://metacpan.org/pod/Data::UUID::LibUUID) and
verified that it did not have this issue with
either of the supported UUID versions.  After the code was deployed we verified
that the issues above were resolved, and they were.

---

I've thought about the implications of this bug quite a bit.  Initially I
assumed that I simply hadn't read the docs for `Data::UUID` carefully enough.
Here's a line from the official docs:

> The algorithm provides reasonably efficient and reliable framework for
> generating UUIDs and supports fairly high allocation rates -- 10 million per
> second per machine -- and therefore is suitable for identifying both extremely
> short-lived and very persistent objects on a given system as well as across
> the network.

On top of that, `Data::UUID` and `Data::GUID` (which is based on the former,)
are incredibly popular and thus are de facto standards.  In any case I suggest
that if your UUIDs need to be unique (and they almost surely do) you use
`Data::UUID::LibUUID`, or maybe something else.

We are still iterating on the log loss found by this system.  Most loss we have
found so far is at the logger level, not the pipeline level.  A really nice
side-effect of this system is that when you find yourself in the place to be
investigating log loss you can run this simple oneliner to see the gaps:

``` bash
$ diff <(grep -Fh $UUID whatever.log | jq .script_exec_nth | sort -n) <(seq  1 4578')
471a472
> 900
472a474,475
> 902
```

The above implies that the records for line 900 and 902 are missing.  Note that
the requirement of `sort -n` implies a bug in our logging framework which means
we see some phantom loss that disappears when we increase the amount of time we
look at.

---

This log loss metric, while requiring a lot of work at many levels, is so
valuable.  It lets us detect that loss has occurred before the logs have rolled
off the box and we can get the logs off (if they ever existed in the first
place) and figure out what's going wrong.

---

(The following includes affiliate links.)

The first book I'd suggest to dig deeper on this topic would be
<a target="_blank" href="https://www.amazon.com/gp/product/B01DCPXKZ6/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B01DCPXKZ6&linkCode=as2&tag=afoolishmanif-20&linkId=726913b220882e92501a012766cf81a6">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B01DCPXKZ6" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It can be a bit "Googly" in that it goes into far too much detail in some
places, with far too little in other places, but it can be a source for
inspiration.

I don't know what else will help learn how to do this.  I'm reading
<a target="_blank" href="https://www.amazon.com/gp/product/0544716949/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0544716949&linkCode=as2&tag=afoolishmanif-20&linkId=a98c88495274c5b6422110a8ff09a4a1">A Crack in Creation</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0544716949" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
right now and it's really interesting.  This topic (gene editing) will certainly
become more and more relevant.
