---
title: Using Tailscale for Authentication
date: 2022-06-09T08:35:13
tags: [ "frew-warez", "tailscale", "golang" ]
guid: 2da70b08-7b48-453d-8dd4-93e33c486489
---

I recently used [Tailscale](https://tailscale.com/) to add an authenticated portion to a public website,
hosted via [Fly.io](https://fly.io/).

<!--more-->

Historically I’ve avoided putting stuff on the internet that needs
authentication. I know how to manage passwords and [hash
them](/posts/hash-your-passwords-finale/) but passwords are a drag for myself
as a user. Better would be to use OAuth or whatever and log in via Google but
those things are so complicated they take all the fun out of whatever I’m
building.

Enter Tailscale.  [Tailscale](https://tailscale.com/) is a VPN that works by
creating a mesh of all of your devices.  Tailscale has a deceptive amount of
functionality but in general my favorite bit of functionality is that I can
securely access devices behind a NAT without touching any router or firewall
settings.  [I’ve written about using Tailscale for that kind of use
case.](/posts/stateless-notes/)

For a side project at work I created [a service called
shortlinks](https://github.com/frioux/shortlinks), at many companies this is
apparently called golinks.  The project basically lets you store shortlinks for
a chosen short version. You might have /pto link to the official PTO policy.
Then you set it up such that the domain of the app is short and in your DNS
search path, and thus you can type something like `go/pto` and end up where you
want to go.

The intention at work is to have it run behind our VPN and grant write access
to all users.  Lots of people seem to want to add strict ownership to links so
they can only be modified by their creator. I’d rather make bad changes easy to
revert and avoid all the hassle of a complicated authorization system. My
shortlinks application tracks each change to a given link; you can see when it
was changed and what each old version pointed to. 

I wanted to run a copy for myself but shortlinks only accessible to myself are
boring and write access to the world is clearly a non starter.  Here’s another
place Tailscale helps: I set up my server to listen on two interfaces, [the
Public (read only)
side](https://github.com/frioux/shortlinks/blob/328d78f/shortlinks/httpserver.go#L35)
([implementation
here](https://github.com/frioux/shortlinks/blob/328d78f/shortlinks/handler_public_index.go))
[listens on all
interfaces](https://github.com/frioux/shortlinks/blob/739a3e4/main.go#L78), and
[the private side listens on the Tailscale IP
only](https://github.com/frioux/shortlinks/blob/739a3e4/main.go#L81).

That’s pretty good, but once you have Tailscale you have identity, so I took
advantage of that and added [a little bit of
code](https://github.com/frioux/shortlinks/blob/739a3e42b49e63f0e90e4c311c7cf9c99f02bfa5/auth/tailscaleauth/tailscaleauth.go)
to actually figure out who made changes and include their identity in the audit
history.  With all of these pieces in place we can talk about how this looks in
general: [`frewlynx.fly.dev`](https://frewlinks.fly.dev/) points at the public
instance, anyone can see it.  `admin.frewlynx.frew.co` points it the Tailscale
IP. It only works for users authenticated to my tailnet. I could have a
different name but this name is chosen for this blog post to demonstrate the
general pattern.  I can then share that node with other friends who use
Tailscale and they can get write access to the application.

Okay but if I want to host this on the internet I need a publicly addressable
location. While I can host Tailscale stuff on a raspberrypi in a closet at
home, that doesn’t make the public part work. Here’s where we discuss Fly.io.

Fly.io has a free tier like lots of cloud services these days, but typically
storage isn’t free. Even when storage is free, the storage is only accessible
via some API (DynamoDB and S3, for example.) Fly.io gives you a free 3 gigs of
general purpose storage. This means I can just use SQLite for my instance of
shortlinks.  On top of that I store the Tailscale identity material in that
storage, which means fresh deploys of the app continue to have a stable IP
address and MagicDNS name.

I followed [the official Tailscale instructions for integrating with
Fly.io](https://tailscale.com/kb/1132/flydotio/) and seasoned to taste.  Here's
my Dockerfile:

```
FROM golang:alpine as builder
     WORKDIR /shortlinks
     COPY . .
     RUN apk update
     RUN apk add build-base gcc
     RUN go build -o sl
     # this just lets me get the library version I used
     # for tailscale in a later stage.
     RUN go version -m ./sl   | \
           grep tailscale     |  \
           awk '{ print $3 }' |   \
           sed s/v// > tsversion

FROM alpine:latest as tailscale
     COPY --from=builder /shortlinks/tsversion tsversion
     # and here we get the matching version
     RUN wget "https://pkgs.tailscale.com/stable/tailscale_$(cat tsversion)_amd64.tgz" -O ts.tgz && \
           tar xzf ts.tgz --strip-components=1

FROM alpine:latest
     RUN apk update && apk add ca-certificates iptables ip6tables && rm -rf /var/cache/apk/*

     COPY start.sh /bin/start.sh
     COPY --from=builder /shortlinks/start.sh /shortlinks/start.sh
     COPY --from=builder /shortlinks/sl /bin/shortlinks
     COPY --from=tailscale /tailscaled /bin/tailscaled
     COPY --from=tailscale /tailscale /bin/tailscale
     RUN mkdir -p /var/run/tailscale /var/cache/tailscale /var/lib/tailscale

     CMD ["/bin/start.sh"]
```

Here's the `start.sh`:

```bash
#!/bin/sh

tailscaled --state=/data/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock &
tailscale up --authkey=${TAILSCALE_AUTHKEY} --hostname=frewlinks
shortlinks --listen $(tailscale ip --1):80 --public-listen :8080 --db file:/data/db.db
```

My fly.toml has a bunch of stuff in it, not all of which is used, so here's the part
that's relevant to this post:

```toml
[mounts]
source="frewlinks_data"
destination="/data"
```

This means our database and Tailscale state is persistent across deploys.

---

After fitting these components together, I have a read only public website with
an authenticated private half, that works more easily than logging in via OAuth
or whatever, with zero of the hassle.  I want to emphasize that this is just one
of the many things that Tailscale does for me.  I get direct encrypted access to
all of my stuff.  Even while writing this blog post I set up subnet routing so I
could reach devices that cannot run Tailscale directly (think IoT.)  It's great.

---

(Affiliate links below.)

If you're interested in using Go, like I did for this post, to do some basic
network programming, a fun option is [Black Hat
Go](https://www.amazon.com/Black-Hat-Go-Programming-Pentesters/dp/1593278659?&linkCode=ll1&tag=afoolishmanif-20&linkId=62f8fc8ebbaa37150adadb861a8cc9de&language=en_US&ref_=as_li_ss_tl).
I read it a while ago and found it a fun overview of the space.

I've mentioned it before and I'll probably mention it again, the original [Go
Programming
Language](https://www.amazon.com/Programming-Language-Addison-Wesley-Professional-Computing/dp/0134190440?&linkCode=ll1&tag=afoolishmanif-20&linkId=40f2814af1ef74f373d27fd1d7da746e&language=en_US&ref_=as_li_ss_tl)
was a great option for me when I was learning Go.  I know some people felt it
was too technical for them, but for me it gave me the foundation I was looking
for.
