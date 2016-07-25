---
title: Building Secure UserAgents
date: 2016-07-25T08:06:12
tags: [http, golang, perl, io-async, async, python]
guid: 151C08CC-5058-11E6-B499-9478CBE553EB
---
I have been working on making an HTTP client (also known as a user agent) that
is safe for end-users to control.  I investigated building it in Perl, Python,
asynchronous Perl, and Go.

<!--more-->

During my brief downtime during my paternity leave I've been toying with a new
application.  One of the things this application will do is make web requests on
behalf of users.  There are plenty of examples of applications that do this
already: RSS Readers, anything that has OpenID login support, and things that do
postbacks; when someone sends an SMS to my Twilio number, it hits an endpoint of
my choosing.

Sometimes applications that do these kinds of requests can be vulnerable to
attack.  Last year [Clint Ruoho](https://twitter.com/ruoho) [found a handful of
problems with
Pocket](https://www.gnu.gl/blog/Posts/multiple-vulnerabilities-in-pocket/), a
service Mozilla had recently bundled with Firefox.

The vulnerabilities listed there are only the beginning.  Here are some things
that an attacker could do:

 * Connect to private services, listening only on localhost, assumed to be secure
 * Read from AWS EC2 UserData (which Ruoho did in the example above)
 * Connect to private services running on other servers, that are not normally
   addressible to the outside world

## How do we protect against this?

I suspect that most people protect against this by analyzing the url in the
request.

```
if ($req->url->host eq '127.0.0.1') { ... }
```

For example, today, if you go to
[http://isup.me/127.0.0.1](http://isup.me/127.0.0.1) (or the `localhost`
version) it knows that you are hitting a "non-internet" URL.  I made a domain
(`test.afoolishmanifesto.com`) that resolves to `127.0.0.1` and today, if you go
to
[http://isup.me/test.afoolishmanifesto.com](http://isup.me/test.afoolishmanifesto.com)
it claims that the site is actually up.  And that's just the tip of the iceberg.
We can tell that `isup.me` is running in an AWS-like environment because
[http://isup.me/169.254.169.254](http://isup.me/169.254.169.254) seems to be
"up" from the server's perspective.  There are a non-trivial number of private IP
addresses like this (details in the appendix.)

So at the very least we cannot merely inspect the request, we need to verify the
resolution of the domain.

```
use Socket 'getaddrinfo', 'NI_NUMERICHOST';
my (undef, @addrs) = getaddrinfo($req->uri->host, NI_NUMERICHOST);
my @ips = map {
   my (undef, $ip, $service) = getnameinfo($_->{addr}, NI_NUMERICHOST);
   $ip
} @addrs;
if (grep { $_ eq '127.0.0.1' } @ips) { ... }
```

Even that is insufficient though.  As Ruoho found, many user agents will
automatically handle redirects, so even though the implementor may have done all
of the above (which I think is non-trivial; I left out a lot of error handling
in the second part and none of it correctly handles all of the various IP
masks,) a domain could be validated, and then redirect to an IP that should have
been blocked.

There's also what is sometimes called "tarpits."  Some user agents define
timeouts as "stall" timeouts: they reset when any progress is made.  Consider
the [Slowloris](https://en.wikipedia.org/wiki/Slowloris_(computer_security\))
attack, but implemented at the server side instead of at the client.  Similarly
a DNS server can return long chains of CNAMEs to cause the same kind of problem.
This should be fixed with a global timeout (instead of the more common stall
timeouts referenced before.)

Another vulnerability is unexpected schemata for requests.  Some clients are
smart enough to access `file://`, `ftp://`, etc.  Clients like this must be
defanged such that they only access `http://` and `https://`.  I tend to only
use less magical clients, but support for the above is only a patch away.

## Solutions

The redirect detail makes it clear that the post resolution verification *must*
happen within the user agent.  A solid user agent design should make this
reasonably doable.  The first user agent I'd heard of that tackled these
problems (though likely not the first in existence) is
[LWPx::ParanoidAgent](https://metacpan.org/pod/LWPx::ParanoidAgent), made by Brad Fitzpatrick
almost surely while at LiveJournal to protect against attacks originating from
OpenID servers.
[LWP::UserAgent::Paranoid](https://metacpan.org/pod/LWP::UserAgent::Paranoid)
has since supplanted it with better, more modular code; but the general idea and
usage is the same.

### IO::Async

The problem with these two modules is that they are written in the classic
blocking style.  If you need to make 20 HTTP requests and each takes 0.5s you
just spent 10s.  Newer tools are asynchronous, and so could do 20 HTTP requests
in parallel.  When I do async in Perl [I use IO::Async](/tags/io-async).
In `IO::Async` here is how you could create a safe client:

```
#!/usr/bin/env perl

use 5.24.0;
use warnings;

use Net::Async::HTTP;
use IO::Async::Loop::Epoll;

use Net::Subnet;

# this list is incomplete, see the appendix
my $private = subnet_matcher qw(
   10.0.0.0/8
   172.16.0.0/12
   192.168.0.0/16
   127.0.0.0/8
   169.254.0.0/16
);

my $loop = IO::Async::Loop::Epoll->new;
my $http = Net::Async::HTTP->new(
   timeout => 10,
);

$loop->add( $http );

my ( $response ) = $http->do_request(
   uri => URI->new( shift ),
   on_ready => sub {
      my $sock = $_[0]->read_handle->peerhost;
      if ($private->($sock)) {
        close $sock;
        return Future->fail('Illegal IP') 
      }
      Future->done;
   },
)->get;

print $response->code;
```

If I end up using Perl for this project I'll likely publish a subclass of
naHTTP, or submit a patch, allowing the `on_ready` handler to be set for the
whole class instead of requiring it to be set per request.

### Go

Before I came up with the async Perl option above I had come to the conclusion
that it was be a ton of work to get it working in IO::Async and that I should
just use Go.  I might still use Go, as it's more well supported for code of this
nature.  In Go I was able to basically use the same technique as above:

```
package main

import (
  "errors"
  "fmt"
  "net"
  "net/http"
  "os"
  "time"
)

func main() {
  _, net1, _ := net.ParseCIDR("10.0.0.0/8")
  _, net2, _ := net.ParseCIDR("172.16.0.0/12")
  _, net3, _ := net.ParseCIDR("192.168.0.0/16")
  _, net4, _ := net.ParseCIDR("127.0.0.0/8")
  _, net5, _ := net.ParseCIDR("169.254.0.0/16")
  nets := [](*net.IPNet){net1, net2, net3, net4, net5}

  internalClient := &http.Client{
    Timeout: 10 * time.Second,
    Transport: &http.Transport{
      Dial: func(network, addr string) (net.Conn, error) {
        conn, err := net.Dial(network, addr)

        if err != nil {
          return nil, err
        }

        ipStr, _, err := net.SplitHostPort(conn.RemoteAddr().String())
        // no idea how this could happen
        if err != nil {
          return nil, err
        }

        ip := net.ParseIP(ipStr)
        for _, net := range nets {
          if net.Contains(ip) {
            err := conn.Close()
            if err != nil {
              // wtf
            }
            return nil, errors.New("Illegal IP")
          }
        }

        return conn, nil
      },
    },
  }

  res, err := internalClient.Get(os.Args[1])

  if err != nil {
    fmt.Println(err)
    os.Exit(1)
  }

  fmt.Println(res.Status)
}
```

The above is very similar to the IO::Async version.  Basically we set a global
timeout on the client, and the in the code that connects to a socket, vet the
socket before continuing.

### Python

Perl is not really the "big dog" of dynamic languages anymore, so I figured I'd
document how to do this with a more popular language.  I [mentioned that I've
been toying with Python lately](/posts/python-taking-the-good-with-the-bad/)
already, so it seemed like the most natural choice.  If you know how to do this
with other languages hit me up.

I looked at [urllib2](https://docs.python.org/2/library/urllib2.html),
[urllib3](https://urllib3.readthedocs.io/en/latest/), and
[requests](http://docs.python-requests.org/en/master/), and it seemed like this
kind of feature is impossible in these popular Python libraries without
significant rewriting, duplication, or patches.  I would love to be wrong here, and will
update this post if someone can show me how to do what needs to be done.
Otherwise, if you are using Python and need to do requests on behalf of the
user, best of luck: you may end up writing your own HTTP client.

Also beware that at least urllib2 is helpful enough to provide support for
`file://`.  Make sure that if you are using urllib2, even indirectly, you remove
support for untrusted handlers.

---

As with all security concerns, this is about measuring the cost of failure.
There is no bug free code; the cost of eternal vigilance and perfection are too
high.  The only other option I know of would be to spin up a completely separate
virtual machine isolated as much as possible from the rest of your system, in
it's own DMZ maybe.  This is feasible, but it is certainly a high cost
alternative to something that's not technically difficult.

I was surprised at how easy this was in both Go and IO::Async after striking
upon the post-connection verification idea.  Initially I had assumed that this
was a nearly impossible to solve problem, because I assumed it needed to hook
into DNS resolution directly.

The other big win in this modern day and age is that timeouts are easier to
implement, and tend to be more trustworthy.

I hope this helps!

---

### Appendix: Private Ranges

Please do not assume that this list is complete.  I would love for it to be
up-to-date and trustworthy, but it requires knowing all of the relevant RFC's.
Here are the ones I know about and where they are from, almost all of these were
informed by [RFC6890, Sections
2.2.2](https://tools.ietf.org/html/rfc6890#section-2.2.2) and
[2.2.3](https://tools.ietf.org/html/rfc6890#section-2.2.3).  Note also that some
of these may not be a security vulnerability, like `0.0.0.0/8`, but generally I
doubt that the extra check is going to be expensive enough to matter.

| Address Block        | Relevant RFC                                   |
|----------------------|------------------------------------------------|
| `0.0.0.0/8`          | [RFC1122](https://tools.ietf.org/html/rfc1122#section-3.2.1.3) |
| `10.0.0.0/8`         | [RFC1918](https://tools.ietf.org/html/rfc1918) |
| `100.64.0.0/10`      | [RFC6598](https://tools.ietf.org/html/rfc6598) |
| `127.0.0.0/8`        | [RFC1122](https://tools.ietf.org/html/rfc1122#section-3.2.1.3) |
| `169.254.0.0/16`     | [RFC3927](https://tools.ietf.org/html/rfc3927) |
| `172.16.0.0/12`      | [RFC1918](https://tools.ietf.org/html/rfc1918) |
| `192.0.0.0/24`       | [RFC6890](https://tools.ietf.org/html/rfc6890#section-2.1) |
| `192.0.0.0/29`       | [RFC6333](https://tools.ietf.org/html/rfc6333) |
| `192.0.2.0/24`       | [RFC5737](https://tools.ietf.org/html/rfc5737) |
| `192.88.99.0/24`     | [RFC3068](https://tools.ietf.org/html/rfc3068) |
| `192.168.0.0/16`     | [RFC1918](https://tools.ietf.org/html/rfc1918) |
| `198.18.0.0/15`      | [RFC2544](https://tools.ietf.org/html/rfc2544) |
| `198.51.100.0/24`    | [RFC5737](https://tools.ietf.org/html/rfc5737) |
| `203.0.113.0/24`     | [RFC5737](https://tools.ietf.org/html/rfc5737) |
| `240.0.0.0/4`        | [RFC1112](https://tools.ietf.org/html/rfc1112#section-4) |
| `255.255.255.255/32` | [RFC0919](https://tools.ietf.org/html/rfc0919#section-7) |

The IPv6 ranges have a lot of weird stuff in them.  One block, for example, was
terminated already a couple years ago.  Again, I suspect that for most of them
it's safe to block them and then remove the block later if you find that you
need to (like if you absurdly end up on an IPv6 only network.)

| Address Block      | Relevant RFC                                   |
|--------------------|------------------------------------------------|
| `::1/128`          | [RFC4291](https://tools.ietf.org/html/rfc4291) |
| `::/128`           | [RFC4291](https://tools.ietf.org/html/rfc4291) |
| `64:ff9b::/96`     | [RFC6052](https://tools.ietf.org/html/rfc6052) |
| `::ffff:0:0/96`    | [RFC4291](https://tools.ietf.org/html/rfc4291) |
| `100::/64`         | [RFC6666](https://tools.ietf.org/html/rfc6666) |
| `2001::/23`        | [RFC2928](https://tools.ietf.org/html/rfc2928) |
| `2001::/32`        | [RFC4380](https://tools.ietf.org/html/rfc4380) |
| `2001:2::/48`      | [RFC5180](https://tools.ietf.org/html/rfc5180) |
| `2001:db8::/32`    | [RFC3849](https://tools.ietf.org/html/rfc3849) |
| `2001:10::/28`     | [RFC4843](https://tools.ietf.org/html/rfc4843) |
| `2002::/16`        | [RFC3056](https://tools.ietf.org/html/rfc3056) |
| `fc00::/7`         | [RFC4193](https://tools.ietf.org/html/rfc4193) |
| `fe80::/10`        | [RFC4291](https://tools.ietf.org/html/rfc4291) |

There are likely more.  I think the definitive listings are
[here](https://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.xhtml)
and
[here](https://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xhtml)
respectively, but some of the blocks in those listings don't look private to me.
