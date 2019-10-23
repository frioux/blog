---
title: go/types package
date: 2019-05-21T19:20:05
tags: [ golang ]
guid: 3fe980cc-b897-4b8d-b43e-0500e31b1760
---
This past weekend I spent some time playing with the `go/types` package.  It was
pretty cool!

<!--more-->

I have this idea for a tool that will take a Go program and automatically add a
bunch of fault injection code, so you can ensure that rare faults are handled in
a sane way.  I read a paper a year or two ago that did a bunch of analysis of
bugs in distributed systems and showed that most of the bugs would have been
found by just running the code in the error paths.  My idea is just to make that
trivial, or at least easier than faking weird distributed system codepaths.

While trying to write the above, I stumbled across [The Go Type
Checker](https://github.com/golang/example/tree/master/gotypes), a ten thousand
word document by Alan Donovan about go's `go/types` package (and `go/ast`.)  The
document is really eye opening and a very welcome narrative introduction to such
an intimidating, complex package.  If you ever intend to, or even are interested
in writing some kind of Go linter, I suggest reading the above document.

After reading something like half of the above doc I was able to write this
little tool, which will at least identify all the locations where a variable
conforms to the `error` interface.

```golang
package main

import (
	"fmt"
	"go/ast"
	"go/importer"
	"go/parser"
	"go/token"
	"go/types"
	"log"
)

type visitor func(n ast.Node) ast.Visitor

func (v visitor) Visit(n ast.Node) ast.Visitor {
	return v(n)
}

// errType just defines error in terms of go/types
var errType *types.Interface

func init() {
	errType = types.NewInterfaceType([]*types.Func{
		types.NewFunc(0, nil, "Error",
			types.NewSignature(
				nil,              // Receiver
				types.NewTuple(), // Params
				types.NewTuple(types.NewParam(0, nil, "", types.Typ[types.String])), // Result
				false,
			),
		),
	}, nil)

	errType.Complete()
}

func main() {
	// parse the directory of go code
	fset := token.NewFileSet()
	src, err := parser.ParseDir(fset, ".", nil, 0)
	if err != nil {
		panic(err)
	}

	// type check the code
	conf := types.Config{Importer: importer.Default()}
	fs := []*ast.File{}
	for _, tree := range src {
		for _, f := range tree.Files {
			fs = append(fs, f)
		}
	}
	i := &types.Info{Types: map[ast.Expr]types.TypeAndValue{}}
	if _, err := conf.Check("cmd/hello", fset, fs, i); err != nil {
		log.Fatal(err) // type error
	}

	// walk the ast, priting any expression that implements to error
	var v visitor

	v = func(n ast.Node) ast.Visitor {
		e, ok := n.(ast.Expr)
		if !ok {
			return v
		}

		t := i.Types[e].Type
		if implements(t, errType) {
			fmt.Printf("%s, %T %+v %v\n", fset.Position(n.Pos()), n, n, t)
		}

		return v
	}

	ast.Walk(v, fs[0])
}

// implements returns false if t doesn't implement i
//
// The standard types.Implements panics on false, making it inconvenient for
// simple checking.
func implements(t types.Type, i *types.Interface) (ok bool) {
	defer func() {
		if r := recover(); r != nil {
			ok = false
		}
	}()
	ok = types.Implements(t, i)

	return
}
```

I wish the above were less hard earned, but the surface area of `go/types` and
`go/ast` made it much harder for me to write.  On top of it the `ast.Node`
interface is not the typical interface in any OO language; basically there are
only a few types in `go/ast` that implement the interface, and when you check it
you are expected to check from a small, specific set of types implementing it.
(This is called a *discriminated union*, a term I either forgot or never knew.)

Anyway, hopefully next time I play with this code I'll make more progress and be
able to share it then!

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

