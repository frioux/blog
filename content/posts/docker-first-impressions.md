---
title: "Docker: First Impressions"
date: 2015-01-28T21:19:10
tags: [mitsi, "docker", "lxc", "perl", "carton"]
guid: "https://blog.afoolishmanifesto.com/posts/docker-first-impressions"
---
Today I deployed my first Docker based application.  I just wanted to get down
some basic thoughts about how it went down etc.  Nearly all the hosted (ie not
turnkey) apps that we have at work have some form of git-based deployment
strategy.  (*Aside: Don't say something silly to yourself like "git is not a
deployment strategy!"  It totally is, you just don't like the tradeoffs.*)  Each
one has it's own special snowflake of push vs. pull, scripted with perl vs
scripted with shell, how or even if it automates database migrations; I could go
on.

So I was tired of a million different ways to do it, so what did I do?  I came
up with another!  Well, I didn't come up with it obviously, but I decided I
wanted to try Docker out as a deployment strategy.  I've used [Docker for
testing](/posts/use-docker-to-test-your-code-and-a-subtle-announcement/) for
nearly a year at this point and have really enjoyed it, but I didn't have a clue
what it would be like for deployment.

Here are some of the things that I discovered:

 1. Docker without the registry is really not like git.  What I mean by this is
    that while there are layers inside the container (or is it layers in the
    image?) those layers are not used efficiently in a peer to peer setting.
    While a user can run `docker save myapp | ssh foo@bar docker load -` and it
    will defintely work, it will push the entire thing instead of just the new
    layers.  It would be great if docker worked more in this use case as it is
    nice when you are just getting started.

 2. Setup was not magically easy.  While it's true that I was able to just build
    directly off the official Perl 5.20.1 image, that image is relatively large
    ([which I'm working on](https://github.com/Perl/docker-perl/pull/8)).  On
    top of that, installing the latest Perl version is trivial with
    [perlbrew](http://perlbrew.pl/) and
    [plenv](https://github.com/tokuhirom/plenv).  What's the most frustrating is
    the deps.  Initially I just put a `RUN cpanm --installdeps .` in the
    `Dockerfile`.  But that meant that if I ever needed to rebuild my image
    (hint: you will need to rebuild your image) it would need to install all the
    deps again.  This app is super small, it literally has 10 direct deps, but
    it takes a long time even with the testing turned off.  I decided to go with
    [carton](https://metacpan.org/pod/distribution/Carton/script/carton) to
    handle the deps.  It's actually been pretty nice, but I'm not totally
    comfortable with it yet.

 3. What about development?  For an application that you actually work on, I
    don't really see how Docker, or at least using the same Dockerfile, makes
    any sense at all.  My Docker image (or is it the container?) has the actual
    project embedded inside of it; there's no way it would make sense to use the
    same image for dev; you'd wanna use a volume for the actual code, but for
    deployment that would be terrible.  At the very least there is FINALLY a
    plan to allow specifying a Dockerfile, so we could have a Dockerfile.live
    and a Dockerfile.dev.

 4. LXC may be effectively metal, but Docker is a serious resource user.  This
    is likely just me being silly, but I might as well put it down.  When I
    provision a Linux server I usually starve it's resources, if only to show my
    coworkers how much better Linux is in every way than Windows (which nearly
    everything at work runs on.)  What that meant for this project was that it
    started with a meager 256M of RAM.  While the OS itself takes something like
    50M of RAM, and the app is something like 12M, at least while loading up the
    images, Docker spikes to 400M of RAM.  At some point it triggered an OOM so
    bad that there was a kernel panic.  I don't really fault Docker for this in
    the least, but when creating a server that will host a single container, at
    least consider some basic extra stuff for the host.

 5. Automation Rules!  What I am the most excited about is that I created a
    Dockerfile that would automate [the installation of the MS ODBC
    Driver](/posts/install-and-configure-the-ms-odbc-driver-on-debian/).  The
    only slow part of that is that testing DBI is slow, aside from that it's
    really fast and **so** nice to have automated.  I will likely publish it,
    though I don't see how I could legally add it to the index.

Overall, I suspect that this will be a win in the long run, but only after I set
up a private registry and at least do this on one other project (so that this is
not it's own special snowflake like all the rest.)  I also think that setting up
a development Dockerfile will be a huge win, once it's an actual option.

In another post in the future I plan on contrasting Docker and Vagrant, since
one of my coworkers really likes Vagrant.  Not to actually go into detail there,
but I think Vagrant is fine and definitely has it's place, but there are a
number of drawbacks that I think make Docker superior.
