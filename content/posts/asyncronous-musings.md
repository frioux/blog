---
title: Asynchronous Musings
date: 2015-01-22T19:19:21
tags: ["async", "perl", "cpan", "io-async"]
guid: "https://blog.afoolishmanifesto.com/posts/asynchronous-musings"
---
Recently at work I've been working on our first section of code that is purely
asynchronous.  It's pretty exciting!  [As I've discussed
before](/posts/concurrency-and-async-in-perl/), we're using IO::Async, which has
first class support for Futures.  Futures are sorta kinda a way to express
callbacks.  They aren't quite as powerful, but they can do nearly everything
callbacks can do.  (Specifically Futures represent a single action, not a stream
of actions like callbacks can.)

Anyway, with a Future you have to either put the object somewhere, or do a weird
self closure thing.  This post is about avoiding the latter, so I won't discuss
self closing here.

If you are willing to always store your futures, preferably in the same place,
some interesting possibilities open up.  Here's the API that I use at work for
kicking off a Future based async task:

     sub store_f_with_timeout ($self, $future, $timeout) {
        $self->store_named_f_with_timeout("$future", $future, $timeout)
     }

     sub store_named_f_with_timeout ($self, $name, $future, $timeout) {
        my $f = IO::Async::Future->wait_any(
           my $ripcord = Future->new,
           $self->_loop->timeout_future( after => $timeout ),
           $future
        )->set_label($future->label);

        if (my $f = $self->_ripcords->{$name}) {
           $f->fail("This event was already running!  It probably should have timed out before this ($name)", 'overlap')
        }
        $self->in_flight->{$name} = $f;
        $self->_ripcords->{$name} = $ripcord;

                          log_debug { ' started ' . $f->label };
        $f->on_done(sub { log_debug { 'finished ' . $f->label } });
        $f->on_fail(sub {  log_warn { '  failed ' . $f->label . " (@_)" } @_ });

        $f->on_ready(sub {
           delete $self->in_flight->{$name};
           delete $self->_ripcords->{$name};
        })
     }

So basically, we have two entrypoints.  The first is the anonymous one, that
maybe doesn't even need any discussion.  The second one is named.  The name
comes into place in the second block of the second function; if you have a named
task and you schedule that task such that two of the same task are running at
once, the older one fails.  I could have gone newer, and might still, but the
point is that it is a neat side effect that you can only achieve by storing your
futures.  I've already had this solve problems.

A little bit more could be said about what I call ripcords.  We store a
secondary future that allows us to effectively cancel the async event and fail
the outer event.

Thanks to the fact that all the futures are stored by a given name, I have a
Net::Async::HTTP::Server based web server that has access to this hash.  In the
web server I have an endpoint that will:

 * count the outstanding futures
 * list the outstanding futures, showing their labels and how long they have
   been outstanding
 * let the user cancel a future by name

 Also note in the third block of the main function the logging.  The logging
 shown is, as far as I know, all the code that needs to be written to give
 *plenty* of logging to debug the system.  It's pretty handy!

 At some point I might add an entrypoint that has no timeout, but that seems
 pretty sketchy.  A timeout, even a really really high one like 24 hours, gives
 your software a way to avoid a huge class of byzantine failures.

 Next, I hope to write about code that is optionally concurrent!
