---
title: Defining Custom URI Schemata on Linux
date: 2016-09-15T07:56:39
tags: [ linux, email, vim ]
guid: 67DA531E-7AF8-11E6-BE4A-730D2B0DE0B1
---
For years I've wanted a way to link to emails without being tied to some
specific provider.  All emails have a header, Message-ID, that is supposed to be
unique.  I think it would be incredibly useful if there could be links based on
these ids.  I implemented that this past week!

<!--more-->

## `email://`

Here's the idea: you link to an email by Message-ID with the general format of
`email://$Message-ID`, so for example
`email://CANDiX9KooVG=QmNGJaJQ00Voj_u3-fui9SORjzpwG6DhJatG6w@mail.gmail.com`
could link to
`https://groups.google.com/forum/#!original/vim_use/V3V7__4xLdg/vWEkMDvnCQAJ`.
But the magic is that the Message-ID is universal, so if you happen to have all
of your email locally, your email client should also be able to handle
`email://`.  Furthermore, there are lots of mailing list archives that could
resolve the Message-ID.  I know that technically this is hard because mailing
list archives are uncoordinated and the Message-ID has nothing to do with them,
but nonetheless I think this would be awesome.

## Usage

As I said, I've had this idea for a long time as far as technology ideas go.  I
figured it was something that was not really in the cards, but recently I've
been keeping my own notes for all kinds of stuff.  I'll post more about that
later.  The main thing is that I'm using vim, and vim has this default built in
plugin that allows you to press `gx` on a url and have the url open in your
default browser.  With that in mind I wanted to be able to write something like,
`See email://foo for how to run more tests at once`.

## Configuration

I read the docs for [the
plugin](http://www.vim.org/scripts/script.php?script_id=1075) and even read most
of the code, but I had trouble figuring out how to configure it to have special
handlers for a url schema.  With much reticence I reached out to the author of
the plugin and he gave me advice to try to configure `xdg-open` to customize url
handling.  After some Googling I found [a blog
post](https://edoceo.com/howto/xfce-custom-uri-handler) that theoretically
should have been everything I needed, except that I ran into some issues, maybe
caused by my own misreading.

After getting what I thought would work, I hit up both IRC and [the XDG mailing
list](https://lists.freedesktop.org/archives/xdg/2016-September/013776.html).
As is often the case I was warnocked (for at least a week) and I happened to
complain in one of the IRC channels that I hang out in.  [Thomas
Sibley](https://metacpan.org/author/TSIBLEY) volunteered to help me fix my setup
and helped me notice glaring errors in my `.desktop` file and motivated me to
`strace` `xdg-open` to see what it was doing.  The latter made it clear to me
how you install the handlers.

There was one more snag in the road.  [I use
`mutt`](/posts/fast-cli-tools-and-gmail/), which runs in a terminal.  While [the
desktop entry spec technically supports
`Terminal=true`](https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s05.html),
[`xdg-open` does not](https://bugs.freedesktop.org/show_bug.cgi?id=92514).
There was [some hand
wringing](https://lists.freedesktop.org/archives/xdg/2015-October/013587.html)
on the mailing list as to how to achieve this, but of course I don't need a
standard, I just need to fix `xdg-open`.

Here's [my little
patch](https://github.com/frioux/dotfiles/commit/84bb06fb4b3525aeb8a634743e6a79b847ae7819#diff-3ed619735d6d2f59dacae3401c5dd26aL708)
to add support for [a moderately configurable
terminal](https://github.com/frioux/dotfiles/commit/84bb06fb4b3525aeb8a634743e6a79b847ae7819#diff-779066a17ccda7cf81d189f12657fdeeR1)
to `xdg-open`:

```
diff --git a/bin/xdg-open b/bin/xdg-open
index a31c75b..80d8cd9 100755
--- a/bin/xdg-open
+++ b/bin/xdg-open
@@ -706,7 +706,11 @@ search_desktop_file()
             args=$(( $args - 1 ))
         done
         [ $replaced -eq 1 ] || set -- "$@" "$target"
-        "$command_exec" "$@"
+        if [ "$(get_key "${file}" "Terminal")" = true ]; then
+           xdg-terminal "$command_exec" "$@"
+        else
+           "$command_exec" "$@"
+        fi
```

With that in place, Terminal links work just fine, especially since I have
configured my terminal to simply spawn a new window in `tmux`.

## Howto

With all the above, here is how I set it up. First write your handler:

```
#!/usr/bin/perl

use strict;
use warnings;

use autodie;

use File::Temp;

my $url = shift;
my $email = $url =~ s(^email://)()r;

my ($search, $which_email) = split /\.eml@/, $email;

{
   my $dir = File::Temp->newdir;

   my $mutt = 'mutt';

   if ($which_email eq 'zr') {
      $mutt = 'zr-mutt';
      $ENV{NOTMUCH_CONFIG} = "$ENV{HOME}/.zr-notmuch-config";
   }

   system qw(notmuch-mutt -r search), $search, '-o', "$dir";
   system $mutt, qw( -R -f ), "$dir"
}
```

If it's not obvious, my email handler uses the excellent
[notmuch](https://notmuchmail.org/) and the included mutt integration.  I added
an extra little feature where you can trail your link with `.eml@zr` and have
the part after the `@` be an alternate email account, ZipRecruiter in my case.

This should be easily testable, just run `email-handler email://...`.

Now create the `.desktop` file:

```
[Desktop Entry]
Name=Mutt-ID
Exec=/home/frew/code/dotfiles/bin/email-handler %u
Terminal=true
Type=Application
Categories=Utility;
StartupNotify=false
MimeType=x-scheme-handler/email;
```

The important lines are `MimeType` and `Exec`.

Finally, install the `.desktop` file:

```
xdg-mime install frew-email.desktop
xdg-mime default frew-email.desktop x-scheme-handler/email
cp frew-email.desktop ~/.local/share/applications
```

Why the first command doesn't do the copy itself I'll never know.

After that, simply running `xdg-open email://...` should work!  Note that this
does seem to work in Vim with `gx` and Chrome and Firefox, though in my testing
it looks like Chrome is using `xdg-open` and Firefox is using some other
tooling.  This means that if you patch your `xdg-open` like I did the changes
won't apply in Firefox.  That's not my primary use-case at this point so I'm
leaving it at that for now.

---

And that's that!  I intend to create custom schemata for other use cases, like
the issue tracker at work, but the details outlined above should be enough for
anyone to make custom links like this.  Have fun!
