---
title: Mixer Post Mortem
date: 2020-05-13T07:51:57
tags: [ zr, frew-warez, testing, golang ]
guid: 5109fd68-66be-453f-84c7-590eec0208da
---

For about 13 minutes on Cinco de Mayo the Mixer had a near total outage.  The root
cause was a panic due to an out of range access of a slice.

<!--more-->

(This blog post is taken verbatim from our incident log.  I have only done very
light editing of the original vesion.  Hope you find it interesting.  TL;DR: testing
private interfaces along with trusting code coverage is a mistake.)

![woopsie doopsie](/static/img/2020-05-05-woops.png "Woopsie Doopsie")

## Story Time

The Mixer has a critical position (load bearing, you might say) in our
infrastructure, such that any total outage of the Mixer becomes a total outage
of impression engines, and thus placements, like our job pages or our search
pages.  With this in mind, the Mixer project puts a high priority on tests
specifically to surface the kinds of errors that caused this incident.  Why
didn't the tests actually help here?  That's what I want to write about.

Let's briefly touch on the feature I was building: the Mixer has an interface
to the search engine's pick_jobs endpoint that will run any number of queries
in parallel.  A small minority of placements do not actually want to do queries
in parallel, but instead want to do serial queries to allow falling back to
more general queries that return results when the specific queries return no
data.

The interface looks like this, with extra comments included to describe the
relevant parts:

```golang
type zrSEOCompanyDirp struct{}

func (d zrSEOCompanyDirp) name() string { return "zr_seo_company_dirp" }

func (d zrSEOCompanyDirp) input(i MultiSearchRequest) (MultiSearchRequest, error) {
	// ...

	// enabling serial on the MultiSearchRequest is what triggers this
	// serial codepath.
	i.serial = true

	return i, nil
}

func (d zrSEOCompanyDirp) output(r []Response) ([]Response, error) {
	// if the first request gets zero jobs back, try again
	if r[0].which == 0 && len(r[0].AllJobs) == 0 {
		return nil, errNeedMore
	}

	// if we're not on the first request, it's a backfill
	if r[0].which != 0 {
		r[0].IsBackfill = true
	}

	return r, nil
}
```

It's a little strange, but the interface works for the few that need it.  After
writing the code that supports the above, I started on the tests.  Most of
the Mixer's tests are "table driven" tests; that is, they are just data that is
evaluated in a loop.  This methodology allows rich tests without huge amounts
of setup.  Here are the tests I initially wrote to exercize the code above:

```golang
// ...
{
	name: "zr_seo_company_dirp: first request",
	request: tweakSearchRequest(PresentationZRSEOCompanyDirp, V0, func(r *MultiSearchRequest) {
		r.SearchRequests = []SearchRequest{
			{Limit: 1, PlacementID: placement.ZRSEOCompanyDirp},
			{Limit: 1, PlacementID: placement.ZRSEOCompanyDirp},
		}
	}),
	validResponse: func(t *testing.T, resp Response) {
		assert.Equal(t, 1, len(resp.AllJobs))
	},
},
{
	name: "zr_seo_company_dirp: backfill",
	request: tweakSearchRequest(PresentationZRSEOCompanyDirp, V0, func(r *MultiSearchRequest) {
		r.SearchRequests = []SearchRequest{
			{Limit: 0, PlacementID: placement.ZRSEOCompanyDirp},
			{Limit: 1, PlacementID: placement.ZRSEOCompanyDirp},
		}
	}),
	validResponse: func(t *testing.T, resp Response) {
		assert.Equal(t, 1, len(resp.AllJobs))
		assert.Equal(t, true, resp.IsBackfill)
	},
},
{
	name: "zr_seo_company_dirp: 500->502",
	request: tweakSearchRequest(PresentationZRSEOCompanyDirp, V0, func(r *MultiSearchRequest) {
		r.SearchRequests = []SearchRequest{{PlacementID: placement.ZRSEOCompanyDirp, Search: "not-json"}}
	}),
	message: `http error: couldn't deserialize error body; got: "{\"error\":\"couldn't talk to /pick_jobs: http error:"... (502)`,
},
```

These tests aren't great for a number of reasons, but I want to let them lie
while I talk about how they gave me false confidence.  In order to feel good
about our tests, the Mixer project policy is that we must have 89% test coverge
of statements in the project, and *100%* coverage of distillers.  The
`zrSEOCompanyDirp` type above is a distiller.  So I ran the tests, saw that I
had the requisite coverage, shipped the code to production, and took the whole
site down.

It turns out the tests above *do not actually test this line of code:*

```golang
		return nil, errNeedMore
```

Why did I have 100% test coverage?  Well in an effort to surface panics we have
a special test that passes weird data sets directly to all distillers.  The
entire point of those tests is to fail if the distiller itself triggers a
panic.  So the table driven test was only exercizing the happy paths of the
distiller, and the error paths were only ever being run by directly using the
distiller value, rather than while it was integrated with it's relevant
components.

My intention to surface possible panics actually hid real panics.  Fun.

Let's go back to the tests to see how I could have done better.  Here's the
first test, rendered as a diff.

```diff
 {
 	name: "zr_seo_company_dirp: first request",
 	request: tweakSearchRequest(PresentationZRSEOCompanyDirp, V0, func(r *MultiSearchRequest) {
 		r.SearchRequests = []SearchRequest{
-			// The fact that both of these requests are limited to 1 result
-			// means that the Equals assertion later *can't tell which one
-			// is being selected.* 🤦
-			{Limit: 1, PlacementID: placement.ZRSEOCompanyDirp},
-			{Limit: 1, PlacementID: placement.ZRSEOCompanyDirp},
+			// My instinct is that if you are going to use count to
+			// distinguish results, you should probably use primes.
+			{Limit: 13, PlacementID: placement.ZRSEOCompanyDirp},
+			{Limit: 7, PlacementID: placement.ZRSEOCompanyDirp},
 		}
 	}),
 	validResponse: func(t *testing.T, resp Response) {
-		assert.Equal(t, 1, len(resp.AllJobs))
+		assert.Equal(t, 13, len(resp.AllJobs))
+		// actually verify that the IsBackfill flag is false.
+		assert.Equal(t, false, resp.IsBackfill)
 	},
 },
```

The second test was wrong, but in a much more subtle way.  When fixing the code
for the test above, the second test (shown below) fails as commented:

```golang
{
	name: "zr_seo_company_dirp: backfill",
	request: tweakSearchRequest(PresentationZRSEOCompanyDirp, V0, func(r *MultiSearchRequest) {
		r.SearchRequests = []SearchRequest{
			{Limit: 0, PlacementID: placement.ZRSEOCompanyDirp},
			{Limit: 1, PlacementID: placement.ZRSEOCompanyDirp},
		}
	}),
	validResponse: func(t *testing.T, resp Response) {
		assert.Equal(t, 1, len(resp.AllJobs))  // fails with 25
		assert.Equal(t, true, resp.IsBackfill) // false with false
	},
},
```

Someone who knows a lot about Go *might* be able to guess the actual problem.
In the Mixer, we implement mock backends for all of the impression engines,
here's the Limit support for pickjobs:

```golang
if req.Limit != 0 {
	var res Response

	if err := json.Unmarshal(b, &res); err != nil {
		panic(err)
	}

	res.AllJobs = res.AllJobs[:req.Limit]
	for i := range res.AllJobs {
		res.AllJobs[i].ImpressionLogged = true
	}
	if err := json.MarshalToWriter(res, rw); err != nil {
		panic(err)
	}
	return
}
```

If it's not obvious, we only implement Limit when the value isn't zero, so the
zero length response is actually becoming the full, unlimited response!  The solution
to this was to (as we do with lots of the Mixer's pickjobs stuff) communicate via the Search parameter:

```diff
-if req.Limit != 0 {
+if req.Search == "trust-limit" {
```

With the above change (and setting Search to "trust-limit" in the tests) we
*finally* see the actual panic triggered by the unit tests.  Fixing that is actually
much less interesting, but for posterity there were three problems:

 1. I referenced the first element of the `[]Response` that came back from
    output, even though the slice is nil.
 2. I captured an error, logged it, but forgot to `return`, which caused
    confusing errors from the Mixer but did no clear harm.
 3. I left out a `break` to exit the loop early, meaning that even if the first
    request suceeded later requests would still be performed.

## Prevention

The main takeaway for me about this incident is that testing private interfaces
directly (like distillers) leads to false confidence.  The table driven tests
mentioned above actually only interact with Mixer through an actual http client, and
thus are more relevant tests.  If I can make testing arbitrary input to
distillers easier via table driven tests I will look into banning direct tests
of distillers entirely.

---

(Affiliate links below.)

I made a rule for myself that I have to link to two books in affiliate links
for new blog posts, as a kind of investment in this blog.  I can say that both
of these books are on topic and worth reading:

 * <a target="_blank" href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=9cac90c7795bc92c2ef0a2741ab77bac">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> 
 * <a target="_blank" href="https://www.amazon.com/gp/product/1492029505/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1492029505&linkCode=as2&tag=afoolishmanif-20&linkId=0d07413df4d2153777cdef3c8ca95f0c">The SRE Workbook</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1492029505" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

But here's the important bit: do not wait to read a book to start learning from
incidents.  Every time I deal with a production incident I strive to first
understand what happened, but then on top of that, how did that happen.
Consider thist post: very little is dedicated to the actual bug, and *much*
more is dedicated to how we could solve this entire category of bugs.  It takes
practice, so I'd suggest starting now.

If your production system is reliable, I'll bet your staging or dev environment
is less so, so you can glean learnings there.  Even everyday bugs have a larger
context in which they are possible; elimitating the possibility of bugs is much
better than fixing bugs.

Go and improve your context.
