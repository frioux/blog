---
title: My Set of Vim Plugins
date: 2017-03-17T11:38:08
tags: [ vim, toolsmith ]
guid: 5B35ECFC-093E-11E7-A4BA-BDEE1457C320
---
I use a lot of plugins for vim.  I'd like to go through all of my vim settings
in a post at some point, but plugins are nicely isolated for the most part so
describing their functionality seems more approachable.  I am listing (nearly)
all of my plugins and various things I know about each.

<!--more-->

[airline](https://github.com/vim-airline/vim-airline) is a plugin that replaces
ye olde status line.  It is a fork of powerline which was absurdly deprecated
before it's `v2` got written.  Airline requires nothing aside from vim, though
some special fonts (which I don't use) are supported.

[better-whitespace](https://github.com/ntpeters/vim-better-whitespace) solves
the age old problem of trailing whitespace and attempts to be less annoying
about it.  Basically it highlights lines ending in whitespace (or other issues
like using tabs I think) *but only if the line is not being edited.*

[colors-solarized](https://github.com/altercation/vim-colors-solarized) is my
day to day theme.  Only feature worth mentioning is that it has a dark and light
background which I toggle between if it's an exceptionally bright day.

[commentary](https://github.com/tpope/vim-commentary) is the first of many
plugins by Tim Pope that will be listed here.  It is simply a plugin to help
toggling comments for given lines of code.  The neat thing about it is that it
uses a custom vim operator, so you use it along with other text objects the way
you might use `d` to delete lines (`dd`, `d3d`, `dip`, etc.)  So to be clear you
could comment out a paragraph with `gcip`.

[csv](https://github.com/chrisbra/csv.vim) is simply a plugin that adds direct
csv support to vim.  When I use it it simply improves the rendering of the
columns, but I think there is a lot more it does that I do not use.

[ctrlp](https://github.com/ctrlpvim/ctrlp.vim) is one of a newly popular group
of plugins that helps navigate files with a little bit of computer assistance.
I use this to find files based on name, open other buffers, and open other files
in the same directory as the current file.

[eunuch](https://github.com/tpope/vim-eunuch) is more software by Tim Pope.
Provides vim commands for lots of Unix commands.  I use `:Remove`, `:Rename`,
`:Chmod`, and `:SudoWrite` pretty often.

[exchange](https://github.com/tommcdo/vim-exchange) is a hard to describe plugin
that assists in exchanging blocks of text.  I don't use this as often as I used
to; no idea why.  General usage is `cxiw` to select one word and then `cxiw` to
exchange it with some other word.  Any other text-object will work.

[FastFold](https://github.com/Konfekt/FastFold) simply tweaks how often vim
updates it's idea of folds.  Folds are when you collapse regions of text based
on syntax, markers, etc.  Vim by default updates these folds too often; this
plugin simply resolves that problem by taking a more balanced approach.

[fugitive](https://github.com/tpope/vim-fugitive), more from Tim Pope, is
probably "the best Git wrapper of all time."  I use `:Ggrep` and `:Gblame`
multiple times a day, and once in a blue moon use `:Gstatus` to quickly jump
into modified files.

[fugitive-gitlab](https://github.com/shumphrey/fugitive-gitlab.vim) simply
allows running `:Gbrowse` while using a gitlab based repo.  `:Gbrowse` might
seem silly, but it is especially useful in that it works in visual mode and
generates permalinks (that is it includes the current revision in the URL.)

[gitgutter](https://github.com/airblade/vim-gitgutter) adds little markers for
what lines have been modified since last added to the git index.  Cute, but can
be very slow and a little buggy.  Also gives you some handy bindings for jumping
directly from one changed set of lines to the next: `[c` and `]c`.

[go](https://golang.org/) has some official vim support that comes directly from
the golang repository.  I don't actually use this as often as I'd like, and
would consider making it a simple project based plugin.

[goyo](https://github.com/junegunn/goyo.vim) is a plugin that helps you focus on
vim only.  Removes all decoration and information other than the text you are
editing.  I would like to tweak this a little bit as I have some plugins that
interact with it poorly, but I still like it for blogging.

[IndentAnything](https://github.com/vim-scripts/IndentAnything) helps with
indents.  I often forget about plugins like this and will even uninstall them,
and then be annoyed when the built in autoindent is terrible.

[inkpot](https://github.com/ciaranm/inkpot) is the color scheme I use in the
terminal.

[lastplace](https://github.com/farmergreg/vim-lastplace) places the cursor where
it was the last time you edited the file.  There are little snippets floating
around the internet on how to do this but this works better than any I've used
and can be updated.

[matchit](http://www.vim.org/scripts/script.php?script%5Fid=39) allows `%` to
work for more than simple parenthesis.  It's pretty old and I have found it
lacking lately.  There is probably a more modern version that would work more
often.

[matchmaker](https://github.com/qstrahl/vim-matchmaker) is a plugin that simply
highlights words that are the same as the word your cursor is over.  I actually
have it off by default because it slows vim down so much, but I can toggle it
with `coM`.

[obsession](https://github.com/tpope/vim-obsession) is basically a way to make
vim sessions more useful out of the box. More Tim Pope.  [I have blogged about
it](https://blog.afoolishmanifesto.com/posts/vim-session-workflow/) [two
times](https://blog.afoolishmanifesto.com/posts/advanced-vim-sessions/).
Typical usage: `:Obsession $some_path`.

[pathogen](https://github.com/tpope/vim-pathogen) is one of the modern vim
plugin managers.  Probably the hardest to use, but definitely has the best name.
Also from Tim Pope.

[perl](https://github.com/vim-perl/vim-perl) adds latest, greatest support for
my main language to vim.  I have no idea what this does but if I uninstalled it
I'm sure I'd be annoyed.

[projectionist](https://github.com/tpope/vim-projectionist) is a cute little
plugin that adds crystaline access to parts of your project.  Think of it as a
beautiful shrunken `ctrlp`.  You basically define a name and what parts of your
project those map to; so if I type `:Econtroller <tab>` I'll see a list
including `Admin`, `User`, etc.  Very handy.

[python](http://www.vim.org/scripts/script.php?script_id=974) simply makes
indendation easier when I am editing python code.

[quick-scope](https://github.com/unblevable/quick-scope) simply enhances the
standard `t`, `f`, etc mappings to highlight some recommended jumps.  I rarely
use this because I also rarely use `t` and `f`.  I feel guilty about that.

[repeat](https://github.com/tpope/vim-repeat) has the dubious honor of being the
one of two Tim Pope plugins with a boring name.  Simply allows plugins to hook
into `.`.

[sleuth](https://github.com/tpope/vim-sleuth), more from Tim Pope, is supposed
to infer `shiftwidth` and `expandtab` so you don't have to set them by hand.  If
you don't know what that means, it's basically how many spaces are a tab.  I
really want to love this but I find it somewhat frustrating, maybe because I
work in a multilanguage project.

[splitjoin](https://github.com/AndrewRadev/splitjoin.vim) is a plugin that adds
a `gS` binding to split a single line into multiple lines, and `gJ` to join
multiple lines back.  Used for basically this type of change:

```
say 1 if $testing;
```

```
if ($testing) {
   say 1;
}
```
 
Works surprisingly reliably.

[surround](https://github.com/tpope/vim-surround) is the second of Tim Pope's
boringly named plugins.  It may have been the second or third vim plugin I ever
installed.  Typically I use `cs"'` to **c**hange **s**urrounding quote from
**"** to **'**., but `ds"` to **d**elete **s**urrounding quote **"** is pretty
common too.  I still have muscle memory from when you could use `s` in visual
mode to surround text and I do not think that has been supported for literally a
decade.

[syntastic](https://github.com/vim-syntastic/syntastic) adds IDE like syntax
checking for basically every language ever.  It is incredibly convenient for
learning new programming languages or using languages you don't use often.  I
have it off in perl because it rarely helps me and slows me down so much.

[tabular](https://github.com/godlygeek/tabular) provides a command that allows
you to align text using a regex.  You might align commas with `:Tabular /,`.

[terminus](https://github.com/wincent/terminus) adds interesting first class
terminal support.  Most importantly, pasting just works, even if you are in
normal mode or paste metacharacters.

[textobj-between](https://github.com/thinca/vim-textobj-between) defines a text
object that works like `t` and `f` but in both directions at the same time.  For
example, to change all characters between two commas, you could use `cif,`.

[textobj-entire](https://github.com/kana/vim-textobj-entire) adds a text object
for the entire file.  Instead of using `ggyG` to copy an entire file, you
could use `yie`.

[textobj-underscore](https://github.com/lucapette/vim-textobj-underscore) adds a
text object for underscore separated words.  Use `ci_` to change between two
underscores and `ca_` to change including the underscores.

[unimpaired](https://github.com/tpope/vim-unimpaired) is a hard to describe but
incredibly useful set of mappings.  Here are things I use all the time:
`[q`/`]q` to jump back and forth in the quickfix list. `con` to toggle line
numbers. `cos` to toggle spellcheck. `cox` to toggle crosshairs.  There is more
but I use the above more than weekly, if not daily.

[vimoutliner](https://github.com/vimoutliner/vimoutliner) is an outlining plugin
I use in a couple of files.  Basically all I use it for is indentation based
folding.  I wish I liked it as much as I think emacs users like org-mode.

[vinegar](https://github.com/tpope/vim-vinegar) is an incredibly lightweight
file browser for vim.  I used to use
[NERDtree](https://github.com/scrooloose/nerdtree) for this, and eventually
cared more about screen real estate and started using
[ctrlp](https://github.com/ctrlpvim/ctrlp.vim).  vinegar is, in my opinion, a
much more basic option but is great if you are trying to open a file in the same
directory as the file you have open.  Basically you press `-` and get a file
listing, move your cursor over the file you want to open, and press enter.

[visual-star-search](https://github.com/bronson/vim-visual-star-search) allows
you to select some text and press `*` (or `#`) and search for it.  Incredible
that this isn't core.

[wipeout](https://github.com/artnez/vim-wipeout) simply closes all buffers that
are not visible with the `:Wipeout` command.

[neocomplete](https://github.com/Shougo/neocomplete.vim) adds IDE style
autocompletion.  Often it is simply autocomplete of words that are in other
buffers, but in some languages it gives incredible, accurate, contextual
autocomplete.  Use `ctrl+n` and `ctrl+p` to move between completions.

[editorconfig](https://github.com/editorconfig/editorconfig-vim) ([see
also](http://editorconfig.org/)) basically adds support for a more basic...
editor configuration that can be used in more than just vim for a project.  For
example at ZR it is used to specify that perl code is a two space indent.

[ultisnips](https://github.com/SirVer/ultisnips) is a plugin I sorta wish I used
more often but I suspect is good that I don't have to.  It adds really useful
snippets that you can easily populate.  I use it [exclusively for writing new
blog
posts](https://github.com/frioux/dotfiles/blob/master/vim/UltiSnips/markdown.snippets),
where I need to populate a title, tags, uuid, and date.

---

Whew!  That was a lot of plugins!  Hopefully you found something new here.  As
per usual:

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
