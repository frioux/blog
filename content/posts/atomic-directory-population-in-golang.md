---
title: Atomically Directory Population in Go
date: 2018-09-18T07:26:17
tags: [ golang, unix ]
guid: 74744030-cc52-449c-b6ba-5427da79e4aa
---

At [work](https://www.ziprecruiter.com/hiring/technology) I'm building a little
tool to write data from [AWS Secrets
Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)
to a directory on disk.  I wrote a little package to write the secrets
atomically, because that seemed safest at the time.  In retrospect just writing
each file atomically probably would have been good enough. Code and discussion
are below.

<!--more-->

The code follows, but I'll give a quick overview of how it works first:

 * Ensure that what we're updating is actually a symlink (or doesn't exist)
 * Build a tempdir next to the symlink (to be sure it's on the same filesystem)
 * Enqueue a defer to recursively remove `realdir`, which initially is the new
     tempdir
 * Call `populate` to fill the new dir
 * Update the symlink to point at the new dir
 * Update `realdir` so the defer recursively removes the old directory

---

```golang
package atomicdir // import "go.zr.org/secrets/esoterica/atomicdir"

import (
	"io/ioutil"
	"os"
	"path/filepath"

	"go.zr.org/common/go/errors"
)

// ErrNotSymlink is when the symlink to update is some other kind of file
var ErrNotSymlink = errors.New("Not a symlink")

// Fill populates a directory with populate then atomically points d at
// the directory.
func Fill(d string, populate func(string) error) error {
	fi, err := os.Lstat(d)
	if err != nil && !os.IsNotExist(err) {
		return errors.Wrap(err, "os.Lstat", "file", d)
	}

	var old string

	if fi != nil {
		if fi.Mode()&os.ModeSymlink == 0 {
			return errors.WithDetails(ErrNotSymlink, "file", d)
		}

		old, err = os.Readlink(d)
		if err != nil {
			return errors.Wrap(err, "os.Readlink", "file", d)
		}
	}

	dir, file := filepath.Split(d)

	realdir, err := ioutil.TempDir(dir, file+"-")
	if err != nil {
		return errors.Wrap(err, "os.Mkdir", "dir", realdir)
	}
	defer func() { _ = os.RemoveAll(realdir) }() // updated later to the old path

	err = populate(realdir)
	if err != nil {
		return errors.Wrap(err, "populate", "dir", realdir)
	}

	tmplink := filepath.Join(dir, file+".tmp")
	err = os.Symlink(realdir, tmplink)
	if err != nil {
		return errors.Wrap(err, "os.Symlink", "dir", realdir, "file", tmplink)
	}
	err = os.Rename(tmplink, d)
	if err != nil {
		return errors.Wrap(err, "os.Rename", "old", tmplink, "file", d)
	}

	realdir = old // now defer will delete the old symlink path

	return nil
}
```

For the most part this was straightforward, but the `defer` trick to clean up
the correct thing was definitely not obvious from the start.

---

(The following includes affiliate links.)


If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

For information on how to write code like the above in Unix systems in general,
<a target="_blank" href="https://www.amazon.com/gp/product/0321637739/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321637739&linkCode=as2&tag=afoolishmanif-20&linkId=78d6d5796e3eefc734692d307ed34915">Advanced Programming in the UNIX Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321637739" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is a great option.  More typically just called "Stevens," it gives a solid
overview of Unix in general.  I haven't read this updated version myself, but
I've definitely learned a lot from the older editions.
