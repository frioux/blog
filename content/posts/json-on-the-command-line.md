---
title: JSON on the Command Line
date: 2017-09-18T07:58:44
tags: [ ziprecruiter, json, perl ]
guid: B834E2B4-9AED-11E7-9D7D-60A9878F3B27
---
Recently my coworker Andy Ruder was complaining that he often reached for grep
when filtering JSON, and I offered to give him some tips.  This post is an
expansion of what I told him.

<!--more-->

I deal with JSON multiple times a day.  Our logs are JSON, so easily being able
to read and interact with them is important.  I use a small number of tools and
techniques and in general think that my life with JSON on par with, say,
traditional Unix files that are tables (at best) separated by a single
character.

## `jq`

The primary tool for JSON interaction is the popular [`jq`][jq].  Generally
speaking the usage of `jq` is unsurprising and approachable.  Here is a
typical use of `jq`:

``` bash
$ echo '{"user": { "groups":[{"id":1,"name":"frew"},{"id":2,"name":"admin"}]}}' |
   jq '.user.groups[].name'
"frew"
"admin"
```

`jq` has a couple flags that you really want to know about.  First is `-S` which
sorts the keys of any objects that it prints out.  At some point I am likely to
make a `jq` wrapper to just always turn this on.  Second is `-r` which disables
the quoting and (I think) color coding of the output.  We'll use this in a later
example.

Another feature `jq` offers, which is really strange at first, is the ability to
filter with simple JavaScript like expressions.  Here's how that works:

``` bash
$ echo '{"name":"frew","value":"engineer"}{"name":"frooh","value":"pal"}' |
   jq 'select(.name == "frew") | .value'
"engineer"
```

Note that `jq` allows leaving the `|` off between it's internal pipelines almost
always, but it helps my understanding to include it.

`jq` can understand any documents that are concatenated together, thanks to the
fact that JSON is self terminating.  So the above works, newline terminated
works, etc.

## `gron`

While `jq` gives you a nice little DSL for interacting with JSON, [`gron`][gron]
makes JSON fit in better with typical Unix tools.

Here's how you use it:

``` bash
$ echo '{"user": { "groups":[{"id":1,"name":"frew"},{"id":2,"name":"admin"}]}}' |
   gron
json = {};
json.user = {};
json.user.groups = [];
json.user.groups[0] = {};
json.user.groups[0].id = 1;
json.user.groups[0].name = "frew";
json.user.groups[1] = {};
json.user.groups[1].id = 2;
json.user.groups[1].name = "admin";
```

I use this probably twice a month by running something like this:

``` bash
$ cat bigfile.json | gron | grep 'me@frioux.com'
json.user[123].email = "me@frioux.com";
```

And then to get the rest of the record I use `grep -F`:

``` bash
$ cat bigfile.json | gron | grep -F 'json.user[123]'
json.user[123].id = 123;
json.user[123].email = "me@frioux.com";
json.user[123].name = "Frew Schmidt";
```

Then, if you are using this with a program, you can pipe to `gron -u` (`ungron`)
to get json back out.  Honestly though, I find that mode better for filtering on
"columns:"

``` bash
$ cat bigfile.json | gron | grep -P '\.(id|name) ' | gron -u
...
  },
  {
    "id": 123,
    "name": "Frew Schmidt"
  }
]
```

Finally, if it's not obvious, `gron` is great for reverse engineering the path
of a deeply nested structure.  Like I did with the second `gron` example, but
not so trivial to eyeball.

## `csv2json`

[`csv2json`][c2j] (which I [have mentioned][1] [twice now][2]) is a very simple
Perl script, originally implemented by Andrew Farmer, that turns CSV into JSON.

Usage is trivial:

``` bash
$ cat foo.csv | csv2json | jq .
```

It uses the header of the csv for column names.  This means that it can be
annoying in pipelines, requiring something like this:

``` bash
$ ( head -1 foo.csv ; cat foo.csv | grep whatever ) | csv2json | jq .
```

I rarely use the above idiom, but it's good for when you proces enough data to
actually have to wait (10s or more) for `jq` to finish. I've found that `grep`
will outperform it by orders of magnitude.

Because of all of these tools, I am often willing to use JSON even if it's less
efficient than something more natural.  For example, [when querying Athena][athena] I will
get CSV with a `log_date` column and a `record` column.  The former is an
ISO8601 date and the latter is just JSON.  Sure, I could probably use `cut` to
extract the record, but the following works well enough and I suspect works
better in cases where the output is "strange:"

``` bash
$ cat athena.csv | csv2json | jq .record -r | jq .
```

## `yaml2json`

This is a tiny tool that I have in [my dotfiles][dotfiles] ([and thus on all
servers I connect to][fressh]) which makes treating YAML like JSON trivial.  I
suspect the usage is obvious but here it is:

``` bash
$ cat /etc/salt/grains | yaml2json | jq .
```

I avoid YAML when possible, but sometimes I have to interact with it, and this
helps a lot.

---

I hope this is helpful!  I think if anything, the tooling above should be an
encouragement for those on the fence about JSON oriented logs.  The only place
where I am not a fan of JSON oriented logs is directly to the screen, which I am
actually, actively working on solving at work and may blog about some other
time.

---

(The following includes affiliate links.)

If you'd like to learn more about this kind of tool,
<a target="_blank" href="https://www.amazon.com/gp/product/1593273894/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593273894&linkCode=as2&tag=afoolishmanif-20&linkId=f63ee71fb68dc4e6522523d6fbedb2c9">The Linux Command Line</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593273894" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
would be a good start.  Chapter 20 specifically covers this kind of tool, though
with more of the usual suspects like `cut`, `sort`, `uniq`, etc.

If you want to improve your foundations, 
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=6279d8d234dff9ee5623e7ad7bed35df">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> 
is an excellent read.  It was one of the few tech books in recent memory that I
read cover to cover.

[jq]: https://stedolan.github.io/jq/
[gron]: https://github.com/tomnomnom/gron
[1]: /posts/day-to-day-tools/#csv2json-https-github-com-frioux-dotfiles-blob-c109ceb28ef9ab34ac35ca07d943049763fdacb5-bin-csv2json
[2]: /posts/csv-databases-in-perl/
[dotfiles]: https://github.com/frioux/dotfiles
[fressh]: /posts/my-mobile-shell-home/
[athena]: /posts/using-amazon-athena-from-perl/
[c2j]: https://github.com/frioux/dotfiles/blob/e28e98ad5066e21eb125bce1db0d180b90906c6a/bin/csv2json
