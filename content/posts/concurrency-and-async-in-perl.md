---
title: Concurrency and Asynchrony in Perl
date: 2014-07-29T10:34:10
tags: [frew-warez, mitsi, "perl", "async", "io-async", "poe", "anyevent"]
guid: "https://blog.afoolishmanifesto.com/posts/concurrency-and-async-in-perl"
---
Lately I've been in situations where I need to write some event driven, parallel
code.  Most people call that "async" and I'll stick to that for now.

What I've been doing is writing a little TCP service that can accept any
number of clients at the same time (though typically only one) and interact
with the clients in a single process and with no multithreading.  As surely
many have remarked before, this is to some extent the future of computing.
I vaguely mentioned [Node.JS](http://nodejs.org/) in [one of my previous
posts](https://blog.afoolishmanifesto.com/posts/a-gentle-tls-intro-for-perlers/)
as it has become [super popular](http://www.modulecounts.com/) for doing
this kind of stuff "from the start."

That's another post though.  For now, I'd like to discuss the various ways the
major async frameworks in perl do concurrency.  For communication purposes, I'm
going to use (what I think is) CSP terminology that I've gathered over time from
playing with Go stuff.  So basically that means:

Parallelism is multiple things happening at once.

Concurrency is things communicating to each other.

Side note: these two things are actually orthogonal and treating them as such
can yield a much better understanding of a given system.

With that aside, what this post is about is *concurrency*.  At this point I've
used two of the three major Perl async frameworks professionally.  I'd not
consider myself any kind of expert, but I think that I can make some reasonable
comparisons.

About the code snippets; I've shown and discussed the code included in
this post with Rocco Caputo, Paul Evans, Marc Lehmann, Peter Rabbitson, and
Sawyer X.  They all gave feedback that ended up with the code included here.
I did write it myself and there is some advice that I did not take because I
felt that it would diminish what I'm trying to communicate here, so I take
fault for any mistakes included within.  Also thanks to Tom Molesworth for
reviewing the post.

The basic goal of the code in this post is to create an echo server that
also periodically prints ping to the connected client.  While this may be
obviously a toy, it is enough to demonstrate the various ways to connect related
events with the discussed frameworks.

## AnyEvent

The framework I first did async work in perl with was AnyEvent.  (Well actually
I did a tiny bit of POE in the distant past of 2006, but I didn't understand
what I was doing so we'll ignore that.)  AnyEvent is really easy to jump into
and tends to work fairly well.  The fundamental way that AnyEvent works is just
with normal perl variables and what are called `condvars` which are sorta like
semaphores.

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

For what it's worth, there is a much shorter way to do the above in POE,
but the abstractions obscured the way that this is working.  (See appendix.)
So while AnyEvent has objects that are instantiated and when they go out of
scope the stop running, POE has states that are triggered in various ways.
In the above code when a client first connects (`on_client_accept`) a `ping`
event is triggered for 5 seconds in the future with our current `$wheel_id`
included in the call.  As can be seen in the `ping` state the `$wheel_id`
is used to send ping, and then another `ping` is enqueued.

It's interesting to me how vastly different this methodology is from AnyEvent's
way.  AnyEvent feels much more "Perly", but the POE way feels a lot more
predictable and structured.  More on that in a bit.

## IO::Async

IO::Async is my new favorite async framework.  It's the newest of the three
here, though it's hardly young (five years old.)  One of the distinguishing
features of IO::Async is that it has pervasive support for Futures.  I won't
really discuss that here but I think it's pretty cool when you get to use them.

So while POE is fundamentally one or more state machines, and AnyEvent is a
natural directed graph due to Perl's references, IO::Async is more of a tree:

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

So note that unlike AnyEvent, we use a special method `add_child` to add the
timer to the stream.

## Value Judgements

I think all of POE, IO::Async, and AnyEvent have things to offer the Perl world.
I would say that it's almost uncontestable that AnyEvent is the easiest to get
started with and even be productive.  The venerable POE has a lot of interesting
components that you can use to avoid rewriting code from scratch, though really
all of the async frameworks have something like that.

I do have to say that I personally find the anonymous-callback style both
IO::Async and AnyEvent promote to be a little problematic.  It's easy to
accidentally create a loop in your references, which means that the loop
will never be garbage collected and now you at least have a leak, if not
more bugs.  Additionally, both IO::Async and AnyEvent have parts of the
code that are related to garbage collection so you can accidentally forget
to keep a reference to something and then just lose the event/notifier.

POE sidesteps this problem by being a little strict about how it is defined;
anonymous subs are used but it's almost as if Perl is not.  The callers of the
subs that define POE states use their own memory store and calling conventions.

I think IO::Async gives the user just enough structure to be much safer
than AnyEvent.  Note that in my IO::Async example the only way the timer can
access the stream is with `$self->parent`.  These are references maintained by
the IO::Async framework, which tears them down for us at the end of the
notifiers life.

So if I were to advise someone on how to learn to code async Perl I'd say start
with AnyEvent, but if someone were to write something for *work* I'd recommend
IO::Async or POE if you're willing to put in the work.

---

I don't know of any books to suggest that are fully on topic, but here are a
couple you might be interested in anyway.  One of the most fascinating and
approachable hard tech books I've ever read is
<a target="_blank" href="https://www.amazon.com/gp/product/1558607013/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1558607013&linkCode=as2&tag=afoolishmanif-20&linkId=34bb4d6db235d3fea06697134dd203c3">Higher-Order Perl</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1558607013" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
If you want to up your perl game, or bend your mind, or both, read this book.
The hard copy is beautiful, but the PDF version is free these days.

If you have somehow gotten this far in this article and just now realized that
you don't actually know Perl at all, or maybe you've been stuck in Perl 5.005
and would like to learn how to code in a more modern fashion, maybe check out
<a target="_blank" href="https://www.amazon.com/gp/product/1680500880/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680500880&linkCode=as2&tag=afoolishmanif-20&linkId=b94d729d29e65b0bd778b25a79818394">Modern Perl</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680500880" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
Modern Perl is a little too dogmatic for my tastes, but it's more likely to be
a helpful start than one of the older O'Reilly books at this point.

---

## POE Appendix

    #!/usr/bin/env perl
    
    use warnings;
    use strict;
    
    use POE qw( Component::Server::TCP );
    
    POE::Component::Server::TCP->new(
	    Port => 9935,
	    Started => sub {
		    warn "listening on 0.0.0.0:9935\n";
	    },
	    ClientConnected => sub {
		    warn "client connected\n";
		    POE::Kernel->delay( ping => 5 );
	    },
	    ClientInput => sub {
		    my $input = $_[ARG0];
		    $_[HEAP]{client}->put( $input );
	    },
	    ClientDisconnected => sub {
		    warn "client disconnected\n";
		    POE::Kernel->delay( ping => undef );
	    },
    
	    # Custom event handlers.
	    # Encapsulated in /(Inline|Object|Package)States/ to avoid potential
	    # conflict with reserved constructor parameters.
	    InlineStates => {
		    ping => sub {
			    $_[HEAP]{client}->put('ping!');
			    POE::Kernel->delay( ping => 5 );
		    },
	    },
    );
    
    POE::Kernel->run();
