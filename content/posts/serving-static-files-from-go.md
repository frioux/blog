---
title: Serving Static Files from Go
date: 2023-03-07T08:47:02
tags: [ "golang" ]
guid: e020988b-47cc-4be3-a771-82bf706fbd2b
---
How to easily serve static files in a Go app.

<!--more-->

I have included this in so many apps and even in blog posts, but never front
and center.  I think this is a very handy pattern and should be easy to
discover, so here we are.

Here's how I usually start.  The use of `go:embed` means that the assets are
directly built into the Go binary, which is conventient for deployment.  The
use of `fs.Sub` in `run()` means that a file at path `assets/x.txt` could be
accessed at `http://localhost:8080/x.txt`.  This is the detail I forget the
most often and what motivated me to write this post down.

```golang
package main

import (
	"fmt"
	"embed"
	"io/fs"
	"net/http"
	"os"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

//go:embed assets/*
var assets embed.FS

func run() error {
	mux := http.NewServeMux()
	sub, err := fs.Sub(assets, "assets")
	if err != nil {
		return err
	}
	mux.Handle("/", http.FileServer(http.FS(sub)))
	return http.ListenAndServe(":8080", mux)
}
```

The drawback to the above is that the assets, being embedded directly into the
binary, will not change when you modify the files.  I think that for deployed
code that's perfectly fine, but during development it can be annoying.  Here's
a more complicated version.  This takes advantage of build tags, though you could
just as easily make this a commandline flag:

`main.go`:

```golang
package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run() error {
	mux := http.NewServeMux()
	mux.Handle("/", http.FileServer(http.FS(assets())))
	return http.ListenAndServe(":8080", mux)
}
```

`main_prod.go`:

```golang
//go:build !dev
// +build !dev

package main

import (
	"embed"
	"io/fs"
)

//go:embed assets/*
var _assets embed.FS

func assets() fs.FS {
	sub, err := fs.Sub(_assets, "assets")
	if err != nil {
		panic(err)
	}
	return sub
}
```

`main_dev.go`:

```golang
//go:build dev
// +build dev

package main

import (
	"io/fs"
	"os"
)

func assets() fs.FS {
	return os.DirFS("assets")
}
```

The above code, when run or built normally will function just like the first
version.  But if you run it with `go run -tags dev .` or build it with `go
build -tags dev .` you'll get a binary that serves whatever is in `assets` like
a normal file serving http server.
