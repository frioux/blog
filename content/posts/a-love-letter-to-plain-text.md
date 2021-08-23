---
title: A Love Letter to Plain Text
date: 2018-01-02T09:14:29
tags: [ perl, meta, hugo ]
guid: 506e2457-5617-4e2b-acc0-d5a2231579c3
---
I have used Hugo, the blog engine this blog runs on top of, more and more lately
for less and less typical use cases.  Hopefully this post will inspire others in
similar ways.

<!--more-->

[There was another post on twitter recently that inspired me to write this
post.][pt] The point of that post was that when your blog is [just a pile of
textfiles][tf] generic Unix tools combine to make many things are trivial that
wouldn't be with a more traditional database backed system.

Some of the examples given in the post were using `wc(1)` to count words in a
post and `aspell(1)` to spellcheck posts.  I'm all about that, but I have a tool
in my back pocket that allows more advanced analysis.

[tf]: https://github.com/frioux/blog/tree/master/content/posts
[pt]: http://composition.al/blog/2017/11/29/the-power-of-blogging-with-plain-old-versioned-text/

## `q`: A Refresher

[I posted about `q` before][q], but I'll give a quick refresher here.

[`q` is a 120 line perl script][code] that parses all of my blog posts, puts the
metadata in an in-memory database, and thus allows querying the metadata with
SQL.  Here's an example invocation:

```
bin/q --sql 'SELECT COUNT(*) FROM _ WHERE tag = ?' perl
243
```

The `_` thing is a view with the tags joined with the articles for brevity and
convenience.  I use `q` very often for a chronological view of my posts in the
vim quickfix; see the [original post for details on that][q].  I want to discuss
some of the other doors that `q` has opened here.

By the way, the above invocation takes about 53 milliseconds to run, so `q` is
actually fast enough that it feels realtime and I use it in an autocompleter
[(see the original post for details)][qtop].

[q]: /posts/hugo-unix-vim-integration/#advanced-unix-tools
[qtop]: /posts/hugo-unix-vim-integration/
[code]: https://github.com/frioux/blog/blob/f9bbf8bd91a0f3796c409ffccae5d909e6a7049d/bin/q

### `check-guids`

For RSS feeds each post needs a unique id.  By default the id is the url of the
post.  Often you'll notice that people will switch from http to https and their
RSS feed will list all posts ever as if they are new.  For this reason I always
explicitly list an id.  I used to have it match the post url but that led to
problems when they didn't match.  RSS actually assumes that the id is the url
unless you specify otherwise (with `isPermaLink="false"` in the id field.)

When I write a post [I have a template][tpl] that generates a fresh GUID each time.
There was a time though when I would copy paste a prior post to build a new
post.  Once or twice I accidentally forgot to regenerate the GUID and RSS feeds
never saw the new post.  I resolved this by adding [the following little
script][check-guids] to detect any duplicate GUIDs and [run it in my
makefile][make] before building the blog.

``` bash
#!/bin/sh

duplicates="$(bin/q --sql \
 'SELECT filename
    FROM articles
   WHERE guid IN (
      SELECT guid
        FROM articles
    GROUP BY guid
      HAVING COUNT(*) > 1
   )' --formatter='" * $r{filename}"'
)"

if [ -n "$duplicates" ]; then
   echo "Duplicate GUIDs found!\n$duplicates"
   exit 1
fi
```

[check-guids]: https://github.com/frioux/blog/blob/f9bbf8bd91a0f3796c409ffccae5d909e6a7049d/bin/check-guids
[make]: https://github.com/frioux/blog/blob/f9bbf8bd91a0f3796c409ffccae5d909e6a7049d/Makefile#L12
[tpl]: https://github.com/frioux/blog/blob/f9bbf8bd91a0f3796c409ffccae5d909e6a7049d/.projections.json#L9

## Clog

[I started roasting my own coffee a year ago][roast] and have been tracking
details related to the roasts for about six months.  Initially I tried to keep
it simple and put the notes in a spreadsheet.  The spreadsheet interface was
terrible; it was incredibly slow and bloated, and hard to see a roast's details
at a glance.  Someone maybe jokingly mentioned that I should make a blog.  I
liked the idea and my [coffee log][clog] is working well.  Big thanks to my wife
for recommending "clog" as a name as opposed to my initial idea: "covfefe."

One of the benefits of using Hugo is the ability to have arbitrary structured
information for easy per roast data:

``` yaml
---
title: Ethiopia Grade 1 Dry Process Yirga Cheffe Dumerso
date: 2017-12-16T09:53:39
tags: [ ethiopia, grade-1, dry-process, yirga-cheffe, dumerso ]
guid: f98e617f-a62e-4b1b-9513-ccb42816ef73
total_roast: 12m2s
first_crack: 9m17s
start_weight: 1.2
end_weight: 1.016
weight_loss: 15
---
```

[roast]: /posts/diy-coffee-roasting-and-coffee-setup/
[clog]: https://frioux.github.io/clog/

### `check-math`

Unfortunately, Hugo uses Go's templating, which is, to put it nicely, simple.
So while it can do some math, it cannot calculate the weight loss above.  I
resolved this issue by adding [a `check-math` script][check-math] that [gets run
by the `Makefile`][clog-make]:

``` bash
#!/bin/sh

errors="$(bin/q --sql \
   "SELECT filename, weight_loss as rep,
   round(100 * ( 100*start_weight - 100*end_weight ) / ( 100*start_weight ))
      as calc
   FROM articles
   WHERE start_weight IS NOT NULL AND
   round(100 * ( 100*start_weight - 100*end_weight ) / ( 100*start_weight)) !=
      round(weight_loss)" \
         --formatter '"$r{filename} says $r{rep}; should be $r{calc}"')"

if [ -n "$errors" ]; then
   echo "$errors"
   exit 1
fi
```

It's a little weird because of annoying floating point issues, and honestly this
script is a hack, but it was far easier than submitting a patch to add advanced
math support to the templating engine (and likely have it rejected.)

[check-math]: https://github.com/frioux/clog/blob/b2faa763052cafd68c6106358bdf30eb1b340508/bin/check-math
[clog-make]: https://github.com/frioux/clog/blob/b2faa763052cafd68c6106358bdf30eb1b340508/Makefile#L12

---

## Notes

For a long time I have tracked various facts, aspirations, and plans in a couple
basic text files. [I blogged about the format a while ago][gtd].  I recently
started taking a class on coursera and wished I could take notes as in depth as
I take for coffee.  I was inspired to convert my notes to a similarly plaintext
*page* based format instead of a *line* based format.

### `public-build`

In my notes I have data that must remain private, but I also have a non-trivial
number of [public pages that would be nice to see without any
authentication][notes]; [here's an aspirational example][vex].  I wrote the following script to build a public view of
the site:

``` bash
#!/bin/sh

set -e

PATH="$PATH:$(pwd)/bin"
tmpdir="$(mktemp -d --tmpdir public-notes.XXXXXXXXXX)"
final_dir="$(pwd)/public/"

# 1. copy infrastructure to tmpdir
cp -r ./static/ ./layouts/ ./config.yaml "$tmpdir"

# 2. copy posts tagged public to tmpdir
mkdir -p "$tmpdir/content/posts"
q --sql 'SELECT filename FROM articles a WHERE
   EXISTS (SELECT 1 FROM article_tag at WHERE a.guid = at.guid AND tag = ?)
   AND NOT
   EXISTS (SELECT 1 FROM article_tag at WHERE a.guid = at.guid AND tag = ?)
   ' public private |
   xargs -n50 -I{} cp {} "$tmpdir/content/posts"

# 3. build
cd $tmpdir
hugo

check-private 'public/'

# 4. sync
rm -rf "$final_dir/"*
cp -r public/* "$final_dir/"

cd ..
rm -rf "$tmpdir"
```

The use of `q` is pretty great here; as otherwise I'd be stuck at grepping for
words.

[notes]: https://frioux.github.io/notes/
[vex]: https://frioux.github.io/notes/posts/vim/

### `check-private`

I am paranoid that there will be a bug in the above code on
accident, one way or another, so I wrote another script (`check-private`, run in
the above) that checks that a number of canary posts (posts tagged private, not
tagged public, tagged both) are not included in the built corpus:

``` bash
#!/bin/sh

root="$1"

failed_build() {
   echo "Canary got into the build ($1); something is wrong"
   echo "Current build is at $tmpdir"
   exit 1
}

test -e ${root}posts/private-canary &&
   failed_build 'expected location, private'

git grep --no-index -q PRIVATECANARY &&
   failed_build 'unexpected location, private'

test -e ${root}posts/untagged-canary &&
   failed_build 'expected location, untagged'

git grep --no-index -q UNTAGGEDCANARY &&
   failed_build 'unexpected location, untagged'

test -e ${root}posts/both-canary &&
   failed_build 'expected location, public&private'

git grep --no-index -q BOTHCANARY &&
   failed_build 'unexpected location, public&private'

exit 0
```

The above runs before the build, before the commit, and before the push; so I
think it's sufficiently paranoid to keep my stuff safe.

[gtd]: /posts/getting-things-done/

## `plaintext`

The original post mentioned spell checking, word counting, etc.
I have enough large code blocks in my posts that I can't sensibly send a whole
file to one of those programs so [I have a tool](plain) that will convert the data +
markdown to plain text for this purpose, mostly.  It's slow (5.2s to convert my
entire corpus,) and a little buggy but it's a start.  I may implement my own
markdown parser specifically for improved speed.  I haven't yet because I hate
implementing parsers.  Here's the code:

``` perl

#!/usr/bin/env perl

use 5.20.1;
use warnings;

package MarkdownToText;

use Moo;

extends 'Markdent::Handler::HTMLStream::Fragment';

our $printing = 1;

sub start_code { $printing = 0 }
sub end_code   { $printing = 1 }

# disabled events
sub code_block {}
sub preformatted {}

# disable html stuf
sub _stream_start_tag {}
sub _stream_end_tag {}

# disable encoding of html entities, only print when not in code block
sub _stream_text { shift->_output->print(shift) if $printing }

package main;

use autodie;
use Markdent::Parser;

die "usage: $0 \$mdwn [\$md2 \$md3 ...]\n"
   unless @ARGV;

while (my $markdown = do { local $/; <<>> }) {
  $markdown =~ s/---\n.*?---\n//s;

  my $out = '';
  open my $fh, '>', \$out;
  my $parser = Markdent::Parser->new(
    dialects => 'GitHub',
    handler  => MarkdownToText->new( output => $fh ),
  );

  $parser->parse( markdown => $markdown );

  print $out;
}
```

I'd like to build more on top of this plaintext tool (like detecting accidental
duplicate words, grammatical mistakes, etc) but it's too slow to be added to the
build process, so I'm torn.

On top of that, the amount of words that `aspell(1)` calls misspelled is
crippling.  There are some words that are made up for single posts, and I can
either globally whitelist the word, or I can change the post.  Currently
counting all of the words in my corpus that `aspell(1)` complains about shows a
whopping 2,353 unique words.  Joy.

[plain]: https://github.com/frioux/blog/blob/f9bbf8bd91a0f3796c409ffccae5d909e6a7049d/bin/plaintext

---

I hope that this inspires others.  These are all tools that *could* be written
against a traditional blog engine, but would likely be slower and less flexible.
On top of the above handmade features, there are all kinds of reasons to use a
plaintext format: trivial version control, less dependence on the state of
a pet server, trivial backups, relatively simple migrations, and more.

---

I am at a loss to recommend just the right book to learn more about these
topics.  I have some vague recommendations but I also think that the book I want
to recommend just does not exist.

(The following includes affiliate links.)

I think every software engineer, especially newer ones, should read
<a target="_blank" href="https://www.amazon.com/gp/product/020161622X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=020161622X&linkCode=as2&tag=afoolishmanif-20&linkId=19c5844608b13f3213680206aefc37ac">The Pragmatic Programmer</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=020161622X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The book is pretty heavy on dogma, which would not be super welcome to me today,
but when I was just starting it was a great inspiration.  This is probably one
of five tech books I've read cover to cover.

Another book in the same vein, which I read many years ago, is
<a target="_blank" href="https://www.amazon.com/gp/product/1934356344/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1934356344&linkCode=as2&tag=afoolishmanif-20&linkId=32622d658bb29f27cbdee4a544a96fda">The Passionate Programmer</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1934356344" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I read that book and it opened a whole world to me as a relatively green
engineer.  Highly recommend.
