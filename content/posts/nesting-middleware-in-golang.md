---
title: Nesting Middleware in Go
date: 2019-07-08T19:50:29
tags: [ golang, http ]
guid: 2ce6d463-b647-4148-aaef-a4a766a51d81
---
I recently, finally, figured out how to properly nest middleware in Go.

<!--more-->

Maybe this isn't news to everyone else, but I couldn't quite figure out how to
apply middleware to more than a single handler in Go.  Well over the weekend it
magically clicked.

## Middleware

If you are unaware, middleware is some code that typically runs some code before
or after a web request.  There are other kinds of middleware but they are
irrelevant to this post.  Here's a slightly simplified bit of middleware I like
and use:

```golang
type logline struct {
	Time       string
	Duration   float64
	URL        string
	StatusCode int
}

func Log(logger io.Writer) func(http.Handler) http.Handler {
	e := json.NewEncoder(logger)

	return func(h http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()

			lw := &loggingResponseWriter{ResponseWriter: w}
			defer func() {
				e.Encode(logline{
					Time:       start.Format(time.RFC3339Nano),
					Duration:   time.Now().Sub(start).Seconds(),
					URL:        r.URL.String(),
					StatusCode: lw.statusCode,
				})
			}()
			h.ServeHTTP(lw, r)
		})
	}
}

type loggingResponseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (lrw *loggingResponseWriter) WriteHeader(code int) {
	lrw.statusCode = code
	lrw.ResponseWriter.WriteHeader(code)
}
```

The above middleware can log all requests as json to some `io.Writer`.  To
install it you just do something like this:

```golang
http.Handle("/foo", Log(os.Stdout)(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { ... })))
```

The above is pretty noisy and contributes to why I hadn't figured this out
sooner, so I'll unpack this one part at a time.

First off, http.Handle takes an http.Handler, which is simply an interface that
has a ServeHTTP method.  One confusing part above is that we used
`http.HandlerFunc`, not any thing even mentioning ServeHTTP.  Well
`http.HandlerFunc` is just a type that adds the ServeHTTP method.  That's not so
bad.

Ok so next is that while we added the above to the `/foo` endpoint, it's totally
unclear how we could apply that middleware to the entire webserver.  Joke's on
us because we used a global and that makes this way harder than it has to be.
Here's how you apply it to the whole web server:

```golang
mux := http.NewServeMux()

mux.Handle("/foo", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { ... }))

h := Log(os.Stdout)(mux)
```

In the above code, `h` is an opaque `http.Handler` wrapped around the whole
`ServeMux`.  You can wrap *another* ServeMux around this if you wanted to only
apply the middleware to part of the tree of urls.  Hope this is helpful!

---

If you are interested in learning Go, this is my recommendation:

(The following includes affiliate links.)

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
