---
aliases: ["/archives/1525"]
title: "Event Loops are better than while (1)"
date: "2011-08-03T03:04:35-05:00"
tags: [mitsi, cpan, event-loops, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1525"
---
One of the projects that I worked on last year had a number, five I think, of background daemons. Basically the way we implemented this was by making a DoesRun role that looked something like the following:

    package Lynx::SMS::DoesRun;

    use Moose::Role;

    requires 'single_run';

    has period => (
       is => 'ro',
       required => 1,
    );

    sub run {
       my $self = shift;
       while (1) {
          $self->single_run;
          sleep $self->period;
       }
    }

    no Moose::Role;

    1;

And then a typical Runner class looked something like this:

    package Lynx::SMS::Runner::Voice;

    use Moose;
    use Log::Contextual::SimpleLogger;
    use Log::Contextual qw( :dlog :log ),
      -default_logger => Log::Contextual::SimpleLogger->new({ levels => [qw( warn error fatal )]});

    with 'Lynx::SMS::DoesRun';
    has schema => (
       is => 'ro',
       required => 1,
    );

    sub single_run {
       my $self = shift;

       log_debug { 'Processing voice messages' };
       my $guard = $self->schema->txn_scope_guard;
       while ($self->schema->resultset('MessageChild')->voice->unsent->not_blocked->count) {
          ...
       }
       $guard->commit;
    }

    no Moose;

    __PACKAGE__->meta->make_immutable;

    1;

And lastly, a script using the runner looked like this:

    #!/usr/bin/env perl

    use 5.12.1;
    use warnings;
    use rlib;

    use Lynx::SMS::Runner::Voice;
    use Lynx::SMS::Schema;
    use Config::ZOMG;

    my $config = Config::ZOMG->open(
       name => 'Lynx::SMS',
       path => '.',
    );

    my $voicer = Lynx::SMS::Runner::Voice->new(
       schema => Lynx::SMS::Schema->connect( $config->{Model}{DB}{connect_info} ),
       period => 60, # seconds
    );

    $voicer->run;

Anyway, that was all well and good, but at some point things would die and the whole thing would come crashing down, so then we started adding an eval around the call to run in the script, and then I thought, "someone must have done this before..." So I asked in the #catalyst channel on irc.perl.org and rafl pointed out that this is what event loops (POE being the oldest and probably most popular) are great at.

So I updated the run method in the DoesRun role, so now it looks like this:

    sub run {
       my $self = shift;
       my $j = AnyEvent->condvar;
       my $w = AnyEvent->timer(
          interval => $self->period,
          cb => sub { $self->single_run },
       );
       $j->recv;
    }

Ok, cool enough, it basically does the exact same thing as before except it never dies. But then I had an idea, on a server with 16 Gigs of RAM and a dual quad-core CPU five fat perl daemons is hardly an issue. But when developing it's certainly a hassle to have to start them all up myself. So why not combine them and have them all run in the same process? Cake! I made the following Runner class to do the magic:

    package Lynx::SMS::Runner;

    use Moose;

    has tasks => (
       is => 'ro',
       default => sub { [] },
    );

    sub run {
       my $self = shift;
       my $j = AnyEvent->condvar;

       my $x = 0;
       my @tasks = @{$self->tasks};
       @tasks = map {
          my $task = $_;
          AnyEvent->timer(
             after    => ($x++ / @tasks),
             interval => $task->period,
             cb       => sub { $task->single_run },
          )
       } @tasks;
       $j->recv;
    }

    no Moose;

    __PACKAGE__->meta->make_immutable;

    1;

The after thing is weird, but the idea there is that each task will start at a different time, so things are more likely to run at a different time. Not really important, but it makes the logs easier to follow for me.

And then here is my script using it:

    #!/usr/bin/env perl

    use 5.12.1;
    use warnings;
    use rlib;

    use Lynx::SMS::Runner::SMS;
    use Lynx::SMS::Runner::Voice;
    use Lynx::SMS::Runner::Emailer;
    use Lynx::SMS::Runner::Notifier;
    use Lynx::SMS::Runner;
    use Lynx::SMS::Schema;
    use Config::ZOMG;
    use Lynx::SMS::Logger;
    use Log::Contextual
      -logger => Lynx::SMS::Logger->new({
        levels_upto => 'trace',
        format      => '[%d] %m',
      });

    my $config = Config::ZOMG->open(
       name => 'Lynx::SMS',
       path => '.',
    );

    my $schema = Lynx::SMS::Schema->connect($config->{Model}{DB}{connect_info});
    my $runner = Lynx::SMS::Runner->new(
       tasks => [
          Lynx::SMS::Runner::SMS->new(
             schema => $schema,
             period => 1, # seconds
          ),
          Lynx::SMS::Runner::Voice->new(
             schema => $schema,
             period => 1, # seconds
          ),
          Lynx::SMS::Runner::Emailer->new(
             schema => $schema,
             period => 60*5, # 5 minutes
          ),
          Lynx::SMS::Runner::Notifier->new(
             schema => $schema,
             period => 60*60*24, # 1 day
          ),
       ]
    );

    $runner->run;

One thing that would improve this whole thing would be to capture dies or whatever and log $@ in our standard error logger thing. I haven't quite figured out how to do that yet, but if someone knows how and comments I'd appreciate it.
