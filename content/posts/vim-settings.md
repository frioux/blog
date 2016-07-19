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
