---
title: "file-context: for when you are lost in a file"
date: 2017-05-01T07:47:33
tags: [ toolsmith, vim, git, axel, ziprecruiter ]
guid: 3EE7828C-2D28-11E7-863A-4FDB92525F5E
---
Sometimes I will edit a huge file and got confused or distracted and lose track
of where in the file I am.  I wrote a tool a few days ago and integrated it into
vim.  It's pretty cool.

<!--more-->

## Inspiration

One of the subtle brilliances that `git` provides is context other than simple
line numbers in diffs.  I know that it wasn't the first tool to implement such a
feature (`diff -p` does the same thing) but it was the first one that I've seen
use it by default.  For example, the diff
[here](https://github.com/frioux/DBIx-Class-Helpers/commit/2bef898e9c2c70c79d269c7222e619ac08be027c#diff-541385fdf1ae526e444d502ed0483b3cL33)
includes the following snippet:

```
@@ -33,9 +44,9 @@ sub _defaults {
    my ($self, $params) = @_;

    $params->{namespace}           ||= [ get_namespace_parts($self) ]->[0];
-   $params->{left_method}         ||= String::CamelCase::decamelize($params->{left_class});
-   $params->{right_method}        ||= String::CamelCase::decamelize($params->{right_class});
-   $params->{self_method}         ||= String::CamelCase::decamelize($self);
+   $params->{left_method}         ||= $decamelize->($params->{left_class});
+   $params->{right_method}        ||= $decamelize->($params->{right_class});
+   $params->{self_method}         ||= $decamelize->($self);
    $params->{left_method_plural}  ||= $self->_pluralize($params->{left_method});
    $params->{right_method_plural} ||= $self->_pluralize($params->{right_method});
    $params->{self_method_plural}  ||= $self->_pluralize($params->{self_method});

```

The top of the snippet is the function that the change was made in.  The
context is not always perfect, but it's right so often it is astounding.  This
is exactly what I wanted, but generalized.

## `file-context`

So I write
[`file-context`](https://github.com/frioux/dotfiles/blob/master/bin/file-context).
Here's the entirety of the code at this time of writing:

```
#!/bin/dash

if [ $# -ne 2 ]; then
  echo "Usage: $0 path/to/file linenumber" 1>&2
  exit 1
fi


file="$1"
line="$2"
newfile="/run/shm/$(basename "$file").munged"

cp "$file" "$newfile"
echo "$line\ni\ntmp\n.\nwq" | ed -s "$newfile" >/dev/null

git diff --no-index "$file" "$newfile" |
   perl -pne 'if (m/^@@ .* @@ (.*)/) { $_ = "$1\n"} else { undef $_ }'

rm "$newfile"

# vim: ft=sh
```

Basically all it does is insert the string `tmp` at the passed line number, does
a `git diff`, and prints out the context that `git` prints.  I am delighted by
how simple and brief the code is.

# Vim integration

I wanted a way to ask vim where I was, so I defined a command called
[`:Lost`](https://github.com/frioux/dotfiles/blob/e2930933a86ded32259c40777496d898825c9404/vimrc#L426-L431)
that would call `file-context`.  Here it is:

```
function Lost()
  let line = line('.')
  let file = expand('%')
  exe 'echom system("file-context ' . file . ' ' . line . '")'
endfunction
command Lost call Lost()
```

So when you call this the output of `file-context` gets placed in a single line
at the bottom of your vim window.  The only thing that would be more natural is
if it automatically got placed there when I paused, but that might get annoying.

---

I enjoyed building this tool, and will be interested to find out how useful it
is in the future, and what tweaks might be needed.  The best part was, as
sometimes happens when you have been doing something for a long time, how
effortless this was.  The only hard part was reading the git source to see if
maybe I could get the context more directly, and deciding I couldn't.

---

As with the last post about writing tools, I want to mention <a
target="_blank"
href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=cecea11ea25b6635dd78601d2ec1abef">The
Unix Programming Environment</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  It's a great book that includes a lot of what you might
consider the spirit of building tools.

For the Vim integration it might be worth looking at <a
href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning
the vi and Vim Editors</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  The new edition has a lot more information and spends more
time on Vim specific features.  It was helpful for me when I first started with
Vim, and the fundamental model of vi is still well supported in Vim and this
book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.
