---
title: Writing a Go Linter
date: 2019-12-30T10:21:00
tags: [ golang, linter ]
guid: d460b73b-04ed-496a-bde2-a2d4aaac2c9e
---
I wrote a little linter for Go.  Here's why and how.

<!--more-->

These days I primarily write Go [at
work](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) (if you've been reading
this blog and hadn't noticed... How?)  Go is a statically typed language with
some other nice benefits.  For those new to go, you can copy paste nearly all
of the examples from this post to [The Go Playground](https://play.golang.org/)
to see what they do and how they work.

Function definitions look like this:

```golang
package main

import "fmt"

func main() {
	printName("frew")
}

func printName(name string) {
	fmt.Println("My name is", name)
}
```

If you want to have a function take a non-static number of (known as variadic)
parameters you'd write something like this:

```golang
package main

import "fmt"

func main() {
	printNames("frew", "frioux")
}

func printNames(names ...string) {
        for _, name := range names {
                fmt.Println("My name is", name)
        }
}
```

Great.  But what if you want to have your variadic parameters be of
varying types?  The most basic way to do that is using an empty interface:
`interface{}`.  **When you do this you are giving up all compile time
garauntees.**  Here's how it might work:

```golang
package main

import "fmt"

func main() {
	printJunk("frew", 1, []float32{1.0, 3.5})
}

func printJunk(debris ...interface{}) {
        for _, val := range debris {
                fmt.Printf("%T %v", val, val)
        }
}
```

The above works and has no requirements.  Almost nothing could go wrong there,
so it's fine.

Here's an example of where it actually would matter; this is a real API we
use at work, though the implementation has been changed for simplicity.


```golang
package main

import (
	"os"
	"encoding/json"
)

func main() {
	log("server went down!", "pid", os.Getpid())
	// log("help it's crashing!", "pid", os.Getpid(), "woops")
	// log("I have no idea what I'm doing", os.Getpid(), "pid")
}

func log(message string, v ...interface{}) error {
	toLog := map[string]interface{}{"message":message}
	e := json.NewEncoder(os.Stdout)
	for i := 0; i < len(v); i += 2 {
		key := v[i].(string) // !!!
		value := v[i+1]
		toLog[key] = value
	}
	return e.Encode(toLog)
}
```

The two commented out calls to `log` will panic.  The first because we are
going past the end of an array, and the second because we are asserting that
an int is a string.

We handle this a little bit more gracefully in our library at work, but it
still panics, just a little bit more clearly.  The goal of my linter is to
surface both of these issues; concretely they are:

 1. Odd number of pair-values.
 2. Non-string for key in pair.

So I built that!  The following is the entirety of the code, with a generous
amount of comments on how you might refactor it if you wanted to maintain
a public version.  That said, this works out of the box:

---

```golang
package main

// go/ast and go/types are some of the most complex packages I've
// worked with in Go.  It is almost critical that you read this tutorial
// (https://golang.org/s/types-tutorial) to be able to work with them.
// If you haven't read that tutorial, this post is likely to be
// incomprehensible, but maybe it's concrete enough to help anyway.

// astutil provides a handy callback interface that can be used both to
// walk through the syntax tree as well as transform it.

// packages is especially critical now that modules have become commonplace.
// Before packages existed it was a big hassle to get go/types and go/ast
// working on a source tree.

// If I were to release a standalone library I'd rephrase this in terms of
// golang.org/x/tools/go/analysis; it works very similarly to packages, but
// adds some other nice benefits.  Check it out.

import (
	"errors"
	"fmt"
	"go/ast"
	"go/constant"
	"go/types"
	"os"

	"golang.org/x/tools/go/ast/astutil"
	"golang.org/x/tools/go/packages"
)

func main() {
	// This should use flag, but it works for my purposes.  By default
	// we lint the current package, but the user can pass something else
	// (like `./...` to lint all packages under the current directory)
	// to lint other stuff.
	pattern := "."
	if len(os.Args) > 1 {
		pattern = os.Args[1]
	}
	if err := run(pattern); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(pattern string) error {
	// Each of the flags below that we pass to packages has a measurable
	// cost.  I am pretty sure I don't need all of them, but this becomes moot
	// if we use analysis, so I didn't stress too much about it.
	cfg := &packages.Config{Mode: packages.NeedDeps | packages.NeedImports | packages.NeedName | packages.NeedSyntax | packages.NeedTypes | packages.NeedTypesInfo | packages.NeedTypesSizes}

	pkgs, err := packages.Load(cfg, "pattern="+pattern)
	if err != nil {
		return fmt.Errorf("load: %s", err)
	}

	if packages.PrintErrors(pkgs) > 0 {
		os.Exit(1)
	}

	if len(pkgs) == 0 {
		return errors.New("no packages found")
	}

	// These package functions are hardcodeded for linting.
	// These should be passed via flag, which the analysis package would simplify.
	argsOffset := map[string]int{
		"go.zr.org/common/go/log+Debug":         3,
		"go.zr.org/common/go/log+Info":          3,
		"go.zr.org/common/go/log+Log":           3,
		"go.zr.org/common/go/log+InfoSampled":   4,
		"go.zr.org/common/go/log+NewFromWriter": 1,
		"go.zr.org/common/go/log+WithDetails":   1,
		"go.zr.org/common/go/log+NewBuffer":     0,
		"go.zr.org/common/go/errors+Wrap":       2,
	}

	// Lint each package we find.
	for _, p := range pkgs {
		i := p.TypesInfo

		// Each of these is a parsed file.
		for _, f := range p.Syntax {

			// Here's where we walk over the syntax tree.  We can
			// return false to stop walking early.  The code could
			// probably be faster by carefully stopping the walk
			// early, but I decided that probably wasn't worth the
			// effort.
			astutil.Apply(f, func(cur *astutil.Cursor) bool {

				// Find all call expression (functions,
				// methods) This is one of the weird ways that
				// both go/types and go/ast works: you have
				// to type assert everything.  You use type
				// switches if you need to branch out.
				c, ok := cur.Node().(*ast.CallExpr)

				// if it's not a call, bail out.
				if !ok {
					return true
				}

				// verify that the function being called is a
				// selector.  A selector in Go looks like
				// `foo.bar`.  Read more here:
				// https://golang.org/ref/spec#Selectors
				s, ok := c.Fun.(*ast.SelectorExpr) // possibly method calls
				if !ok {
					return true
				}

				// package functions
				nv, ok := i.Selections[s]
				// If you happened to read the selector
				// spec above, you'll note that a function
				// call like `fmt.Printf` is not a selector.
				// If this node is not found in the Selections
				// map we know it's not a selection, and is instead
				// a qualified identifier.
				if !ok {
					// A selector has an X and a Sel;
					// the X is the part on the left of the
					// dot, the Sel is the part on the right.
					//
					// Here, we assert that if it's not a selector,
					// X must be an *ast.Ident, that it's
					// in the Uses map, and that whatever
					// is there must be a package name.
					//
					// I cannot believe that this
					// never panicked on our codebase, with
					// over a quarter million lines of Go.
					pkgName := i.Uses[s.X.(*ast.Ident)].(*types.PkgName) // 😅
					path := pkgName.Imported().Path()

					// here we combine the package path
					// and the name of the function to
					// get the configured offset to start
					// looking for pairs.
					offset, ok := argsOffset[path+"+"+s.Sel.Name]
					if !ok { // we don't care about this function
						return true
					}

					// This checks for odd args (after the offset) to package functions.
					if (len(c.Args)-offset)%2 != 0 {
						fmt.Printf("%s %d args passed to %s; must be even\n",
							p.Fset.Position(c.Pos()),
							len(c.Args),
							path+"."+s.Sel.Name,
						)
					}

					// Check all args of the *ast.CallExpr
					// starting at offset, and we're done
					// with packages!
					checkArgs(p, path+"."+s.Sel.Name, offset, c)

					return true
				}

				// The following hardcodes Log rather than
				// doing something more flexible like taking a
				// slice of type names.  While it would be good to
				// take a slice of type names, Log is actually an
				// interface anyway, so there isn't a concrete
				// type to look for.  I could check to see if the
				// value implements the Logger interface, which I
				// might do some time down the road, but this has
				// almost zero false positives anyway.
				if s.Sel.Name != "Log" {
					return true
				}
				// Get the named type of the reciever.  If the
				// thing has no name we just ignore it.  I am not
				// sure how you could have an anonymous receiver
				// in Go anyway.
				named, ok := nv.Recv().(*types.Named)
				if !ok {
					return true
				}

				// As with packages, we check for an odd number of args.
				if len(c.Args)%2 != 0 {
					fmt.Printf("%s %d args passed to %s; must be even\n",
						p.Fset.Position(c.Pos()),
						len(c.Args),
						types.ObjectString(named.Obj(), nil),
					)
				}

				// Check the individual args for Log.
				checkArgs(p, types.ObjectString(named.Obj(), nil), 0, c)
				return true
			}, nil)
		}
	}

	return nil
}

// checkArgs prints a warning if the arguments to c are not even with string
// keys after the offset.
func checkArgs(p *packages.Package, name string, offset int, c *ast.CallExpr) {
	// This will probably just end up a compile time failure since it means
	// someone probably missed some non-variadic parameters.
	if len(c.Args) <= offset {
		return
	}
	for i, a := range c.Args[offset:] {
		// Skip the odd values.
		// I don't know why I did this instead of for i := offset; i < len(c.Args); i += 2.
		if i%2 != 0 {
			continue
		}

		// typ will have a Value if the argument is constant or a Type
		// if it's not a constant expression.  I don't think anything can
		// ever be both.
		typ := p.TypesInfo.Types[a]

		// This runs when the type is a constant but not a string.
		if typ.Value != nil { // constant
			if typ.Value.Kind() != constant.String {
				fmt.Printf("%s arg %d to %s is constant %s but should be a constant string\n",
					p.Fset.Position(a.Pos()),
					i+offset,
					name,
					types.TypeString(typ.Type, nil),
				)
			}
			continue
		}

		// This runs if it's an expression that's not actually a string.
		if typ.Type != nil { // expression
			b, ok := typ.Type.Underlying().(*types.Basic)
			if ok && b.Kind() == types.String {
				// it's a string expression, this is not preferred, but is acceptable
				continue
			}
			fmt.Printf("%s arg %d to %s is expression %s but should be a constant string\n",
				p.Fset.Position(a.Pos()),
				i+offset,
				name,
				types.TypeString(typ.Type, nil),
			)
		}
	}
}
```

---

I'm pretty pleased with this!  I wrote it entirely while my kids were resting
during naptimes while taking a Christmas vacation.  When I ran it against our
work repo it found a few dozen issues, but many of them will be non-trivial
to fix.  Most of the problems are not of these problematic forms:

```golang
log("hello!", "user", user, "pid", pid, "bonus") // extra arg
log("hello!", 1, "flag")                         // key is an int
```

They are instead like this:

```golang
data := []interface{"user", user, "pid", pid}
log("hello!", data...)
```

The above is not wrong, but it means we cannot detect the mistake that this
post is about, and it also makes the code harder to read.  My intention is
to remove the vast majority of this from the codebase, but *some* of it in
central places in the code, like HTTP middleware that logs some arbitrary
pile of parameters.

---

(The following includes affiliate links.)

I'm currently reading
<a target="_blank" href="https://www.amazon.com/gp/product/1732102201/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1732102201&linkCode=as2&tag=afoolishmanif-20&linkId=69fd8dd4af8463070c10dc3039ca5e35">A Philosophy of Software Design</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1732102201" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has some strong opinions I'm not sure I agree with, but it also has some
good rules of thumb that I think are worth internalizing.

I also just got <a target="_blank" href="https://www.amazon.com/gp/product/0136554822/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136554822&linkCode=as2&tag=afoolishmanif-20&linkId=1cc427f499bf6b66725fd76a0f4364b2">BPF Performance Tools</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136554822" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I'm really excited for this, as longtime readers and friends probably know.
I even have a little (or not so little?) project in mind.
