---
title: Testing in Go
date: 2019-03-28T07:05:04
tags: [ golang, perl ]
guid: 71eba579-e65a-4662-945c-03baf06543c3
---
This weekend I wrote a bunch of "happy path" tests in Go.

<!--more-->

I've been writing tests alongside my own software for a long time.  When [I
started porting tools to
Go](/posts/benefits-using-golang-adhoc-code-leatherman/) I decided getting
something that would function was higher priority than quality, including tests,
documentation, and style.  I think that was the right call, but I've been
writing enough Go now that I'm circling back and at least writing basic tests so
that if I come across some weird bug I can hack in a test to fix it.

Tests in Go are far less important than they are in, for example, Perl, where
the lack of static typing necesarily means that compilation means less.  Sure,
`perl -c` is worth doing; you'll at least find out if you misspelled a variable,
but in Go the static types mean that, generally speaking, code that compiles,
works.

I still like to at least have basic tests, if only because it allows me to
iterate faster while implementing features.  If you are building something that
scrapes a webpage (which I do weirdly often) it's probably better to make a test
that starts with a copy-pasted version of the site you are scraping, rather than
hitting the real thing every time.  You will need to update your test when the
real site changes, but it's still nice to ensure that your test suite has
examples of all the weird edge cases you've run into.

Part of the interesting thing here, to me, is that Go ships with a package
specifically made for testing web applications.  Perl's de facto solution, on
the other hand, is Test::TCP, which can be a bit flaky.  I think the issue here
is that Go has engineers being paid to work on the standard library who have
leadership and momentum keeping the standard library of high quality.

Perl (and nearly all other Open Source languages, like Ruby, Python, PHP, etc)
just depends on volunteers to make good choices.  Frustrating stuff.

Here's [one of my
tests](https://github.com/frioux/leatherman/blob/c7515a4de1670b0de560716c0e4571ec4da952b0/pkg/sweetmarias/sm_test.go)
that works well and I think shows off a couple neat features of Go's test
harness:

```golang
func TestLoadCoffee(t *testing.T) {
	ts := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html")
		f, err := os.Open("./sm.html")
		if err != nil {
			panic(err)
		}
		_, err = io.Copy(w, f)
		if err != nil {
			panic(err)
		}
	}))
	defer ts.Close()

	c, err := LoadCoffee(ts.URL)
	if err != nil {
		t.Fatalf("Failed to LoadCoffee: %s", err)
	}

	assert.Equal(t, Coffee{
		Title:    "Papua New Guinea Honey Nebilyer Estate",
		Score:    86.6,
		URL:      ts.URL,

		// ...
	}, c)
}
```

The first cool thing you can see is the trivial creation of `ts`, a test http
server that can serve content for the client I'm testing.  Another convenience is
that I can trivially load content from disk because when testing a package `go
test` automatically runs the test harness in the package directory, where you
can put various bits of test data.

This example isn't even as good as it could get, but I'm trying to first
increase coverage before adding various test cases.  If you write Go and want to
get better at testing, I strongly recommend watching [Mitchell Hashimoto's
Advanced Testing with Go](https://www.youtube.com/watch?v=8hQG7QlcLBk).

If you watch that talk you'll see really powerful examples where, for example,
in a single function he creates both a client and server socket for use in
tests.  This is something I would never have considered doing in any other
language.  Maybe it's because in other languages people were more willing to
just test protocols without the socket objects.

In any case I am inspired to try writing more tests with greater coverage for my
Go.

---

(The following includes affiliate links.)

I mentioned both of these books yesterday, but it bears repeating: if you want
to learn Go or improve your testing in Go, both 
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
are good options.
