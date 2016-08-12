---
title: Staring into the Void
date: 2016-06-16T00:06:39
tags: [frew-warez, programming, productivity, perl, email, angst]
guid: "https://blog.afoolishmanifesto.com/posts/staring-into-the-void"
aliases: ["/posts/starting-into-the-void/"]
---
Monday of this week either Gmail or [OfflineIMAP](http://www.offlineimap.org/)
had a super rare transient bug and duplicated all of the emails in my inbox,
twice.  I had three copies of every email!  It was annoying, but I figured it
would be pretty easy to fix with a simple Perl script.  I was right; here's how
I did it:

<!--more-->

```
#!/usr/bin/env perl

use 5.24.0;
use warnings;

use Email::MIME;
use IO::All;

my $dir = shift;

my @files = io->dir($dir)->all_files;

my %message_id;

for my $file (@files) {
   my $message_id = Email::MIME->new( $file->all )->header_str('message-id');
   unless ($message_id) {
      warn "No Message-ID for $file\n";
      next;
   }

   $message_id{$message_id} ||= [];
   push $message_id{$message_id}->@*, $file->name;
}

for my $message_id (keys %message_id) {
   my ($keep, @remove) = $message_id{$message_id}->@*;

   say "# keep $keep";
   say "rm $_" for @remove;
}
```

After running the script above I could eyeball the output and be fairly
confident that I was not accidentally deleting everything.  Then I just re-ran
it and piped the output to `sh`.  *Et voilà*!  The inbox was back to normal, and
I felt good about myself.

## Then I got nervous

Sometimes when you are programming, you solve real world problems, like [what
day you'll get married](/posts/screen-scrape-for-love-with-web-scraper/).  Other
times, you're just digging yourself out of the pit that is everything that comes
with programming.  This is one of those times.  [I've mentioned my email setup
before](/posts/fast-cli-tools-and-gmail/), and I am still very pleased with it.
But I have to admit to myself that this problem would never have happened if I
were using the web interface that Gmail exposes.

See, while I can program all day, it's not actually what I get paid to do.  I
get paid to solve problems, not make more of them and then fix them with code.
It's a lot of fun to write code; when you write code you are making something
and you get the nearly instant gratification of seeing it work.

I think code can solve **many** problems, and is worth doing for sure.  In fact
I do think the code above is useful and was worth writing and running.  But it
comes really close to what I like to call "life support" code.  Life support
code is not code that keeps a person living.  Life support code is code that
hacks around bugs or lack of features or whatever else, to keep other code
running.

No software is perfect; there will always be life support code, incidental
complexity, lack of idempotence, and bugs.  But that doesn't mean that I can
stop struggling against this fundamental truth and just write / support bad
software.  I will continue to attempt to improve my code and the code around me,
but I think writing stuff like the above is, to some extent, [a warning
sign](https://www.youtube.com/watch?v=0rpYo4GFt2k).

Don't just mortgage your technical debt; pay it down.  Fix the problems.  And
keep the real goal in sight; you do not exist to pour your blood into a machine:
solve real problems.
