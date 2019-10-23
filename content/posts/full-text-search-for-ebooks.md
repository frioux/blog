---
title: Full Text Search for ebooks
date: 2019-01-28T07:30:26
tags: [ meta, learning-day ]
guid: 78bcacf7-dc50-4fdf-91c5-8365ab61c86f
---
This past weekend I did a learning day that inspired me to try SQLite for
indexing my ebooks; it worked!

<!--more-->

## SQLite Rules

[Yesterday I mentioned](/posts/learning-day-1-golang/) my first learning day.
The first talk discussed the incredible power in the nearly ubiquitous SQLite.
I've used SQLite in anger for over a decade now; my first released software that
used it was
[SuperSearch](https://github.com/frioux/supersearch/commit/195ec14de5baff408170bc2bc1fd7e9f7bbac0dc#diff-6048200fb8d691db0ef9e650144eab6bR24),
released for Android less than two months after Android itself was released.
Before that I used it instead of a more traditional database when learning SQL.
[I have used it for years to do in memory tests against a
database](https://github.com/frioux/DBIx-Class-Helpers/blob/b71389697ae27e0f3fc7540c1290343721e3e30e/t/lib/TestSchema.pm#L35);
[I use it now to index this
blog](https://github.com/frioux/blog/blob/master/bin/q#L22) while editing,
again, in memory.  I even use it to [simplify dealing with a lot of
data](https://blog.afoolishmanifesto.com/posts/categorically-solving-cronspam/#zr-cron-report)
at work.

The talk that I watched opened my eyes about some of the amazing features that
SQLite provides.  [I was already aware that SQLite is more reliable than most
software](https://danluu.com/file-consistency/), but wasn't aware of some of the
more powerful features.  I won't go over all of them here; [you should just
watch the talk](https://www.youtube.com/watch?v=RqubKSF3wig).  I will go over
the one that is relevant to my needs though.

A little over six months ago I wanted to search my ebooks for some anecdote, but
was surprised that I apparently didn't have any tools to do that, either with
the Kindle, or Calibre.  There are various Calibre plugins floating around but
they seemed defunct.  I figured I'd end up using Xapian, since [I use that for
my email](/posts/fast-cli-tools-and-gmail/#notmuch), but never got around to
putting it together, since it was enough work that I dragged my feet.

## Full Text Search

Fast forward to Saturday, and I discovered indexing my books could be as simple
as this:

```sql
CREATE VIRTUAL TABLE booksearch USING fts5( fulltext );
```

I then populated the table with this Perl script:

```perl
#!/usr/bin/perl

use strict;
use warnings;

use autodie ':all';

no warnings 'uninitialized';

use DBI;
my $dbh = DBI->connect('dbi:SQLite:/home/frew/books.db', {
      RaiseError => 1,
});

my $sth = $dbh->prepare('INSERT INTO booksearch (fulltext) VALUES (?)');

$dbh->begin_work;
for my $doc (@ARGV) {
   open my $fh, "<", $doc;

   $sth->execute(do { local $/; <$fh>});
   print scalar localtime ." Inserted $doc\n";
}
$dbh->commit;
```

And ran the Perl script like this:

```bash
$ populate-book-index ~/Dropbox/Books/Calibre/**/*.txt
```

Finally, to do a query, I was able to run this:

```sql
  SELECT snippet(booksearch, 0, '>>>', '<<<', '???', 64)
    FROM booksearch
   WHERE fulltext MATCH 'diamond'
ORDER BY rank desc
```

The above shows something like:

```
???Below this were numbers arranged in a shape which made a >>>diamond<<<:
Under the >>>diamond<<< were two other buttons with words of the High Speech printed on them: COMMAND and ENTER.
Susannah looked bewildered and doubtful. “What is this thing, do you think? It looks like a gadget in a science fiction movie.”
Of course it did, Eddie realized. Susannah had probably seen a???
```

Clearly I already had plaintext versions of all of my ebooks, for exactly this
purpose in fact.  I did that with Calibre and just selected all of my books and
told it to create plain text versions.  The weird shell glob syntax above
(`**/*`) is a zshism that could be implemented with a relatively simple
`find(1)` command if you wanted.

## What's next

If it's not clear, the above has literally no metadata, it just helps me find
snippets.  It won't be a lot more work to add the relevant data about the books
in question to the database; I just need to figure out how to get it from
Calibre, which already has everything I could want.  I might want to put a
little interface on this, if only a CLI tool that lets me not type the whole
query.  Finally I would like to automate it such that adding new books to
Calibre automatically exports the plain text version and adds them to the index,
but given that creating the entire index only takes about seven seconds, it'd be
fine to just rebuild the whole index each time.

---

(The following includes affiliate links.)

There are a lot of books out there about SQLite; a couple that I am interested
in are
<a target="_blank" href="https://www.amazon.com/gp/product/1980293074/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1980293074&linkCode=as2&tag=afoolishmanif-20&linkId=3de2f331a522b0b89750dcc1bbc3aaea">SQLite Forensics</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1980293074" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
along with
<a target="_blank" href="https://www.amazon.com/gp/product/0596521189/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0596521189&linkCode=as2&tag=afoolishmanif-20&linkId=0fb2ed6057784de93ddce594bd8cb615">Using SQLite</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0596521189" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I haven't read either yet but intend to at some point to get more information
about this great little database.

I first taught myself SQL with
<a target="_blank" href="https://www.amazon.com/gp/product/0672336073/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0672336073&linkCode=as2&tag=afoolishmanif-20&linkId=80f1cd88c5359bc91de5b971577f02d5">SQL in 10 Minutes</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0672336073" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />;
if you are just starting out with SQL I think this is a great introduction.  If
you use SQLite like I did you won't even need to deal with the complexities of
managing a database!
