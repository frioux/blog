---
title: Updates to my Notes Linking Tools
date: 2019-01-08T08:11:00
tags: [ frew-warez, golang, meta, vim ]
guid: 2d7780f0-d095-4df6-97ac-cc1802b44cf5
---
I recently improved some of my notes tools, most especially around linking to
emails.

<!--more-->

[About a year and a half ago I configured my laptop to let me directly link to
an email](/posts/custom-uri-schemata-on-linux/).  I've improved on that tooling
in a couple of ways since then.  In short I changed the schema to `mid:` instead
of `email://`, which my friend Meredith showed me was kindav a standard.  Also
instead of having a trailing segment that starts with `@` to specify the account
that the message is in, I simply search in both of my local mail accounts,
assuming the Message-ID is unique.  [You can see those changes
here.](https://github.com/frioux/dotfiles/commit/0d08632c83792ac62b389de169c57b353c1b59cc)

I some software to build these links more simply.  I have gotten used to using
[a tool](/posts/some-cool-new-tools/#dump-mozlz4) to build a list of all of my
open tabs into my [notes system](/posts/a-love-letter-to-plain-text/).  I
recently decided that I wanted to do the same thing for my email, so that I
could easily "dump" my email inboxes into my notes inbox, and then just use
vim's built in delete/put functions to either dispatch the item into more
contextual next step lists or just open them immediately.

I started off, as I often do, building [a tool to export email to
json](https://github.com/frioux/leatherman#email2json).

Interestingly, to me anyway, this was not as straightforward as I expeced it to
be.  Mainly because the Go mail parser does not decode headers out of the box,
or even have a method to do that.  The mail packages is `net/mail`, but to
decode your headers you need to use `mime.WordDecoder`'s `DecodeHeader` method:

```golang
	e, err := mail.ReadMessage(file)
	if err != nil {
		return errors.Wrap(err, "mail.ReadMessage, path="+path)
	}

	dec := new(mime.WordDecoder)

	s, err := dec.DecodeHeader(e.Header.Get("Subject"))
	if err != nil {
		panic(err)
	}
	fmt.Println(s)
   ```

`email2json` is not perfect; it only handles headers and even then only the first of a
given header, but that solves my needs.  I use that tool to then generate a
markdown list of links based on the inboxes of both of my mail accounts:

```bash
#!/bin/sh

email2json \
    '/home/frew/var/mail/INBOX/cur/*' '/home/frew/var/mail/INBOX/new/*' \
    '/home/frew/var/zr-mail/INBOX/new/*' '/home/frew/var/zr-mail/INBOX/cur/*' |
    jq -r \
    '" * ["+.Header.Subject+"](mid:"+(.Header["Message-Id"]|match("<(.*)>")|.captures[0].string)+")"'
```

That's great, I love it, but I decided that "clicking" links within vim was too
much of a hassle, typically involving visually selecting the target of the link
and pressing `gx`, so I (finally) made a mapping to do that for me.

```
nmap g<space> mm0f]f(vi(gx`m
```

Unpacking that, it maps `g<space>` to mark the location of the cursor into `m`,
jump to the 0 column, find the first `]`, then the first `(`, then select all
the text inside a pair of parentheses, then `gx` (click the link), and jump back
to wherever the `m` mark is.

I am really surprised and how natural the `g<space>` mapping is.  I had muscle
memory in less than a day.

This has really helped me both maintail inbox zero and ensure that the emails
get categorized into some meaningful context (instead of just dealing with all
of them immediately.)  The main risk right now is that all work emails end up in
"work."  I probably need to break up the work next step lists a bit.

---

(The following includes affiliate links.)

If you're at all interested in the system I use for my notes, it's based on
<a target="_blank" href="https://www.amazon.com/gp/product/0143126563/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0143126563&linkCode=as2&tag=afoolishmanif-20&linkId=37ab814736ab4a3ead2bff3dc5bb7b56">Getting Things Done</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0143126563" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
and I've found it pretty helpful.

If you are inspired by all these tools that I've built, I suggest reading
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=7320143b3b25493a297e134aa6fc0846">The UNIX Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
