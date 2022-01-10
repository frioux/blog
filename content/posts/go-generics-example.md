---
title: Go Generics Example
date: 2022-01-09T08:16:39
tags: [ golang ]
guid: 8997b9b7-8fe1-4f19-9f1f-5595fb6fbd49
---
[Go 1.18](https://go.dev/blog/go1.18beta1) will be adding [Go's version of
generics](https://go.googlesource.com/proposal/+/refs/heads/master/design/43651-type-parameters.md)
pretty soon.  I wanted to get a feel for how I might use them.  Read on for a
concrete example.

<!--more-->

I wanted to get some hands on experience with generics to
understand what would or wouldn't work so I built a little web app that has a
separate component for serialization and the actual handler.

Typically when I write an http handler in Go, the general pattern is:

```golang
func (x X) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
        var i inputType
        if err := json.NewDecoder(r.Body).Decode(&i); err != nil {
                rw.WriteHeader(400)
                // maybe log here
                return
        }

        var o outputType

        // meat of the function is here, populates o

        if err := json.NewEncoder(rw).Encode(o); err !- nil {
                rw.WriteHeader(500) // probably too late
                // definitely log here
                return
        }
}
```

The code above is almost exclusively boilerplate to handle serialization.  I
write up an example of how to translate this to generics.

---

Before I show the code let me describe some (not all) of the foundational bits of generics in Go.

First, and most basic, is that `any` becomes an alias for `interface{}`.  This is pure sugar
but makes the code much less noisy for a pretty common case.

Next, we have the opportunity to include **parameter lists** in our type definitions.  The gist
is you can do something like:

```golang
type Reducer[T any] interface {
    reduce func (a, b T) T
}


```

The square brackets are where you put one or more new parameters in your type.  The parameters
end up used in the body of the type (or function or method or whatever.)  I used `any` above
but you can use other interfaces there too.

---


I started from the bottom up, basically making sure that the `go1.18beta1` would
compile at each step.

First, let's define what our handler interface.  In prose we might say that
this receives any type for input as I and returns any kind of output as O.

```golang
type Handler[I, O any] interface {
	Handle(context.Context, I) (O, error)
}
```

At the same time I wrote my silly concrete version.  Note that the input and
output are both simple strings.

```golang
type titleHandler struct {}

func (h titleHandler) Handle (ctx context.Context, i string) (string, error) {
	return strings.Title(i), nil
}
```

Next up, a serializer interface.  If we wrote `interface{}` instead of `any`
this type would work with older versions of Go.

```golang
type serde interface {
	deserialize(*http.Request, any) error
	serialize(any, http.ResponseWriter) error
}
```

I could imagine serializers being parameterized (ie have an `[I, O any]`) but
didn't have any good examples where it would actually make the code any better.

Here are my concrete examples:

```golang
type jserde struct{}

func (s jserde) deserialize(r *http.Request, i any) error {
	d := json.NewDecoder(r.Body)
	defer r.Body.Close()
	return d.Decode(i)
}

func (s jserde) serialize(o any, rw http.ResponseWriter) error {
	e := json.NewEncoder(rw)
	return e.Encode(o)
}


type xserde struct{}

func (s xserde) deserialize(r *http.Request, i any) error {
	d := xml.NewDecoder(r.Body)
	defer r.Body.Close()
	return d.Decode(i)
}

func (s xserde) serialize(o any, rw http.ResponseWriter) error {
	e := xml.NewEncoder(rw)
	return e.Encode(o)
}
```

Of course you could split these into two values (a serializer and a
deserializer) so you could take JSON in and respond with XML, but that would be
uncouth, so we'll leave everything as is.

And for the meat of the post, let's define a generic type that bundles these together:

```golang
type LMHTTP[I, O any] struct {
	serde serde
	handler Handler[I, O]
}

func (h LMHTTP[I, O]) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	var i I
	if err := h.serde.deserialize(r, &i); err != nil {
		fmt.Fprintf(os.Stderr, "deser: %s\n", err)
		rw.WriteHeader(400)
	}
	o, err := h.handler.Handle(r.Context(), i)
	if err != nil {
		fmt.Fprintf(os.Stderr, "handle: %s\n", err)
		rw.WriteHeader(500)
	}
	if err := h.serde.serialize(o, rw); err != nil {
		fmt.Fprintf(os.Stderr, "ser: %s\n", err)
		rw.WriteHeader(500)
	}
}
```

The main things to notice above are:

 1. We put the type parameters on the type itself (`[I, O any]`).
 2. The method gets the names of the parameters (`[I, O]`) and it's important
    that the order is the same.
 3. The method can use the parameter names as if they were types (`var i I`,
    for example.)

Finally, let's use all the types together:

```golang
func main() {
	mux := http.NewServeMux()
	mux.Handle("/json", LMHTTP[string, string]{
		serde: jserde{},
		handler: titleHandler{},
	})
	mux.Handle("/xml", LMHTTP[string, string]{
		serde: xserde{},
		handler: titleHandler{},
	})
	fmt.Println(http.ListenAndServe(":8083", mux))
}
```

With the above I was able to run the code and interact with it:

```bash
$ curl http://localhost:8083/xml --request POST --data '<string>king of the world</string>'
<string>King Of The World</string>

$ curl http://localhost:8083/json --request POST --data '"king of the world"'
"King Of The World"
```

## Why

I think generics to allow switching from JSON to XML is pretty silly.  It'd be
convenient to drop in if it were warranted, but I prefer APIs to be limited and
straightforward.  If I were doing this in anger I'd probably hardcode the json
serialization (or whatever) directly into the `LMHTTP.Handle` method.

The real boon is that the business logic of our code (the handler) is
straightforwardly defined in terms of concrete types.  Here we're using just a
string in and a string out, but it works just as well with a struct in and a
struct out.

I do think that writing the generics above are much more complicated and
confusing than typical Go, but I could imagine having a minimalist framework
built around the pattern above.  It could pick apart errors returned from the
handler to map to errors other than simply `500`.

Of course middleware can now be added at either the outer layer (the
traditional way to add middleware in Go) or the inner layer (wrapping the
handler.)  Both have uses, for example timing the outer layer will be more
accurate, but the inner layer might let you have metrics that include parts of
the request body, for example.

## Middleware

Speaking of middleware, middleware is where generics *really* shine.
Fundamentally, generics allow our middleware to not obfuscate our types behind
an interface.  Normally if you were to layer a bunch of middleware together in
Go, once one of the middleware says: "my input param must implement interface
X" and then passes that parameter to another middleware in the chain, that next
layer gets... well an X.  The concrete implementation is now hidden.  

I wrote some middleware with this post in mind, parameterizing on the output
value, but you could just as easily do this with other values you pass along.
First, a middleware that times the request:

```golang
type setDuration interface {
	setDuration(time.Duration)
}

type timerMW[I any, O setDuration] struct{
	inner Handler[I, O]
}

func (h timerMW[I, O]) Handle(ctx context.Context, i I) (O, error) {
	t0 := time.Now()
	o, err := h.inner.Handle(ctx, i)
	o.setDuration(time.Now().Sub(t0))
	return o, err
}
```

Note that we use the `setDuration` interface above, instead of `any` like we've
been using before.  This means that we can call the `setDuration` method on `o`.
But critically, `o` is not a value of type `setDuration`, like it would have been
in previous versions of Go.  `o` is parameterized and has the type we request when
we (later) instantiate the middleware value.

Next, lets add another middleware, presumably to emit some metrics:

```golang
type metricsEmitter interface {
	emitMetrics()
}

type metricsMW[I any, O metricsEmitter] struct{
	inner Handler[I, O]
}

func (h metricsMW[I, O]) Handle(ctx context.Context, i I) (O, error) {
	o, err := h.inner.Handle(ctx, i)
	o.emitMetrics()
	return o, err
}
```

Let's define a type that implements these interfaces and use it in our
application handler:

```golang
type titleOut struct {
	Out string
	d time.Duration
}

func (s *titleOut) setDuration(d time.Duration) { s.d = d }

func (s *titleOut) emitMetrics() {
	fmt.Println("request time", s.d)
}

type titleHandler struct {}

func (h titleHandler) Handle (ctx context.Context, i string) (*titleOut, error) {
	return &titleOut{Out: strings.Title(i)}, nil
}
```

Finally, here's an example of putting it all together:

```golang
func main() {
	mux := http.NewServeMux()
	mux.Handle("/json", LMHTTP[string, *titleOut]{
		serde: jserde{},
		handler: metricsMW[string, *titleOut]{timerMW[string, *titleOut]{titleHandler{}}},
	})
	mux.Handle("/xml", LMHTTP[string, *titleOut]{
		serde: xserde{},
		handler: metricsMW[string, *titleOut]{timerMW[string, *titleOut]{titleHandler{}}},
	})
	fmt.Println(http.ListenAndServe(":8083", mux))
}
```

In some of the lower level uses of generics (like a function that finds the minimum value
in a slice) the type inference lets callers not even realize they are using generics:

```golang
func min[P constraints.Ordered](ps []P) P {
	ret := ps[0]

	for _, p := range ps[1:] {
		if p < ret {
			ret = p
		}
	}

	return ret
}

func main() {
	fmt.Println(min([]int{24, -2, 42, 0}))
}
```

But when doing more complex code like above I have found the type inference
lacking.  Go's type inference has improved over time so maybe with generics
that will happen too.

---

I am confident that generics will end up overused, at least for a while, in Go.
We'll have code that's harder to understand than it has to be both due to a
slightly more complex syntax but more much because of an added abstraction
layer.

On the other hand, the use case for this post (middleware and web frameworks)
is a real limitation in Go.  I look forward to have nicely reusable middleware
and web frameworks.  Today I just eschew most existing middleware, but this
added functionality will hopefully change that.

---

[If you are interested in more posts like this, follow me on twitter](https://twitter.com/frioux).

### Appendix A: Full Version of Code without Middleware

Don't forget that for this to work you need to be using Go 1.18 or higher
([beta is here](https://go.dev/dl/#go1.18beta1)) and you need to declare go
1.18 in your go.mod.

```golang
package main

import (
	"os"
	"net/http"
	"strings"
	"context"
	"fmt"
	"encoding/json"
	"encoding/xml"
)

func main() {
	mux := http.NewServeMux()
	mux.Handle("/json", LMHTTP[string, string]{
		serde: jserde{},
		handler: titleHandler{},
	})
	mux.Handle("/xml", LMHTTP[string, string]{
		serde: xserde{},
		handler: titleHandler{},
	})
	fmt.Println(http.ListenAndServe(":8083", mux))
}

type LMHTTP[I, O any] struct {
	serde serde
	handler Handler[I, O]
}

func (h LMHTTP[I, O]) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	var i I
	if err := h.serde.deserialize(r, &i); err != nil {
		fmt.Fprintf(os.Stderr, "deser: %s\n", err)
		rw.WriteHeader(500)
	}
	o, err := h.handler.Handle(r.Context(), i)
	if err != nil {
		fmt.Fprintf(os.Stderr, "handle: %s\n", err)
		rw.WriteHeader(500)
	}
	if err := h.serde.serialize(o, rw); err != nil {
		fmt.Fprintf(os.Stderr, "ser: %s\n", err)
		rw.WriteHeader(500)
	}
}

type titleHandler struct {}

func (h titleHandler) Handle (ctx context.Context, i string) (string, error) {
	return strings.Title(i), nil
}

type Handler[I, O any] interface {
	Handle(context.Context, I) (O, error)
}

type serde interface {
	deserialize(*http.Request, any) error
	serialize(any, http.ResponseWriter) error
}

type jserde struct{}

func (s jserde) deserialize(r *http.Request, i any) error {
	d := json.NewDecoder(r.Body)
	defer r.Body.Close()
	return d.Decode(i)
}

func (s jserde) serialize(o any, rw http.ResponseWriter) error {
	e := json.NewEncoder(rw)
	return e.Encode(o)
}


type xserde struct{}

func (s xserde) deserialize(r *http.Request, i any) error {
	d := xml.NewDecoder(r.Body)
	defer r.Body.Close()
	return d.Decode(i)
}

func (s xserde) serialize(o any, rw http.ResponseWriter) error {
	e := xml.NewEncoder(rw)
	return e.Encode(o)
}
```

## Appendix B: Full Version of Code with Middleware

```golang
package main

import (
	"os"
	"time"
	"net/http"
	"strings"
	"context"
	"fmt"
	"encoding/json"
	"encoding/xml"
)

func main() {
	mux := http.NewServeMux()
	mux.Handle("/json", LMHTTP[string, *titleOut]{
		serde: jserde{},
		handler: metricsMW[string, *titleOut]{timerMW[string, *titleOut]{titleHandler{}}},
	})
	mux.Handle("/xml", LMHTTP[string, *titleOut]{
		serde: xserde{},
		handler: metricsMW[string, *titleOut]{timerMW[string, *titleOut]{titleHandler{}}},
	})
	fmt.Println(http.ListenAndServe(":8083", mux))
}

type LMHTTP[I, O any] struct {
	serde serde
	handler Handler[I, O]
}

func (h LMHTTP[I, O]) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	var i I
	if err := h.serde.deserialize(r, &i); err != nil {
		fmt.Fprintf(os.Stderr, "deser: %s\n", err)
		rw.WriteHeader(500)
	}
	o, err := h.handler.Handle(r.Context(), i)
	if err != nil {
		fmt.Fprintf(os.Stderr, "handle: %s\n", err)
		rw.WriteHeader(500)
	}
	if err := h.serde.serialize(o, rw); err != nil {
		fmt.Fprintf(os.Stderr, "ser: %s\n", err)
		rw.WriteHeader(500)
	}
}

type titleOut struct {
	Out string
	d time.Duration
}

func (s *titleOut) setDuration(d time.Duration) { s.d = d }

func (s *titleOut) emitMetrics() {
	fmt.Println("request duration", s.d)
}

type titleHandler struct {}

func (h titleHandler) Handle (ctx context.Context, i string) (*titleOut, error) {
	return &titleOut{Out: strings.Title(i)}, nil
}

type Handler[I, O any] interface {
	Handle(context.Context, I) (O, error)
}

type setDuration interface {
	setDuration(time.Duration)
}

type timerMW[I any, O setDuration] struct{
	inner Handler[I, O]
}

func (h timerMW[I, O]) Handle(ctx context.Context, i I) (O, error) {
	t0 := time.Now()
	o, err := h.inner.Handle(ctx, i)
	o.setDuration(time.Now().Sub(t0))
	return o, err
}

type metricsEmitter interface {
	emitMetrics()
}

type metricsMW[I any, O metricsEmitter] struct{
	inner Handler[I, O]
}

func (h metricsMW[I, O]) Handle(ctx context.Context, i I) (O, error) {
	o, err := h.inner.Handle(ctx, i)
	o.emitMetrics()
	return o, err
}

type serde interface {
	deserialize(*http.Request, any) error
	serialize(any, http.ResponseWriter) error
}

type jserde struct{}

func (s jserde) deserialize(r *http.Request, i any) error {
	d := json.NewDecoder(r.Body)
	defer r.Body.Close()
	return d.Decode(i)
}

func (s jserde) serialize(o any, rw http.ResponseWriter) error {
	e := json.NewEncoder(rw)
	return e.Encode(o)
}


type xserde struct{}

func (s xserde) deserialize(r *http.Request, i any) error {
	d := xml.NewDecoder(r.Body)
	defer r.Body.Close()
	return d.Decode(i)
}

func (s xserde) serialize(o any, rw http.ResponseWriter) error {
	e := xml.NewEncoder(rw)
	return e.Encode(o)
}
```
