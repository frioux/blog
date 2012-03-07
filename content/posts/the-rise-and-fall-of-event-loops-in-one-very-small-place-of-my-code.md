---
aliases: ["/archives/1687"]
title: "The Rise and Fall of Event Loops (in one very small place of my code)"
date: "2012-03-07T01:22:18-06:00"
tags: ["anyevent", "perl", "poe", "while1"]
guid: "http://blog.afoolishmanifesto.com/?p=1687"
---
[In the spirit of one of my other posts](/archives/1303) I've decided to chronicle my path with at least a [couple](https://metacpan.org/module/AnyEvent) [event loops](https://metacpan.org/module/POE).

More than eighteen months ago I [documented](/archives/1525) my decision to start using an event loop as it would handle things I may not have considered, the example mentioned specifically in that post being exceptions. Things went well! I used the code I documented in that post for a long time with no issues until recently. It turns out that the event loop I was using didn't actually handle exceptions at all, thus completely nullifying my reason to use it.

So I looked elsewhere. [I looked at the grandfather of event loops, POE](/archives/1682). I like a lot of the components that have been written on top of POE, but POE itself is frustratingly low level. That's a topic for another post though (yes I looked at Reflex.)

After my last post and speaking with Rocco Caputo, auther of our venerable POE, I came up with the following runner role:

    package Lynx::SMS::DoesRun;

    use Moose::Role;
    use POE;

    # this merely uses our logger etc
    with 'Lynx::SMS::HandlesDieForPOE';

    requires 'single_run';

    has period => (
       is => 'ro',
       required => 1,
    );

    has schema => (
       is => 'ro',
    );

    sub run {
       my $self = shift;

       POE::Session->create(
          inline_states => {
             _start => sub {
                $_[KERNEL]->sig( DIE => 'sig_DIE' );
                $_[KERNEL]->yield('loop');
             },
             sig_DIE => \&die_handler,
             loop => sub {
                $_[KERNEL]->delay( loop => $self->period );
                $self->single_run;
             },
          },
       );

       POE::Kernel->run;
    }

    no Moose::Role;

    1;

This works fine. It's (to me) a little ugly, but I imagine that I'd get used to it if I were to write much more POE. But then Rocco pointed out that maybe I'm just wasting my time with event loops for this use case. Ultimately using POE as a glorified Try::Tiny is stupid and really not even the goal. So finally I've ended up just a few steps beyond where I started:

    package Lynx::SMS::DoesRun;

    use Moose::Role;
    use Try::Tiny;
    use Log::Contextual qw(:log :dlog);

    requires 'single_run';

    has period => (
       is => 'ro',
       required => 1,
    );

    has schema => (
       is => 'ro',
    );

    sub run {
       my $self = shift;

       while (1) {
          try {
             $self->single_run;
          } catch {
             my $error = $_;
             log_error { $error }
          };
          sleep($self->period)
       }
    }

    no Moose::Role;

    1;

The observant reader will notice that despite me mentioning the above use case, which is really the only important one for me given that our actual server will run all of our services in separate processes, there is still the benefit of Event Loops mentioned in the first post for development purposes (starting all services in a single program.) I have indeed converted that to POE, but that probably doesn't matter. I run my unified service script maybe once or twice a year at this point. Here it is if anyone is interested:

    package Lynx::SMS::Runner;

    use Moose;
    use POE;

    with 'Lynx::SMS::HandlesDieForPOE';

    has tasks => (
       is => 'ro',
       default => sub { [] },
    );

    sub run {
       my $self = shift;

       POE::Session->create(
          inline_states => {
             _start => sub {
                $_[KERNEL]->sig( DIE => 'sig_DIE' );
                $self->create_children_sessions,
             },
             sig_DIE => \&die_handler,
          },
       );

       POE::Kernel->run;
    }

    sub create_children_sessions {
       my $self = shift;
       my $x = 0;
       my @tasks = @{$self->tasks};
       for my $task (@tasks) {
          POE::Session->create(
             inline_states => {
                _start => sub {
                   $_[KERNEL]->delay(loop => ($x++ / @tasks ));
                },
                loop => sub {
                   $_[KERNEL]->delay( loop => $task->period );
                   $task->single_run;
                },
             },
          );
       }
    }

    no Moose;

    __PACKAGE__->meta->make_immutable;

    1;

I look forward to using POE for actual heavy-lifting in another one of our projects, and will post about the experience when I get there.
