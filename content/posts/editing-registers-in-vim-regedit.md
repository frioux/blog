---
title: "Editing Registers in Vim: RegEdit.vim"
date: 2017-10-20T08:30:15
tags: [ vim ]
guid: 04ed30aa-5850-487e-81a6-f3b2c77b8e5a
---
I recently came up with the most satisfying way to edit registers in Vim I've
ever seen.  I hope you like it as much as I do.

<!--more-->

([If this post is too long and boring, check out the demo.][regedit])

In Vim there are these things called registers, which you can think of as "a
bunch of copy buffers."  If you, for instance, highlight some text, and run the
command `"ay`, you will "yank" the text into register `a`.

Registers are also used for macros, one of the simple ways that a user can
quickly automate a task.  Imagine you wanted to surround ten lines of text with
quotes and append a comma.  You could could start a macro in register `w`: `qw`
and then add the quotes and comma around the current line: `I"<Esc>A",<Esc>` and then
move down to the next line: `j` and then end the macro: `q`.  So all together
you'd type: `qwI"<Esc>A",<Esc>jq`.

## The Traditional Edit Method

Sometimes you'll make a mistake.  One way to handle this is to give up your
partially complete macro and start over.  Another way is to complete the macro
and leave in the mistake, so if you moved left right before adding the `",` in
the example before, you'd include a couple backspaces and move right, or
something.

Often leaving in such mistakes doesn't matter, but sometimes these mistakes are
ok for some of the text and in other lines they break the macro entirely.  What
I have typically heard you should do, in this case, is paste the register in
your document (`"wp`), modify the contents, and the copy it back out (`"wy`).

I don't like this.  I am always worried I'll accidentally copy an extra newline
or drop one.  I always feel weird treating my current document as a scratch
space.  I don't even want to start a fresh empty file for something like this
since it seems like such overkill.  So I came up with something that I think is
better.

## Announcing RegEdit.vim

Instead of setting the register using normal mode commands, you can set them as
variables in ex mode.  The basic syntax is `:let @a = "some text"`.  Of course
that only helps in *setting* the registers, not editing them.

I built [a mapping (and a couple somewhat generic functions)][regedit] that you can use to
populate the command-line with `:let @a = "current contents of @a"`.  The usage
is: `<leader>Ea` to edit the `a` register.

As a bonus it replaces special characters (like `<Esc>`, `<BS>`, `<Tab>`) with
named variants.  So instead of seeing `^[`, you'd see `\<Esc>`.

## Do you hate Command-line mode?

The next tip, on top of this, is that you may not love editing text in command
mode, because you have to use the arrow keys or whatever to move around.  If you
press `<C-f>` you will be "upgraded" to the `cmdline-history` window.  This is
what you have probably stumbled upon by accident by pressing `q:`.  It lets you
edit the command using normal mode, and you can then press enter to execute the
command.  (By the way, if you accidentally hit `q:`, the best way to get out
is to just press `<Enter>`, since it starts on a blank line.)

---

And that's it!  It was a lot of fun building this plugin, even though I'm sure I
spent a lot more time writing and documenting it than I would have saved using
it.  Special thanks to [Wes Malone][wes] and [Rik Signes][rik] for their help
and suggestions.

[And don't forget to install the plugin!][regedit]

---

(The following includes affiliate links.)

If you'd like to learn more about vim, I can recommend a few excellent books.  I
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

Third and finally, if you want to really grok the guts of advanced vim, to write
a plugin for example, you should really check out [Learn Vimscript the Hard Way
by Steve Losh][lvsthw].  I expect to reread it two or three more times.  I got
the PDF version so I could read it while offline.

[wes]: https://github.com/wesQ3/
[rik]: https://rjbs.manxome.org/
[lvsthw]: http://learnvimscriptthehardway.stevelosh.com
[regedit]: https://github.com/frioux/vim-regedit
