---
aliases: ["/archives/1411"]
title: "Using Plack for Hardware emulation"
date: "2010-08-10T14:49:09-05:00"
tags: [mitsi, cpan, perl, plack]
guid: "http://blog.afoolishmanifesto.com/?p=1411"
---
One of the first projects I did at work was to make a web/javascript based
interface for a [piece of
hardware](http://www.lynxguide.com/bm/Products/InputDevices/index.shtml#LynxNet256)
that we sell. The machine is very underpowered so pushing a lot of the
complexity to the client makes sense. It was a great project and is one of the
few that I haven't had to make modifications to since I finished it nearly two
years ago.

Well, it turns out we are making a new version of the hardware and I have to add
a ton of options to the UI. That is pretty easy in general, but first I have to
get the app up and running. There's NO WAY I'm going to flash the firmware every
time I need to make a change to the javascript. What do I do instead? Mock the
hardware with Plack!

Here's the code I'm using:

    use Plack::App::File;
    my $app = Plack::App::File->new(root => ".")->to_app;

    use Plack::Builder;
    builder {
       mount '/settings.htm' =>
          Plack::App::File->new(file => "../Web Source/settings.js");
       mount '/WebResources/resources/css/extall.css.gz' =>
          Plack::App::File->new(file => "../Web Source/extall.css");
       mount '/WebResources/resources/css/xthemeblack.css.gz' =>
          Plack::App::File->new(file => "../Web Source/xthemeblack.css");
       mount "/WebResources/$_.gz" =>
          Plack::App::File->new(file => "../Web Source/$_") for (
          'extall.js',
          'extprototypeadapter.js',
          'harmony_config.css',
          'harmony_config.js',
          'prototype.js',
       );
       mount '/' => $app;
    };

The first and second line make a basic file server which serves up all the
images and whatnot. The rest, the mount commands that is, rearrange things so
that instead of using our pre-gzipped files it points to my source files. That
way we can leave the html static but I don't have to waste time copying stuff
all over the place all the time.

Awesome!
