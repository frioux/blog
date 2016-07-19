---
title: UCSPI
date: 2016-02-10T09:42:34
tags: [frew-warez, ucspi, cgi, psgi, unix, pipes]
guid: "https://blog.afoolishmanifesto.com/posts/ucspi"
---
While [CGI](https://www.ietf.org/rfc/rfc3875) is a fairly well established, if
aging, protocol, [UCSPI](http://cr.yp.to/proto/ucspi.txt) seems fairly obscure.
I suspect that UCSPI may see a resurgence as finally with
[systemd](https://www.freedesktop.org/software/systemd/man/systemd.socket.html)
projects will have a reason to support running in such a mode.  But here I go,
burying the lede.

## CGI Refresher

Just as a way of illustrating by example, I think that I should explain
(hopefully only by way of reminder) how CGI works.  Basically a server (usually
Apache, IIS, or lately, nginx) waits for a client to connect, and when it does,
it parses the request and all of the request headers.  They look something like
this:

```
POST /upload?test=false HTTP/1.1
User-Agent: blog/0.0.1
Content-Type: text/plain
Content-Length: 4

frew
```

And then various parts of the above go into environment variables; for example
`test=false` would become the value of `QUERY_STRING`.  Then the body (in this
example, `frew`) would be written to the standard input of the CGI script.
While this seems a little fiddly compared to some of the more modern APIs and
frameworks, it is nice because you don't even need a language that supports
sockets.  You can even write a simple script with a shell!

### ugh

The response is *almost* just whatever the script prints to standard out, though
perversely there is a small bit of modification that happens, so the server has
to parse some of the output, which seems like a huge oversight in the
specification.  Specifically, instead of allowing the script to print:

```
HTTP/1.1 200 OK
Content-Type: text/html
...
```

It instead must write:

```
Status: 200 OK
Content-Type: text/html
...
```

and is even allowed to write:

```
Content-Type: text/html
Status: 200 OK
...
```

but the server still must translate that to:

```
HTTP/1.1 200 OK
Content-Type: text/html
...
```

This means that if the server works correctly it may need to buffer an unbound
(by the spec) amount of headers before it gets to the `Status` header.  Ah the
joys of implementing a CGI server.

## What is UCSPI

UCSPI stands for Unix Client Server Program Interface.  Basically the way it
works is that you have a tool that opens a socket and waits for new connections.
When it gets a new connection it spins up a new process, setting up pipes
between standard input and standard output of that process and to the input and
output of the socket.

Here's an interesting thing that I have needed to do that I could not do without
UCSPI.  Because each connection in the UCSPI model ends up being a separate set
of processes, the connection can restart the parent UCSPI worker and still
finish it's connection.

This means that, for example, I can have a push to github automatically update
my running server, without any weird side mechanisms like a second updater
service or worse, a cronjob.  I just do a `git fetch` and `git reset --hard
@{u}`, and the next time a client connects it will be running the new code.

[Here is how I did
that](https://github.com/frioux/Lizard-Brain/blob/master/www/cgi-bin/impulse-www#L57-L86).
At some point I expect to make the automatic updater more reliable and generic.

Another sorta nice thing, though this is very much a tradeoff, is that the
process that has the listening port is very small (2M on my machine) compared
to, say, an actual Plack server (which is an order of magnitude bigger.)  On the
other hand, if your actual cgi script has a lot of dependencies it can take a
long time to start, so this may not be a good long term solution.

Note that there are problems of course.  Aside from the increased cost of
spinning up a new server, you also have to be careful to avoid printing to
standard out.  If you do you are almost ensured to print your whatever before
any headers which ends up being an invalid response.  On the other hand you can
do a bunch of weird old school type stuff like `chdir`ing in a script and not
worry about global state changes.

## Aside: Plack under CGI

Because my web apps thus far have been implemented using PSGI, an abstraction of
HTTP, they can run under their own servers or under CGI directly.  I only really
needed to do one of two things to make my application run under CGI:

 * Set the shebang to `#!/usr/bin/env plackup`
 * Or in my case, [just use `plackup` directly as the commandline](https://github.com/frioux/Lizard-Brain/blob/master/services/lizard-brain-www/run#L6)

I hope you found this interesting!
