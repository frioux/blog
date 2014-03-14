---
aliases: ["/archives/570"]
title: "Why CPAN is Awesome"
date: "2009-04-23T03:58:54-05:00"
tags: ["cpan", "perl", "sockets"]
guid: "http://blog.afoolishmanifesto.com/?p=570"
---
Have you ever written a server? It's kinda fun! Yes, I'm a nerd. Anyway, I learned the easy way and the hard way to make a server in Perl yesterday. Here's the easy way:

    #!/usr/bin/perl

    use strict;
    use warnings;
    use feature ':5.10';
    use Socket;
    use Carp;
    use constant PORT => 7890;
    use lib '../lib';
    use WebCritic::Critic;

    my $dir = shift;
    my $port = shift || PORT;
    my $proto = getprotobyname 'tcp';

    # create a socket, make it reusable
    socket SERVER, PF_INET, SOCK_STREAM, $proto or
       croak "socket: $!";

    setsockopt SERVER, SOL_SOCKET, SO_REUSEADDR, 1 or
       croak "setsock: $!";

    # grab a port on this machine
    my $paddr = sockaddr_in( $port, INADDR_ANY );

    # bind to a port, then listen
    bind SERVER, $paddr or croak "bind: $!";
    listen SERVER, SOMAXCONN or croak "listen: $!";
    say "SERVER started on port $port ";

    my $client_addr;
    my $critic = WebCritic::Critic->new({
       directory => $dir
    });
    while ( $client_addr = accept CLIENT, SERVER ) {

        # find out who connected
        my ( $client_port, $client_ip ) =
           sockaddr_in($client_addr);

        my $client_ipnum =
           inet_ntoa($client_ip);

        my $client_host =
           gethostbyaddr $client_ip, AF_INET;

        # print who has connected
        say "got a connection from: $client_host",
            "[$client_ipnum] ";

        # send them a message, close connection
        say CLIENT $critic->criticisms;
        close CLIENT or
           croak "couldn't close connection! $@";
    }

So that's the Perl code to make a simple server! Unfortunately it is a little incomprehensible, at least to me. A lot of that has to do with the fact that Socket is just a translation of socket.h. Why are all those functions weirdly named? What do they do? I don't know. I don't even care to know. Why? I'm not a C programmer.

So I found IO::All. Check out the rewrite.

    #!/usr/bin/perl

    use strict;
    use warnings;
    use feature ':5.10';
    use IO::All;
    use Carp;
    use constant PORT => 7890;
    use lib '../lib';
    use WebCritic::Critic;

    my $dir = shift;
    my $port = shift || PORT;

    my $socket = io(":$port") or
       croak "server couldn't load on port $port";

    say "server loaded on port $port";

    my $critic = WebCritic::Critic->new({
       directory => $dir
    });
    while ( my $s = $socket->accept ) {
       say "Servicing client";
       $s->print($critic->criticisms);
    }

It's like, half the length and so much simpler! Anyway... next up: Web Based, AJAX-y, "threaded" version of PerlCritic coming up soon! (I am using it at work :-) )
