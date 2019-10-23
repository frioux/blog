---
title: "Leatherman: Using `go generate`"
date: 2019-05-13T19:30:21
tags: [ frew-warez, golang ]
guid: 0ec077aa-b528-4345-a914-d22809492dc5
---
This weekend I updated the leatherman's code to be a little more automated,
using `go generate` and some nice parsing tooling.

<!--more-->

[The leatherman](https://github.com/frioux/leatherman) is a multitool I use all
the time.  Saturday I decided to work on automating the process of adding more
tools.  In the past to add a tool I would:

 1. Add a public function to an internal package
 2. Document the function
 3. Add it to the tool dispatch table
 4. Document it in the README
 5. Hopefully add a test

Today I automated steps 3 and 4 by leveraging the function documentation.  I
started by generating the README docs.  I use a few tools to
generate the docs:

 1. `go list`
 2. `goblin`
 3. `jq`
 4. `perl`

`go list` lets you examine Go packages and some basic primitives of the source
code in a very straightforward fashion.  I use it to find out what all packages
I have and what files comprise those packages.

Next I use [`goblin`](https://github.com/ReconfigureIO/goblin), which transforms
the Go AST into JSON.  Go ships with packages to parse and even type check Go
source code, so simple software to transform that into JSON is not surprising.

Finally, I use `jq` to filter the JSON and Perl to put the documentation from
the JSON back together in a nice fashion.  I could do it in pure `jq` but that
seems annoying.  Here's all but the perl for generating the README:

```bash
go list -f '{{$dir := .Dir}}{{range .GoFiles}}{{$dir}}/{{.}}{{"\n"}}{{end}}' ./internal/tool/... |
   xargs -n1 -I{} goblin -file {} |
   jq '.declarations[] | select(.type == "function") | select(.comments[] | match("Command: ")) | .comments' -c
```

And here's the perl code:

```perl
#!/usr/bin/perl -CO

use strict;
use warnings;

use JSON::PP;

no warnings 'uninitialized';

my %doc;

while (<STDIN>) {
   my $c = decode_json($_);

   die "Command should have exactly one comment\n" if @$c != 1;

   my $d = $c->[0];

   $d =~ s/^ \/\*\s+  //x;
   $d =~ s/  \s+\*\/ $//x;

   my ($body, $cmd) = ($d =~ m/^(?:\S+\s+)(.+)\s+Command:\s+(.+)$/s);

   $doc{$cmd} = $body;
}

print "### `$_`\n\n`$_` $doc{$_}\n" for sort keys %doc;
```

The above generates the 400 line README.  Awesome.

After generating the README I immediately wrote the code to generate the
dispatch table.  The dispatch table is simply a map from command name to
function that the leatherman uses to figure out what to call.

Generating the dispatch table is more fiddly, but I used the same general
technique as before, this time calling `go list` and `goblin` from Perl
directly.  [The code is
here](https://github.com/frioux/leatherman/blob/c0b5d137e257f77a2a9a2dfc2b7fcb3c38f40de8/maint/generate-dispatch)
if you want to read it.  The one change I might consider making is to have it
call `gofmt` so that it's more neatly formatted, but I am not going to worry
about that for now.

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
