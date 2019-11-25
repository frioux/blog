---
title: Brute Force Image Recovery
date: 2019-11-25T07:07:54
tags: [ golang, shell ]
guid: 4f497811-9dbb-4235-90d5-bdeb1be9bf95
---
Last week was the
[ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) holiday party.
As usual they had a photobooth (two in fact!)  Catherine and I took three
sets of pictures but I didn't get an email for one of the three.  Read on
to find out how I got them.

<!--more-->

At the second photo booth we took two sets of pictures and I'm guessing I
put in my phone number for the second set but not the first, so it wasn't
able to text me the URL.  But what I noticed was that the URL only had a four
character identifier.  I did some math and figured the search space was 1.6
million URLs.  I started off with a shell script and Perl using LWP to just
iterate over all of them.  I used LWP because I wanted to make sure Keepalive
would work, since keeping connections open could make a huge difference here.

Unfortunately that was too slow and would have taken something like twenty
days.

Next I wrote a little Go program to iterate over a list of URLs, printing URLs
that are found and printing something else if they are not found.  The host in
question does not return 404 on not found, and instead returns a 200 with an
explanation that the photo is missing.  Here's what I ended up with:

```golang
package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"sync"
)

var cl *http.Client

func init() {
	cl = &http.Client{}
}

// create a goroutine for each url; use a channel to limit to ten goroutines at
// a time.
func main() {
	wg := sync.WaitGroup{}

	tokens := make(chan struct{}, 10)

	s := bufio.NewScanner(os.Stdin)
	for s.Scan() {
		wg.Add(1)
		tokens <- struct{}{}
		url := s.Text()
		go func() {
			defer func() { wg.Done(); <-tokens }()
			checkURL(url)
		}()
	}
	if s.Err() != nil {
		fmt.Println("trouble scanning:", s.Err())
	}

	wg.Wait()
}

// checkURL prints the url if it's valid, prints it with a `! ` prefix if not,
// and prints something else if there was an error.  Normally I'd write errors
// to stderr, but I wanted to be sure that everything was in the log.
func checkURL(u string) {
	s, err := tryURL(u)
	if err != nil {
		fmt.Println("Couldn't try", u, "because:", err)
		return
	}

	if s {
		fmt.Println(u)
	} else {
		fmt.Println("!", u)
	}
}

// tryURL returns true if the url is valid; ie the content doesn't include
// "couldn't find"
func tryURL(s string) (bool, error) {
	r, err := cl.Get(s)
	if err != nil {
		return false, err
	}

	buf := &bytes.Buffer{}
	if _, err := io.Copy(buf, r.Body); err != nil {
		return false, err
	}

	if strings.Contains(buf.String(), "couldn't find") {
		return false, nil
	}
	return true, nil
}
```

I added comments to explain how the above works, but it's not that important.
I ran the scrape tool like this:

```bash
< urls.txt shuf | ./scrape| tee log.txt
```

It probably wasn't important to shuffle the urls like this, but it didn't hurt
anything.

As that was chugging along I wrote a little tool to report progress:

```bash
#!/bin/zsh

total=$(cat urls.txt | wc -l)
finished=$(cat log.txt| wc -l)
remaining=$(calc $total - $finished)
found=$(cat log.txt | grep '^h' | wc -l)
start=$(date -d 'Sat Nov 23 10:50:12 PST 2019' +%s)
now=$(date +%s)
duration=$(calc $now - $start)

echo "$(date +%FT%T) $remaining to go; found $found (of $finished); expect to find $(calc $total * $found / $finished); hours to go: $(calc $duration / $finished * $remaining / 60 / 60)"
```

I ran that on the commandline like this:

```bash
while true; do sleep 5; ./report; done
```

That's convenient because as I update the report it just runs the new version
on the next run, rather than having the while loop inside.

Here's how it looks:

```
2019-11-23T19:34:57 1313711 to go; found 1725 (of 365905); expect to find 7918.27824; hours to go: 31.39769
2019-11-23T19:35:03 1313659 to go; found 1725 (of 365957); expect to find 7917.15310; hours to go: 31.40009                                                                                    
2019-11-23T19:35:08 1313618 to go; found 1725 (of 365998); expect to find 7916.26620; hours to go: 31.39911                                                                                    
2019-11-23T19:35:13 1313572 to go; found 1726 (of 366044); expect to find 7919.85995; hours to go: 31.39801                                                                                    
2019-11-23T19:35:18 1313529 to go; found 1727 (of 366087); expect to find 7923.51772; hours to go: 31.40064                                                                                    
2019-11-23T19:35:24 1313484 to go; found 1728 (of 366132); expect to find 7927.13132; hours to go: 31.39956                                                                                    
2019-11-23T19:35:29 1313434 to go; found 1728 (of 366182); expect to find 7926.04892; hours to go: 31.39836                                                                                    
2019-11-23T19:35:34 1313383 to go; found 1728 (of 366233); expect to find 7924.94517; hours to go: 31.40079                                                                                    
2019-11-23T19:35:39 1313337 to go; found 1728 (of 366279); expect to find 7923.94990; hours to go: 31.39969                                                                                    
2019-11-23T19:35:45 1313289 to go; found 1729 (of 366327); expect to find 7927.49664; hours to go: 31.39855                                                                                    
2019-11-23T19:35:50 1313249 to go; found 1729 (of 366367); expect to find 7926.63112; hours to go: 31.40124
```

While those were running I made a pleasant discovery: the JPEGs contain the
date the picture was taken in the EXIF comment, so I could easily have the
computer go through the possibly thousands of images rather than having
to do that myself.  I wrote two more tools; one to convert the URL above
(which is an HTML page) into the JPEG URL:

```bash
#!/bin/sh

cat log.txt |
    grep '^h' |
    sed 's/view.php?photo=/sessions\/strips\//; s/$/.jpg/'
```

And then I made a downloader tool:

```bash
#!/bin/sh

for u in $(./strips); do
    (
        cd photos
        file=$(echo "$u" | sed 's#.*/##')
        [ -e "$file" ] || wget --quiet "$u"
    )
done
```

The downloader tool is probably more expensive than it has to be (new subshell
per URL, using sed to get the filename, etc) but it only downloads images it
hasn't already downloaded, so I just re-ran it periodically.

The last piece of the puzzle is the EXIF bit:

```bash
#!/bin/sh

cd photos
for x in *; do
    if exiftool -Comment "$x" | grep -qF 'Nov 22'; then
        echo "$x"
    fi
done
```

The EXIF-based filter (`relevant`) is painfully slow since we have to fire up `exiftool`
for each image rather than batching.  I would have just made a new EXIF wrapper
but I found the image I was looking for before it would have been relevant.

Finally, I ran `relevant` just after checking 10% of the possible 1.6 million
URLs.  It printed a measly ten images.  I manually copy pasted the names
and ran:

```bash
feh -. 3384.jpg 3s68.jpg 4zr4.jpg 863d.jpg r4sk.jpg y3cu.jpg y6ve.jpg yc24.jpg yfyk.jpg 4zi7.jpg
```

The third one was what I was looking for!  Success!

![woo!](/static/img/holiday2019.jpg)

---

I am surprised I got so lucky.  After just three hours of scanning URLs and
writing fun little tools I was able to find my needle in the haystack.
Normally this isn't an issue because the photo booth company we rent from makes
an album of all the pictures that were taken, so I can easily find any I
missed or group shots I was a part of.

---

(The following includes affiliate links.)

The concurrency algorithm above came from
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

If you are inspired by all these tools that I've built, I suggest reading
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=7320143b3b25493a297e134aa6fc0846">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
