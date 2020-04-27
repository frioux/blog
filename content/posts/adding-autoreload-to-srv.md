---
title: Adding Autoreload to srv
date: 2020-04-27T08:00:36
tags: [ "frew-warez", "leatherman", "golang", "javascript" ]
guid: 20ede85c-cb8f-4a62-8e64-3683aaf14baf
---
About a week ago I added automatic reload to my little web server.

<!--more-->

One of the tools [in my leatherman](https://github.com/frioux/leatherman/) is a
simple static file server.  I constantly use it to serve [my own
notes](https://frioux.github.io/notes/), but I also use it to serve offline
versions of various websites.  For example I've been on a plane and used it to
serve the prometheus web docs so I could review them while traveling.

Last weekend I took a long weekend (we had intended to take a whole week off to
travel but a certain pandemic took that option off the table) and decided to
finally add a feature to `srv` I've been wanting for a long time: automatic
reload.

Here's the idea: `srv` uses a filesystem watcher to notice when one of the
files changes.  When this happens, it signals to any running browsers that the
file changed, and the browser page reloads.  The signal happens via SSE, which
is basically a weird kind of AJAX, which is really just a web request the
javascript makes.  The javascript that initiates the SSE is injected by `srv`
whenever any html is served.

Let's go over it in pieces.

## Middleware in Go to Modify Response Bodies

I did a ton of research trying to find an example of how you can modify a
response body in Go middleware and couldn't find *a single example.*  Go's
HTTP API looks like this:

```golang
type Handler interface {
        ServeHTTP(ResponseWriter, *Request)
}
```

All that says is: provide a value that has a method named `ServeHTTP` that
takes an `http.ResponseWriter` and an `*http.Request` as arguments.  Typically
people will do this with a function value, but you can make the type anything
(like a struct if you need to hold database handles, or whatever.  Here's a middleware
I wrote for `srv` to add a super basic accesslog:

```golang
func logReqs(h http.Handler) http.Handler {
	return http.HandlerFunc(func(rw http.ResponseWriter, r *http.Request) {
		fmt.Fprintln(os.Stderr, time.Now(), r.URL)
		h.ServeHTTP(rw, r)
	})
}
```

Here, `logReqs` takes a handler, wraps it with it's own function based handler
(`HandlerFunc` just turns a function value into a value with a `ServeHTTP`
method that calls ... itself.)  Inside the function it writes the current time
and the URL of the request, and then runs the inner handler.

Easy!  Now what if we want to capture the body and modify it?  I'll save you my
failed attempts and show the code that works.  The magic solution is
`net/http/httptest.ResponseRecorder`.  It implements the `ResponseWriter`
interface and stores the headers and response body, which you can then inspect,
modify, and re-send to the client.  Here's how I used it, including adding the
JavaScript:

```golang
// This is a pretty inefficient way to do this, but
// it's reliable at least.  Given time and motivation
// this could be more stream oriented and not buffer
// the whole response.
brw := httptest.NewRecorder()

// Copy headers into buffer
for h := range rw.Header() {
	brw.Header().Set(h, rw.Header().Get(h))
}

// Run handler against buffer
h.ServeHTTP(brw, r)

// Copy headers back out
for h := range brw.Header() {
	rw.Header().Set(h, brw.Header().Get(h))
}

// Remove Content-Length, since our modifications will make it incorrect.
rw.Header().Del("Content-Length")

res := brw.Result()
defer res.Body.Close()

// Copy status code
rw.WriteHeader(res.StatusCode)

// Copy body
if _, err := io.Copy(rw, res.Body); err != nil {
	fmt.Fprintf(os.Stderr, "error writing body: %s\n", err)
}

// Inject js if the content is html
if mt, _, _ := mime.ParseMediaType(res.Header.Get("Content-Type")); mt == "text/html" {
	fmt.Fprint(rw, js)
}
```

As mentioned in the comment, this could be much more efficient.  At some point
I'd like to make it so that it's fully streaming, or maybe build a streaming
middleware as an example.  Basically it'd be a value that watches for a
WriteHeader, inspects the headers at that point, and then chooses how to
override the Write method.

## SSE in JavaScript and in Go

OK!  We've injected some JS, but what does it look like?  It looks like this:

```javascript
// create the event source for the /_reload endpoint
const evtSource = new EventSource("/_reload");

// handle any errors related to the event source
evtSource.onerror = function(event) {

  // if the event source is closed (like the server crashes or the socket is
  // lost, due to suspending my laptop for example,) just reload the whole page
  if (event.target.readyState == EventSource.CLOSED) {
    // refresh page after 2-5s
    setTimeout(function() { location.reload() }, 2000 + Math.random() * 3000);
    return;
  }

  // log unexpected errors
  console.log(event);
};

// if we get the event reload the page
evtSource.onmessage = function(event) { location.reload() }
```

Pretty straightforward.  I had to get help writing the error handling, which my
friend [Rob Hoelz](https://hoelz.ro/) suggested I handle.

Here's the Go part:

```golang
// if we somehow have an http.ResponseWriter that can't do streaming, give up.
f, ok := rw.(http.Flusher)
if !ok {
	http.Error(rw, "Streaming unsupported!", 500)
	return
}

// Cargo cult from the Mozilla docs
rw.Header().Set("Cache-Control", "no-cache")
rw.Header().Set("Content-Type", "text/event-stream")

select {
// if generation has any events, files were written and tell the client to
// reload.
case <-generation:
	fmt.Fprintf(rw, "data: Message: reload!!!\n\n")
	f.Flush()
// if the client's context finishes, return to clean up the goroutine.
case <-r.Context().Done():
	// client went away
}
return
```

Then there's the file watching stuff... It's complicated and I don't want to
explain all of it here, but basically I copy pasted the code from [The
Leatherman's
`minotaur`](https://github.com/frioux/leatherman/blob/30881cad9fac8ea96cbe806e4c83d33e2afcbdb6/internal/tool/minotaur/minotaur.go#L100) and modified it slightly;
instead of running a script, I close a channel and reinitialize it:

```golang
close(generation)
generation = make(chan bool)
```

Closing a channel sends zero values to all blocking receives, so I could have
thousands of browser windows blocking on this (hah) one channel and all would
send the restart signal when the channel is closed.  Reinitializing the channel
allows future connections (some from reloaded windows, some from new tabs) to
block on other file events.

Now that you've read the above, maybe [take a look at the full source
code](https://github.com/frioux/leatherman/blob/a0572adeaa2c7fde7520bdd7453eb54525763211/internal/tool/srv/autoreload.go)
or [try it out](https://github.com/frioux/leatherman/releases).

---

I use this for [autoreloading my own
notes](/posts/zine-software-for-managing-notes/).  Just a couple of days after
writing it I came up with another fun use case:  the html view of test coverage
in Go!  Basically [I run tests in a file
watcher](https://github.com/frioux/dotfiles/blob/0c6e0b676849d098bc921a01858d525cc2c3a458/bin/gotest):

```bash
$ gotest -coverprofile=$TMPDIR/covin/c.out ./job_services/mixer/public/mixer
============== 2020-04-22 04:41:43 ==============
ok      go.zr.org/job_services/mixer/public/mixer       0.369s  coverage: 89.7% of statements  
=================================================
```

That'll run tests whenever a file changes, building coverage info.

I ran another file watcher to to update the html view of coverage when `c.out`
is changed.  I could have done it with a more complicated first watcher, but
this was easier:

```bash
$ minotaur . -- sh -c 'cd $PROJECT; go tool cover -html $TMPDIR/covin/c.out -o $TMPDIR/covout/coverage.html'
```

And finally, I serve `coverage.html` via `srv` instead of directly as a file to
get automatic reloading:

```bash
$ cd $TMPDIR/covout
$ srv
Serving . on [::]:25725
```

---

This felt great to finally put together.  It was fun to play with different
parts of the tech stack than I normally do.  It feels like an instant hit,
though time will tell if it remains part of my flow.

---

Thanks to John Anderson, Kevin O'Neal, and Rob Hoelz for reviewing this post.

---

(The following includes affiliate links.)

<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=01cde3ac7bf536c84bfff0cc1078bc56">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is one of the most inspiring software engineering books I've ever read.  I
suggest reading it if you use UNIX either at home (Linux, OSX, WSL) or at work.
It can really clarify some of the foundational tools you can use to build your
own tools or extend your environment.

If you want to learn more about programming Go, you should check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It is one of the best programming books I've read.  You will not only learn Go,
but also get some solid introductions on how to write code that is safely
concurrent.  **Highly recommend.**  This book is so good that I might write a
blog post solely about learning Go with this book.
