---
aliases: ["/archives/1746"]
title: "Announcing Catalyst::Action::FromPSGI"
date: "2012-06-25T15:30:50-05:00"
tags: ["catalyst", "catalystactionfrompsgi", "cpan", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1746"
---
At YAPC this year I spoke with Stevan Little about his new module, Web::Machine. He mentioned that ultimately he wanted to figure out how to shim it into Catalyst. mst actually implemented something like that exactly a month ago, and I actually want to use it to make little redistributable apps that are the backend implementations of the gadgets for our dashboards at work. So I took Matt's code and made a module!

# [Catalyst::Action::FromPSGI](https://metacpan.org/module/Catalyst::Action::FromPSGI)

Here's the stupid obvious mostly worthless example:

    sub from_plack :Path('/lol') :ActionClass('FromPSGI') {
       sub {
         [ 200,
            [ 'Content-type' => 'text/plain' ],
            [ 'lololol' ],
         ]
       }
    }

So that's neat, but who cares? What's really nice is that you can pass stuff from Catalyst into the PSGI app. Here's an example of something like that:

    sub from_plack :Path('/my_lol') :ActionClass('FromPSGI') {
       my $username = $_[1]->user->obj->name;
       sub {
         [ 200,
            [ 'Content-type' => 'text/plain' ],
            [ "lol: $username" ],
         ]
       }
    }

Anyway, I'll have another post in a few days of how I am looking forward to using this. Have fun!
