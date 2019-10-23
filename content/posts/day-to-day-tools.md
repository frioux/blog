---
title: Day-to-Day Tools
date: 2017-04-07T07:35:18
tags: [ tool, toolsmith, perl, golang, vim, git ]
guid: 466BD748-18F5-11E7-B56B-E693D5D8593D
---
I have a ton of little programs I use on a day-to-day basis just to make my life
easier.  I figured it would be fun to share them so other people could either
copy them or be inspired to make there own.  I have blogged about some of
these tools before and will link to the appropriate full posts when applicable.

<!--more-->

Note that these are in somewhat arbitrary order such that the things are grouped
near related items.  There are even more that I left out which you can see [at
github](https://github.com/frioux/dotfiles/tree/master/bin).

## Desktop Tools

### Unicode Selection

The following four tools, taken together, allow me to select a unicode
character by name, which then gets placed in my copy buffer, and then I can
paste it.  It may sound silly but it's pretty handy for certain characters.  I'd
like to get `XCompose` working at some point to bolster this but this works
better for less commonly typed characters.  I use this a handful of times a day.

 * [`alluni.pl`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/alluni.pl)
   prints all unicode characters (by name.)

 * [`prepend-emoji-hist`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/prepend-emoji-hist) (`alluni.pl | prefix-emoji-hist ~/.uni_history`) prints
   out the deduplicated lines from the passed file, converting characters to
   unicode names, and then printing out the lines from STDIN, filtering out
   what's already been printed.  In short: it prepends the history.

 * [`showuni`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/showuni)
   shows a [dmenu](http://tools.suckless.org/dmenu/) of unicode characters (by
   name) and stores selection into `~/.uni_history`.

 * [`store-hist`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/store-hist)
   (`echo -n "foo" | store-hist ~/.history`) is basically `tee -a` but only
   writes a single line and always adds a newline.  Only used with `showuni` at
   the moment, but might bake it into the others to allow preferring recent
   selections.

An honorary member of the tools above is
[`shrug`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/shrug), which
copies `¯\_(ツ)_/¯` to my copy buffer.  I should figure out how to merge it into
something above.

### [`showdm`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/showdm)

Show dmenu, to select program to run (eg `firefox`.)  I use this a few times a
day.

### [`showsession`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/showsession)

Show dmenu of vim sessions to resume.  ([More details
here](/posts/vim-session-workflow/) and to a lesser extent
[here](/posts/advanced-vim-sessions/).)  I use this a few times a day.

### [`screenshot-to-text`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/screenshot-to-text)

Prompts the user to make a partial screen selection with the mouse, and then
runs OCR on the screenshot and places the results in the copy buffer.  For best
results make text of size 16 or higher.  It is absurd that I have no post for
this.  Used maybe once a month but I get really stoked every time.

### [`scenery`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/scenery)

Randomly show a different background from the `~/Dropbox/Pictures/wallpaper`
directory, every 25 minutes.  I sorta think this is stupid and want to stop
using it, but every time I go to delete it I can't bring myself to.

### [`type-clipboard`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/type-clipboard)

This tool fixes the annoying problem of websites blocking paste.  It simply
types out whatever is in the clipboard.  Lifesaver.

### `xclip`

An xclip wrapper that uses a less bizarre default selection buffer.

### Custom URI Handlers

The following four tools are custom URI handlers.  [I wrote all about these a
while back](/posts/custom-uri-schemata-on-linux/).  I use these fairly often
with my personal reference system.

 * [`bible-handler`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/bible-handler) handles `bible://` links.
 * [`email-handler`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/email-handler) handles `mid:` links.
 * [`fogbugz-handler`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/fogbugz-handler) handles `bugzid:` links.
 * [`rt-handler`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/rt-handler) handles `rt:` links.

And the following two exists almost solely to support the `email-handler`,
though I could see writing some program to make a CLI fogbugz handler.

 * [`xdg-open`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/xdg-open)
   is a fork of `xdg-open` that adds support for `Terminal=true` support.
 * [`xdg-terminal`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/xdg-terminal)
   is a terminal wrapper run by the above.

### [`file-manager`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/file-manager)

Runs my choice of file manager.  For some reason I periodically forget the
completely arbitrary string:
[`pcmanfm`](http://pcmanfm.sourceforge.net/intro.html).  Used maybe once a week when I forget
that string.

### [`lock-now`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/lock-now)

Runs screen locker.  Used constantly.

## Docker Tools

### [`docker-pstree`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/docker-pstree)

Print the `pstree` of the passed container.  [Read all about this
here](/posts/linux-containers-and-docker-pstree/) and to a lesser extent
[here](/posts/docker-pstree-from-the-inside/).  I rarely use this but when I do
it's really handly.
[`docker-root-pids`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/docker-root-pids)
prints the root pids of the passed container and was written to support
`docker-pstree` and mentioned in the inital blog post.

### [`sv-run-w.pl`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/sv-run-w.pl)

Run the obscurely named [w.pl](https://github.com/frioux/w.pl) container. I
could and maybe should write a whole blog post about this.  The short version is
that this exists solely so that [awesomewm](https://awesomewm.org/index.html)
won't block on the network when showing my weather widgets.  Runs automatically
when I start my X session.

## Generic Wrappers

### [`replace-unzip`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/replace-unzip)

Reimplementation of `unzip`.  Leaves out `.DS_Store` and other OS cruft, wraps
output files in a directory if no root directory was created.  Another tool that
probably deserves it's own post.

### [`wrap-tar`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/wrap-tar)

Wraps tar to encourage me to not use muscle memory for longer command flags.

## Git Tools

### [`gg`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/gg)

Like [`ag`](https://geoff.greer.fm/ag/) but using `git grep`.  Not in the habit
of using this yet.

### [`git`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/git)

[See complete post here](/posts/adding-features-to-git-the-easy-way/).

### [`git-amend-file-split`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/git-amend-file-split)

Splits most recent commit into a separate commit per file.  I used this when I
had to manually clean up a boatload of git history.

### [`git-revert-whitespace-changes`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/git-revert-whitespace-changes)

Remove whitespace only changes from the current checkout.  This is from back
when I had hooks to automatically fix whitespace on save.

## Mail Tools

[I have written too much about these
already](https://blog.afoolishmanifesto.com/tags/email/).

### Address File Management

 * [`addrdedup`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/addrdedup)
   deduplicates addresses based on the mutt address format.
 * [`addrlookup-fast`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/addrlookup-fast)
   uses `grep` to quickly search a preformatted address file.
 * [`addrs`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/addrs)
   is a newish tool that also probably should have it's own blog post.  It
   builds an address file based on a glob of emails, ordered by
   "[frecency](https://en.wikipedia.org/wiki/Frecency)."  I use an [algorithm
   from
   Mozilla](https://wiki.mozilla.org/User:Jesse/NewFrecency#Efficient_computation).
   What I like best about this is that I generate the list in the background;
   the actual realtime lookup is done simply using `addrlookup-fast`.
 * [`sync-addresses`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/sync-addresses)
   creates fresh mutt address file using tools above.  Carefully written to not
   clobber the existing address file, which was fun for me.

### [`email-fix-in-reply-to`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/email-fix-in-reply-to)

Complicated; [read about it here](/posts/email-threading-for-professionals/).

### [`live-email`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/live-email)

List and view emails directly via IMAP.  `live-email -h` for more details.  [Has
bugs because
python.](/posts/python-taking-the-good-with-the-bad/#batteries-included:a21e944a85227ef87f7f95cec950182e)

### [`mail-picture`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/mail-picture)

Creates resized copies of all passed filenames to `1024x768` and initiates a new
email containing them via mutt.  I used to use this a lot when sharing baby
pictures with my family.  Now I just text them the pictures.

### Postfix Monitoring

 * [`postqueue-checker`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/postqueue-checker)
   just executes `postqueue-notify` every ten minutes.  Would use cron but
   couldn't figure out how to get X11 notifications to work from cron.
 * [`postqueue-notify`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/postqueue-notify)
   finds out if I have enqueued emails that are over five minutes old.  It's sad
   that I need this, but I have some weird problems with `postfix` where it will
   continue to resolve gmail's smtp servers as IPv6 addresses even when I am in
   a location that only supports IPv4 traffic.  I was grimly delighted that this
   helped me out the day I wrote it *and* the following day.

### [`top-post`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/top-post)

An attempt at generically trimming emails for brief responses to very long
emails.  Currently unused and very flakey.

## Misc Tools

### [`ascii-ify`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/ascii-ify)

Silly filter that removes all non-ASCII characters, and replaces a couple UTF-8
characters with ascii versions.

### [`backlight`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/backlight)

I used to use `xbacklight` to dim my laptop's screen, but it has a weird delay
caused by dbus or something, so I wrote `backlight`, which is way less generic
but is instant and simple.

### [`clock`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/clock)

This silly thing goes in my prompt and prints the unicode character that
represents the clock face for the current time.  Simply to remind me that time
is fleeting and not to waste it.

### [`clocks`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/clocks)

My personal, digital, wall of clocks.  Used a few times a week.

### [`csv2json`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/csv2json)

The actual inspiration for this post.  I have been using
[Athena](https://aws.amazon.com/athena/) a lot lately and the output is CSV, but
I don't have great commandline tools for CSV.  This simply converts the CSV to
JSON using the first line as the keys.

### [`diff-hunk-list`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/diff-hunk-list)

Tool to assist in [iterating over chunks of a diff in
vim](/posts/iterating-over-chunks-of-a-diff-in-vim/).

### [`dog`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/dog)

Like `cat`, but better; works with directories too.  Strangely preëxists my
knowledge that `cat` actually used to work with directories.

### [`expand-url`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/expand-url)

Filter that reads lines prefixed with `$n`tabs and newline separated links;
writes title of page prefixed with `$n` tabs and link prefixed with `$n + 1`
tabs.  Used fairly often with my personal filing system.

### [`fn`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/fn)

Create persistent functions by actually writing scripts.  Example usage:

```
fn count-users 'wc -l < /etc/passwd'
```

I can't believe I don't use this more.

### [`fressh`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/fressh)

Awesome tool to ensure I have dotfiles wherever I go.  [Read about it
here](/posts/my-mobile-shell-home/).  Used multiple times a day.

### [`fx`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/fx)

Firefox wrapper that reads from standard in instead of requiring a filename.
Used fairly often.

### [`graph-by-date`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/graph-by-date)

Graphs time series data by parsing CSV from standard in.

### [`group-by-date`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/group-by-date)

Creates time series data (likely used with the above `graph-by-date`) by
counting lines and grouping them by a given date format.

### [`minotaur`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/minotaur)

Watches a list of directories defined in the json document in the file in the
first argument, and restarts the `runit` service by sending `SIGTERM`, `SIGCONT`,
and telling the supervisor to start the service.  I have a version of this at
work that is more generically useful.  I sorta wanna rewrite it in Go since a
tool like this feels weird and bloated in Perl.

### [`netrc-password`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/netrc-password)

```
netrc-password imap.gmail.com foo@example.com
```

Gets a password from your netrc file.  (Login is optional.)

### [`paste_edit`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/paste_edit)

Creates a temporary file containing the contents of the copy buffer, allows the
user to edit it with gvim, and the submits the contents to a pastebin via
[nopaste](https://metacpan.org/pod/App::Nopaste).  Rarely used; not sure why.

### [`perl-browse`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/perl-browse)

Pass a module name (eg `File::Find`) and shows it in vim.  To browse as if you
were in a web browser, press `gf` over other modules (like `File::Basename`) and
to go back press `CTRL-O`.  I use this fairly often.  I really like it.

### [`plain`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/plain)

Strips formatting from any text in the copy buffer.  Not used that often.

### [`pomotimer`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/pomotimer)

```
pomotimer 2.5m
```

Handy terminal based timer especially for [The Pomodoro
Technique](/posts/the-pomodoro-technique/).  Allows pausing, resuming, and
aborting the timer entirely.  If a [`blink(1)`](https://blink1.thingm.com/) is
running and the `blink1-tool` is installed, will `pomotimer` will slowly
decrease light from bright red to black, ending with 5 green blinks.

### [`rand`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/rand)

One indexed random number picker.  Handy.

### [`screen-res`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/screen-res)

Prints the screen resolution.  I used to use this when I used `rdesktop` to
connect to windows.  Still handy sometimes.

### [`skip`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/skip)

```
$ perl -E'say for 1..10' | skip 9
10
```

Skips the passed amount of lines.

## Perl Tools

### [`abc`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/abc)

```
$ abc LWP::UserAgent '$ua = A->new; say length $ua->get("http://google.com")->content'
```

Runs passed perl script, with the leading tokens being loaded and aliased as
`A`, `B`, `C`, etc.

### [`compile-mkit`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/bin/compile-mkit)

```
compile-mkit ./mkit/password-reset '{ username frew link http://test }'
```

Compile and render an mkit to STDOUT.  Takes path of mkit and [JSONY
doc](https://metacpan.org/pod/distribution/JSONY/lib/JSONY.pod) as the data.  I
don't use this since we don't (yet?) use mkit at my current job.

### Work Tools

Almost none of the code for work runs on my actual laptop, but I like to make it
feel local, so I have a bunch of little wrapper scripts for commonly run
commands to run inside of my sandbox.  More importantly is
[`run-d`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/zr-bin/run-d),
which runs a command (as in `run-d ls ~`) inside of my sandbox as my user with
lots of env vars set.  Closely related is [`run-s`](https://github.com/frioux/dotfiles/blob/c109ceb28ef9ab34ac35ca07d943049763fdacb5/zr-bin/run-s),
which runs the command over ssh instead of execing directly, so that the command
has access to my `ssh-agent`.

---

(The following includes affiliate links.)

This post is already too long, but I absolutely have to mention <a
target="_blank"
href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=cecea11ea25b6635dd78601d2ec1abef">The
Unix Programming Environment</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  My friend and coworker [Mark Jason
Dominus](http://blog.plover.com/) gave me his copy and it has been great.  I
wish that they made books like this nowadays.  It's a solid survey of Unix tech
and a surprising amount of it still applies, **thirty four years later**.

Even ignoring the specifics, the viewpoint of improving your environment instead
of living with the pain of what the vendor shipped you is something that
resonates deeply with me (which is hopefully obvious at this point.)  I might
write a whole post about this book at some point, but even if I don't consider
this post a spiritual followup of that book.

I hope some of the tools above inspire you to make your own tools or soften the
edges of some of the things you use on a daily basis.
