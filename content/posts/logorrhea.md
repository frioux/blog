---
title: Logorrhea
date: 2020-09-21T08:08:28
tags: [ "golang", "logging", "docker", "kubernetes" ]
guid: 0785bd72-454e-4566-ae4f-19c5d9b1042d
---
I was part of a convergence of changes that ended up causing us to lose 30% of
important logs.  The full investigation involved application, log pipeline, and
Kubernetes integration. *Read how it happened.*

<!--more-->

(If this is too much for you, skip to [the takeaway](#the-takeaway) and read
much less.)

At ZipRecruiter we use logs to record important business metrics.  For example,
we emit a log line when a job seeker applies to a job.  That log line can be
consumed (almost) realtime from Kafka, or offline from our S3 hosted data lake.

On Sunday, 31, May 2020, shortly before we put our kids down for nap, an
analyst mentioned that he noticed a significant (~30%) reduction in log
volume from my service.  He couldn't make heads or tails of it and asked if I
could take a look.

Once the boys were down I started to investigate.  It was an effective
distraction from the helicopters, protesting, and eventual rioting going on
only four blocks from my apartment.

That whole day (and part of the following day) [I used Athena and SQLite to
analyze the logs](#sql-to-investigate-logs).  In the end I found no pattern other
than some scant log loss.

The most typical cause of log loss is emitting non-json interleaved with json,
which would implicate something in my service.  I checked for that and found no
evidence that it had been happening.

One of the product people who were pitching in while I was digging asked if
this reduction in records could be organic.  There were helicopters!  People
were legit rioting!  Also COVID-19 had sent people home in the prior two weeks.
Did the civil unrest really reduce our traffic by 30%?

My assumption was that we were legitimately losing logs, it was not caused by a
simple bug affecting the data, but instead a systemic bug in either the logging
library or the logging infrastructure itself (which has for years been
incredibly resilient.)

At some point [Aaron](https://www.aaronhopkins.com/) looked at the rate at
which we were logging.  We built our logging pipeline to support up to 10
megabytes logged per second.  This thing was logging *50 megabytes per second.*
Yikes.

---

Let me take a this opportunity to explain the interface to our logging system,
along with some details about how that's implemented.  The interface is
deceptively simple:

 * Applications log to standard out and standard error
 * The logs must be JSON

Logs are intended to be available to engineers within a few minutes (but
often are available within seconds.)

The implementation (at least the very beginning of it) is that we have a
program called `tsar` that works as both a supervisor and log capturer.  It
captures the logs and wraps them in JSON if it needs to.  It sets the pipe
buffer size on stdout and stderr so our logs can be atomically written for our
required size (1 megabyte.)

That then reëmits the logs, but serially such that they will never be
interleaved.  As it stands today, Docker captures those and writes them to disk
in configurably sized chunks before starting to write to a new file.  It deletes
the old files after there are too many other files, again configurably.

Another tool, `filebeat`, picks up the files as they are written to and streams
the files up to kafka.  `filebeat` notices writes via `inotify` and keeps the
files open, so in theory you can never lose data.

The problem is, it only checks for *new files* every so often (maybe every 20
seconds.)  I don't recall the exact numbers, but basically the size of the
files docker was writing were something like 100 Megs, and it would keep up to
five around.  So we were writing 50 megs per second to 100 megabyte files and
only keep five of them.  In total this means we buffer a mere 10 seconds of
logs on disk in this situation.

Yikes.

---

This was worsened when Aaron had made the application that was logging more
efficient, and packed it into fewer containers with more cores.  Instead of
before, running (something like) 20 two cpu containers (each theoretically
logging 25 megs per second) we were now running 10 four cpu containers, now
logging the extreme 50 megs per second.  Ok so fine, we revert this efficiency
change, increase the file size docker uses to buffer logs, and move on.

---

A few days pass and someone on the analytics team says: "fREW, we are logging
records that we shouldn't be for X."  This is not unusual; it's a new project,
mistakes are made and we fix them and move on.  The odd detail here is that I
had *explicitly* written code to handle this case, because we knew these
records were worthless.

Here's the buggy code:

```golang
		switch distiller.(type) {
		case theCoolAPI:
			/* HEY */ pjResp.AllJobs[i].ImpressionLogged = /* HEY */ true // IF SOMEONE COPY PASTES THIS CODE I'LL FIND YOU.
		default:
```

Here's the fix:

```golang
		switch distiller.(type) {
		case *theCoolAPI:
			/* HEY */ pjResp.AllJobs[i].ImpressionLogged = /* HEY */ true // IF SOMEONE COPY PASTES THIS CODE I'LL FIND YOU.
		default:
```

Did you catch that?  It's *a single character fix.*  The problem is, the
`distiller` value could be implemented by either a `theCoolAPI` value or a
pointer to it (`*theCoolAPI`.)  Worse: it had worked previously, but in
the course of regular changes, because we needed to start mutating a value, I
replaced what actually used to be a `theCoolAPI` value with a pointer to one.

Gracious.  So I fix this, but this time [I wrote a test, to ensure that this
very subtle behavior will not regress.](#test-to-validate-the-fix)


I rolled it out with a sneaking suspicion, wait a few hours, and check our log
rate.

Before the change: 50 megabytes per second, after the change **five megabytes
per second.**  We knew these records were high volume and low value, but of
course we never really considered how high volume they were before.  Nearly
*ten times the rest of the volume of the system.*

---

This was such a frustrating incident.  To fix it we needed to rope in high
level app devs, low level system people who worked on the logging pipeline, and
lower level people who knew how we'd integrated the pipeline with kubernetes.
And that wasn't even the "real" root cause!  The fundamental issue was that
a type assertion in Go was subtly wrong.

## The Takeaway

To me this emphasizes one specific idea and one general idea.

The specific idea is, when you are doing type assertions in Go, you really
should have a test that validates that it is correct.  Frustratingly, errors
are checked via type assertions and can be incredibly difficult to trigger in a
test.  Also: if you injected the error via a mock, you are not actually testing
the codepath that you should be checking.  *angst*

The general idea is: root causes are fractal.  It would be nice if there were a
single issue here, but real production incidents are almost never that simple.
These complex systems, both social and technical, fail in more ways than you
will ever guess.  I am regularly rewarded by diving deeper, or fixing the issue
"a layer lower" to categorically solve issues.

---

(Much thanks to [David Golden](https://xdg.me/), [Matthew
Horsfall](http://hiddenrealms.org/), [Rob Hoelz](https://hoelz.ro/), [John
Anderson](https://genehack.org/), and [Kevin
O'Neal](https://twitter.com/scuilion) for review of this post.)

---

I think <a target="_blank" href="https://www.amazon.com/gp/product/1492029505/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1492029505&linkCode=as2&tag=afoolishmanif-20&linkId=00cf11fe356cdbbd398f492d25736e7b">The Site Reliability Workbook</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1492029505" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
gives a description of this kind of incident analysis can be done.  It's a good
book, but really, the best teacher is practice.  If you want to dig deeper when
it matters, exercise your skill by digging deeper in non-emergency incidents.

To learn more about Go I suspect I'll forever recommend
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=9ce3dc1667339e430d3b8a4b515b0420">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I found it a good overview of the language that equipped me to write
solid production code.

## Appendices

### SQL to Investigate Logs

There is a lot of data here; so much that two days of data (which I am
analyzing below) wouldn't even fit on my laptop (about 22 gigs per day.)

I started off by running an Athena query to get a small subset of the logs I
could look at in more depth:

```sql
SELECT *
  FROM data_logs
 WHERE log_date = 20200529 and
       placement_id = 37864 and
       to_hex(md5(to_utf8(impression_set_id))) LIKE '%FF'
```

In the above query, I hash `impression_set_id` with md5 and then use `LIKE
'%FF'` to get a 256th of it.

I changed the date to `20200501` to compare to a working subset as well.

I downloaded the results from Athena as CSV into sensibly named files.  That
gave me a pleasantly small (~88 megs) dataset to work with.  I then used SQLite
to dig into that data:

```
create table old("actual_daily_spend_millicents","bid_millicents","campaign_id","engine_cargo","engine_id","expected_daily_spend_millicents","impression_id","is_predicted_giveaway","is_tracking_daily_spend","job_id","outer_request_id","placement_buyer_rules_uri","placement_cargo","placement_id","request_id","sort_position","target_daily_spend_millicents","viewer_id","viewer_property_id","log_timestamp_string","load_timestamp_utc","jobs_skipped","impression_set_id","impression_superset_id","built_for_viewer_id","built_for_viewer_realm","listing_key","listing_version","buyer_bid_millicents","log_date");
.mode csv
.import 2020-05-01.csv old
create table new("actual_daily_spend_millicents","bid_millicents","campaign_id","engine_cargo","engine_id","expected_daily_spend_millicents","impression_id","is_predicted_giveaway","is_tracking_daily_spend","job_id","outer_request_id","placement_buyer_rules_uri","placement_cargo","placement_id","request_id","sort_position","target_daily_spend_millicents","viewer_id","viewer_property_id","log_timestamp_string","load_timestamp_utc","jobs_skipped","impression_set_id","impression_superset_id","built_for_viewer_id","built_for_viewer_realm","listing_key","listing_version","buyer_bid_millicents","log_date");
.import 2020-05-29.csv new
```

I verified our initial observations:

```
sqlite> select count(*) from (select DISTINCT(impression_set_id) FROM old);
1128
sqlite> select count(*) from (select DISTINCT(impression_set_id) FROM new);
758
```

My first instinct was that somehow we were filtering the data that was
being logged, so I made a scrappy histogram of the sets of data:

```
sqlite> select c from (select COUNT(*) AS c FROM old group by impression_set_id) order by c LIMIT 1 OFFSET cast(0.5*1128 as int);
59
sqlite> select c from (select COUNT(*) AS c FROM old group by impression_set_id) order by c LIMIT 1 OFFSET cast(0.25*1128 as int);
56
sqlite> select c from (select COUNT(*) AS c FROM old group by impression_set_id) order by c LIMIT 1 OFFSET cast(0.10*1128 as int);
19
```

```
sqlite> select c from (select COUNT(*) AS c FROM new group by impression_set_id) order by c LIMIT 1 OFFSET cast(0.5*758 as int);
59
sqlite> select c from (select COUNT(*) AS c FROM new group by impression_set_id) order by c LIMIT 1 OFFSET cast(0.25*758 as int);
47
sqlite> select c from (select COUNT(*) AS c FROM new group by impression_set_id) order by c LIMIT 1 OFFSET cast(0.10*758 as int);
12
```

Ok so that's... something.  Let's look for gaps:

```
sqlite> select COUNT(*), impression_set_id,sort_position FROM new GROUP BY impression_set_id HAVING COUNT(*) != MAX(cast(sort_position as INT));
46,CFRAY:59frewwashere03b-IAD,59
sqlite> select COUNT(*), impression_set_id,sort_position FROM old GROUP BY impression_set_id HAVING COUNT(*) != MAX(cast(sort_position as INT));
sqlite>
```

(The cast above is required because I didn't put types on any of the values in the SQLite schema.)

So we found a single gap.  That's something, but it's not much.  To get more
information I ran the same Athena query, but with `LIKE '%F'` to increase my
data set by a factor of 16.

After getting a bigger data set, I was able to show that I had 40x the loss in
the larger data set.  Still only 0.2% loss though, not 30%.

### Test to Validate the Fix

When writing tests I strive to use the most public interface possible; in this
case that's the actual HTTP API of my project.  [I suggest reading a previous
post mortem to understand why.](/posts/mixer-post-mortem/)  Comments describing
the test below are inline.

```golang
func TestSupressedImpressionLogging(t *testing.T) {
	t.Parallel()

	// create an ephemeral server listening on a random http port, this
	// also creates a client pointing at said server, and all the other stuff
	// the server needs to function
	env := setup(setupConfig{})
	defer env.teardown()

	// validSearchRequest returns an object we can pass to PickJobs, and `theCoolAPI`
	// ensures that we are hitting the endpoint that should not log.
	resp, err := env.cl.PickJobs(context.TODO(), validSearchRequest(theCoolAPI, V0))
	if err != nil {
		t.Errorf("Failed to search: %s", err)
		return
	}
	if len(resp.AllJobs) == 0 {
		t.Fatalf("no jobs in response, test invalid")
	}

	// because we created the ephemeral server, we pass in our own in-memory logger
	// rather than logging to stdout.  This way we can actually parse the logs and
	// validate that they are correct.
	s := bufio.NewScanner(env.testlog.buf)
	for s.Scan() {
		type impression struct {
			Tag  string `json:"@tag"`
			Data *unifiedimpression.Data
		}
		var v impression
		if err := json.Unmarshal(s.Bytes(), &v); err != nil {
			panic(err)
		}

		if v.Tag == "data.unified.impression" {
			t.Error("impressions should not be logged")
			return
		}
	}
}
```


