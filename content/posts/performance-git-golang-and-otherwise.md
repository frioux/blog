---
title: "Performance; git, go, and otherwise"
date: 2019-09-13T11:37:42
tags: [ git, golang, optimization ]
guid: 8bc8e3a4-add3-4498-9af1-f5d2cbda8e4f
---
I recently made a change that made some code non-trivially faster.  Also I
think most of the performance related advice out there is bad.

<!--more-->

Something that sticks in my craw is advice that implies that optimizing code is
somehow increbily hard.  You often hear on the internet advice that seems to
imply that computers are these unpredictable black boxes that you cannot reason
about.  One of the most common ways I hear this is that you should never
optimize code without first profiling it.

Eventually, this is true, but in my experience the *vast* majority of slow code
is slow for really obvious reasons.  For example, probably 95% of the time a
page I've dealt with is slow is because it's doing O(n) database queries; a
profiler can show you this, but so can your brain.

An example that came up at work last week was some code that took about 8s
to run.   This is code that runs as part of a git hook; it happens every
time someone pushes, so it's pretty annoying.  I was pleased that porting
it from shell to Go cut the runtime down by about 3s, but 8s is still
frustratingly slow.

While I could have (and actually did, to prove a point) profile the code to find
the hot spots, I knew exactly where all the time was going: `git show`.

This code uses `git show` to look at the contents of some files in our git repo
to decide what to do next.  Unfortunately there are hundreds of these files and
we intend for there to be more.  Because of that we are basically running O(n)
`git show`s.  git is fast software, for sure, but you just cannot execute a
program hundreds of times for free.

That's another way I see a lot of advice go wrong.  Sure, you can do something
in a separate thread or maybe avoid doing it or whatever, but again, 95% of the
time you can get huge wins by simply *batching* the stuff slowing you down.
With SQL this typically just means trivial ([or not so
trivial](https://gist.github.com/frioux/8676459)) query reorganization.

I had a hunch we could do the same thing with our `git show`s.  After a couple
false starts (like trying a sparse checkout) we came up with this gross but
*totally* effective solution:

Commit a file to the repo that has a single null byte in it. Then run
`git show file1:$rev null:$nullrev file2:$rev null:$nullrev ... `.  You end up
getting all the content printed at once with nulls between the sections
(obviously this specific trick wouldn't work for binary data.)  This change
reduced our runtime from 8s to about 381ms.  Not bad!

---

I don't know why people so often make optimization sound fiendishly hard.  My
guess is that they are talking about optimizing that last few percent (or more
clearly: the stuff not worth optimizing.)  Hopefully this hacky optimization
shows the pattern that I'm trying to get across, which is that batching
typically works wonders.

---

(The following includes affiliate links.)

Very, very vaguely related to this is
BCC; I don't think there is a book about BCC
(yet.)  I think the closest thing would be Brendan Gregg's <a target="_blank"
href="https://www.amazon.com/gp/product/0133390098/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0133390098&linkCode=as2&tag=afoolishmanif-20&linkId=20dafcbf13582f9fe5049d9fde39dd79">Systems
Performance</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0133390098"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.  It's got a ton of detail and a good helping
of methodology that will help with the kind of stuff that one tends to use
BCC for.

BCC is very much implemented atop Linux, so it is worth
knowing Linux and Unix if you ever need to do something more
advanced than use an out-of-the-box tool.  I suggest reading <a target="_blank"
href="https://www.amazon.com/gp/product/1593272200/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593272200&linkCode=as2&tag=afoolishmanif-20&linkId=afca82c8c1ccaa7f97bd25b0c8e6a062">The
Linux Programming Interface</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593272200"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" /> for that kind of information.
