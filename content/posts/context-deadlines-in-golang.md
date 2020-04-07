---
title: context Deadlines in Go
date: 2020-04-07T09:46:25
tags: [ golang ]
guid: de541875-7a9a-4a6b-b3af-1672386c7c18
---
I recently learned more about contexts in Go.

<!--more-->

The project I'm spending my time on [at
work](https://www.ziprecruiter.com/hiring/technology) is mostly a glorified
proxy; I have learned a lot about contexts and thought I'd share some of it.

A quick note before we get into this post: channels are a central concept in
Go, and are the fundamental mechanism behind contexts.  I am all about cargo
culting weird syntax, but be warned that this is not just a palette shifted
Perl or Python.  With that in mind, I will touch on some of those semantics in
the post, but if you see something that I don't explain (notably anything
involving `select` or `<-`) maybe just copy and paste it and move on.

There are also other Go constructs, like `defer`, used within this post that I
won't spend time on either.

## Contexts?

[The `context` package](https://golang.org/pkg/context/) defines contexts as:

>  deadlines, cancellation signals, and other request-scoped values across API
>  boundaries and between processes.

For this post I'm only going to talk about the first two.  Deadlines are just
more humane names for timeouts:

 * at work you may hear the term deadline 
 * while timeout is typically used at a daycare

and is has nothing to do with the timeout term we use in software engineering.

Deadlines mean we'll give up waiting on a thing after some time.  A Deadline
can be defined either absolutely:

```golang
ctx, cancel := context.WithDeadline(time.Date(2020, 4, 1, 0, 0, 0, time.UTC))
```

Deadlines can also be defined relatively:

```golang
ctx, cancel := context.WithTimeout(2 * time.Second)
```

The latter is just a shortcut for a deadline of `time.Now()` plus the duration.

Here's an example of actually using a context:

```golang
package main

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"time"
)

func main() {
	server := httptest.NewServer(http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		fmt.Printf("s\t%ss\n", "server got request")

		time.Sleep(500 * time.Millisecond) // <<<< CHANGE ME <<<<
		
		fmt.Printf("s\t%s\n", "server sent response")
	}))
	defer server.Close()

	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, time.Second)
	defer cancel()

	r, _ := http.NewRequest("GET", server.URL, nil)
	r = r.WithContext(ctx)
	fmt.Printf("c %s\n", "client sending req")
	_, err := http.DefaultClient.Do(r)
	fmt.Printf("c %s\n", "client finished")
	if err != nil {
		fmt.Printf("c %s\n", err)
	}
}
```

([Try this at home!](https://play.golang.org/p/UiGqvHCxyyV))

You can play with the duration passed in the marked line; if you make it less
than 1 second everything should work fine.

With that code, you'll see output like this for no timeout:

```
c client sending req
s	server got requests
s	server sent response
c client finished
```

Or this if there was a timeout:

```
c client sending req
s	server got requests
c client finished
c Get http://127.0.0.1:2: context deadline exceeded
s	server sent response
```

We already have an interesting detail to note: the server sends the response
even though the client gave up waiting.  This can be resolved, but it
demonstrates an important detail of Go: you are responsible for the lifetimes
of your goroutines and if you are not careful they will leak.  If we wanted to
resolve that issue we could modify the body of the server to:

```golang
		fmt.Printf("s\t%ss\n", "server got request")

		time.Sleep(1500 * time.Millisecond) // <<<< CHANGE ME <<<<

		select {
		case <-r.Context().Done():
			fmt.Println("s\toh dang already timed out!")
			rw.WriteHeader(504)
			return
		default:
		}

		fmt.Printf("s\t%s\n", "server sent response")
```

...but any code with a sleep in it is a toy.  We could make the above more
industrial, but I don't see a good reason to build an enterprise grade
chalkboard.  Let's move on to the next example.

More typically, when using contexts, you'll pass the context to some other
layer, like a database or some other API.  Here's an example:

```golang
package main

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"time"
)

func main() {
	back := httptest.NewServer(http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		fmt.Printf("b\t\t%ss\n", "back got request")

		time.Sleep(500 * time.Millisecond) // <<<< CHANGE ME <<<<

		fmt.Printf("b\t\t%s\n", "back sent response")
	}))
	defer back.Close()

	middle := httptest.NewServer(http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		fmt.Printf("m\t%ss\n", "middle got request")
		
		req, _ := http.NewRequest("GET", back.URL, nil)
		req = req.WithContext(r.Context())
		fmt.Printf("m\t%s\n", "middle sending req")
		_, err := http.DefaultClient.Do(req)
		fmt.Printf("m\t%s\n", "middle finished")
		if err != nil {
			fmt.Printf("m\t%s\n", err)
			rw.WriteHeader(500)
			return
		}

		fmt.Printf("m\t%s\n", "middle sent response")
	}))
	defer middle.Close()

	ctx := context.Background()
	ctx, cancel := context.WithTimeout(ctx, time.Second)
	defer cancel()

	r, _ := http.NewRequest("GET", middle.URL, nil)
	r = r.WithContext(ctx)
	fmt.Printf("f %s\n", "front sending req")
	_, err := http.DefaultClient.Do(r)
	fmt.Printf("f %s\n", "front finished")
	if err != nil {
		fmt.Printf("f %s\n", err)
	}
}
```

([Try me!](https://play.golang.org/p/PR2CtShD7uG))

This should look similar to the previous example, but with another layer
between the "front" client and the "back" server.  In this version, with a low
enough sleep you should see output like this:

```
f front sending req
m	middle got requests
m	middle sending req
b		back got requests
b		back sent response
m	middle finished
m	middle sent response
f front finished
```

If you increase the timeout the output changes drastically:

```
f front sending req
m	middle got requests
m	middle sending req
b		back got requests
f front finished
f Get http://127.0.0.1:3: context deadline exceeded
m	middle finished
m	Get http://127.0.0.1:2: context canceled
b		back sent response
```

We can see here that, at least in this case, it's the front, or outermost
layer, that gives up first.  In fact, the act of giving up is what triggers the
next layer, middle, to give up.  This is one of the neat things about contexts:
when used properly they propagate the cancellation signal to the next inner
layer.

My code at work is "middle;" one of my goals with this project is to neatly
track how my code is working, such that we know what is going wrong when things
inevitably go wrong.  I'm sure we've all worked on codebases that only have one
or two HTTP status codes: 200 and 500.  (Let's not even discuss 200 responses
as errors.)  In this project I am carefully serving:

 * 400 Bad Request when the client passes any kind of invalid input
 * 500 Internal Server Error when my code fails in an unexpected way
 * 502 Bad Gateway when my code fails to interact with the upstream server
 * 504 Gateway Timeout when the upstream server is too slow

With this in mind I am carefully paying attention to errors so I can
distinguish between (typically) serialization errors and timeouts.  Here's an
example, that could be dropped in to the middle function:

```golang
		fmt.Printf("m\t%ss\n", "middle got request")
		
		req, _ := http.NewRequest("GET", back.URL, nil)
		req = req.WithContext(r.Context())
		fmt.Printf("m\t%s\n", "middle sending req")
		_, err := http.DefaultClient.Do(req)
		fmt.Printf("m\t%s\n", "middle finished")
		if err != nil {
			var uErr *url.Error
			if errors.As(err, &uErr) && uErr.Timeout() {
				fmt.Printf("m\t504: %s\n", err)
				rw.WriteHeader(504)
			} else {
				fmt.Printf("m\t502 %s\n", err)
				rw.WriteHeader(502)
			}
			return
		}

		fmt.Printf("m\t%s\n", "middle sent response")
```

(If you paste that into the example above you'll need to add `errors` and
`net/url` to the imports.)

Running the above such that it times out prints:

```
f front sending req
m	middle got requests
m	middle sending req
b		back got requests
f front finished
f Get http://127.0.0.1:3: context deadline exceeded
m	middle finished
m	502 Get http://127.0.0.1:2: context canceled
b		back sent response
```

When this first happened it surprised me!  I got a timeout, but the error's
Timeout method returned false.  What gives?  If you look closely you'll see
that middle actually got `context canceled` while front got `context deadline
exceeded`.  The client knows about the timeout, and actually initiated it.  All
middle knows is that the client stopped waiting.  In our case this is a
timeout, but in theory the client could have asked for data from ten servers
and canceled nine requests when the first one responded.

This is the main point about cancellations as opposed to deadlines; deadlines
are simply a time in the future that will trigger *a cancellation.*
Cancellations are more general, and could map to any event.  In this case, the
closing of the socket by the client, to tell the server that it's not waiting
for your response anymore.

In the end we decided we'd rather just assume this is a timeout.  We made a little
helper function and used that; here it is:

```golang
// IsTimeout returns true if the underlying error is a timeout.  This function
// counts canceled contexts as timeouts.
func IsTimeout(err error) bool {
	var uErr *url.Error
	switch {
	case errors.Is(err, context.Canceled):
		return true
	case errors.Is(err, context.DeadlineExceeded):
		return true
	case errors.As(err, &uErr) && uErr.Timeout():
		return true
	}

	return false
}
```

And here's how you use it:

```golang
		fmt.Printf("m\t%ss\n", "middle got request")
		
		req, _ := http.NewRequest("GET", back.URL, nil)
		req = req.WithContext(r.Context())
		fmt.Printf("m\t%s\n", "middle sending req")
		_, err := http.DefaultClient.Do(req)
		fmt.Printf("m\t%s\n", "middle finished")
		if err != nil {
			if IsTimeout(err) {
				fmt.Printf("m\t504: %s\n", err)
				rw.WriteHeader(504)
			} else {
				fmt.Printf("m\t502 %s\n", err)
				rw.WriteHeader(502)
			}
			return
		}

		fmt.Printf("m\t%s\n", "middle sent response")
```

This made a big difference in surfacing the *right* issues; if we saw a large
increase in 504s we knew that some upstream server probably started going so
slow that our downstream clients were giving up.

---

I think there is certainly more work to do on `IsTimeout`; it probably needs to
check for `net.Error` too, or maybe just look for an `interface { Timeout()
bool }`.  I'm sure there are lots of other types we should be teasing apart,
but this was a good start.  It's useful to put this kind of function in a
generic error package that much of your code uses, so you can centralize a rich
set of error detection.

---

(Affiliate links below.)

Thanks to Shannon Barrett, Kevin O'Neal, and Eric Weinstein for reviewing this
post.

If you want to learn more
about programming Go, you should check out <a target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.  It is one of the best programming books I've read.
You will not only learn Go, but also get some solid introductions on how to
write code that is safely concurrent.  **Highly recommend.**

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.

For a *much* more in depth discussion of contexts, you might check out [the
blog post from the Go team](https://blog.golang.org/context).
