---
aliases: ["/archives/1682"]
title: "Perl Event Loop"
date: "2012-03-04T17:09:16-06:00"
tags: ["anyevent", "event-loops", "perl", "poe"]
guid: "http://blog.afoolishmanifesto.com/?p=1682"
---
I have some extremely basic code using [AnyEvent](https://metacpan.org/module/AnyEvent) but I recently found out that I was doing it wrong. That is, the **entire reason** I am using an event loop is to catch errors, log them, and keep going. That's one of the great benefits that [Catalyst](https://metacpan.org/module/Catalyst) gives me; I override one thing and I get universal error logging. The problem is that AnyEvent [specifically does not handle this use case](https://metacpan.org/module/AnyEvent::FAQ#My-callback-dies-and...).

I have a working solution, but as I am planning on rewriting our services in evented code this prohibition makes me **really** worried. The problem is that you can't just know your code won't die. Exceptions happen and as a developer of a language that's not Java or C# I don't know where they come from. My current solution is ok, but I don't think it's really viable long term. Here's my current code:

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use AnyEvent;
    use Try::Tiny;

    sub event {
       print "looped\n";
       die "lol" if rand() < .5;
    }

    sub NEVER_DIE {
       my $code = shift;
       return sub {
          try \&$code, catch { warn $_ } # <-- this should be logging, you get the idea
       }
    }

    my $cv = AE::cv;
    my $w = AE::timer 0, 1, NEVER_DIE(\&event);
    $cv->recv;

This works for simple cases, but if I chose to go down this route in the long term I'd have to wrap every single code ref in NEVER\_DIE, which is pretty lame.

I looked at [POE](https://metacpan.org/modules/POE) as it may support my use case better but as far as I can tell it's support is WORSE. Here's what I came up with:

    #!/usr/bin/perl

    use strict;
    use warnings;

    use POE;
    use Try::Tiny;

    sub handler_start {
      my ($kernel, $heap, $session) = @_[KERNEL, HEAP, SESSION];
      $kernel->yield('event');
    }

    sub NEVER_DIE {
       my $code = shift;
       return sub {
          try \&$code, catch { warn $_ } # <-- this should be logging, you get the idea
       }
    }

    sub event {
       print "looped\n";
       die "lol" if rand() < .5;
       $_[KERNEL]->delay_add('event', 1);
    }

    POE::Session->create(
     inline_states => {
       _start    => \&handler_start,
       event     => NEVER_DIE(\&event),
       _stop     => sub{},
     }
    );

    POE::Kernel->run();
    exit;

So I still have to use NEVER\_DIE, so that's a lose, and worse, if event dies before the call to delay\_add we end anyway. Sure, I could put delay\_add at the beginning of event, but that brings me to another thing that really bothers me about the "POE Way" (my own terminology, I may just not be getting it), for my AnyEvent code I can add a bunch of things and they don't have to know about each other. The loop handles calling the events. With POE it seems like I have to manually tell it "call this, now call this." That seems to defeat the entire purpose! What am I missing here?

If anyone knows an event loop I should consider (MUST RUN WELL ON WINDOWS) or maybe some setting in POE and some kind of POE timer thing, or some way of safely overriding how AE calls it's events, please, comment and let me know.
