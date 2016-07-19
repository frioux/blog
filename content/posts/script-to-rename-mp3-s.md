---
aliases: ["/archives/764"]
title: "Script to Rename MP3's"
date: "2009-05-31T22:37:34-05:00"
tags: [frew-warez, mp3, music, perl]
guid: "http://blog.afoolishmanifesto.com/?p=764"
---
I recently got a new car stereo due to the other one being stolen. I am almost entirely happy with the model that I ended up purchasing, but one thing that it does, which is really obnoxious, is that it doesn't sort the files correctly unless the track number is early on in the file name. Even if all tracks are "FooBarBaz 01 - name.mp3" it seems to ignore the number unless it's the very beginning of the file name. Anyway, easy fix:

    #!perl
    use strict;
    use warnings;
    use feature ':5.10';

    use Music::Tag;
    use File::Find::Rule;
    use File::Basename "fileparse";
    use File::Copy "move";
    use File::Spec;
    my $directory = shift || '.';

    my @songs
       = File::Find::Rule->file()->name( '*.mp3' )
       ->in( $directory );

    foreach my $song (@songs) {
       my $info = Music::Tag->new($song);
       $info->get_tag;
       my $track = $info->track;
       my $title = $info->title;
       my (undef, $dir, $suffix) =
          fileparse($song, qr/\.[^.]*/);
       $info->close;
       if ($track and $title) {
          my $newfilename = File::Spec->catfile(
             $dir,
             sprintf "%02d %s%s", $track, $title, $suffix
          );
          if ($song ne $newfilename) {
             say "renaming $song to $newfilename";
             move $song, $newfilename;
          }
       }
    }

It doesn't really deal with illegal characters, it just doesn't rename those files. Eventually I'll get around to doing that. Anyway, just figured someone might be interested/want to copy paste this.
