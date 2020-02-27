---
title: "Zine: Software for Managing Notes"
date: 2020-02-27T07:15:28
tags: [ frew-warez, zine, golang ]
guid: 51d9902f-a61c-482a-9a84-8bab0b2a796d
---
I recently completed a major new iteration of my custom notes management
software.

<!--more-->

Since late 2017 [I've been managing my notes as markdown files with a yaml
header.](/posts/a-love-letter-to-plain-text/#notes) I used
[hugo](https://gohugo.io/) to automatically render and serve the files, since
it works well for this blog and works well enough.  On top of that I used [a
carefully written perl
script](https://github.com/frioux/blog/blob/73441c4f908ec67ee400a5590ca766cdf82acf33/bin/q)
to surface a SQL interface to the metadata of the posts.  I use that for tab
completion of tags, loading up a list of all new notes in my inbox, etc.

That perl script, called `q`, would parse all the posts and insert all of the
metadata to an in memory SQLite database, and then run a SQL query provided by
the user against the database.  It would do all of this as quickly as 60ms...

![Editing this blog post](/static/img/blog-autocomplete.gif "Editing this blog post")

(I know the above doesn't look good on mobile.  [PRs warmly
welcome](https://github.com/frioux/blog).)

## Why New Software?

I built the index page of my notes to carefully surface the most important
information and show all the other information I might want on the page:

![Screenshot of Top of Notes](/static/img/notes-top.png "Screenshot of Top of Notes")

![Screenshot of Bottom of Notes](/static/img/notes-bottom.png "Screenshot of Bottom of Notes")

The Next Steps section contains the actual content of all pages that have a
next-steps tag.  The same applies to the waiting section and the inbox section,
though I have intentionally reduced the emphasis of those sections by putting
them after Next Steps.

Finally, I have three columns for projects, reference, and incubation.  (This
is based on (affilliate link:)
<a target="_blank" href="https://www.amazon.com/gp/product/0143126563/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0143126563&linkCode=as2&tag=afoolishmanif-20&linkId=04f5faa589e85c6dcdba336d7d157a50">GTD</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0143126563" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
which works really well for me.)

The above all works splendidly with the original setup, but I had some
inspiration when speaking with my friend Melinda about recipe storage.  At the
time I stored recipes simply as a gigantic list of links on a single page.
While discussing better recipe storage methods I thought aloud:

> My plan is to segregate things into meals (breakfast, lunch, dinner, snacks,
> etc) and then maybe explode each from a bullet to a full page that I can keep
> notes on, so I can say, for example, "made this 2020-01-04; was too salty" or
> whatever.  Thoughts?

I initially planned on cobbling this together with hugo [but didn't get very
far](https://discourse.gohugo.io/t/creating-custom-indexes/22645).  After pondering
on it for a little over a month, I decided to dive in and just do it: build my own
system from scratch to allow this kind of flexible page generation.

## Performance Driven Development

I mentioned before that the original system had a fast query interface, which
is literally what I wanted to provide to the pages for ad-hoc linking.  I
wanted to maintain the speed of the old query engine, but also wanted page
generation to be fast too.  With that in mind I set my goal at generating a
thousand pages in one second.  I don't expect to have a thousand pages any time
soon, but having drawn a line in the sand I was able to make decisions on what
worked and what didn't.

I started off by implementing the most basic functionality, both with a test and a
benchmark, to verify that I could do it quickly enough to meet my goals.

Here's a test that verifies the code actually works:

```golang
func TestRender(t *testing.T) {
	z, err := newZine()
	if err != nil {
		t.Fatalf("couldn't create db: %s", err)
	}

	a := article{
		Title: "frew",
		Tags:  []string{"foo", "bar"},
		Extra: map[string]string{"foo": "bar"},
	}
	for i := 0; i < 1000; i++ {
		if err := z.insertArticle(a); err != nil {
			t.Fatalf("couldn't insert article: %s", err)
		}
	}
	got, err := z.render(article{Title: "x", Body: []byte(`hello! *{{ with $r := (q "SELECT COUNT(*) AS c FROM _")}}{{ index $r 0 "c" }}{{end}}*`)})
	if err != nil {
		t.Errorf("should not have gotten an error: %s", err)
		return
	}

	testutil.Equal(t, string(got), "<p>start</p>\n<p>hello! <em>2000</em></p>\n<p>end</p>\n", "simple")
}
```

Knowing it works, I verified that it was fast enough:

```golang
// The S stuff is cargo cult to make sure the benchmark doesn't get inlined to
// nothing.  Basically forcing some kind of minor side effects.
var S string

func BenchmarkRender(b *testing.B) {
	b.StopTimer()
	z, err := newZine()
	if err != nil {
		b.Fatalf("couldn't create db: %s", err)
	}

	a := article{
		Title: "frew",
		Tags:  []string{"foo", "bar"},
		Extra: map[string]string{"foo": "bar"},
	}
	for i := 0; i < 1000; i++ {
		if err := z.insertArticle(a); err != nil {
			b.Fatalf("couldn't insert article: %s", err)
		}
	}

	var out []byte
	b.StartTimer()
	for i := 0; i < b.N; i++ {
		var err error
		out, err = z.render(article{Title: "X", Body: []byte(`hello! *{{ with $r := (q "SELECT COUNT(*) AS c FROM _")}}{{ index $r 0 "c" }}{{end}}*`)})
		if err != nil {
			b.Errorf("should not have gotten an error: %s", err)
			return
		}
	}

	S = string(out)
}
```

![Example of running benchmark](/static/img/zine-bench.gif)

When I would add a feature I'd verify that the code never got too slow; some
might call this premature optimization, but in reality I was verifying that I
never crossed an unacceptable line regarding my desired peformance.

```
$ time bin/zine render

real    0m0.446s
user    0m0.373s
sys     0m0.149s
```

In fact, throughout the project I have only implemented a single optimization:

```diff
 CREATE TABLE articles (
    title,
    date,
-   guid,
    filename
 );
-CREATE TABLE article_tag ( guid, tag );
+CREATE TABLE article_tag ( id, tag );
-CREATE VIEW _ ( guid, title, date, filename, tag) AS
+CREATE VIEW _ ( id, title, date, filename, tag) AS
-   SELECT a.guid, title, date, filename, tag
+   SELECT a.rowid, title, date, filename, tag
    FROM articles a
-   JOIN article_tag at ON a.guid = at.guid;
+   JOIN article_tag at ON a.rowid = at.id;
```

The above change dropped my query time from 1.6ms to 16µs.  I'll take a four
line change for a two order of magntiude speedup any day.  This is because
SQLite has an implicit index on the (automatic) `rowid` column.

## Using Zine in Anger

Immediately after implementing the basic functionality I used it for the
intended use case.  I added this little bit to my recipes page:

```
## Dinner

{{range (q "SELECT title, url FROM _ WHERE tag = 'dinner'") }}
 * [{{.title}}](/{{.url}})
{{- end}}

```

and then added this article the next day:

```
{
"title": "Sous Vide Burgers",
"tags": [ "recipe", "dinner", "reference" ]
}

[Sous Vide Burgers](https://www.seriouseats.com/recipes/2010/06/sous-vide-burgers-recipe.html#toc)

## 2020-02-17

 * Made 2 quarter pound burgers and 3 half pound burgers
 * pre-seared one of the half pound burgers
 * salt on all, pepper on catherines
 * Cooked at 54°C, started at 3:08pm
 * Stopped cook at 5:20pm, padded burgers dry, let air on rack for 10m
 * Torched each side of burger for 30s, added cheese and torched cheese for ~15s
 * Burgers were probably too big; should do 3rd pounders for ours
 * pre-sear had negative effect
```

I am able to link to recipes on a dedicated recipes page, which is a mix of
both my own content and links to external content.  As I make recipes I'm able
to build out their content to be notes to my future self.  The autolinking in
the Recipes page makes this easy and fun for me.

While the above is all nice and handy, of course there are times when my
templates produce Markdown that is not what I intend.  For example, these two
lists produce painfully different results:

```markdown
 * first
 * second
 * third
```

The above makes a normal bulleted list.

```markdown
 * first
 * second

 * third
```


This, on the other hand makes a bulleted list of *paragraphs*, so you end up
with a bunch of annoying whitespace.

To be clear, here's the actual rendered output of the first chunk of markdown:

 * first
 * second
 * third

And second:

 * first

 * second

 * third

This is easy to do on accident when the content is generated.  With that in
mind I made a little debug command that generates the markdown but doesn't turn
it into HTML.

```
$ zine debug -file index
 [ ... ]

# Projects
                                                                                               
 * [Amygdala](posts/amygdala)                                                                                                                                                                  
 * [AwesomeWM](posts/awesomewm)                                                                
 * [BPF](posts/bpf) 
 [ ... ]
```

This is the cost of the complexity of this system, but I'm ok with it.

## Missing Features

There are some missing features in zine still, of course.  The main one is that
there is no way to generate an index.  For example, if I wanted to have a
distinct page for each tag, I'd have to make a markdown file for each tag.  At
some point I'll come up with some solution for that, but it's not a big deal.
The main tags are all surfaced on the landing page ([recall the screenshots
from before](#why-new-software).) And on top of that I have a little script
that validates that all posts have one of the canonical tags:

```
#!/bin/sh

bin/zine q -sql 'SELECT filename FROM articles a WHERE
    NOT EXISTS (SELECT 1 FROM article_tag at WHERE a.rowid = at.id AND tag IN
    (?, ?, ?, ?, ?, ?, ?))
   ' project reference incubation next-steps meta waiting inbox
```

---

Is zine software everyone should be using?  Absolutely not.  In fact I am not
even maintaining it outside of my notes repo, which means that there is no
public repo of the code.  Was it worth doing?  For me, it scratched an itch
that I'd had for quite a while: I wanted to make cross linking in my notes easy
and fun.

There are probably other ways to achieve the same thing; some wikis probably
support this, but I have my own workflow around these plaintext notes and do
not want to change it.

If anything, I think making software just for myself is very pleasant and
freeing.  I can be as picky as I want.  I can get sloppy if I want.  I can
stick with a small set of libraries or I can pull in all of Kubernetes.  It's
mine and I need no justification other than my own whims.


Thanks to Matthew Horsfall for reviewing this post.

---

(The following includes affiliate links.)

If you want to learn more
about programming Go, you should check out <a target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.  It is one of the best programming books I've read.
You will not only learn Go, but also get some solid introductions on how to
write code that is safely concurrent.  **Highly recommend.**

If you are inspired by all these tools that I've built, I suggest reading
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=7320143b3b25493a297e134aa6fc0846">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
