---
title: Concurrency and Asyncrony in Perl
date: 2014-07-29T10:34:10
tags: ["perl", "async", "io-async", "IO::Async", "POE", "AnyEvent", "AE"]
guid: "https://blog.afoolishmanifesto.com/posts/concurrency-and-async-in-perl"
---
Lately I've been in situations where I need to write some event driven, parallel
code.  Most people call that "async" and I'll stick to that for now.

What I've been doing is writing a little TCP service that can accept any number
of clients at the same time (though typically only one) and interact with the
clients in a single process and with no multithreading.  As surely many have
remakred before, this is to some extent the future of computing.  I vaguely
mentioned [Node.JS] in [one of my previous posts] as it has become [super
popular] for doing this kind of stuff "from the start."

That's another post though.  For now, I'd like to discuss the various ways the
major async frameworks in perl do concurrency.  For communication purposes, I'm
going to use (what I think is) CSP terminology that I've gathered over time from
playing with Go stuff.  So basically that means:

Parallelism is multiple things happening at once.

Concurrency is things communicating to each other.

As an aside, these two things are actually orthogonal and treating them as such
can yield a much better understanding of a given system.

With that aside, what this post is about is *concurrency*.  At this point I've
used two of the three major Perl async frameworks professionally.  I'd not
consider myself any kind of expert, but I think that I can make some reasonable
comparisons.

An aside about the code snippets; I've shown and discussed the code included in
this post with Rocco Caputo, Paul Evans, Marc Lehmann, Peter Rabbitson, and
Sawyer X.  They all gave feedback that ended up with the code included here.  I
did write it myself and there is some advice that I did not take because I felt
that it would diminish what I'm trying to communicate here, so I take fault for
any mistakes included within.

The basic goal of the code in this post is to create an echo server that
also periodically prints ping to the connected client.  While this may be
obviously a toy, it is enough to demonstrate the various ways to connect related
events with the discussed frameworks.

## AnyEvent

The framework I first did async work in perl with was AnyEvent.  (Well actually
I did a tiny bit of POE in the distant past of 2006, but I didn't understand
what I was doing so we'll ignore that.)  AnyEvent is really easy to jump into
and tends to work fairly well.  The fundamental way that AnyEvent works is just
with normal perl variables and what are called `condvars` which are basically a
weirdly named Future/Promise.

So here's the example I came up with for AnyEvent:

    #!/usr/bin/env perl
    
    use 5.20.0;
    use warnings;
    
    use experimental 'signatures';
    
    use AnyEvent;
    use AnyEvent::Socket;
    use AnyEvent::Handle;
    use AnyEvent::Loop;
    use Scalar::Util 'refaddr';
    
    my %handles;
    
    my $server = tcp_server undef, 9934, sub ($fh, $host, $port) {
       my $hdl = AnyEvent::Handle->new(
          fh => $fh,
          on_eof => \&disconnect,
          on_error => \&disconnect,
          on_read => sub ($hdl) {
             $hdl->push_write($hdl->rbuf);
             substr($hdl->{rbuf}, 0) = '';
          },
       );
       $handles{refaddr $hdl} = $hdl;
       $hdl->{timer} = AnyEvent->timer(
          after    => 5,
          interval => 5,
          cb       => sub { $hdl->push_write("ping!\n") },
       )
    }, sub ($fh, $thishost, $thisport) {
       warn "listening on $thishost:$thisport\n";
    };
    
    AnyEvent::Loop::run;
    
    sub disconnect ($hdl, @) {
       warn "client disconnected\n";
       delete $handles{refaddr $hdl}
    }

So the way that we connect the ping timer to the handle is just be adding a
reference to the timer inside the handle.  We could just as easily put them both
in another data structure and store that.

## POE

I've tried on and off to use POE a few times over the years.  The fact is
AnyEvent and IO::Async are just more attractive to me aesthetically.  POE is by
far the oldest of the async frameworks discussed here, and it has a huge amount
of extensions, though to some extent they are aging.  While AnyEvent is
fundamentally just a bunch of Perl objects, POE pretty clearly exposes a state
machine.

    #!/usr/bin/env perl
    
    use 5.20.0;
    use warnings;
    
    use POE qw(Wheel::ListenAccept Wheel::ReadWrite);
    
    POE::Session->create(
       inline_states => {
    
          _start => sub {
             $_[HEAP]{server} = POE::Wheel::ListenAccept->new(
                Handle => IO::Socket::INET->new(
                   LocalPort => 9935,
                   Listen    => 5,
                ),
                AcceptEvent => "on_client_accept",
                ErrorEvent  => "on_server_error",
             );
             warn "listening on: 0.0.0.0:9935\n";
          },
    
          on_client_accept => sub {
             my $client_socket = $_[ARG0];
             my $io_wheel      = POE::Wheel::ReadWrite->new(
                Handle     => $client_socket,
                InputEvent => "on_client_input",
                ErrorEvent => "on_client_error",
             );
             warn "client connected\n";
             my $wheel_id = $io_wheel->ID;
             $_[KERNEL]->alarm( ping => time() + 5, $wheel_id);
             $_[HEAP]{client}{$wheel_id} = $io_wheel;
          },
    
          ping => sub {
             my $wheel_id = $_[ARG0];
             $_[HEAP]{client}{$wheel_id}->put('ping!');
             $_[KERNEL]->alarm( ping => time() + 5, $wheel_id);
          },
    
          on_server_error => sub {
             my ($operation, $errnum, $errstr) = @_[ARG0, ARG1, ARG2];
             warn "Server $operation error $errnum: $errstr\n";
             delete $_[HEAP]{server};
          },
    
          on_client_input => sub {
             my ($input, $wheel_id) = @_[ARG0, ARG1];
             $_[HEAP]{client}{$wheel_id}->put($input);
          },
    
          on_client_error => sub {
             my $wheel_id = $_[ARG3];
             delete $_[HEAP]{client}{$wheel_id};
             warn "client (probably) disconnected\n";
          },
       }
    );
    
    POE::Kernel->run;

## IO::Async

    #!/usr/bin/env perl
    
    use 5.20.0;
    use warnings;
    
    use experimental 'signatures';
    
    use IO::Async::Loop;
    use IO::Async::Timer::Periodic;
    
    my $loop = IO::Async::Loop->new;
    
    my $server = $loop->listen(
       host => '0.0.0.0',
       socktype => 'stream',
       service => 9933,
    
       on_stream => sub ($stream) {
          $stream->configure(
             on_read => sub ($self, $buffref, $eof) {
                $self->write($$buffref);
                $$buffref = '';
                0
             },
          );
    
          $stream->add_child(
             IO::Async::Timer::Periodic->new(
                interval => 5,
                on_tick => sub ($self) { $self->parent->write("ping!\n") },
             )->start
          );
          $loop->add( $stream );
       },
    
       on_resolve_error => sub { die "Cannot resolve - $_[1]\n"; },
       on_listen_error => sub { die "Cannot listen - $_[1]\n"; },
    
       on_listen => sub ($s) {
          warn "listening on: " . $s->sockhost . ':' . $s->sockport . "\n";
       },
    
    );
    
    $loop->run;

