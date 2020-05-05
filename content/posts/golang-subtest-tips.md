---
title: Go Subtest Tips
date: 2020-05-05T08:13:37
tags: [ "golang", "testing" ]
guid: 507e1ff6-c0e9-434e-adf6-dc0036172b21
---
I recently learned more detail about subtests in Go.

<!--more-->

Testing in Go is a first class concept.  It's this easy (example taken from
[play.golang.org](https://play.golang.org):

```golang
package main

import (
	"testing"
)

// LastIndex returns the index of the last instance of x in list, or
// -1 if x is not present. The loop condition has a fault that
// causes somes tests to fail. Change it to i >= 0 to see them pass.
func LastIndex(list []int, x int) int {
	for i := len(list) - 1; i > 0; i-- {
		if list[i] == x {
			return i
		}
	}
	return -1
}

func TestLastIndex(t *testing.T) {
	tests := []struct {
		list []int
		x    int
		want int
	}{
		{list: []int{1}, x: 1, want: 0},
		{list: []int{1, 1}, x: 1, want: 1},
		{list: []int{2, 1}, x: 2, want: 0},
		{list: []int{1, 2, 1, 1}, x: 2, want: 1},
		{list: []int{1, 1, 1, 2, 2, 1}, x: 3, want: -1},
		{list: []int{3, 1, 2, 2, 1, 1}, x: 3, want: 0},
	}
	for _, tt := range tests {
		if got := LastIndex(tt.list, tt.x); got != tt.want {
			t.Errorf("LastIndex(%v, %v) = %v, want %v", tt.list, tt.x, got, tt.want)
		}
	}
}
```

([Try this at home](https://play.golang.org/p/kIZkoT2EvJX).)

The output of the above is:

```
=== RUN   TestLastIndex
    TestLastIndex: prog.go:34: LastIndex([1], 1) = -1, want 0
    TestLastIndex: prog.go:34: LastIndex([2 1], 2) = -1, want 0
    TestLastIndex: prog.go:34: LastIndex([3 1 2 2 1 1], 3) = -1, want 0
--- FAIL: TestLastIndex (0.00s)
FAIL

1 test failed.
```

Tests of any substance I tend to break up into subtests.  I might change the above like this:

```golang
package main

import (
	"strconv"
	"testing"
)

func LastIndex(list []int, x int) int {
	for i := len(list) - 1; i > 0; i-- {
		if list[i] == x {
			return i
		}
	}
	return -1
}

func TestLastIndex(t *testing.T) {
	tests := []struct {
		list []int
		x    int
		want int
	}{
		0: {list: []int{1}, x: 1, want: 0},
		1: {list: []int{1, 1}, x: 1, want: 1},
		2: {list: []int{2, 1}, x: 2, want: 0},
		3: {list: []int{1, 2, 1, 1}, x: 2, want: 1},
		4: {list: []int{1, 1, 1, 2, 2, 1}, x: 3, want: -1},
		5: {list: []int{3, 1, 2, 2, 1, 1}, x: 3, want: 0},
	}
	for i, tt := range tests {
		t.Run(strconv.Itoa(i), func(t *testing.T) {
			if got := LastIndex(tt.list, tt.x); got != tt.want {
				t.Errorf("LastIndex(%v, %v) = %v, want %v", tt.list, tt.x, got, tt.want)
			}
		})
	}
}
```

([Try this at home](https://play.golang.org/p/NP1Gaz9R82Y).)

The output of this version is:

```
=== RUN   TestLastIndex
=== RUN   TestLastIndex/0
    TestLastIndex/0: prog.go:33: LastIndex([1], 1) = -1, want 0
=== RUN   TestLastIndex/1
=== RUN   TestLastIndex/2
    TestLastIndex/2: prog.go:33: LastIndex([2 1], 2) = -1, want 0
=== RUN   TestLastIndex/3
=== RUN   TestLastIndex/4
=== RUN   TestLastIndex/5
    TestLastIndex/5: prog.go:33: LastIndex([3 1 2 2 1 1], 3) = -1, want 0
--- FAIL: TestLastIndex (0.00s)
    --- FAIL: TestLastIndex/0 (0.00s)
    --- PASS: TestLastIndex/1 (0.00s)
    --- FAIL: TestLastIndex/2 (0.00s)
    --- PASS: TestLastIndex/3 (0.00s)
    --- PASS: TestLastIndex/4 (0.00s)
    --- FAIL: TestLastIndex/5 (0.00s)
FAIL

4 tests failed.
```

There are two nice thing about subtests:

 * built in reporting of which tests failed (0, 2, and 5)
 * the ability to only run some subset of tests

The built in test framework allows running tests like this:

```bash
$ go test ./...
```

That runs tests for all of the go recursively under the current directory.
Sometimes when you are dealing with a failing test you might want to run just
the broken ones:

```bash
$ go test -v -run 'Last/[025]'
=== RUN   TestLastIndex
=== RUN   TestLastIndex/0
    TestLastIndex/0: x_test.go:33: LastIndex([1], 1) = -1, want 0
=== RUN   TestLastIndex/2
    TestLastIndex/2: x_test.go:33: LastIndex([2 1], 2) = -1, want 0
=== RUN   TestLastIndex/5
    TestLastIndex/5: x_test.go:33: LastIndex([3 1 2 2 1 1], 3) = -1, want 0
--- FAIL: TestLastIndex (0.00s)
    --- FAIL: TestLastIndex/0 (0.00s)
    --- FAIL: TestLastIndex/2 (0.00s)
    --- FAIL: TestLastIndex/5 (0.00s)
FAIL
FAIL    x       0.003s
FAIL
```

The `-run` flag to `go test` is a regex, or actually a bunch of regexen
separated with `/`s.  This is super handy and allows for realy brief
commandlines, but also there are some subtle implications.  Consider this
totally contrived code:

```golang
package main

import (
	"testing"
)

func LastIndex(list []int, x int) int {
	for i := len(list) - 1; i > 0; i-- {
		if list[i] == x {
			return i
		}
	}
	return -1
}

func TestLastIndex(t *testing.T) {
	tests := []struct {
		name string
		list []int
		x    int
		want int
	}{
		{name: "single", list: []int{1}, x: 1, want: 0},
		{name: "pair", list: []int{1, 1}, x: 1, want: 1},
		{name: "pair/different", list: []int{2, 1}, x: 2, want: 0},
		{name: "four", list: []int{1, 2, 1, 1}, x: 2, want: 1},
		{name: "five", list: []int{1, 1, 1, 2, 2, 1}, x: 3, want: -1},
		{name: "six", list: []int{3, 1, 2, 2, 1, 1}, x: 3, want: 0},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := LastIndex(tt.list, tt.x); got != tt.want {
				t.Errorf("LastIndex(%v, %v) = %v, want %v", tt.list, tt.x, got, tt.want)
			}
		})
	}
}
```

([Try at home.](https://play.golang.org/p/wTUizrttwuV))

Output is (hopefully unsurprisingly:)

```
=== RUN   TestLastIndex
=== RUN   TestLastIndex/single
    TestLastIndex/single: prog.go:33: LastIndex([1], 1) = -1, want 0
=== RUN   TestLastIndex/pair
=== RUN   TestLastIndex/pair/different
    TestLastIndex/pair/different: prog.go:33: LastIndex([2 1], 2) = -1, want 0
=== RUN   TestLastIndex/four
=== RUN   TestLastIndex/five
=== RUN   TestLastIndex/six
    TestLastIndex/six: prog.go:33: LastIndex([3 1 2 2 1 1], 3) = -1, want 0
--- FAIL: TestLastIndex (0.00s)
    --- FAIL: TestLastIndex/single (0.00s)
    --- PASS: TestLastIndex/pair (0.00s)
    --- FAIL: TestLastIndex/pair/different (0.00s)
    --- PASS: TestLastIndex/four (0.00s)
    --- PASS: TestLastIndex/five (0.00s)
    --- FAIL: TestLastIndex/six (0.00s)
FAIL

4 tests failed.
```

Now let's say you wanted to run just `pair/different` while you debug it.  In
this test there's not a lot of output, but sometimes tests might have tons of
lines of output so it can be useful to only run what you must.  Here's some commands you
might consider trying to run `pair/different`:

 * `go test -run Index/pair/different`
 * `go test -run Index/pair\/different`
 * `go test -run 'Index/pair\/different'`
 * `go test -run 'Index/pair[/]different'`
 * `go test -run 'Index/pair.different'`

All of these either run both `pair` and `pair/different` or they run no
subtests at all.  The answer comes in the documentation for `-run`:

```
        -run regexp                            
            Run only those tests and examples matching the regular expression.
            For tests, the regular expression is split by unbracketed slash (/)
            characters into a sequence of regular expressions, and each part                   
            of a test's identifier must match the corresponding element in                     
            the sequence, if any. Note that possible parents of matches are
            run too, so that -run=X/Y matches and runs and reports the result   
            of all tests matching X, even those without sub-tests matching Y,                  
            because it must run them to look for those sub-tests.  
```

This explains both of the outcomes in the commands above.  When you run `go
test -run X/Y/Z` go creates three regexp objects (one for X, one for Y, and one
for Z.) It matches X against the function name of the test; if it matches, it
will then run the test.  When the test is running, it tries to run all subtests
and if the subtest matches Y, the subtest gets run.  Finally any subtests of Y
named Z will be run, though we happen to not have a third level of nesting
here.

This implies two rules for subtests in go.  First, do not put `/` in subtest
names.  One could argue that `testing` should actually escape these, but just
not using `/` is simple.  If you have a `/` in a subtest name and the prefix
before the matches other tests, you'll never be able to run the longer named
test without also running the prefix.  At work I used to have tests that had
filenames in the subtest name; because of this I replaced the `/` with
something like `!`.

Second, if possible, keep the meat of the test in the leaf tests.  Anything in
non-leaf tests may get run and may produce distracting output.

---

(Affiliate links below.)

If you want to learn more
about programming Go, you should check out <a target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.  It is one of the best programming books I've read.
You will not only learn Go, but also get some solid introductions on how to
write code that is safely concurrent.  **Highly recommend.**

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
