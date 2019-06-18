---
title: Productive Weekend
date: 2019-06-17T19:25:39
tags: [ frew-warez, vim, amygdala, leatherman ]
guid: 0571ffd7-5131-4001-8a0d-8eeb3c2c8885
---
I got a bunch of random stuff done this weekend.

<!--more-->

I wrote
[markdownfmt](https://github.com/frioux/dotfiles/commit/a197dbc92fab03ea7a7d466a761e746156db16a9)
and
[mailfmt](https://github.com/frioux/dotfiles/commit/6f581da759f1deec95b76c7387911691ea574c4f)
which are stupid wrappers around `fmt -w80` that ignore blog metadata and my
email signature, respectively.  This was after trying to figure out what to do
with [this](http://vimdoc.sourceforge.net/htmldoc/options.html#'paragraphs'):

```
'paragraphs' 'para'	string	(default "IPLPPPQPP TPHPLIPpLpItpplpipbp")
			global
	Specifies the nroff macros that separate paragraphs.  These are pairs
	of two letters (see |object-motions|).
```

Writing a script is a hack, but learning how to handle the above sounds like a
waste of time.

I updated my amygdala to [immediately deliver messages from the
past](https://github.com/frioux/amygdala/commit/8e77db667eb93c5ca56e7ce7c005b81d52f72374)
(basically when my laptop comes back online,) [deliver x11
notifications](https://github.com/frioux/amygdala/commit/64ea3507ded10e8ededa3b85b7fa648d9fc6e729),
and [support the words "noon" and "midnight" in reminder
input](https://github.com/frioux/amygdala/commit/a18080061a01eed5c4d64061d5f57491534aa783).

I added [a very basic accesslog to the leatherman's `srv`
tool](https://github.com/frioux/leatherman/commit/6c318ce9d56a1a6b9bcccbf9c5ac3313a7f0504b).

I built a little vim command that would let me cycle through my quickfix, rather
than hittin a wall at the end:

```vim
command! Ccycle call Ccycle()

function Ccycle()
   if getqflist({ 'idx': 1 }).idx == len(getqflist())
      exe 'cfirst'
   else
      exe 'cnext'
   endif
endfunction
```

And this is all on top of setting up an s3 hosted website so my father-in-law
wouldn't have to deal with scummy web hosts who keep ghosting his company.

All in all a pretty productive weekend!
