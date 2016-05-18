---
title: Faster DBI Profiling
date: 2016-05-18T10:07:07
tags: ["perl", "dbi", "dbic"]
guid: "https://blog.afoolishmanifesto.com/posts/faster-dbi-profiling"
---
Nearly two months ago [I blogged about how to do profiling with
DBI](/posts/dbi-logging-and-profiling), which of course was about the same time
we did this [at work](https://www.ziprecruiter.com/).

At the same time there was a non-trivial slowdown in some pages on the
application.  I spent some time trying to figure out why, but never made any
real progress.  On Monday of this week Aaron Hopkins pointed out that we had set
`$DBI::Profile::ON_DESTROY_DUMP` to an empty code reference.  If you [take a peak
at the code](https://metacpan.org/source/TIMB/DBI-1.636/lib/DBI/Profile.pm#L933)
you'll see that setting this to a coderef is much less efficient than it could be.

So the short solution is to set `$DBI::Profile::ON_DESTROY_DUMP` to false.

A better solution is to avoid the global entirely by making a simple subclass of
`DBI::Profile`.  Here's how I did it:

```
package MyApp::DBI::Profile;

use strict;
use warnings;

use parent 'DBI::Profile';

sub DESTROY {}

1;
```

This correctly causes the destructor to do nothing, and allows us to avoid
setting globals.  If you are profiling all of your queries like we are, you
*really* should do this.
