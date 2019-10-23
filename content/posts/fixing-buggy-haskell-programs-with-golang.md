---
title: Fixing Buggy Haskell Programs with Go
date: 2019-02-27T07:11:08
tags: [ haskell, golang ]
guid: b940dc2a-6ebd-4a0f-b6c2-3a5f452e2230
---
I recently ran into a stupid bug in a program written in Haskell and found it
much easier to paper over with a few lines of Go than to properly fix.

<!--more-->

Some readers may remember that a couple years ago [I switched back to
XMonad](/posts/hello-xmonad-goodbye-awesomewm/); as part of that switch I
started using [TaffyBar](https://github.com/taffybar/taffybar) as a bit of
persistent UI to keep my system tray, CPU usage and memory usage graphs, a
couple weather widgets, and more.

For better or worse, the endpoints that all the weather widgets used changed a
couple weeks ago when [NOAA](https://www.noaa.gov/) decided to switch their
endpoints to HTTPS.  Some programs probably were able to update trivially,
either by simply adding an `s` to the URL scheme, or maybe less, by following a
redirect.

Sadly, the Haskell program in question used an HTTP client that *doesn't support
TLS out of the box.*  The upshot of this is that [you need to do some relatively
major surgery to update the
program](https://github.com/taffybar/taffybar/pull/439/commits/327bc64ce9894c47b55126743baa91ba5d9ff590).
I might consider that had I not had to deal with Haskell before; in my
experience casually using Haskell is like giving yourself a tattoo.  Painful,
frustrating, and not very useful in the long run.

I had a conversation at work with my coworker, Joshua Pollack, and together we
came to the conclusion that a much more sensible solution would be to just build
a little proxy.  In just under an hour I was able to get something put together!
I made it yet another tool within [my
leatherman](https://github.com/frioux/leatherman) and creatively [named it
`noaa-proxy`](https://github.com/frioux/leatherman/commit/11fc9eb575494718e87042064079c084e335acf2).

For the record, here is all of the code:

```golang
package noaa

import (
	"io"
	"net/http"
	"net/http/httputil"
	"net/url"
)

var upstream *url.URL

func init() {
	// Manually resolved CNAME of tgftp.nws.noaa.gov
	u, err := url.Parse("https://tgftp.cp.ncep.noaa.gov")
	if err != nil {
		panic("Couldn't parse url: " + err.Error())
	}
	upstream = u
}

// Proxy starts a proxy that can pretend to be the old noaa on http while
// actually proxying to noaa on https.
func Proxy(_ []string, _ io.Reader) error {
	http.Handle("/", httputil.NewSingleHostReverseProxy(upstream))

	return http.ListenAndServe(":9090", nil)
}
```

Because the Haskell program doesn't support proxies or anything, I had to hack
this in with an entry in `/etc/hosts`.  That was a pretty limiting factor here.

First I tried having it proxy to the IP address instead of another hostname.
That didn't work because TLS validation failed.  Even by disabling validation,
it still failed validation, because it finds the IP address in the cert before
calling the validation function.

After that I tried to hook into the DNS resolver so that I could have it bypass
my entry in the hostsfile.  I couldn't get that to work either.  Thankfully the
CNAME I found works so I was able to give up and call it done.  None of that
would have been necessary if I were willing to either run it in a docker
container or somewhere in the cloud, but I was too lazy for either of those.

---

This was annoying, but way less annoying than setting up a Haskell environment
to either backport a patch from a 2.x version or a 0.4.x version or compile and
run the 2.x version myself.  All told it took less than an hour.

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
