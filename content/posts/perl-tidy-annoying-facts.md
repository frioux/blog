---
aliases: ["/archives/586"]
title: "Perl::Tidy: annoying facts"
date: "2009-04-24T03:22:03-05:00"
tags: [perl, perltidy]
guid: "http://blog.afoolishmanifesto.com/?p=586"
---
So I was trying to use perltidy programmatically, that means using Perl::Tidy. Basically I wanted to use an existing .perltidyrc along with the backup option. That is, instead of making a new file with .tdy at the end, replace the original and back it up to .bak. So after reading the docs I figured that this should work:

       use Perl::Tidy ();
       use File::Spec;

       my $file = File::Spec->catfile( $dir,
          $filename );

       Perl::Tidy::perltidy(
          source     => $file,
          argv        => '-b',
          perltidyrc => $perltidyrc,
       );

Unfortunately that **just doesn't work**. Here's how I got it to work:

       Perl::Tidy::perltidy(
          argv        => "-b $file",
          perltidyrc => $perltidyrc,
       );

I also had to modify the .perltidyrc file some as apparently Perl::Tidy doesn't have a way to choose who wins when there are conflicts in the switches and the config file. One way or another, it was annoying.

Maybe I was doing it wrong?
