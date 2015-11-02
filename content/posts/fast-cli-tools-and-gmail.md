---
title: "Fast CLI Tools: gmail"
date: 2015-11-01T20:22:13
tags: ["mutt", "gmail", "goobook", "offlineimap", "notmuch"]
guid: "https://blog.afoolishmanifesto.com/posts/fast-cli-tools-and-gmail"
---
I have been using commandline tools to interact email for quite a while now.
Basically there were two reasons:

 * I wanted to use [GnuPG](https://www.gnupg.org/)
 * gmail's web interface became too slow

The former should be obvious; attempting to have secure communications in the
context of a web browser is laughable.

The latter often surprises people.  I think that if you pay a little more
attention you'll notice that gmail is clearly slower than local options.  Not
*all* local options, but the ones I'll be discussing. 😄

For example, just *loading* gmail fresh takes 10s.  Loading mutt takes less than
0.5s.  In my email, searching for "station" takes 4s on the web interface.
Using `notmuch` locally takes less than 2s, and of course since it's a local
machine, the second search is in a cache and thus is less than half that.  On
top of all of that, unlike modern web browsers, mutt *never* ends up taking up
gigs of my memory.

Here are the tools that I use:

 * [OfflineIMAP](http://offlineimap.org/): for syncing the email
 * [Mutt](https://github.com/frioux/dotfiles#install-mutt): for reading and writing email (with integrated patches for using notmuch)
 * [goobook](https://pypi.python.org/pypi/goobook): for syncing contacts
 * [addrlookup](https://raw.githubusercontent.com/spaetz/vala-notmuch/static-sources/src/addrlookup.c): for syncing contacts; [originally mentioned here](http://dbp.io/essays/2013-06-29-hackers-replacement-for-gmail.html)
 * [notmuch](https://notmuchmail.org/): for searching through email

### OfflineIMAP

My OfflineIMAP setup is fairly complex, because I've found that OfflineIMAP is a
little bit buggy.  [You can read more about that on my OfflineIMAP Docker
page](https://hub.docker.com/r/frew/offlineimap/).  I'm very proud of this
setup, but it still has a way to go before it's as good as I want it to be.

### Mutt

The main thing I'm pleased about with mutt, aside from the fact that I can and
do trivialy use vim as my editor, is the integration with notmuch.  This mostly
replaces all of the stuff I "lose" when not using gmail.  So for example I can
press `F8` to search directly from within mutt and get a threaded view of the
results.  Similarly, if I press `F9` I get a complete thread of the current
email.  To be clear, if I archive some of the messages in mutt, the thread will
be incomplete or even broken, and almost never will my messages be shown.  This
resolves that "lack."

### notmuch

I mostly went over what `notmuch` buys you in the Mutt section.  I am a huge fan
of `notmuch`.  People need to factor out simple tools like this more often.
Good job notmuch humans, I love your work.

### Contact Sync Tools

This set of tools is actually why I'm writing this post.  Before today, I would
either use `goobook` integrated with mutt, or `addrlookup` (via my
[addrlookup-compat](https://github.com/frioux/dotfiles/blob/c4767ad337aab3a6d38e8e07f650d23878b0810d/bin/addrlookup-compat))
on the console.  First off: `goobook` is slow.  If you reload your contacts
(which happens automatically at least every 24h) you will be waiting for about
4s in a "tab complete."  4s is too long for anything interactive.  On top of
that `addrlookup` can be similarly slow and even more: using two separate tools
is annoying!  Even searching, *locally mind you*, in my 150 entry address book
with `goobook query` takes more than a second.  Python programmers: do better.

So today I resolved these speed issues.  First off, I just use an hourly cronjob
(could likely be daily but my computer is rarely on all day and this isn't
resource intensive so it seemed easier) to export all of the contacts
`addrlookup` finds and then concatenate the contacts that `goobook` lists into a
flat file.  [I wrote the smallest tool ever to filter that
file](https://github.com/frioux/dotfiles/blob/c4767ad337aab3a6d38e8e07f650d23878b0810d/bin/addrlookup-fast);
basically it's just grep though.

It's of course super fast; currently taking 5ms for a query.  That's *well*
within my requirements.

Oh, and because `goobook` is not packaged for ubuntu, [I made a nice docker
container for it](https://hub.docker.com/r/frew/goobook/).  This container is
the first that I've made which uses [Alpine Linux](http://alpinelinux.org/), and
I am impressed.  The Ubuntu version would have been 300M, where the Alpine
version is a mere 60M.

---

So that's that!  I have well integrated, very fast, commandline tools for all of
my email needs.  I can use all of these tools while disconnected from the
internet and they are faster than what google can provide.  I hope this helps
you in your speedy endevours.

#### colophon

This article was written in Santa Monica with vim and the excellent
[Goyo](https://github.com/junegunn/goyo.vim) plugin.
