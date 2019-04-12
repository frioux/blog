---
title: Lag from Timers in Go
date: 2019-04-11T19:01:32
tags: [ golang, gnuplot ]
guid: 9b87eb92-d786-420a-8f64-023f941bab38
---
I noticed that timers in Go aren't perfect.

<!--more-->

The above, banal statement should be obvious given almost any amount of thought,
but it's still worth being aware of.

I have [a tool called debounce](https://github.com/frioux/leatherman#debounce)
to generically [debounce](https://en.wikipedia.org/wiki/Switch#Contact_bounce)
lines on stdin such that multiple lines that happen close together in time will
be merged into a single line.

I recently decided to refactor my `debounce` tool into two separate types; one
for debouncing on the leading edge of an event, and one on the trailing edge.
Here's the leading edge type:

```golang
type leadingBouncer struct {
	w        io.Writer
	next     time.Time
	duration time.Duration
}

func (l *leadingBouncer) Write(t time.Time, s []byte) error {
	oldNext := l.next
	l.next = t.Add(l.duration)
	if t.After(oldNext) {
		_, err := l.w.Write([]byte(s))
		return err
	}
	return nil
}
```

Pretty simple, works great.  Next I wrote the trailing edge version:

```golang
type trailingBouncer chan struct {
	t  time.Time
	in []byte
}

func (t trailingBouncer) Write(at time.Time, in []byte) error {
	t <- struct {
		t  time.Time
		in []byte
	}{at, in}

	return nil
}

func newTrailingBouncer(w io.Writer, duration time.Duration) trailingBouncer {
	ch := make(chan struct {
		t  time.Time
		in []byte
	})

	go func() {
		v := <-ch
		timeout := time.NewTimer(duration)

		for {
			select {
			case <-timeout.C:
				w.Write(v.in)
			case v = <-ch:
				timeout = time.NewTimer(duration)
			}
		}
	}()

	return trailingBouncer(ch)
}
```

This is hugely more complicated.  It's two functions instead of one; it uses a
channel and a goroutine.  It uses a select statement.  It works in the tool just
fine, but I am trying to write tests for these things.  The test for the leading
edge is boring and reliable, but the trailing edge test is more interesting:

```golang
func TestTrailing(t *testing.T) {
	buf := &bytes.Buffer{}

	l := newTrailingBouncer(buf, 5*time.Millisecond)

	l.Write(time.Now(), []byte("1\n"))

	time.Sleep(time.Millisecond)
	l.Write(time.Now(), []byte("2\n"))

	time.Sleep(time.Millisecond)
	l.Write(time.Now(), []byte("3\n"))

	time.Sleep(6 * time.Millisecond) // print 3
	l.Write(time.Now(), []byte("4\n"))

	time.Sleep(6 * time.Millisecond) // print 4
	l.Write(time.Now(), []byte("5\n"))

	time.Sleep(6 * time.Millisecond) // print 5

	assert.Equal(t, "3\n4\n5\n", buf.String())
}
```

The smaller the time unit I use in the test above, the flakier it is.  Initially
I had the lockout time be one millisecond and for less than that dealt with
single, then tens, then hundreds of nanoseconds.  It failed *a lot*.  The above
vesion fails much less often, but it still does.  (Side note: while I could have
built some kind of mock for time it would have complicated the code and hidden
this issue.  Bad tradeoff.)

Because Go caches test results and this test is flaky, it would be easy to miss.
I worked around that by building the test binary and running that a lot of times
directly:

```
$ go test -o deb.test           
PASS
ok      github.com/frioux/leatherman/internal/tool/debounce     0.026s

$ while true; do ./deb.test -test.run Trail || break; done
PASS
PASS
PASS
PASS
PASS
PASS
PASS
PASS
PASS
--- FAIL: TestTrailing (0.02s)
    trailing_test.go:32: 
                Error Trace:    trailing_test.go:32
                Error:          Not equal: 
                                expected: "3\n4\n5\n"
                                actual  : "3\n5\n"
                            
                                Diff:
                                --- Expected
                                +++ Actual
                                @@ -1,3 +1,2 @@
                                 3
                                -4
                                 5
                Test:           TestTrailing
FAIL
```

It doesn't always fail in the same way either!  Sometimes, the 3 is missing,
sometimes the 4 is missing, and sometimes the 5 is missing.  Fun.

Part of the issue here is that Go and Linux just don't want to waste time
dealing with overly small time slices when context switching.  [I wrote more
about this topic some, a couple of years ago.](/posts/linux-clocks/)  When I was
trying to figure out the above issue I asked on Slack and Ivan Kurnosov pointed
out that Go doesn't promise when the tick will happen, just the minimum
duration.

After being clued in I decided to measure just how "late" events typically are.
[I whipped up a little
tool](https://github.com/frioux/go-scraps/blob/master/cmd/timer-latency/main.go):

```golang
package main

import (
	"flag"
	"fmt"
	"time"
)

var duration time.Duration

func init() {
	flag.DurationVar(&duration, "duration", time.Millisecond, "how long to sleep")
}

func main() {
	flag.Parse()

	for {
		start := time.Now()
		timer := time.NewTimer(duration)

		<-timer.C
		end := time.Now()
		fmt.Println(end.Sub(start) - duration)
	}
}
```

I suspect the results vary based on OS, hardware, and load.  At least on my
laptop you typically get a range from a few to hundreds of nanoseconds.  Here's
a histogram of the latencies:

![Histogram of Timer Lag](/static/img/go-timer-latency-plot.png "Histogram of Timer Lag")

And the code used to generate the histogram:

```gnuplot
#!/usr/bin/gnuplot

reset

set terminal png
set grid
set boxwidth 4
set style fill solid
set xlabel "ns"
set ylabel "count"

plot "./data" using 1:2 with boxes
```

```bash
$ go run main.go -duration 1ms |
  head -10000 |
  perl -E '
    BEGIN { our %h }
    END { say "$_\t$h{$_}" for sort { $a <=> $b } keys %h}
    sub b { my $a = shift; my $i = 0; while (1) { return $i if $a < $i; $i += 10 }  }
    while (<>) { $h{b($_)}++ }' > data
$ gnuplot plot > plot.png
```

You can't really see it in the graph, but the latencies in this test go as high
as 830ns.

---

Honestly the takeaway here is that you can't really depend on timers to be exact
(no matter what the programming language is,) unless you are using some kind of
real time system, and if you are using a real time system you are *probably*
writing C or C++.

---

If you don't already know how to use gnuplot, you might benefit from
<a target="_blank" href="https://www.amazon.com/gp/product/1633430189/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1633430189&linkCode=as2&tag=afoolishmanif-20&linkId=b130595553eee19794fcc127da039126">Gnuplot in Action</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1633430189" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The tool can be hard to get into and a proper introduction can go a long way.

As usual, I have to mention my favorite Go book: 
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.
