---
title: A Gentle TLS Intro for Perlers
date: 2014-07-17T09:35:52
tags: ["perl", "tls", "ssl", "async"]
guid: "https://blog.afoolishmanifesto.com/posts/a-gentle-tls-intro-for-perlers"
---
At work we've recently been audited for security by one of our customers and one
of the takeaways was that we need to encrypt more things.  Specifically all
things.  This lead me on a journey of discovery.  In this post I'll give some
basic sample code on how to set up and debug a server using TLS, as well as some
basic info on TLS itself.

# TLS?

TLS is what most people think of as SSL.  SSL was originally released- with many
problems- in the mid 90's by Netscape.  After it had been around for a few years
TLS 1.0 was defined in '99 in an effort to make a more generic way to encrypt
traffic.  TLS 1.0 is really just the version after SSL 3.0.  As far as I know
the names are interchangeable and I suspect most people will be saying SSL
for a very long time, and that's fine.

There is a lot that goes into encryption in general, and I am not the guy to
educate everyone in it, just yet.  But there are a few interesting facts
regarding security, which is what I think is an important "tl;dr" bit.  With
that in mind, SSL all the way up to 3.0 is usually considered Insecure, TLS 1.0
is often insecure, and TLS 1.1 and 1.2 are usually Secure.
([Citation](https://en.wikipedia.org/wiki/Secure_Sockets_Layer#Cipher))

# A Digression About Keys and Certs

<img src="/static/img/keychain.jpg" />

It's often stated that the hardest part of any crypto is Key Management.  I'm
not really in a position to judge that statement but I can explain what we are
going to do.  Our software is all intranet, non-cloud hosted.  The reason for
this is that it's used for emergency notifications to literally call the local
security with walkie-talkies, PA systems, and other less timely methods (SMS,
email, phone, etc.)  Ultimately this means that not only is an actual purchased
certificate overkill, but also most customers do not care, as they view their
LAN as secure (maybe, maybe not.)

So our solution is to basically be our own Certificate Authority.  When a
customer buys a new server we create and sign a key for their server.  All of
our client software and hardware look for something signed by our CA when
connecting to the server (via port 4430.)  If a customer is willing to either
purchase their own certificate from a trustworthy internet CA (something based
in the US, COMODO for instance) we have configuration options that will allow
the user to set that, and then when the user connects over port 443 they will
see that cert.  Also, optionally, if the customer is willing do deploy our CA
across heir network we can use our own cert for port 443.  Finally, if they
choose neither, they can use port 80 while our hardware and software clients
will still use the encrypted version.

# How to make Certs and Keys

After looking around on the internet and playing around with OpenSSL for a few
hours I came up with the following, easily tweakable steps to generate what we
need.  This will almost certainly be different for others, but it's a sensible
first step at least for testing out your TLS service.  This will:

 * Create a root (aka CA) key
 * Create a root (aka CA) cert
 * Create a host key
 * Create a host certificate request
 * Create a host cert from that request

Here's the actual code:

    openssl genrsa -out rootCA.key 2048
    openssl req -x509 -new -nodes -key rootCA.key -days 365 -out rootCA.crt -subj '/C=US/ST=Texas/L=Dallas/CN=localhost'
    openssl genrsa -out host.key 2048 -subj '/C=US/ST=Texas/L=Dallas/CN=localhost'
    openssl req -new -key host.key -out host.csr  -subj '/C=US/ST=Texas/L=Dallas/CN=localhost'
    openssl x509 -req -in host.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out host.crt -days 365

Note the `-subj`s.  You'll want to tweak those for your usage.  When it comes to
our customers, I suspect that the keys we distribute will have either nothing or
placeholders for everything but the CN, which needs to match the hostname.  We
might even do wildcard certs because customers rename servers more often than
you'd expect.

# How to make a TLS echo server

This first example is mostly for debugging.  It allows a single client to
connect, echos back the lines the client sends, and then after the client
disconnects the server shuts down.  Here's the code:


    #!/usr/bin/env perl
    
    use 5.20.0;
    use warnings;
    
    use IO::Socket::SSL;
    $IO::Socket::SSL::DEBUG = 3;
    
    my $server = IO::Socket::SSL->new(
        LocalAddr => '0.0.0.0',
        LocalPort => 9934,
        Listen => 10,
    
        SSL_cert_file => './host.crt',
        SSL_key_file => './host.key',
    ) or die "failed to listen: $!";
    
    my $client = $server->accept or die
        "failed to accept or ssl handshake: $!,$SSL_ERROR";
    
    while (my $line = <$client>) {
       print $client $line
    }

There's not a lot special here except that we use IO::Sockect::SSL which
beautifully hides the difference between a regular socket and an encrypted
socket from the user.

# Testing your new Enterprise Grade Security Echo Server

We all love our telnet for testing our various services, but once you start
encrypting that will not longer be a tenable option (without switching telnets
anyway.)  Fortunately `openssl` already has a tool for this.  All you need to do
is connect with:

    openssl s_client -connect 127.0.0.1:9934

You get a lot of interesting output at the top detailing the encryption info and
then a pretty standard terminal in which you can type to your hearts content,
and then complete the connection with control-d (or in windows who knows.)  (Oh
by the way this all works with windows, I tried it.)

# How to make a TLS echo server, redux

The former is neat, but it can only handle one client at once.  And while our
previous echo server had Enterprise Grade Security we want one that also has
Enterprise Grade Scalability.  The trick is to switch to an async framework.
It's sorta like what Node.js does, except the framework we are using is only a
couple years older.  If we wanted we could use one that's [ten years
older](https://metacpan.org/pod/POE) but this will do fine.

    #!/usr/bin/env perl
    
    use 5.20.0;
    use warnings;
    
    use experimental 'signatures';
    
    use IO::Async::Loop;
    use IO::Async::SSL;
    use IO::Async::SSLStream;
    
    $IO::Socket::SSL::DEBUG = 3;
    
    my $loop = IO::Async::Loop->new;
    
    my $server = $loop->SSL_listen(
       host     => '0.0.0.0',
       socktype => 'stream',
       service  => 9932,
    
       SSL_key_file  => './host.key',
       SSL_cert_file => './host.crt',
    
       on_stream => sub ($stream) {
          $stream->configure(
             on_read => sub ($self, $buffref, $eof) {
                $self->write($$buffref);
                $$buffref = '';
                0
             },
          );
    
          $loop->add( $stream );
       },
    
       on_ssl_error     => sub { die "Cannot negotiate SSL - $_[-1]\n"; },
       on_resolve_error => sub { die "Cannot resolve - $_[1]\n"; },
       on_listen_error  => sub { die "Cannot listen - $_[1]\n"; },
    
       on_listen => sub ($s) {
          warn "listening on: " . $s->sockhost . ':' . $s->sockport . "\n";
       },
    
    );
    
    $loop->run;

Similar to before, the actual special bits here are very few and far between.
We use two new modules, listen with a special `SSL_listen` method, and lastly,
optionally add an error handler for ssl errors.  If you run this you should be
able to connect multiple times to a single server.

And that's it!  You are now armed with the information you need to make secure,
encryped tcp/ip services in Perl!

## Bonus Crytpo Post Script

While I was mulling this stuff over while I was waking up this morning, I
realized that these certificates can solve another one of our longstanding
issues at work.

Currently when a customer buys a server they get a license that allows them to
use a certain number of clients, which we also sell.  The license could easily
be copied from one customer to another customer and still work.  Happily, we can
solve this with our new certificates.  All that we need to do is set the license
count in the certificate request and key.  I chose to use the GN (given
name) field for that because I couldn't find a good set of documentation about
what `openssl x509` supports in there.  As I said, the main thing that matters
for a working cert is the CN.  This is what I did:

    openssl genrsa -out host.key 2048 -subj '/C=US/ST=Texas/L=Dallas/GN={"keypro":250,"total":5000}/CN=localhost'
    openssl req -new -key host.key -out host.csr -subj '/C=US/ST=Texas/L=Dallas/GN={"keypro":250,"total":5000}/CN=localhost'

Now when I inspect the signed certificate with `openssl x509 -in host.crt
-text` I see the following subject: `Subject: C=US, ST=Texas, L=Dallas,
GN={"keypro":250,"total":5000}, CN=localhost`.  So I can easily look at that
programmatically to ensure that those numbers are above the current client
count.  And if the customer fiddles with the numbers to try to increase their
client count (unlikely) the crypto will stop working!
