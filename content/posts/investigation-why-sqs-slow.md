---
title: "Investigation: Why is SQS so slow?"
date: 2017-08-20T08:04:55
tags: [ziprecruiter, investigation, furl, curl, http, perl, aws, sqs ]
guid: 148DE95E-8057-11E7-9203-ACD27A8F3B27
---
Recently I spent time figuring out why sending items to our message queue often
took absurdly long.  I am really pleased with both my solutions and my methodogy,
maybe you will be too.

<!--more-->

[At ZipRecruiter][zr] we use [AWS SQS][sqs] for our message queue.  As I suspect
is typical, we use message queues to avoid talking to external services directly
from web workers.  The reason, which I have [written obliquely about
before][reaper], is that external services inevitably get slow, go down, or
whatever, and end up causing your web workers to be completely saturated,
blocking on said external service.  I've seen it happen with SMTP, REST APIs,
and even foundational backends like databases.  When possible, not using the
backing service from the web worker is the best option, and adding something to
a message queue that will allow a batch process to talk to the service is a good
way to make that happen.

So we recently did some work to migrate a large chunk of SMTP traffic to SQS.
When the work was done an incredible number of requests started taking a really
long time (22s.)  One morning the CTO, Craig Ogg, asked me if I'd be willing to
take a look.

I've worked on our SQS code before; specifically when I needed to [add IAM EC2
role support][iam].  Our SQS module is straightforward; there is a single
`_request` method and a boatload of wrappers for each API call.  The request
call is simple: it builds up the HTTP::Request object, signs it, pulls it back
apart, and hands it off to the UserAgent to perform.  The only reason we don't
give the request object directly to a UserAgent is this code is written to be
as fast as possible so skips some abstraction for performance.

All that said: after a careful reading of our code I saw no obvious problems.
Here is the timeline of interesting bits:

### Logging

The SQS library is generic enough to go to CPAN, so stuff like logging was
delegated to callers.  I decided to add logging directly to the library so that
even if a caller ignored a class of exceptions we would still know.  After the
logging was live for less than ten hours we had some (previously unknown)
details.  Exactly three errors:

 * Broken Pipe
 * Connection timed out
 * Connection reset by peer

They all came from [a single callsite in Furl, the UserAgent the code
uses][callsite].

### TCP Tuning

A couple of the errors above could be explained by NAT forgetting about
long-lived sockets.  The reason we have to go through NAT is boring and
pointless, but we successfully reproduced the problem by sending an SQS message,
sleeping six minutes, and then trying to send another message.  The fix was to
tell the kernel to send TCP Keepalive packets more often:

``` sh
sysctl -w net.ipv4.tcp_keepalive_time=250
sysctl -w net.ipv4.tcp_keepalive_intvl=75
```

And to ensure that the TCP_KEEPALIVE flag was on for the sockets returned by the
`connect` method in `Furl::HTTP`:

``` perl
use Socket qw(SOL_SOCKET SO_KEEPALIVE);

setsockopt $sock, SOL_SOCKET, SO_KEEPALIVE, 1
  if $sock;
```

This fixed the problem we reproduced, but made no clear difference on our
servers in either staging or production.

### Instrumentation

The amount of exceptions logged was incredible and I was astounded that
ElasticSearch didn't crash.  I wrote a little bit of code to translate known
exceptions to stats, which are much lighter weight.  At the same time I added
some other useful stats: duration of request, retry count, etc.  The added stats
made it clear that we were getting network exceptions and additionally an
astounding amount of library level retries; the main caller of the SQS library
retries for certain exceptions.

---

At this point Aaron had read relevant kernel source and was of the opinion that
Furl was just doing something wrong in [its `select(2)` loop][furlsel].  We
tried one quick thing (checking errors with `getsockopt` after connect) in case
Furl not checking was masking a real problem, but that made no difference.  The
next easy option was to try another HTTP UserAgent.

The main reason I was willing to make such a drastic change at this point is
that the HTTP Keepalive implementation Furl provides is barely sufficent to even
work, let alone be called correct.  Instead of maintaining a pool, checking
timers, etc, it simply has a "pool" of the one last used connection and reuses
it forever, assuming the other side will close it eventually.

## Curl

[Years ago I read an HTTP UserAgent benchmark that mje published][benchmark].
The details may no longer be super accurate, but honestly I just wanted to avoid
anything notably slower.  Using the benchmark I decided to go with Curl via
[`Net::Curl`][netcurl].  I was implementing this for SQS, so I only needed to
support `GET`s, which meant building a client compatible with `Furl::HTTP` would
be pretty simple.  Here is the (slightly trimmed) code:

``` perl
package ZR::Curl;

use 5.20.0;
use warnings;

use experimental 'signatures';

use Net::Curl::Easy qw(/^CURLOPT_/ /^CURLINFO_/ /^CURLPROTO_HTTP/ );

use namespace::clean;

use parent 'Net::Curl::Easy';

sub new ($class) {
  my $self = $class->SUPER::new();

  $self->setopt( CURLOPT_USERAGENT, "ZR::Curl/v0.1" );
  $self->setopt( CURLOPT_PROTOCOLS, CURLPROTO_HTTP | CURLPROTO_HTTPS );
  $self->setopt( CURLOPT_TCP_KEEPALIVE, 1 );
  $self->setopt( CURLOPT_TIMEOUT, 2 );

  return $self;
}

sub get ($self, $uri, $headers = [] ) {
  my ($body, $head) = ( '', '' );

  $self->setopt( CURLOPT_FILE, \$body );
  $self->setopt( CURLOPT_HEADERDATA, \$head );
  $self->setopt( CURLOPT_URL, $uri );
  $self->setopt( CURLOPT_HTTPHEADER, $headers );

  $self->perform;

  my ($minor, $code, $msg, $ret_headers) =
    ($head =~ m/HTTP\/1\.(.) ([0-9]{3}) (.*?)\r\n(.*)$/s);

  my @headers = map { split /:\s/, $_, 2 } split /\r\n/, $ret_headers;

  return ($minor, $code, $msg, \@headers, $body);
}

1;
```

I have more to say about the above, but swapping in the above client completely
fixed our problems.  We reduced our timeout to something more reasonable (it was
22s) but *also* the occurance of timeouts is much less common, presumably
because Curl closes expired sockets instead of trying to use them anyway.

### Things I Like About Curl

Ignoring the better handling of HTTP Keepalive, there are still many things I
like about Curl.  The main one is that errors are [clearly enumerated][curlerr].
In some languages this may be the norm, but in Perl it's frustratingly rare.
With Curl you can (and indeed I did) do some research on errors and plan ahead
of time for different failures.  Typically in Perl I end up doing this by
running the code and seeing what happens.

Fundamentally Curl works by allowing you to set up your request, do it, and
examine the results.  Most UserAgents expose all kinds of methods which allow
you to do various kinds of requests, build URIs, manipulate one or more headers,
etc.  Curl exposes a little over a dozen methods, a handful of which you'd never
use in perl anyway.  The interface for me is basically:

 * `setopt` to prepare the request and other features
 * `perform` to actually do the request

Because the model is so simple, the documentation is too.  [The list of the many,
many options is here.][setopt]

On top of the excellent documentation there are lots of features that do not
exist in most UserAgents:

 * [specify which interface to use](https://curl.haxx.se/libcurl/c/CURLOPT_INTERFACE.html)
 * [set a minimum speed limit](https://curl.haxx.se/libcurl/c/CURLOPT_LOW_SPEED_LIMIT.html)
 * [debug nearly all levels of the protocol: HTTP, TLS, TCP](https://curl.haxx.se/libcurl/c/CURLOPT_DEBUGFUNCTION.html)

Note that those all have examples.  Despite the fact that they are in C they
still make it fairly obvious (at least to me) how you can use them.  I
especially think that the debug function is useful.  Nowadays because so much is
HTTPS I can't trivially `strace` a process to see what headers it is sending,
but the debug function gives me just what I need.

---

I doubt that Curl will become the one true UserAgent at ZipRecruiter; but I
definitely see swapping it in for Furl, which we use in many places.  I suspect
Furl is fine for HTTP, but once you use HTTPS you will likely want persistent
sockets, and Furl barely supports this.  One of my coworkers pointed out the
fundamental difference is this:

 * [Curl (like most UserAgents) retries on TCP level errors][curlre]
 * [Furl surfaces these errors to the user][furlre]

There are always difficult tradeoffs to make; Curl chose the more user-friendly
tradeoff, and Furl chose the simpler to implement tradeoff.  Unfortunately I
think requiring all callers to know the various possible TCP errors that the
UserAgent can encounter is just too much of a burden.

---

(The following includes affiliate links.)

I don't have a lot of great recommendations for further research here.  A lot of
my ideas depended on having a good logging and statistics setup, which is worth
entire series of posts.  I do think that <a target="_blank"
href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=a7610c779654105cddeb8ee1773e5984">The
SRE Book</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" /> has plenty to say about this stuff and is well worth the read.

[furlre]: https://github.com/tokuhirom/Furl/issues/98
[curlre]: https://github.com/curl/curl/blob/4ebe24dfea0c9f93cbfaee66b52a0670e66124d8/lib/transfer.c#L1852
[benchmark]: http://www.martin-evans.me.uk/node/169#results
[furlsel]: https://metacpan.org/source/TOKUHIROM/Furl-3.11/lib/Furl/HTTP.pm#L864-882
[setopt]: https://curl.haxx.se/libcurl/c/curl_easy_setopt.html
[zr]: https://www.ziprecruiter.com/hiring/technology
[sqs]: https://aws.amazon.com/sqs/
[reaper]: /posts/reap-slow-and-bloated-plack-workers/
[iam]: /posts/aws-iam-at-ziprecruiter/
[callsite]: https://metacpan.org/source/TOKUHIROM/Furl-3.05/lib/Furl/HTTP.pm#L381
[netcurl]: https://metacpan.org/pod/Net::Curl
[curlerr]: https://curl.haxx.se/libcurl/c/libcurl-errors.html
