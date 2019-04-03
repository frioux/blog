---
title: Optimizing my Workflow for Go
date: 2019-04-03T08:00:18
tags: [ golang, testing, ziprecruiter ]
guid: 2a88c70a-68b8-484b-bc0f-82be5cd08d21
---
I spent about four hours programming on a plane last week; thanks to good tools
it was fun and easy.

<!--more-->

[I blogged before about our Kubernetes validation
tooling](/posts/validating-kubernetes-manifests/).  Since that blog post the
tool has been significantly upgraded thanks to the efforts of C Anthony Risinger
and Joshua Pollack, using a JSON Schema validator plus some JSON Patches to add
our own policy to the original Kubernetes Schema.  The implication is that
instead of weird Go code we just write a JSON Patch to the schema to do some
validation.  Here's an example Patch that disallows using `:latest` for an image
on a container:

```json
[
  {
    "op": "add",
    "path": "/definitions/io.k8s.api.core.v1.Container/allOf/-",
    "value": {
      "if": {
        "properties": {
          "image": {
            "pattern": ":latest$"
          }
        }
      },
      "then": {
        "dependencies": {
          "image": ["$error,format:image images must not use ':latest'"]
        }
      }
    }
  }
]
```

(Side note: I believe we have extended JSON Schema or maybe used it creatively
to inject errors, so if the `$error` bit above looks odd, that's why.)

After [my last blog post about tests](/posts/testing-in-golang/) I decided that, before my next major
task on this tool, I would write some basic but solid tests for this project.
I wrote the following test:

```golang
var defines = map[string]string{
	"docker-repo":   "docker-repo",
	"default-image": "foo:bar",
	"start-time":    "now",
}

func TestTailoredResources(t *testing.T) {
	type trtest struct {
		name          string
		newErr, trErr *regexp.Regexp
	}

	trtests := []trtest{{
		name: "passing",
	}, {
		name:   "no-dash",
		newErr: regexp.MustCompile("https://wiki.zr.org/Apps#app-name"),
	}, {
		name:  "wrong_namespace",
		trErr: regexp.MustCompile("need=testdata--wrong-namespace"),
	}, {
		name:  "invalid_manifest",
		trErr: regexp.MustCompile("property made-up-key is not allowed"),
	}, {
		name:  "invalid_app",
		trErr: regexp.MustCompile("backoffLimit is required"),
	}}

	for _, test := range trtests {
		t.Run(test.name, func(t *testing.T) {
			a, err := New(filepath.Join("testdata", test.name), "k1", defines, 1)
			// ...
		})
	}
}
```

The Go test harness will automatically `chdir` into the package, and a directory
named `testdata` is ignored by the go tooling.  I was then able to put apps in
`testdata/$testname`.  Within the app in question I have a `golden.yaml` which
contains the expected, built manifest which includes all of the epoxy transforms
applied.  I can run `go test -update` to regenerate those files after making
changes to epoxy.

The `newErr` and `trErr` fields are regexen that match the errors that come from
`New` and `TailoredResources`.  A nil regexp means we assert no error, otherwise
we assert the error matches the regexp.  Our errors are actually structured but
this was easy and verified what I care about for now.

The actual tests are carefully written to go through a handful of categories for
the code:

 * passing
 * failure in New
 * failure before validating the manifest
 * failure because the manifest is invalid given the stock k8s schema
 * failure because the manifest is invalid given our patches on the k8s schema

I don't have a test for every single patch and think that is overkill.

The above tests exercise a little over 75% of the package that does the manifest
work and a little over 50% of the entire set of packages in the `config/epoxy`
project.  That, plus the static typing of Go, tells me that if the tests pass,
my change is good.

My primary goal here was to allow some apps to have a different set of patches
applied to the schema.  After the tests above were written I needed to start
refactoring the code.  It was originally written such that schema patches
came from an in memory file system, and they were chosen inside of the
validator, rather than during app creation.  I decided that I would refactor the
code and `git add .` every time the tests pass, committing once my changes were
at a meaningful checkpoint.

My first step was to open a separate terminal window so I could easily see
results of tests, and to run the following command:

```bash
minotaur . -- sh -c 'date; go test -coverprofile=$HOME/prof.prof -v ./...'
```

This would run all of the epoxy tests, including a date before the tests so that
I could be sure I was looking at a recent run rather than the prior run, and
emit some basic coverage information.  While trying to increase coverage by
removing dead code I changed the command to:

```bash
minotaur . -- sh -c 'date;
   go test -coverprofile=$HOME/prof.prof -coverpkg=./... -v ./...; go tool cover -func $HOME/prof.prof'
```

Same basic deal, but we get more coverage info and a report is written to the
console.  With [minotaur](/posts/the-evolution-of-minotaur/) running my tests
every time I ran my code I was able to quickly make changes, see if they worked,
stage them in git, or if they didn't work see `git diff` and reason about what
had broken since my last set of changes.

I worked like this for nearly four hours straight.  For the first three hours I
mostly spent time simplifying the code by removing special cases that either
never or always got exercized, variables that only got used in logs, functions
that were used but could be inlined manually for clarity, etc.  I can't quite
quantify the results but I can describe some.

In one case I took a function that returned five values and changed it to return
three, since two values ere unconditionally ignored.  I took types like
`ValidationFuncMap` and replaced them with `map[string]ValidationFunc`, because
the latter is more clear and the former was simply a shortcut rather than a way
to add methods to the type.  Originally the schemas were on a struct that
contained a schema map, but the map only ever had two schemata.  I replaced the
map with two fields in the struct.  This both clarifies the code and adds
compile time safety.

All in all it was about 350 lines of changes, much of which was an interface
reduction and increase in readability due to more clarity *within* fuctions.
After all that was done and the interface was how I wanted it, I added a test
that would fail for our old set of schema patches, but should pass with the new
set of patches.  I watched it fail, added the new patches, and saw it pass.

I did a touch of cleanup after this, to ensure that maintaining the patches
would be easy, but ultimately that was easy and just tying off loose ends so I
could put this out of mind and dive into the next project clear headed.

---

I found this all very rewarding.  It was especially pleasant because it was the
one outstanding work task I had on my plate while traveling to visit family and
I was able to get it done on the plane.
[ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) would have been
fine if I had not done it, but it allowed me to fully relax while at home.

---

This post is written leveraging the Go programming language and tooling; with
that in mind, if you are interested in learning Go, this is my recommendation:

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
