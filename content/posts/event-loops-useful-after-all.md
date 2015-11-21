---
aliases: ["/archives/1873"]
title: "Event Loops: Useful After All"
date: "2013-07-27T14:57:26-05:00"
tags: ["anyevent", "event-loops", "http", "ioasync", "perl", "udp"]
guid: "http://blog.afoolishmanifesto.com/?p=1873"
---
I've had a [series](/archives/1525) of [blog](/archives/1682) [posts](/archives/1687) referring to event loops; the final message ended up being something like YAGNI. Well, I am eating my hat in this blog post; I have seen the light, I am drinking the kool-aide, I am stockpiling weapons... er, how about I just give some details!

## Tech Aside: IO::Async

I have done some research for a blog post comparing AnyEvent, POE, and IO::Async. This is not that blog post, but in researching that post I came to a conclusion. Until recently I have been a little uncomfortable with event based programming in Perl. I assumed this was because I didn't understand some foundational fact or something, despite the fact that I've done this kind of programming in JavaScript for years now. It turns out that what I was confused by is **condvars**. condvars are (as far as I can tell) an AnyEvent way to confuse me. Here is how you make a loop every second in AnyEvent (note the condvar.)

    my $j = AnyEvent->condvar;

    my $timer = AnyEvent->timer(
       after    => 0,
       interval => 1,
       cb       => sub { print "beep\n" },
    );

    $j->recv;

Does that look like magic to anyone else? Maybe I'm just dumb. But how about I show you how it works in IO::Async, which is what I used in my recent foray into Perl event loops.

    my $loop = IO::Async::Loop->new;

    my $timer = IO::Async::Timer::Periodic->new(
       interval => 1,
       on_tick => sub { print "beep\n" },
    );

    $timer->start;
    $loop->add($timer);
    $loop->run;

The IO::Async::Loop is really the same thing as a condvar, but it is much more obvious to me.

## Background

The product I work on is a mass notification and duress tool. You can use it to tell everyone in your company that the west wing is on fire (via a popup on the PC, SMS, Email, phone, PA System, etc) or you can use it so that the nurse in your psych ward can press a button to call security, and security knows who pressed the button and where it was pressed. The problem is that we are getting large and more geographically disparate deployments. Instead of a single large hospital, customers are wanting to put the software at all of the miles-apart clinics as well. This is a reasonable thing to want, but once you move from one server to many you have opened quite the can of worms.

In researching our path forward on interserver communication I decided to see how well perl with IO::Async could handle large amounts of UDP packets. I'd been inspired by the performance of mosh, which leverages UDP to give the user a much better experience than vanilla ssh on flaky network connections. So with some help from #io-async I made a little UDP client and a UDP server and fired up 35 clients each sending 100 datagrams a second. The server didn't start to drop packets until I started that 36th client. Not Bad.

## Inspiration

After playing with plain UDP for experimentation's sake, I started to think about how this could change some of our existing infrastructure. For ease of deployment, the typical way we do message queues in my company is just to create a table in our database called MessageQueue with id, date\_inserted, type, and data columns. The type is generally searched against per consumer, and then the rows are simply removed from oldest to newest, one at a time. As I mentioned before I usually handle this by polling the table once a second to once a minute, depending on how important the task is. Well with a little UDP socket, I could change my MQ pattern to poll more rarely, but also listen for a datagram that will kickstart the process. The idea being that whatever inserts into the MQ can initiate the consumer to act immediately, but if the datagram didn't survive, for whatever reason, the polling will still work. (Note that using polling and interrupts at the same time came from something Matt S. Trout said at YAPC about how doing push deployments is dumb.) So here's the code for that:

    my $loop = IO::Async::Loop->new;

    my $s = IO::Socket::INET->new(
       Proto => 'udp',
       ReuseAddr => 1,
       Type => SOCK_DGRAM,
       LocalPort => 8001,
    ) or die "No bind: $@\n";

    my $timer = IO::Async::Timer::Periodic->new(
       interval => 60,

       on_tick => \&mq,
    );

    $timer->start;
    $loop->add($timer);

    my $sock = IO::Async::Socket->new(
       handle => $s,
       on_recv => \&mq,
       on_recv_error =>
          sub { die "Cannot recv - $_[1]\n" },
    );
    $loop->add($sock);
    $loop->run;

    sub mq { ... }

I like it. When this gets put into our code what is likely to happen is that, as always, "runners" consume the ::DoesRun role, and then I'll add ::TraitFor::Runner::Poll and ::TraitFor::Runner::Kickstart roles, which will simply do the IO::Async stuff for you, so the actual runner doesn't need to know the details of the event loop.

## It Gets Better

This last bit is cribbed directly from xSawyerx's YAPC talk. It wasn't my idea, but I do like the idea :)

One thing that is annoying about these little daemons is that unless you have really good logging (that's a blog post in itself) it's hard to tell what they are doing when things go wrong. You ultimately have to stop them and start them in a console to see what's happening. To make your application easily introspectible, just add an HTTP server into it that outputs the state of the application!

A really basic implementation of that looks like this:

```
my $httpserver = Net::Async::HTTP::Server->new(
   on_request => sub {
      my $self = shift;
      my ( $req ) = @_;

      my $response = HTTP::Response->new( 200 );
      $response->add_content(
         "     iterations: $ITERATIONS"
      );
      $response->content_type( 'text/html' );
      $response->content_length( length $response->content );
      $req->respond( $response );
   },
);
$loop->add($httpserver);
$httpserver->listen(
   addr => { family => ‘inet6’, socktype => ‘stream’, port => 8080 },
   on_listen_error => sub { die “Cannot listen - $_[-1]\n” },
);
```

Obviously you'd have to increment $ITERATIONS in the mq method. Of course this has the same problems as before, you have to make sure to store all the information in variables, so my next experiment is to capture STDOUT and STDERR and keep the last thousand lines of each in memory, and then show that on the status page. I'll also probably add the stuff that got explicitely logged and maybe add some other interesting status info. I'll blog about that too when I get it working.

## Postscript

I was inspired by [Rik's post](http://rjbs.manxome.org/rubric/entry/1998) about using TDP to motivate himself. I decided to set up [an account](http://tdp.me/person/frioux) and added blogging to the goals. I think blogging once a week is just too much for me, but twice a month shouldn't be too bad. Maybe TDP will work for you too.
