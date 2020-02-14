---
title: Testing Perl Clients and Go Servers
date: 2020-02-14T08:51:49
tags: [ perl, golang, testing ]
guid: 21c9d379-8ce3-4673-954a-fbdc7de56a80
---
[At work](https://www.ziprecruiter.com/hiring/technology) I recently built what
would normally be forced to be an integration test in a unit test.  It's
awesome.

<!--more-->

The project I'm working on has a lower tolerance than most for mistakes, so I'm
leaning hard on automated testing.  For the most part, testing in Go is both
straightforward and easy.  There exists lots of good built-in tooling to run
tests, get coverage, etc.

The first non-Go code I wrote for this project is a Perl client to access the
server.  Writing a Perl web client is cake but I wanted to at least exercise
some basic bits of the code.  Since I already have infrastructure for the Go
tests, I though, "why not just have the Perl client access the Go server in a
test?"

Here's the code I have for the Go test, with extra comments for clarity:

```golang
// TestPerlClient runs the perl tests as a child process.  This should be run with
// -count=1, since caching needs to be disabled.
func TestPerlClient(t *testing.T) {
	// setup returns a special struct just for tests, after starting up the
	// actual server at a test port.
	env := setup()

	// for non-Go programmers, defer is used to run some code when the
	// current function completes; this would be a destructor in languages
	// that have reference counting.
	defer env.teardown()

	os.Setenv("TEST_MIXER", env.hostname)

	// run the actual perl test.
	cmd := exec.Command("perl",
		// tests are run in their current package dir, hence the slightly odd paths
		"-I../../../../app/lib", "-MZR::Lib",
		"-I../Foo-Client/lib",
		"../Foo-Client/t/client.t",
	)

	// capture and relay output, emitting failure on errors.
	out, err := cmd.CombinedOutput()
	s := bufio.NewScanner(bytes.NewReader(out))
	for s.Scan() {
		t.Logf("perl> %s", s.Text())
	}
	if s.Err() != nil {
		t.Errorf("Got an error from scanner: %s", err)
	}
	if err != nil {
		t.Errorf("perl test failed: %s", err)
	}

	// parse our server's (in memory) logs and error if our page never got
	// hit, to protect us from something making the perl test exit 0 early
	var ran bool
	s := bufio.NewScanner(env.testlog.buf)
	for s.Scan() {
		type access struct {
			Tag  string `json:"@tag"`
			Path string `json:"uri_path"`
		}
		var v access
		if err := json.Unmarshal(s.Bytes(), &v); err != nil {
			panic(err)
		}

		if v.Tag == "app.foo" && v.Path == "/mix/js_web_serp" {
			ran = true
			break
		}
	}
	if !ran {
		t.Error("the perl tests never actually hit the foo!")
	}
}
```

Cool!  This runs in about 0.3s.  Given that I want it to run early in our build
pipeline, to prevent larger errors from percolating through.  With that in
mind, I built the test as a binary and ran it in a perl image within `docker
build`.  Our perl image doesn't have go installed, and our go image doesn't
have perl, but the single binary makes this easy to thread through:

```Dockerfile
ARG REPO
FROM $REPO/go:latest AS builder

COPY . /go/src/go.zr.org

WORKDIR /go/src/go.zr.org

# ...

# -o builds the test as a binary, emitting it to `/mixertest`
# -run xyzzy says to run tests that contain the xyzzy string, so none
RUN go test -o /mixertest -run xyzzy go.zr.org/job_services/mixer/public/mixer

# start a new perl image
FROM $REPO/perl:latest AS perl-test

COPY . /var/starterview

WORKDIR /var/starterview/job_services/mixer/public/mixer

# copy the binary from the other image
COPY --from=builder /mixertest .

# run the test binary
# ... -test.count=1 disables caching
# ... -test.v runs the test verbose
# ... -test.run Perl only runs our Perl test
RUN ./mixertest -test.count=1 -test.v -test.run Perl
```

## What kind of tests are these?

Typically the software industry groups automated testing into unit tests and
integration tests.  Unit tests should be fast and stable, since they should
avoid network resources.  They should uncover regressions caused by changes
in your own code or your own dependencies or external services.

Integration tests tend to be flaky, since they will fail due to timeouts (and
other temporary failures,) which may not mean anything broke at all.  On the
other hand if part of what you are integrating with is a third party service,
you *do* want to fail if they change the way they encode data or authenticate.

Many people balk at the testing strategy I show above, since it crosses the
clearly delineated boundaries above.  I would suggest that in fact what I am
doing is a unit test because I control both sides of the code, it is fast,
and it is not flaky.

But I'll actually go a step further.  At some point I expect this code to need
to talk to mysql.  I intend to set up
[github.com/src-d/go-mysql-server](https://github.com/src-d/go-mysql-server),
which allows me to run an in process mysql-compatible server that will allow me
to skip any database client mocking at all.  This means:

 * my code stays simple; no mock hooks
 * my tests exercise more of the code; the real client and real
   queries will be used
 * as usual, my code can be quickly validated

It's become a bit of a best practice in Go to implement server protocols rather
than mocking clients.  This isn't free, but it's *such* an improvement in
testing, since you don't end up mocking away huge piles of functionality.  I
thought it was crazy at first, but I've learned to really appreciate the
technique.

Thanks to John SJ Anderson for reviewing this post.

---

(The following contains affiliate links.)

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

I recently read
<a target="_blank" href="https://www.amazon.com/gp/product/1732102201/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1732102201&linkCode=as2&tag=afoolishmanif-20&linkId=25f61ccbee6f99d0038e283dd551a943">A Philosophy of Software Design</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1732102201" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I really enjoyed it and will likely have a whole blog post about it.  I suggest
reading it.
