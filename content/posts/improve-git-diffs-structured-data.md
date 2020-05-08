---
title: Improve Git Diffs for Structured Data
date: 2020-05-08T08:11:14
tags: [ git, frew-warez ]
guid: 5599b00b-c125-40df-bba4-a267628eb142
---
I made diffs of some structured data more useful.

<!--more-->

I have a git repo with a file that looks like this:

```json
{
  "data": [
    {
      "id": 1,
      "imgUrl": "https://some-url.com/foo.jpg",
      "name": "television"
    }
  ]
}
```

Imagine that but with a thousand objects in `data` and about two dozen fields in
the objects.

This file is pulled from a third party, and recently the value in `imgUrl` went
from a simple link to an image to a long, signed url.  Where before the images
would only change due to an actual change in the source, now they change at
least every few hours.


```json
{
  "data": [
    {
      "id": 1,
      "imgUrl": "https://some-url.com/foo.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zb21lLXVybC5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlR3JlYXRlclRoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTU4ODcxNjE4M30sIkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkxMzA4MTg0fX19XX0&Key-Pair-Id=APKAIZ7QQNDH4DJY7K4Q",
      "name": "television"
    }
  ]
}
```

This makes the git history *way* less useful.  I get all these diffs with *very
slight* changes to the policy that makes *every single* image (so ~1200 lines)
change.

```diff
diff --git a/thedata.js b/thedata.js
index f8a3e0141b5..bccaf0607f5 100644
--- a/thedata.js
+++ b/thedata.js
@@ -2,17 +2,17 @@
   "data": [
     {
-      "id": 1,
+      "id": 10,
-      "imgUrl": "https://some-url.com/television.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zb21lLXVybC5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlR3JlYXRlclRoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTU4ODcxNjE4M30sIkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkxMzA4MTg0fX19XX0&Key-Pair-Id=APKAIZ7QQNDH4DJY7K4Q",
+      "imgUrl": "https://some-url.com/television.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zb21lLXVybC5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlR3JlYXRlclRoYW4iOnsiQVdTOkVwb2NoVGltZ2I6MTU4ODcxNjE4M30sIkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkxMzA4MTg0fX19XX0&Key-Pair-Id=APKAIZ7QQNDH4DJY7K4Q",
       "name": "television"
     },
     {
       "id": 2,
-      "imgUrl": "https://some-url.com/telephone.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zb21lLXVybC5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlR3JlYXRlclRoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTU4ODcxNjE4M30sIkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkxMzA4MTg0fX19XX0&Key-Pair-Id=APKAIZ7QQNDH4DJY7K4Q",
+      "imgUrl": "https://some-url.com/telephone.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zb21lLXVybC5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlR3JlYXRlclRoYW4iOnsiQVdTOkVwb2NoVGltZS26MTU4ODcxNjE4M30sIkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkxMzA4MTg0fX19XX0&Key-Pair-Id=APKAIZ7QQNDH4DJY7K4Q",
       "name": "telephone"
     },
     {
       "id": 3,
-      "imgUrl": "https://some-url.com/telethon.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zb21lLXVybC5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlR3JlYXRlclRoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTU4ODcxNjE4M30sIkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkxMzA4MTg0fX19XX0&Key-Pair-Id=APKAIZ7QQNDH4DJY7K4Q",
+      "imgUrl": "https://some-url.com/telethon.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9zb21lLXVybC5jb20vKiIsIkNvbmRpdGlvbiI6eyJEYXRlR3JlYXRlclRoYW4iOnsiQVdTOkVwb2NoVGltZSI2MTU4ODcxNjE4M30sIkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNTkxMzA4MTg0fX19XX0&Key-Pair-Id=APKAIZ7QQNDH4DJY7K4Q",
       "name": "telethon"
     }
   ]
```


I considered filtering the data before commiting it, but that has some
other annoying implications (specifically that the urls are then definitely not
useful.)  I decided to try using `gitattributes`.

## `gitattributes`

Git has functionality to use alternate programs to produce diffs.  Typically
this is used to make diffs of non-text, like word documents.  There are three
things you need to configure for these attributes:

 1. The attribute on the file
 2. The handler for the attribute
 3. The program to do the diffing

The attribute should go in either `.gitattributes` or `.git/info/attributes` in
your checkout, or whatever `core.attributesFile` is configured to point at.
Here's what mine looks like:

```
thedata.js diff=thedata
```

Very simple.  Could easily be based on extension (so the prefix would be
`*.js`) but that would cause more problems in my case.

Next, we wire up the handler (I did it in the `.git/config` of the repo, but
`~/.gitconfig` would work too:)

```
[diff "thedata"]
        command = bin/tidy-photos
```

I'm just configuring the external diff tool to be `bin/tidy-photos`, which
happens to be in my repo, though you could put something without a prefix to
search your path if you wanted.


Finally, the actual code for `tidy-photos`, with extra comments:

```bash
#!/bin/sh

# see git(1)'s GIT_EXTERNAL_DIFF section for the details here.
old_file=$2
new_file=$5

# jq is often baroque and confusing.  The tricky bit here is that |= means
# modify in place.  The crazy `match` stuff is just doing a regex and
# extracting the value.
jq -S '.data |= (
  map(.imgUrl |= (match("^(.*\\.jpg)\\?.*") | .captures[0].string))
)' < $old_file | sponge $old_file
#                sponge allows you to safely replace the contents of 
#                a file with a pipeline.


jq -S '.data |= (
  map(.imgUrl |= (match("^(.*\\.jpg)\\?.*") | .captures[0].string))
)' < $new_file | sponge $new_file

# git-diff does color better than regular diff does.  --no-index is needed
# since we are literally just diffing two files, rather than revisions or
# whatever.
git diff --no-index -- $old_file $new_file || true
#                                             we use true here so that
#                                             empty diffs do not exit 1.

```

With these changes in place the diffs are much more useful:

```diff
```diff
diff --git a/thedata.js b/thedata.js
index f8a3e0141b5..bccaf0607f5 100644
--- a/thedata.js
+++ b/thedata.js
@@ -2,17 +2,17 @@
   "data": [
     {
-      "id": 1,
+      "id": 10,
       "imgUrl": "https://some-url.com/television.jpg",
       "name": "television"
```

There's one more annoyance though: `git log -p` does not use this tooling out of the box, so you need to run
`git log -p --ext-diff`.  Pretty handy!

---

Thanks to Wes Malone, Neil Gaylor, John Anderson, Rob Hoelz, and Michael McClimon for reviewing this article.

---

(Affiliate links below)

Years ago I read <a target="_blank" href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=4868d32051a14290953f78a85e8967c7">Pro Git</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and it was a solid, really good read.  I strongly recommend this if you want to
improve your grasp of this complex version control system.

<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=01cde3ac7bf536c84bfff0cc1078bc56">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is one of the most inspiring software engineering books I've ever read.  I
suggest reading it if you use UNIX either at home (Linux, OSX, WSL) or at work.
It can really clarify some of the foundational tools you can use to build your
own tools or extend your environment.
