---
aliases: ["/archives/105"]
title: "Vim Settings"
date: "2009-01-30T16:16:27-06:00"
tags: [user-interface, vim]
guid: "http://blog.afoolishmanifesto.com/?p=105"
---
Today I am just going to talk about my favorite vim "stuff." A lot of this I
have gathered over the past 3-5 years of serious vim usage. I used vim before
that, but not with this heavy of customization. I'll start with the simple stuff
and move up from there.

**Basic settings:**

```
" Enable Line Numbers
set number

" Ignore case for searches
set ignorecase

" Unless you type an uppercase letter
set smartcase

" Incremental searching is sexy
set incsearch

" Highlight things that we find with the search
set hlsearch

" This is totally awesome - remap jj to escape
" in insert mode.  You'll never type jj anyway,
" so it's great!
inoremap jj <esc>

" If you have caps lock on disable too many J's
nnoremap JJJJ <nop>

" Set off the other paren
highlight MatchParen ctermbg=4

" no longer press shift to enter commands
nnoremap ; :
nnoremap : ;
vnoremap ; :
vnoremap : ;

```

I also highly recommend the InkPot color scheme for gui mode and metacosm for
console mode. Here's some code to pull that off:

    " Favorite Color Scheme
    if has("gui_running")
       colorscheme inkpot
    else
       colorscheme metacosm
    endif

I also use some plugins to make my life easier.

- **[matchit](http://www.vim.org/scripts/script.php?script_id=39)**: allows you to match things like html tags and other complicated matches with %.
- **[NERD\_commenter](http://www.vim.org/scripts/script.php?script_id=1218)**: simple keystrokes to comment/uncomment any code.
- **[project](http://www.vim.org/scripts/script.php?script_id=69)**: this allows you to have a user defined file listing on the left (or right) which I find quite nice for navigation. You can also use it to have special mappings defined when you open a file in a specific project.
- **[surround](http://www.vim.org/scripts/script.php?script_id=1697)**: surround anything with quotes, parens, braces, xml tags... Great for html editing, but I use this all the time for normal code. (And I just used it to put all of these items in a list easily!)

Do you have any suggestions for killer additions to vim?

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
