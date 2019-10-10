---
title: Direct Observation with Go Tooling
date: 2019-10-10T07:03:03
tags: [ golang ]
guid: b4615f9d-5279-48ad-acdc-91a066eaef9d
---
Today I investigated a hunch using some nice tooling built into the Go
compiler.

<!--more-->

[At work](https://www.ziprecruiter.com/hiring/technology) I'm building a tool
that will generate nginx config to act as a dispatcher for all of our various
software that the external world interacts with.  A bunch of this work has been
done, with other goals, in
[ingress-nginx](https://github.com/kubernetes/ingress-nginx/), so I've been
using bits and pieces of the code from that project as a jumping off point.

Today I found [this
section](https://github.com/kubernetes/ingress-nginx/blob/97577c07a57b2c9160d927825fbb01cb2912a46b/internal/ingress/controller/template/buffer_pool.go#L30-L40):

```golang
func NewBufferPool(s int) *BufferPool {
	return &BufferPool{
		Pool: sync.Pool{
			New: func() interface{} {
				b := bytes.NewBuffer(make([]byte, s)) // create *bytes.Buffer
				b.Reset()                             // reset it
				return b
			},
		},
	}
}
```

The comments are mine, and are the relevant lines for this blog post.  I had a
hunch that the above could be written both more neatly and actually perform
better as:

```golang
b := bytes.NewBuffer(make([]byte, 0, s))
```

That's making a zero length byte slice, but with a capacity of s.  The Go
compiler has surprised me before but optimizing away silly stuff (like setting
fields in maps to their zero value, like someone would do in Python) so I
figured I'd check to be sure.

First I created a little test program:

```golang
package main

import (
	"bytes"
	"fmt"
)

func main() {
	s := 1024
	p := bytes.NewBuffer(make([]byte, 0, s))
	p.Reset()
	fmt.Printf("%#v\n", p)
}
```

Running the above produces `&bytes.Buffer{buf:[]uint8{}, off:0, lastRead:0}`,
but that's not actually what I am interested in.  Go ships with a tool to
display the actual assembly (or some vague layer atop assembly) of the built
code.  Using `go tool objdump -S -s main.main ./binary` we can get the full
assembly of a given function.  Here's a subset of the output from that:

```
        p := bytes.NewBuffer(make([]byte, 0, s))
  0x48ec81              488d0518170100          LEAQ 0x11718(IP), AX
  0x48ec88              48890424                MOVQ AX, 0(SP)
  0x48ec8c              48c744240800000000      MOVQ $0x0, 0x8(SP)
  0x48ec95              48c744241000040000      MOVQ $0x400, 0x10(SP)
  0x48ec9e              e8fddefaff              CALL runtime.makeslice(SB)
  0x48eca3              488b442418              MOVQ 0x18(SP), AX
  0x48eca8              4889442450              MOVQ AX, 0x50(SP)
func NewBuffer(buf []byte) *Buffer { return &Buffer{buf: buf} }
  0x48ecad              488d0dcc1c0200          LEAQ 0x21ccc(IP), CX
  0x48ecb4              48890c24                MOVQ CX, 0(SP)
  0x48ecb8              e8a3caf7ff              CALL runtime.newobject(SB)
  0x48ecbd              488b7c2408              MOVQ 0x8(SP), DI
  0x48ecc2              48c7471000040000        MOVQ $0x400, 0x10(DI)
  0x48ecca              833d2fdf0e0000          CMPL $0x0, runtime.writeBarrier(SB)
  0x48ecd1              0f858d000000            JNE 0x48ed64
  0x48ecd7              488b442450              MOVQ 0x50(SP), AX
  0x48ecdc              488907                  MOVQ AX, 0(DI)
        p.Reset()
  0x48ecdf              90                      NOPL
        b.buf = b.buf[:0]
  0x48ece0              48c7470800000000        MOVQ $0x0, 0x8(DI)
        b.off = 0
  0x48ece8              48c7471800000000        MOVQ $0x0, 0x18(DI)
        b.lastRead = opInvalid
  0x48ecf0              c6472000                MOVB $0x0, 0x20(DI)
        fmt.Printf("%#v\n", p)
```

My plan was to diff the old and the new, but with all the offsets in place I new
that wouldn't work, so I made a tool to filter the above output to be at least
slightly more stable:

```bash
#!/bin/sh

go tool objdump -S -s main.main $1 | perl -p -e "s/^\s+0x[0-9a-f]{6}\t+[0-9a-f]+\t+/\t\t/"
```

Using that my output becomes:

```
func NewBuffer(buf []byte) *Buffer { return &Buffer{buf: buf} }
                LEAQ 0x21ccc(IP), CX
                MOVQ CX, 0(SP)
                CALL runtime.newobject(SB)
                MOVQ 0x8(SP), DI
                MOVQ $0x400, 0x10(DI)
                CMPL $0x0, runtime.writeBarrier(SB)
                JNE 0x48ed64
                MOVQ 0x50(SP), AX
                MOVQ AX, 0(DI)
        p.Reset()
                NOPL
        b.buf = b.buf[:0]
                MOVQ $0x0, 0x8(DI)
        b.off = 0
                MOVQ $0x0, 0x18(DI)
        b.lastRead = opInvalid
                MOVB $0x0, 0x20(DI)
        fmt.Printf("%#v\n", p)

```

I built the old binary and named it `reset` with `go build -o reset`, created
the new version (code below) and named it `noreset` with `go build -o noreset`.

```golang
package main

import (
	"bytes"
	"fmt"
)

func main() {
	s := 1024
	p := bytes.NewBuffer(make([]byte, 0, s))
	fmt.Printf("%#v\n", p)
}
```

Finally, I diff'd the two, to see if indeed my version would be different (and
hopefully skip unneeded steps) by running
`diff -U5 <(simpledump reset) <(simpledump noreset)`.  Here's the relevant
section of the diff:

```diff
 func NewBuffer(buf []byte) *Buffer { return &Buffer{buf: buf} }
                LEAQ 0x21ccc(IP), CX
                MOVQ CX, 0(SP)
                CALL runtime.newobject(SB)
                MOVQ 0x8(SP), DI
-               MOVQ $0x400, 0x8(DI)
                MOVQ $0x400, 0x10(DI)
                CMPL $0x0, runtime.writeBarrier(SB)
-               JNE 0x48ed6c
+               JNE 0x48ed4b
                MOVQ 0x50(SP), AX
                MOVQ AX, 0(DI)
-       fmt.Printf("%#v\n", p)
-               NOPL
-       b.buf = b.buf[:0]
-               MOVQ $0x0, 0x8(DI)
-       b.off = 0
-               MOVQ $0x0, 0x18(DI)
-       b.lastRead = opInvalid
-               MOVB $0x0, 0x20(DI)
 }
                XORPS X0, X0
                MOVUPS X0, 0x58(SP)
-               LEAQ 0x2dd55(IP), AX
+               LEAQ 0x2dd76(IP), AX
                MOVQ AX, 0x58(SP)
                MOVQ DI, 0x60(SP)
        return Fprintf(os.Stdout, format, a...)
```

As I'd expected, the new version is actually simpler, but barely.  My hunch is
that this would not actually affect performance unless something else is wrong,
but the code is neater, works, and is slightly simpler.  Cool.

Side note: I'm not totally sure why the `fmt.Printf` call evaporates.  My only
guess is that stuff gets short enough to be inlined, but I really don't know.

---

If you are interested in learning Go, this is my recommendation:

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
