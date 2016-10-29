---
title: The Ultimate Email Filtering
date: 2016-10-29T07:55:17
tags: [email, perl, javascript, gmail]
guid: 83E6F784-9DE3-11E6-94EC-6CEFDBC68D77
---
I've [posted plenty about email before](/tags/email), so it might not be
surprising that along with all of my other tooling, I have some email filtering
tools as well.  I recently rewrote most of my filtering tools after being
inspired by my friend and coworker Meredith's email filtering.  It's pretty
cool!

<!--more-->

## The Old

The old way that I filtered my mail involved a script that cron would run once a
minute, using the [notmuch](http://notmuchmail.org/) email index and basically
moving the files in a given search somewhere.  Here's an small bit of it:

```
#!/bin/dash
MAILDIR=$HOME/var/zr-mail
export NOTMUCH_CONFIG="$HOME/.zr-notmuch-config"

_safe_mv() {
   local dest="$1"
   shift
   if [ -n "$1" ]; then
      mv "$@" "$dest"
   fi
}

archive() rm -f "$@"
trash() _safe_mv $MAILDIR/gmail.Trash/new "$@"
search() notmuch search --output=files "$@" folder:INBOX
thread() {
   notmuch search --output=threads "$@" folder:INBOX | \
      xargs -I{} -n1 notmuch search --output=files folder:INBOX {}
}

days_ago() perl -MDateTime -E"say DateTime->now->subtract(days => $1)->ymd(q(-))"
days_old() echo "date:..$(days_ago $1)"

archive $(search '"SECURITY information for some-weird-server"' '"unable to resolve host"')

# delete production errors email that is older than todays
archive $(search 'fluentd.error summary' "$(days_old 1)")
archive $(search 'Production errors from yesterday' "$(days_old 1)")
archive $(search 'heavy queries' "$(days_old 1)")

# squelch noise till after next release
if [ "$(date +%Y%m%d)" -lt "20160628" ]; then
   archive $(search '"Use of uninitialized value $sub_status in pattern match (m//)"' from:root)
fi

```

I am and was pretty proud of this set of functionality.  If I wanted to quickly
filter a given sender, I could just add a line to `bin/clean-email`.  I could
archive emails that were effectively replaced by a new one the next day.  And
finally I could add ad-hoc date triggered filters that would go away after a
given day.

There are a few problems here:

 * If my laptop is off, email doesn't get filtered.  Annoying for phone email.
 * If I want to move the code to a server, I need a full copy of my email on
   the server.
 * There is an annoying bit of lag where the email shows up in my inbox and
   won't go away for about 60s.

## The New

Meredith mentioned at some point that she had a script that filtered email in a
similar way to mine, but it ran on Google's servers!  She shared it with me and
I looked into making my own version.  Before proceeding though I went through
the annoying but reasonable process of converting the simple non-date based
searched into standard server-side filters.  I have resisted that in the past
just because it's such a hassle compared to editing a text file, but it's
legitimately the best option so I will just get used to it (till I make a tool
to sync from a text file of course.)

So the gist of it is that there's this thing called Google App Script, which is
JavaScript with some API access running on their servers.  [The docs are
here](https://developers.google.com/apps-script/reference/gmail/).  I ended up
writing the following, and having it run once a minute:

```
function archiveInbox() {
  var count;
  
  var searches = [
    'older_than:1d fluentd.error summary',
    'older_than:1d "Production errors from yesterday"',
    'older_than:1d "heavy queries"',
    
    'older_than:8d from:cron',
    'older_than:8d from:no-reply@pagerduty.com',
  ];
  for (var i = 0; i < searches.length; i++) {
    archive('in:inbox ' + searches[i]);
  }
}

function archive(search) {
  var count;
  do {
    count = archiveInboxIncremental(search);
  }
  while (count !== 0);
}

function archiveInboxIncremental(search) {
  var threads = GmailApp.search(search, 0, 50);
  GmailApp.moveThreadsToArchive(threads);

  Logger.log('Archived %s threads for %s', threads.length, search);
  return threads.length;
}
```

---

This is defintely less convenient than editing a local script, but it runs all
the time and not on my own infrastructure.  Stay tuned for the next post where I
show how I wrote a script for fixing emails that don't thread right.
