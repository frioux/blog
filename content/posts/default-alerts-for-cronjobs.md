---
title: Stupid Default Alerts for cronjobs
date: 2019-05-15T19:30:16
tags: [ zr, frew-warez, monitoring ] 
guid: f3784b5f-da8e-4b30-9fe2-1f124375a894
---
Today I whipped up an initial default set of cronjobs for all of our teams at
[ZipRecruiter](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology).  It was almost
trivial and will get most teams started on at least not-terrible alerting.
Neat.

<!--more-->

[I've written about cronjobs at ZR
before](/posts/categorically-solving-cronspam/).  The previous post (from a
little over a year ago) was more about subduing the crontab beast by replacing
the cron email alerting system with something driven by logs.  That was a huge
improvement.  We are moving to Kubernetes now and the email based alerting is
not an option for a couple of reasons:

 1. The CronJob thing in k8s doesn't automatically email based on output
 2. sometimes things in k8s will fail silently

The second reason above is actually true in *all* environments, but with static
virtual machines you can get things very reliable such that things almost never
fail.  This might sound like a good thing, but the actual result is complacency:
people assume that error logs (for example) will be sufficient.

Consider though, a configuration error that ends up meaning your cronjob never
ran at all.  When this happens you won't get an error, things will just not run
till someone notices.  This should make it clear that the *best* way to
monitor something is to actually monitor (and alert on) the *results* of what
you are doing, rather than exit code, error logs, or whatever else.

On the other hand, we (ZR) have over two hunderd "managed" cronjobs.  Managed
means they are automatically deployed to servers that match certain
characteristics and are owned by certain teams.  Because we have this huge
amount of cronjobs, we (my team) can do just a little bit of work to get better
monitoring of the jobs than just emailing on failure (either at failure time or
in a daily report.)

First we wrote a tool called `cr8s` (`cron` + `k8s`) that wraps all managed
cronjobs.  If a job is properly managed, `cr8s` will send two simple metrics to
a prometheus pushgateway on success:

 1. The duration of the job
 2. The unix timestamp when the job succeeded

Next we suggest that teams create prometheus alertrules like the following:

```
time() - cronjob_successful_completion_timestamp{job="my-cool-cronjob"} > 24 * 60 * 60
```

The above would trigger an alert if your cronjob has been failing for a full
day.

Finally, we generated a default set of alertrules for all of the managed
cronjobs.  The gist is that we parse the cron spec (with
`github.com/robfig/cron`), measure the duration between two events, and pick the
smallest duration in a given crontab.  That's the alert duration expressed above
for each crontab.  Here's the code:

```golang
func minimumDurationForCronjob(specParser cron.Parser, path string) (string, string, time.Duration, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", "", time.Duration(0), err
	}
	defer f.Close()

	s := bufio.NewScanner(f)

	var min time.Duration

	// 0   1      2             3   4   5
	// etc/cron.d/core-services/dev/act/run-list-log-files
	p := strings.Split(path, "/")
	if len(p) != 6 {
		return "", "", 0, fmt.Errorf("Wrong number of segments in path (%d)", len(p))
	}
	team := p[2]
	tab := p[5]

	for s.Scan() {
		l := s.Text()

		f := strings.Fields(l)

		if l == "" || strings.HasPrefix(l, "#") {
			continue
		} else if strings.HasPrefix(l, "@") {
			l = f[0]
		} else {
			if len(f) < 6 {
				continue
			}
			l = strings.Join(f[:5], " ")
		}

		sched, err := specParser.Parse(l)
		if err != nil {
			return "", "", 0, fmt.Errorf("coudln't parse %s: %s", s.Text(), err)
		}

		n1 := sched.Next(time.Now())
		n2 := sched.Next(n1)
		delta := n2.Sub(n1)
		if min == 0 || min > delta {
			min = delta
		}
	}

	return team, tab, min, nil
}
```

Then we just build a little template and create the alerts for all the jobs.  To
be clear this is a one time, very scrappy set of alerts.  These alerts *should*
be replaced with monitoring of results, as discussed above, but this should take
pressure off teams that are already busy with other infrastructure work being
put on their plates.

---

(The following includes affiliate links.)

If you enjoyed this post you might appreciate
<a target="_blank" href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=5157ec4156e15e73699ef549e1c56bad">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and likely also
<a target="_blank" href="https://www.amazon.com/gp/product/1492029505/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1492029505&linkCode=as2&tag=afoolishmanif-20&linkId=7b8b8777b19721fdfe8413072a3fda03">The SRE Workbook</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1492029505" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
