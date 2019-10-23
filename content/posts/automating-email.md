---
title: Automating Email
date: 2019-03-18T07:10:42
tags: [ mutt, golang ]
guid: ddbf4a02-d7b1-4736-8f0d-b5693027a6ca
---
I just automated a couple common email tasks.

<!--more-->

[I use mutt](http://www.mutt.org/).  The original reason I started using mutt
was that no other client could handle my habits (gmail amounts of email but
locally) but a better reason to use mutt, I think, is that it's automatable in
interesting ways.

The most basic ways that I've customized mutt are to create hotkeys for super common
tasks; these are things I suspect gmail already has hotkeys for:

```
macro index,pager IT "<save-message>=gmail.Trash<enter>$" "delete message"
macro index,pager IS "<save-message>=gmail.Spam<enter>$"  "mark message as spam"
macro index,pager Ii "<save-message>=INBOX<enter>$"       "move message back to inbox"

macro index,pager ii "<change-folder>=INBOX<enter>"       "view inbox"
macro index,pager iT "<change-folder>=gmail.Trash<enter>" "view trash"
macro index,pager iS "<change-folder>=gmail.Spam<enter>"  "view spam"
```

Here's another cool pattern, I have it set up so that when I am in the
directories for certain mailing lists, the To address for any emails sent
automatically gets set to the relevant mailing list, and relatedly, when the To
address is set, the correct from address gets set:

```
folder-hook 'coolbeans'  'my_hdr To: coolestbeans@googlegroups.com'
send-hook '~t "coolestbeans@googlegroups.com"' 'my_hdr From: fREW (coolbeans) Schmidt <mrbeanz@gmail.com>'
```

Finally, here's the automation I did that motivated this blog post.  I hear from
recruiters all the time.  I have a canned response and I include a friend's
resume, and Cc the friend, in the response.  Normally I manually reply but it's
annoying.  Now it's a single button:

```
macro index,pager R ":set editor = \"sh -c 'cat /home/frew/Dropbox/notes/.canned-recruiter-response.txt $1 | sponge $1; exec vi $1' _\"<enter><reply><attach-file>$HOME/Dropbox/x.pdf<enter><edit-cc>x@gmail.com<enter>:set editor = \"vi -c 'set tw=70'\"<enter>"
```

It's not beautiful, but the gist is that it sets my editor to munge the body (by
prefixing my canned reply), attaching the file, Ccing, and finally setting the
editor back.  Somewhat comically I initially tried doing this by writing a Go
program to create the whole email and [it was
terrible.](https://stackoverflow.com/a/53798744/12448)  I won't be trying that
again without good reason for a while.

Annoying side note: the above doesn't reliably work if `reply_to` isn't set to
yes.  At least in 2019 that's the only sensible option.

---

Relatedly, I built [a little tool to unsubscribe from
stuff](https://github.com/frioux/dotfiles/blob/dec8ca6ae63752938cad2818b15cb7c85611852a/bin/unsubscribe).
I can't believe I didn't build this tool sooner; which is a feeling I have often
when building software.  I'll paste the full code here only to show how
straightforward it is:

```bash
#!/bin/sh

set -e

unsub=$(email2json /dev/stdin |
   jq -r '.Header["List-Unsubscribe"] |
      split(", ") |
      .[] |
      match("<(.*)>") |
      .captures[0].string')

for u in $unsub; do
   echo "$unsub"
   case $u in
      http*) firefox "$u" ;;
      mailto*) tmux new-window mutt "$u" ;;
      *) echo "I don't know how to unsubscribe from $u" ;;
   esac
done
```

Or in English: "take the List-Unsubscribe header, split by commas, extract the
values from angle brackets, and email `mailto` prefixes and open `http` prefixes
in firefox."

This latter tool is closer to the kind of stuff I'd like to make in general,
since it's not tightly coupled to mutt.  I don't see myself ditching mutt any
time soon, but generic tools can be used in more contexts, so I think they are
worth building.

All in all, automating email is pretty satisfying!  I am all for automation in
general, but email is generally a time-sink that I tend to avoid when possible;
this allows me to reduce the time and avoid it a little less.

---

(The following includes affiliate links.)

If you wanna glue together little things like the above, you might be interested in <a target="_blank" href="https://www.amazon.com/gp/product/1593276028/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593276028&linkCode=as2&tag=afoolishmanif-20&linkId=074e5f2cb88da1ba414f56146d931cb2">Wicked Cool Shell Scripts</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593276028" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I never know if books are too advanced or too basic, but check it out; maybe
it's your speed.

A related topic, to me, is extending my editor.  If you want to go all the way
with that and, like me, use Vim, you might want to grab a copy of
<a target="_blank" href="https://www.amazon.com/gp/product/B00D7JJGQK/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00D7JJGQK&linkCode=as2&tag=afoolishmanif-20&linkId=be40bd6898c988be3212407ddfbc56cb">Learn Vimscript the Hard Way</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B00D7JJGQK" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
