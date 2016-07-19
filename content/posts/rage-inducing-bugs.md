---
title: Rage Inducing Bugs
date: 2016-05-10T21:52:07
tags: [bugs, vim, ubuntu, linux, gtk3, firefox, computer-h8]
guid: "https://blog.afoolishmanifesto.com/posts/rage-inducing-bugs"
---
I have run into a *lot* of bugs lately.  Maybe it's actually a normal amount,
but these bugs, especially taken together, have caused me quite a bit of rage.
Writing is an outlet for me and at the very least you can all enjoy the show, so
here goes!

<!--more-->

# X11 Text Thing

[I tweeted about this one](https://twitter.com/frioux/status/727955721036369920)
a few days ago.  The gist is that, *sometimes*, when going back and forth from
suspend, font data in video memory gets corrupted.  I have a theory that it has
to do with switching from X11 to DRI (the old school TTYs), but it is not the
most reproducable thing in the world, so this is where I've had to leave it.

# Firefox

[I reported a bug against
Firefox](https://bugzilla.mozilla.org/show_bug.cgi?id=1269166) recently about
overlay windows not getting shown.  There is a workaround for this, and the
Firefox team (or at least a Firefox individual,  Karl Tomlinson) has been
willing to look at my errors and have a dialog with me.  I have a sinking
feeling that this could be a kernel driver bug or maybe a GTK3 bug, but I have
no idea how to verify that.

# Vim SIGBUS

Vim has been crashing on my computer for a while now.  I turned on coredumps for
gvim only so that I could repro it about three weeks ago, and I finally got the
coveted `core` yesterday.  I dutifully inspected the core dump with `gdb` and
got this:

```
Program terminated with signal SIGBUS, Bus error.
#0  0x00007fa650515757 in ?? ()
```

**Worthless.**  I knew I needed debugging symbols, but it turns out there is no
`vim-dbg`.  A while ago (like, **eight years ago**) Debian (and thus Ubuntu)
started storing debugging symbols in a completely separate repository.
Thankfully a Debian developer, Niels Thykier, was kind enough to point this out
to me that I was able to install the debugging symbols.  If you want to do that
yourself you can [follow instructions
here](http://stackoverflow.com/a/14421056/12448), but I have to warn you, you
will get errors, because I don't think Ubuntu has really put much effort into
this working well.

After installing the debugging symbols I got this much more useful backtrace:

```
#0  0x00007fa650515757 in kill () at ../sysdeps/unix/syscall-template.S:84
#1  0x0000555fad98c273 in may_core_dump () at os_unix.c:3297
#2  0x0000555fad98dd20 in may_core_dump () at os_unix.c:3266
#3  mch_exit (r=1) at os_unix.c:3263
#4  <signal handler called>
#5  in_id_list (cur_si=<optimized out>, cur_si@entry=0x555fb0591700, list=0x6578655f3931313e, 
    ssp=ssp@entry=0x555faf7497a0, contained=0) at syntax.c:6193
#6  0x0000555fad9fb902 in syn_current_attr (syncing=syncing@entry=0, displaying=displaying@entry=0, 
    can_spell=can_spell@entry=0x0, keep_state=keep_state@entry=0) at syntax.c:2090
#7  0x0000555fad9fc1b4 in syn_finish_line (syncing=syncing@entry=0) at syntax.c:1781
#8  0x0000555fad9fcd3f in syn_finish_line (syncing=0) at syntax.c:758
#9  syntax_start (wp=0x555faf633720, lnum=3250) at syntax.c:536
#10 0x0000555fad9fcf45 in syn_get_foldlevel (wp=0x555faf633720, lnum=lnum@entry=3250) at syntax.c:6546
#11 0x0000555fad9167e9 in foldlevelSyntax (flp=0x7ffe2b90beb0) at fold.c:3222
#12 0x0000555fad917fe8 in foldUpdateIEMSRecurse (gap=gap@entry=0x555faf633828, level=level@entry=1, 
    startlnum=startlnum@entry=1, flp=flp@entry=0x7ffe2b90beb0, 
    getlevel=getlevel@entry=0x555fad9167a0 <foldlevelSyntax>, bot=bot@entry=7532, topflags=2)
    at fold.c:2652
#13 0x0000555fad918dbf in foldUpdateIEMS (bot=7532, top=1, wp=0x555faf633720) at fold.c:2292
#14 foldUpdate (wp=wp@entry=0x555faf633720, top=top@entry=1, bot=bot@entry=2147483647) at fold.c:835
#15 0x0000555fad919123 in checkupdate (wp=wp@entry=0x555faf633720) at fold.c:1187
#16 0x0000555fad91936a in checkupdate (wp=0x555faf633720) at fold.c:217
#17 hasFoldingWin (win=0x555faf633720, lnum=5591, firstp=0x555faf633798, lastp=lastp@entry=0x0, 
    cache=cache@entry=1, infop=infop@entry=0x0) at fold.c:158
#18 0x0000555fad91942e in hasFolding (lnum=<optimized out>, firstp=<optimized out>, 
    lastp=lastp@entry=0x0) at fold.c:133
#19 0x0000555fad959c3e in update_topline () at move.c:291
#20 0x0000555fad9118ee in buf_reload (buf=buf@entry=0x555faf25e210, orig_mode=orig_mode@entry=33204)
    at fileio.c:7155
#21 0x0000555fad911d0c in buf_check_timestamp (buf=buf@entry=0x555faf25e210, focus=focus@entry=1)
    at fileio.c:6997
#22 0x0000555fad912422 in check_timestamps (focus=1) at fileio.c:6664
#23 0x0000555fada1091b in ui_focus_change (in_focus=<optimized out>) at ui.c:3203
#24 0x0000555fad91fd96 in vgetc () at getchar.c:1670
#25 0x0000555fad920019 in safe_vgetc () at getchar.c:1801
#26 0x0000555fad96e775 in normal_cmd (oap=0x7ffe2b90c440, toplevel=1) at normal.c:627
#27 0x0000555fada5d665 in main_loop (cmdwin=0, noexmode=0) at main.c:1359
#28 0x0000555fad88d21d in main (argc=<optimized out>, argv=<optimized out>) at main.c:1051

```

I am already part of the [vim mailing list](http://www.vim.org/maillist.php), so
[I sent an email and see
responses](https://groups.google.com/forum/#!topic/vim_use/TNM4s94IDmE) (though
sadly not CC'd to me) as I write this post, so hopefully this will be resolved
soon.

# Linux Kernel Bugs

[I found a bug in the Linux
Kernel](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1576764), probably
related to the nvidia drivers, but I'm not totally sure.  I'd love for this to
get resolved, though reporting kernel bugs to Ubuntu [has not gone well for me
in the past](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1513157).

# Vim sessions

The kernel bug above causes the computer to crash during xrandr events; this
means that I end up with vim writing a fresh new session file during the event
(thanks to the excellent [Obsession by Tim
Pope](https://github.com/tpope/vim-obsession)) and the session file getting
hopelessly corrupted, because it fails midwrite.

I foolishly mentioned this on the #vim channel on freenode and was reminded how
often IRC channels are actually unrelated to aptitude.  The people in the
channel seemed to think that if the kernel crashes, there is nothing that can be
done by a program to avoid losing data.  I will argue that while it is hard, it
is not impossible.  The most basic thing that can and should be done is:

 1. Write to a tempfile
 2. Rename the tempfile to the final file

This should be atomic and safe.  [There are many
ways](http://danluu.com/file-consistency/) that [dealing with files can go
wrong](http://www.slideshare.net/nan1nan1/eat-my-data), but to believe it is
impossible to protect against them is unimpressive, to say the least.

I will likely submit the above as a proper bug to the Vim team tomorrow.  In the
meantime this must also be done in Obsession, and [I have submitted a small
patch](https://github.com/tpope/vim-obsession/issues/25) to do what I outlined
above.  I'm battle testing it now and will know soon if it resolves the problem.

---

I feel better.  At the very least I've submitted bugs, and in one of the most
annoying cases, been able to submit a patch.  When you run into a bug, why not
do the maintainer a solid and report it?  And if you can, fix it!
