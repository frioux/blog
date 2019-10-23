---
title: Unreliable Cronjobs
date: 2019-06-25T19:47:13
tags: [ cron, zr, frew-warez ]
guid: 0b1c3c05-0e53-42d8-a640-8a75272c1423
---
At [work](https://www.ziprecruiter.com/hiring/technology) we've been working
on monitoring our cronjobs better; armed with some of the knowledge of how
to do this I have made some incredibly unreliable cronjobs much more reliable.

<!--more-->

The general pattern that we suggest at work is to run your cronjobs five to ten
times more often than you need to and to exit early if there is no work to do.
In addition, you should monitor what the cronjob produces (which obviously
varies wildly, per cronjob) rather than the sythentic exit code or output from
the cronjob.  This can both help you to avoid being paged when a cronjob is a
little flaky and additionally detect a cronjob that is failing but still exiting
zero.

Given this knowledge I decided to apply it to the least reliable host I know of:
my laptop.  I have a handful of cronjobs that I want to succeed either hourly or
daily, but I can't assume my laptop will be running at any given time of day.
Here's the pattern I settled on: for jobs that should succeed daily, run hourly;
for jobs that should succeed hourly, run them every minute.  Nearly all my jobs
produce a file on disk, so I add a little header to each job:

```bash
older-than "$OUTPUT_FILE" m 1h || exit
```

[That uses
`older-than`](https://github.com/frioux/dotfiles/blob/ade25d2b264a085a2e7a1ec8f3ab1dcfcde6106b/bin/older-than),
which allows basic time expressions against a file system time (`atime`,
`mtime`, or `ctime`.)

Ok, now the cronjobs are more reliable because they run more often and have more
chances to succeed.  But what about cronjobs that are broken because, for
example, some auth token rotated and I never noticed?  I have a stupid system
for checking these files and notifying me if they are too old.  Basically I run
[this
script](https://github.com/frioux/dotfiles/blob/ade25d2b264a085a2e7a1ec8f3ab1dcfcde6106b/bin/postqueue-notify)
every in a while loop every 5 minutes.  The while loop is started when I log in,
and if it died, for some reason, I would be blind, but that is pretty unlikely.

[One of my
scripts](https://github.com/frioux/dotfiles/blob/ade25d2b264a085a2e7a1ec8f3ab1dcfcde6106b/bin/sync-addresses)
will periodically sync addresses to a local thing mutt can read.  I don't need
it to be super up-to-date, but if it's been broken for a couple days I want to
know so it's not six months till I notice.  Here's my notification command:

```bash
older-than m 2d "$HOME/personal-addresses" || \
   notify-send -u critical "personal-addresses is too old"
```

This will put a little red notification at the top right of my screen, and
because it's "critical" it won't go away till I click it.

---

(The following includes affiliate links.)

If you wanna glue together little things like the above, you might be interested in <a target="_blank" href="https://www.amazon.com/gp/product/1593276028/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593276028&linkCode=as2&tag=afoolishmanif-20&linkId=074e5f2cb88da1ba414f56146d931cb2">Wicked Cool Shell Scripts</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593276028" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I never know if books are too advanced or too basic, but check it out; maybe
it's your speed.

A related topic, to me, is extending my editor.  If you want to go all the way
with that and, like me, use Vim, you might want to grab a copy of
<a target="_blank" href="https://www.amazon.com/gp/product/B00D7JJGQK/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00D7JJGQK&linkCode=as2&tag=afoolishmanif-20&linkId=be40bd6898c988be3212407ddfbc56cb">Learn Vimscript the Hard Way</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B00D7JJGQK" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
