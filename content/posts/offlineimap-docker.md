---
title: OfflineIMAP Docker
date: 2015-02-06T09:44:56
tags: ["offlineimap", "perl", "docker", "lxc"]
guid: "https://blog.afoolishmanifesto.com/posts/offlineimap-docker"
---
This needs to be a short one as I don't have a lot of time to write this, but I
just wanted to quickly put out some thoughts about one of the more complex
Docker setups I've made in the past few days.

I use [offlineimap](http://offlineimap.org/) to sync my mail to all of my local
computers.  I find that it paired with [notmuch](http://notmuchmail.org/) is
both faster and better at search than vanilla Gmail, plus at some point I'd like
to cut the cord with Gmail entirely.

I am also planning on moving away from Linode, though I'll have to save why and
all those details for another post.  But my plan is mostly to convert my major
daemons on my Linode to containers and then migrate them to the new host.

I decided to start with the daemons I run on both my laptop and my server, as
that way I can sorta keep an eye on them better.  OfflineIMAP is an interesting
case because it is way more complex than a simple web app, not only because it
needs access to at least one VOLUME, but because, sadly, it tends to need some
life support.

OfflineIMAP tends to leak and sometimes it even chokes up and keeps running
without actually doing anything.  To take care of this I've set up a
[monit](http://mmonit.com/monit/) watchdog to kill it if it uses more than 1G of
ram and I wrote a [tiny perl
script](https://github.com/frioux/offlineimap/blob/4c410f886f8f3b983985c4b5846cb3f7974904a0/bin/cerberus)
to kill it if it is running but hasn't written to it's log in a while.

Because of these things my [OfflineIMAP
Docker](https://github.com/frioux/offlineimap/blob/8b8815b42ff0de72b3e766de9f7f785b3ab57068/Dockerfile)
is more complex than many others, requiring at least three processes running
within.  Honestly though, I think that this is maybe the *best* use case for a
container, as this is a relatively complex setup and having it all work out of
the box is just great.

I am now using this container locally on my laptop instead of my old setup where
OfflineIMAP, monit, and `cerberus` were all running directly as my user.
Initially I planned on making this container and not ever having anyone else use
it, and that may still be what happens, but since it's more complex than other
setups I think it might be sensible for other people to use.  I still need to
write a `README.mdwn` as well remove my own custom config from the image.

Lastly, if anyone is interested, here's how I run it at the moment:

    docker run --rm --name offlineimap        \
       -v         ~/var/mail:/opt/var/mail    \
       -v ~/.offlineimap/etc:/opt/etc         \
       -v ~/.offlineimap/log:/opt/log         \
       -v ~/.offlineimap/index:/opt/var/index \
       offlineimap

The volumes are:

 * `/opt/var/mail`: the actual email all gets synced here
 * `/opt/var/index`: OfflineIMAP's index of all the email is here
 * `/opt/etc`: I just have `netrc` here to define passwords
 * `/opt/log`: this contains logs for OfflineIMAP, `cerberus`, and monit.
   Leaving this unbound is probably fine.

Finally, there is a port exposed (2812) for the monit web interface.  I never
use that but I figured I might at least put it in there.  To be clear, this is
still what I'd call a work in progress; it needs more documentation and could
probably be a bit simpler to use, but I am open to ideas and corrections (except
the one where you tell me I'm running too many processes in the container.  I'll
just delete that comment if I get it.)
