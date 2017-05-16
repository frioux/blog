---
title: "lost.vim: for when you're lost in a file"
date: 2017-05-15T06:52:28
tags: [ announcement, vim, git, ziprecruiter, axel ]
guid: C1444B76-37F9-11E7-A9D0-AD02DB66A8BE
---
I wrote a plugin on Friday to making orienting yourself in a large piece of code
easier.  The short version is that with the new plugin
[lost.vim](https://github.com/frioux/vim-lost) you can call `:Lost` or use the
`gL` mapping to find your bearings.

<!--more-->

A couple weeks ago [I wrote a post about
`file-context`](/posts/file-context-lost-in-a-file/), a commandline tool that
would give the "context" of a single line of code in a given file.  I
implemented it as a vim plugin.

## What does `lost.vim` do?

The context
for *any* of the lines in the following selections of would be the first line of
each, which with the plugin get echoed when you press `gL` or call `:Lost`:

``` perl
sub perl_func {
  # a thousand lines of code
}
```

``` python
def python_func():
  # a thousand lines of code
```

``` javascript
function javascript_func() {
  // a thousand lines of code
}
```

``` go
func go_function() {
  // a thousand lines of code
}
```

``` perl
my $var = {
   # A thousand lines of hash
};
```

## How does it work?

Initially I assumed that `git(1)` used some kind of deep magic and actual
parsing to do the above, which is why in the original blog post I literally
shelled out to git and then parsed the diff.  Then [on
twitter](https://twitter.com/apag/status/860017116149370880) [Aristotle
Pagaltzis](http://plasmasturm.org/about/#me) [showed me how it actually
works](https://git.savannah.gnu.org/cgit/diffutils.git/tree/src/diff.c?id=eaa2a24345fba918eb7ad7a6a263e7e639d82d5f#n462).

The tool searches backwards for a line that starts with any alphabetical
character, or underscore, or `$`.  The main failure is when working in a
language where functions definitions are indented; Java, C#, and some JavaScript
tend to look this way.

The new version is not just hugely more efficient (before it was copying files,
running programs, doing parsing, etc) but it also works with unwritten files and
is pure vim with literally no requirements other than vim.

My instinct is to extend this to work with formats that it does not already work
with, like markdown, but I honestly think that would be gilding the lily.

By the way while markdown like the following does not work:

```
## The Beginning

Originally I had planned to take a bus to my first stop at 5:30 am, but the guy
that I work with, Kenton, offered to drive me because he was going for groceries
anyway. That was nice and made the trip better since I did not have to take that
long, boring, cramped bus ride. After arriving in La Ceiba Kenton and his wife
Saundi showed me a number of different things that are good gifts to give in the
states. I will not enumerate said gifts because readers may end up being
recipients of the gifts.
```

this renders the same and does work:

```
The Beginning
=============

 Originally I had planned to take a bus to my first stop at 5:30 am, but the guy
 that I work with, Kenton, offered to drive me because he was going for
 groceries anyway. That was nice and made the trip better since I did not have
 to take that long, boring, cramped bus ride. After arriving in La Ceiba Kenton
 and his wife Saundi showed me a number of different things that are good gifts
 to give in the states. I will not enumerate said gifts because readers may end
 up being recipients of the gifts.
```

I don't really care though; I don't edit much (any?) markdown that would benefit
from `lost.vim`.

---

I hope you check out the plugin and find it as useful as I do; feel free to let
me know [on twitter](https://twitter.com/frioux) or in the comments on anything
that you would improve.

If you'd like to learn more about vim, I can recommend two excellent books.  I
first learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.
