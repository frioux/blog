---
title: "Vim Advanced Sessions: Corrected"
date: 2017-05-24T07:10:50
tags: [ vim, session, toolsmith, axel, ziprecruiter ]
guid: 9D95C282-3EF1-11E7-90DE-2261E766A8BE
---
[Last time](/posts/advanced-vim-sessions/) I blogged about [vim
sessions](/posts/vim-session-workflow/) I showed a cool pattern for making
sessions more generally useful.  There was a bug in my example that hamstrung
the technique, so I'll be sharing and updated version here.

<!--more-->

Ever since I built [fressh](/posts/my-mobile-shell-home/) I've been keen to
remove vim plugins (which are submodules in my dotfiles) that are only used on
one or two projects. When I was writing Monday's [post about Vim's File
Lists](/posts/vim-file-lists/) I noticed that factoring my custom commands out
of my `.vimrc` and into a plugin mysteriously didn't work.  I assumed that
somehow I'd typo'd something or more likely the plugin I'd built was somehow
malformed.  The answer is a little bit more interesting.

## Vim Plugins

First, what is a plugin, *really*?  Here's a partial tree listing of [the `UltiSnips`
plugin](https://github.com/sirver/ultisnips):

```
etc/vim-bundle/ultisnips
├── after
│   └── plugin
│       └── UltiSnips_after.vim
├── autoload
│   ├── neocomplete
│   │   └── sources
│   │       └── ultisnips.vim
│   ├── UltiSnips
│   │   └── map_keys.vim
│   ├── UltiSnips.vim
│   └── unite
│       └── sources
│           └── ultisnips.vim
├── doc
│   └── UltiSnips.txt
├── ftdetect
│   └── snippets.vim
├── ftplugin
│   └── snippets.vim
├── plugin
│   └── UltiSnips.vim
├── pythonx
│   └── ...
├── README.md
├── rplugin
│   └── python3
│       └── deoplete
│           └── sources
│               └── ultisnips.py
└── syntax
    ├── snippets_snipmate.vim
    └── snippets.vim
```

We tend to consider all of the files in the above listing part of the plugin.
But really there are two kinds of plugins; we consider sets of files that vim
will read for a related purpose to be a plugin (usually added to `&runtimepath`
by some plugin manager) but to vim only a file that is in the `plugin`
subdirectory in one of the `&runtimepath` directories is a plugin.

Critically: plugins do not get loaded after sessions, so if you modify
`&runtimepath` in a session, `plugin` files will not get loaded, though
`autoload`, `ftplugin`, `syntax`, and other files will.  This is why I thought
my pattern before was fine: the plugins I was testing had no actual `plugin`
files.

## Advanced Vim Sessions

First and foremost, my initial use case was to set project related settings in
vim, typically `path`.  This is handled natively in vim.  From `:help starting`:

> * If a file exists with the same name as the Session file, but ending in
>   "x.vim" (for eXtra), executes that as well.  You can use *x.vim files to
>   specify additional settings and actions associated with a given Session,
>   such as creating menu items in the GUI version.

So instead of building a nested session to set the path, you can simply create
(for a session called `zr`) `zrx.vim` that sets the path.  (My friend Meredith
showed me this; I just looked it up in the docs after she showed me.)

Now for plugins it's more complicated.  I assumed I could use `-c` to add to
runtime path, but it turns out that `-c` runs at the same time as session
loading, so that wasn't an option.  I also considered using `-u` which is the
flag you use to specify an alternate `.vimrc` but it also disables all the
builtin runtime files, so you end up without any syntax highlighting, etc.

The answer lies in the `VIMINIT` environment variable.  Again, from `:help
starting`:

> Five places are searched for initializations.  The first that exists
> is used, the others are ignored.  The $MYVIMRC environment variable is
> set to the file that was first found, unless $MYVIMRC was already set
>  and when using VIMINIT.
>
> 1. The environment variable VIMINIT (see also |compatible-default|) (*)
>    The value of $VIMINIT is used as an Ex command line.

If you want to run some code as if it were in your dotfiles but actually have it
in a session, you could do what I did:

``` sh
VIMINIT='source ~/.vimrc | source zra.vim' vi -S zr
```

So the trick is to source your normal `~/.vimrc` and then source another file.
Doing this by hand is silly, so I wrote (of course) a `vim` wrapper that would
do it for me:

``` perl
#!/usr/bin/perl

use strict;
use warnings;

use File::Basename 'fileparse';

# This way a gvim symlink will work too
my $vim = '/usr/bin/' . fileparse($0);

my $session;
for my $i (0..$#ARGV) {
   if ($ARGV[$i] eq '-S') {
      if ($i eq $#ARGV) {
         $session = 'Session.vim';
      } elsif (exists $ARGV[$i+1]) {
         $session = $ARGV[$i+1]
      }
   }
}

if (defined $session && -f $session) {
   my $presession = "${session}a.vim";
   $ENV{VIMINIT} = "source ~/.vimrc | source $presession" if -f $presession;
}

exec $vim, @ARGV
```

With the above, `vim -S zr` will load `zra.vim` first, then `zr`, then
`zrx.vim`.

---

I doubt a ton of people will find this helpful, but at the very least it might
get you out of a jam when you are in a similar situation.  `VIMINIT` allows for
a lot of flexibility where `-u` is more about removing options than adding them.
Thanks to Tim Pope for pointing out to me that sessions are loaded after
plugins.

---

If you'd like to learn more, I can recommend two excellent books.  I first
learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.
