---
title: Go Concurrency Patterns
date: 2018-10-22T07:20:39
tags: [ golang, concurrency ]
guid: 9ff7b958-fb3a-475d-9522-4de450d6bbbb
---

I've been spending some time the past couple of weeks playing with some of [my
personal Go tools.](/posts/benefits-using-golang-adhoc-code-leatherman/) Nearly
everything I did involved concurrency, for a change.  I'll document how I did it
and some of the wisdom I've gathered from others here.

<!--more-->

First off, concurrency, even with the simple, relatively straightforward
primitives that are built into Go, is inherently complicated.  With this in mind
I heartily encourage that anyone learning Go resist using concurrency
(goroutines and channels, to be clear) until you have a solid grasp of the rest
of the language.

## Recommendations

With that gentle caution out of the way, I'll dive into more positive
recommendations.

### Minimize the Concurrent Interface

Think of concurrency like a web interface; you don't (or at least shouldn't)
return HTML fragments from your ORM.  If you do, presumably there are lower
level methods that return the data undefiled by the current whims of the
front-end world.

Most of your code should be written in a direct fashion: arguments come in,
return values come out.  Easy to test, easy to reason about.  The vast majority
of your code shouldn't interact with channels or run goroutines.  It should be
obvious, but code also should not return callbacks that represent deferred or in
progress work.

### Avoid Premature Optimization of Concurrency

The Go community *loves* optimization, probably more than is warranted.  I would
say that generally speaking this is mostly harmless, but when it comes to
channels and goroutines this should most definitely be avoided unless the
measurable improvement is significant.  A concrete example is the creation of a
worker pool; goroutines are cheap to create and cheap to tear down.  Create a
goroutine that does something, not a goroutine that is a long-lived worker.
I'll show examples of this later.

(I feel compelled to point out that, due to the fact that Go uses a coöperative
scheduler, any goroutine that is CPU bound could starve your whole program.  If
you know for sure that you are writing such a function and that it's likely to
take a while, it would be wise to add a `runtime.Gosched()` (formerly spelled
`time.Sleep(0)`) in a few places.)

### Leverage Built-in Thread Safety

I have no idea how much this permeates the language, but I know that there are
some commonly used bits of functionality that are safe for concurrent use.  The
example I have in mind is writing to files, at least in Unix.  I had some code
that mapped a channel to a goroutine which was then writing to standard out (and
the same pattern for standard error.)  The code worked, but because files
already have locking on the Write method it was overkill.  [Check out how much
simpler it made the
code](https://github.com/frioux/leatherman/commit/68565964b187c8a4ab66f36cf4389610087b1648).
(Note also that the link includes a reference to the implementation of said
locking.)

## Patterns

The following are patterns that I've found that are pretty simple and reliable.
I'll go over how they work and the tradeoffs involved.

### Safe Completion

I suspect anyone who has used goroutines very much knows this, but it's
important to learn in any case.  goroutines don't signal completion out-of-the
box.  There are a few ways you could build blocking on completion, but for the
patterns here we'll be using [the `sync.WaitGroup`
type](https://golang.org/pkg/sync/#WaitGroup).  The general pattern is that you
`Add` to the waitgroup before starting the goroutine and `Done` (which
decrements) inside your goroutine.  The first example below will show how it
works.  It's important to remember that if you are Adding from inside the body
of a goroutine you are *probably* making a mistake (though not surely.)

### Concurrent Outputs

Barely a pattern at all, but a good starting point for any concurrent code:

```golang
wg := sync.WaitGroup{}

tokens := make(chan struct{}, 10)

coffees, err := sweetmarias.AllCoffees()
if err != nil {
	return errors.Wrap(err, "sweetmarias.AllCoffees")
}

e := json.NewEncoder(os.Stdout)

for _, url := range coffees {
	wg.Add(1)
	tokens <- struct{}{}
	url := url
	go func() {
		defer func() { <-tokens; wg.Done() }()
		c, err := sweetmarias.LoadCoffee(url)
		if err != nil {
			fmt.Fprintln(os.Stderr, errors.Wrap(err, "sweetmarias.LoadCoffee"))
			return
		}
		err = e.Encode(c)
		if err != nil {
			fmt.Fprintln(os.Stderr, errors.Wrap(err, "json.Encode"))
		}
	}()
}

wg.Wait()
```

In the code above we use a WaitGroup to block until all of the outstanding
goroutines have completed.  The other pattern used above is the `tokens` channel
being used to avoid more than 10 goroutines running at the same time.  As
mentioned before, this means we don't have a pool of 10 workers, but instead are
running up to 10 goroutines.  The implication is that as we are ramping up work
or finishing the last remaining jobs we only have that many goroutines, instead
of idle goroutines waiting on work to do.

The nice thing about the pattern above is that the output will appear as it is
ready, which is nice in Unix pipelines or just for users to be aware that work
is being done in a natural way (as opposed to a spinner or something like that.)
The main drawback is that the order of the output is almost completely unrelated
to anything other than the speed of the underlying functions.

Note especially the `defer` to handle the tokens and wait group in the
goroutine.  In previous versions of this code I just did this at the end of the
function, but as you add error handling with early returns you should switch to
a defer.  Otherwise your code will hang forever.

### Concurrent Maps

The following is a clever pattern that I suspect is nearly ubiquitous in the Go
world.  Similar to the pattern above, but each goroutine maps to a slot within a
slice.  Slices are safe to modify concurrently (unlike maps.)

```golang
tokens := make(chan struct{}, 10)
wg := sync.WaitGroup{}

for i := range lines {
	i := i
	wg.Add(1)
	tokens <- struct{}{}

	go func() {
		lines[i] = replaceLink(lines[i])
		<-tokens
		wg.Done()
	}()
}

wg.Wait()

for _, line := range lines {
	fmt.Println(line)
}
```

Unlike concurrent outputs, this code will only print the output when all that
data is ready, but also order is maintained in a relatively natural way.

---

Hopefully these examples help you get started with some safe, concurrent code.
I found them confusing at first but now I can write them with without referring
to documentation or examples.

---

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

