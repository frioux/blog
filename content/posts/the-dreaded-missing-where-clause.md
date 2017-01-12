---
title: The Dreaded Missing WHERE Clause
date: 2017-01-11T07:10:14
tags: [ computer-h8, javascript, appscript, gmail, email ]
guid: 0E2E5EA8-D810-11E6-ACE2-A69841BDA81B
---
I recently had a bug in some of my personal software and found it both
interesting and horrifying.  The software in question is what allows me to mute
some kind of email (usually based on subject but it could be anything really)
and unmute it on a given day.  It's great for stuff at work that will continue
spewing until we are able to release a new build.

<!--more-->

The code in question is:

```
function beforeDate(d) {
  var now = new Date();
  return now < d
}

function temporaryDateArchive() {
  var archive_search = [];

  // Zero based dates: so pure and perfect it makes me wanna gag
  if (beforeDate(new Date(2017, 0, 10)))
    archive_search.push(
      'fluentd tail',
      'fluentd listener',
      'elasticsearch cluster'
    )

  if (!archive.length) return;

  archive_search = archive_search.map(function(x) { return "(" + x + ")" }).join(" OR ")
  archive('in:inbox -is:starred AND (' + archive_search + ')');
}

function archive(search) {
  var threads = GmailApp.search(search, 0, 50);
  GmailApp.moveThreadsToArchive(threads);

  Logger.log('Archived %s threads for %s', threads.length, search);
  return threads.length;
}
```

This worked perfectly for about three days (starting the 7th) and then suddenly
my entire inbox was empty.  I suspected this might be the culprit.

When I wrote this, I was at least a little careful.  I've experienced the
missing WHERE clause, causing a statement that originally was intended to
delete a single row to instead truncate an entire table.  Similarly, a regular
expression which happens to be blank will match all the files in a folder,
deleting all of them.

Because this has happened before, I took care to guard against it:

```
  if (!archive.length) return;
```

There are three problems though.  First, the careful reader will know that I
meant to check `archive_search`, not `archive`.  If I had not made that mistake,
everything would have been fine.

Many complain that JavaScript does not limit the user to variables that have
already been defined.  Unfortunately this misses the fact that *archive is
actually already defined.*

Here is what is incredibly weird to me.  In JavaScript, Function objects do
indeed have a `.length` member, or the above would have not been a problem.  My
initial guess as to what the `.length` is defined as was the character count of
the function.  The `.length` of the Function is the amount of required arguments
the function takes (also known as the "arity".)

So ultimately, once the UTC clock rolled over to midnight, the above code said:

```
archive('in:inbox -is:starred AND ()');
```

And all of my email was gone.
