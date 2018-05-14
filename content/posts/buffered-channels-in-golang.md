---
title: Buffered Channels in Golang
date: 2018-05-14T06:56:13
tags: [ golang, fibonacci ]
guid: 879a43f1-4a58-4e11-8eaf-f1ea7e648d90
---
A few weeks ago when I was reading <a target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=7a70d548d8d1ab0e0baf86848938c69a">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" /> I was reading about buffered channels and had a gut instinct
that I could write some code taking advantage of them in a precise way.
This was the comical code that came out of it.

<!--more-->

In Go a channel is typically used to pass messages from one goroutine to
another, but a channel can be used to pass data in other situations too; it's
just more expensive to use a channel than, say, a function call.  A channel
blocks once it's either full (for writing) or empty (for reading.)  So when a
channel has a single slot (an unbuffered channel) things that use channels work
in lockstep and are synchronized.

A buffered channel has more than one slot, but once the channel is full or empty
it works the same.  Really all the buffering does is give you a little slack.
When I read this I thought for a couple minutes about what ridiculous code I
could write using a buffered channel.  Here's what I came up with:

``` go

package main

import "fmt"

func main() {
	c := make(chan int, 2)
	c <- 1
	c <- 0

	for {
		n := <-c
		fmt.Println(n)
		c <- n + <-c
		c <- n
	}
}
```

It's the Fibonacci sequence using the iterative solution, but instead of two
variables or an array, this uses a channel as a kind of ring buffer.  It's
ridiculous and stupid, but it was fun and it works.

Comically, to me, it's so fast that it exhausts the integer type almost
immediately, thus printing negative numbers and other nonsense.  Here's the
`bigint` version:

``` go
package main

import "fmt"
import "math/big"

func main() {
	c := make(chan *big.Int, 2)
	c <- big.NewInt(1)
	c <- big.NewInt(0)

	for {
		n := <-c
		fmt.Println(n)
		c <- big.NewInt(0).Add(n, <-c)
		c <- n
	}
}
```

---

As I've mentioned before, to learn more about Go, I strongly recommend <a
target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=7a70d548d8d1ab0e0baf86848938c69a">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  It's one of the best language oriented programming books I've
ever read, and one of the best on it's own.  I suggest reading it even if you
already know Go in and out.
