---
title: Announcing mozcookiejar
date: 2018-04-20T7:45:02
tags: [ golang, firefox, mozilla, cookies, cookiejar ]
guid: 45efc241-ed83-4b7f-8f9e-f7e932f71d8b
---
I built a little package for loading Firefox cookies into my Go tools!

<!--more-->

[As I posted about a few months
ago](/posts/benefits-using-golang-adhoc-code-leatherman/), I've been porting
bits and pieces of my personal kit to Go lately.  One of the tinier tools is
called `expand-link`.  It needed some serious love since it functions for a
format which [has since been replaced](/posts/getting-things-done/) ([by
markdown](/posts/a-love-letter-to-plain-text/#notes)).  The basic idea of this
tool is that it reads a link on standard in and writes it with a title
(extracted from the HTML) to standard out.

It's a basic tool, but there are *a lot* of moving parts there.  The initial bit
I had to figure out was extracting the title.  Perl has a ton of mature
libraries for these kinds of tasks.  Go has solid foundations, but high level
tooling like this is at a minimum harder to find.  Even after finding a [high
quality low-level option](https://godoc.org/golang.org/x/net/html) and [a couple
sketchier](https://github.com/headzoo/surf) [high-level
options](https://github.com/PuerkitoBio/goquery), there was still another
missing part.

When it comes to simply getting the title of pages, I want the tool to work
reliably and mindlessly.  Part of the way I'd done this before was by leveraging
[HTTP::Cookies::Mozilla](https://metacpan.org/pod/HTTP::Cookies::Mozilla), a
cookiejar that is populated directly from the Firefox cookies.  This means that
for pages that require auth, the tool is effectively already logged in.
Sometimes this doesn't work, but most of the time it does.

Unfortunately nothing like that existed for Go.  I intially decided I'd just
work on something else, but it nagged at me, and seemed pretty easy (especially
if I didn't jump through all of the hoops that the Perl one did by just
requiring that the user have SQLite installed.)

So I wrote the module!

## `github.com/frioux/mozcookiejar`

Here's how you might use it:

``` go
package main

import (
	"database/sql"
	"fmt"
	"io"
	"net/http"
	"net/http/cookiejar"
	"os"

	"github.com/frioux/mozcookiejar"
	"golang.org/x/net/publicsuffix"

	_ "github.com/mattn/go-sqlite3"
)

func main() {
	jar, err := cookiejar.New(&cookiejar.Options{PublicSuffixList: publicsuffix.List})
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to build cookies: %s\n", err)
		os.Exit(1)
	}
	db, err := sql.Open("sqlite3", os.Getenv("MOZ_COOKIEJAR"))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to open db: %s\n", err)
		os.Exit(1)
	}
	defer db.Close()

	err = mozcookiejar.LoadIntoJar(db, jar)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to load cookies: %s\n", err)
		os.Exit(1)
	}
	ua := http.Client{Jar: jar}

	resp, err := ua.Get("https://some.authenticated.com/website")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to fetch page: %s\n", err)
		os.Exit(1)
	}
	io.Copy(os.Stdout, resp.Body)
}
```

Currently the API is as simple as the sole method: `LoadIntoJar`.  I figure at
some point I may support going the other direction, but I have no need for that
so will wait till someone else submits a patch.

## How the Sausage is Made

For the most part this was simply writing the [fairly straightforward
code](https://github.com/frioux/mozcookiejar/blob/d62f0616e7c8285cd5d4876fd6c07bb3587e85b9/cookiejar.go#L48)
for the package.  The testing was nice [as discussed
before](/posts/benefits-using-golang-adhoc-code-leatherman/#unexpected-benefits-of-writing-scripts-in-go).
Documenting a module for OSS consumption was both harder and easier than it is
in Perl.  It is great to have docs *actually* related to bits of code, as well
as a signature with types, which inform actual usage really well.  On the other
hand generating a sensible README from Go documentation is a pain.  [I came
up](https://github.com/frioux/mozcookiejar/blob/d62f0616e7c8285cd5d4876fd6c07bb3587e85b9/bin/gen-readme)
[with something](https://github.com/frioux/godoc2md) but it's messy.

What I *really* enjoyed though was documenting an `Example`.  The code above is
actually a copy paste from [the example
code](https://github.com/frioux/mozcookiejar/blob/d62f0616e7c8285cd5d4876fd6c07bb3587e85b9/examples_test.go#L16)
which is included with my library.  The neat thing is that the example code is
actually compiled to ensure that syntax is correct, and if you add extra stuff
([more detail here](https://blog.golang.org/examples)) it will actually be run
when tests are run.

This is not something unique to Go ([Rust has the same
functionality](https://github.com/frioux/cgid/blob/master/src/lib.rs#L48), and I
believe it can be done in Python, though I don't think it's built in) but it is
a pleasure nonetheless.

---

Overall this was a pleasant experience, though there is a distinct lack of
[automation](/posts/farewell-cpan-contest/#dist-zilla) for releasing software.
I suspect some of that will improve with time, especially given the current work
on [vgo](https://research.swtch.com/vgo-tour).

---

(The following includes affiliate links.)

If you want to learn more about programming Go, you should check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It is one of the best programming books I've read.  You will not only learn Go,
but also get some solid introductions on how to write code that is safely
concurrent.  **Highly recommend.**  This book is so good that I might write a
blog post solely about learning Go with this book.

I haven't started reading it yet, but on my list in programming books to read is
<a target="_blank" href="https://www.amazon.com/gp/product/1449373321/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1449373321&linkCode=as2&tag=afoolishmanif-20&linkId=96316cc857f61b82439f447415a9ad20">Designing Data-Intensive Applications</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1449373321" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I have heard great things.
