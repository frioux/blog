---
title: How I Integrated my blink(1) with PulseAudio
date: 2015-11-17T19:55:28
tags: [frew-warez, ziprecruiter, perl, linux, pulseaudio]
guid: "https://blog.afoolishmanifesto.com/posts/how-i-integrated-my-blink-1--with-pulseaudio"
---
At work I wear some noise cancelling ear buds.  I do this because just twenty
feet behind me there is a one hundred person sales team who sometimes claps,
ring gongs, and is just generally loud.  I also like to work to music and it
helps me focus.

My other coworkers all use large headphones, so they are used to being able to
see at a glance if a given individual is listening to music.  I thought it would
be cool if I made a way to show that I was actually listening to something,
so I wrote the following little script:

```
#!/usr/bin/perl

use strict;
use warnings;

while (1) {
   sleep 1;

   if (playing_sounds()) {
      warn "red\n";
      system 'blink1-tool', '--red';
      $off_count = 0;
   } else {
      warn "black\n";
      system 'blink1-tool', '--off';
   }
}

sub playing_sounds {
   my @lines =
      grep m/RUNNING/,
      split /\n/,
      qx(pacmd list-sink-inputs);

   warn "sound is playing\n" if @lines;
   warn "silence\n" if !@lines;

   scalar @lines
}
```

This very lightweight perl script of 30 lines simply makes my
[blink(1)](http://blink1.thingm.com/) red if *any* sound is playing on my
machine, and turns it back off when there is none.

It works amazingly well and I think it is exactly why it's awesome to be a
software engineer.  I would like to have red imply sound and do something else
with green and blue, but I do not yet have ideas for what those could imply.  I
was considering making green come on if someone `ssh`es into my machine but
that's crazy unlikely 😆.  Pretty cool eh?
