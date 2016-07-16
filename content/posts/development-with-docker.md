---
title: Development with Docker
date: 2016-07-18T07:40:11
tags: [docker]
guid: 60A9D0D4-4942-11E6-9F4E-4F8755BD8D92
---
I have not seen a lot of great examples of how to use Docker as a developer.
There are tons of examples of how to build images; how to use existing images;
etc. Writing code that will end up running inside of a container and moreso
writing code that gets compiled, debugged, and developed in a container is a bit
tricker.  This post dives into my personal usage of containers for development.
I don't know if this is normal or even good, but I can definitely vouch that it
works.

<!--more-->

First off, I am developing with an interpreted langauge most of the time.  I
still think these issues apply with compiled languages but they are easier to
ignore and sweep under the rug.  In this post I'll show I create layered images
for developing a simple web service in Perl.  It could be Ruby or Python of
course, I just know Perl the best so I'm using it for the examples.

Here is a simple Makefile to build the images:

```
api-image:
	docker build -f ./Dockerfile.api -t pw/api .

db-image:
	exit 1

perl-base-image:
	docker build -f ./Dockerfile.perl-base -t pw/perl-base .
```

I can build three images, one of which (db) is not-yet-defined but planned.

# base

Here is `Dockerfile.perl-base`

```
FROM alpine:3.4

ADD cpanfile /root/cpanfile
RUN \
   apk add --update build-base wget perl perl-dev && \
   cpan App::cpm && \
   cd /root && \
   cpm -n --installdeps .
```

I use [Alpine](http://alpinelinux.org/) as the underlying image for my
containers if possible, because it is almost as lightweight as it gets.  Beware
though, if you use it you may run into problems because it uses
[musl](http://www.musl-libc.org/) instead of
[glibc](https://www.gnu.org/software/libc/).  I have only run into issues twice
though, and one was [a bug in the host
kernel](http://www.openwall.com/lists/musl/2016/06/08/4).

Next I add the cpanfile to the image.  I could probably do something weird like
build the Dockerfile and directly add the lines from the cpanfile to the
Dockerfile, but that doesn't seem worth the effort to me.

Finally I, in a single layer (hence the `&& \`'s:)

 * Install Perl (which is a very recent 5.22)
 * Install [cpm](https://metacpan.org/pod/App::cpm)
 * Install the dependencies of the application

Basically what the above gives you is a cache layer where most of your
dependencies are installed.  This can hugely speed development while you are
adding dependencies to the next layer.  This methodology is also useful at
deployment time, because new builds of the codebase need not rebuild the entire
base image, but instead just one or more layers on top.  The base image in this
example is over 400 megs, and that's with Alpine; if it were Ubuntu it would
likely be over 700.  The point is you don't want to have to push that whole base
layer to production for a spelling fix.

# api

Here is `Dockerfile.api`

```
FROM pw/perl-base

ADD . /opt/api
WORKDIR /opt/api

RUN cpm -n --installdeps .
```

Sometimes I'll add extra bits to the RUN directive.  Like currently in the
project I'm working on it's:

```
RUN apk add perl-posix-strftime-compiler && cpanm --installdeps .
```

Because I needed Alpine's
[patched](http://git.alpinelinux.org/cgit/aports/tree/main/perl-posix-strftime-compiler/musl-fix.patch?h=3.4-stable)
[POSIX::Strftime::Compiler](https://metacpan.org/pod/POSIX::strftime::Compiler).
That will at some point be baked into the lower layer.

## Refinements

If your project is sufficiently large, it is also likely worth it to break `api`
into two layers.  One called, for example, `staging`, which is almost exactly
the same as the `base` layer, but it's `FROM` is your `base`.  `api` then
becomes just the `ADD` and `WORKDIR` directives.

Another pretty cool refinement is to use `docker run` to build images.  If you
have special build requirements this is super handy.  A couple reasons why one
might need this would include needing to run multiple programs at once during
the build, or needing to mount code that will not be added directly to an image.
Here's how it's done:

```
FROM=pw/stage2
TMP_DIR=$(mktemp -td tmp.$1.XXXXXXXX)

# start container
docker run -d \
   --name $TMPNAME \
   --volume $TMP_DIR:/tmp \
   $FROM /sbin/init

# build
docker exec $TMPNAME build --my /code

# save to pw/api
docker commit -m "build --my /code" $TMPNAME pw/api
docker rm -f $TMPNAME
sudo rm -rf $TMP_DIR
```

Both of these refinements are arguably gross, but they really help speed
development and solve problems, so until there are better ways, I'm happy with
them.

# Running

The above is a useful workflow for building your images, but that does not answer
how the containers are used during development.  There are a couple pieces to
the answer there.  First is this little script, which I placed in
`maint/dev-api`:

```
#!/bin/dash

exec docker run --rm \
                --link some-postgres:db \
                --publish 5000:5000 \
                --user "$(id -u)" \
                --volume "$(pwd):/opt/api" \
                pw/api "$@"
```

The `--link` and `--publish` directives are sorta ghetto.  At some point I'll
make the script dispatch based on the arguments and only link or publish if
needed.

If possible I always use a non-root user, hence the `--user` directive.  It is
probably silly, but you almost never need root anyway, so you might as well not
give it to the container.  This has the nice side effect of ensuring that any
files created from the container in a volume have the right owner.

The `--volume` should be clear: it replaces the code you built into the image
with the code that's on your laptop, without requiring a rebuilt image.

The other part to make this all work are a few more directives in the Makefile:

```
prepare-migrations:
	maint/dev-api perl -Ilib bin/update-database

run-migrations:
	docker run --rm --link some-postgres:db pw/api perl -Ilib bin/update-database 1

run-db:
	docker run --name some-postgres -d postgres

rm-db:
	docker rm -f some-postgres
```

I haven't gotten around to creating a database container; I'm just using the
official docker one for now.  I will eventually replicate it for my application
in a more lightweight fashion, but this helps me get up and get going.  I
wouldn't have made the `rm-db` directive except the docker tab completion seems
to be pretty terrible, but the make tab completion is perfect.

`run-migrations` is a little weird.  It requires a complete rebuild just to
update some DDL; but I believe it will be worth it in the long term.  I suspect
that I'll be able to push the api container to some host, `run-migrations`, and
it be done, instead of needing a checkout of the code on the host.

# Linking

One of the details above that I haven't gone into is the `--link` directive.
This sets up the container so that it has access to the other container, with
some environment variables set for the exposed ports in the linked container.
On the face of it, this is just a way to connect two containers.  Here is how
I'm connecting from a script that deploys database code:

```
#!/usr/bin/env perl

use 5.22.0;
use warnings;

use DBIx::RetryConnect 'Pg';
use PW::Schema;
my $s = PW::Schema->connect(
 "dbi:Pg:dbname=postgres;host=$ENV{DB_PORT_5432_TCP_ADDR}",
 'postgres',
 $ENV{DB_ENV_POSTGRES_PASSWORD},
);
```

Notice that I simply use some environment variables that follow a fairly
obvious pattern (though it can be referenced by linking a container running
`env` more easily than the docs.)

One other subtle detail is the use of
[DBIx::RetryConnect](https://metacpan.org/pod/DBIx::RetryConnect).  With
containers it is much more common to start all of your containers concurrently,
versus with typical init systems or even virtual machines.  This means baking
retries into your applications, as it stands today, is a requirement.  Either
that or you add stupid sleep statements and hope nothing ever gets run on an
overloaded machine.

## Refinements

Linking is pretty cool.  For those who haven't investigated this space much,
linking seems like some cool magic "thing."  Linking is actually a builtin
*service discovery* method for allowing containers to know about each other.  But
linking has a major drawback: to link containers in docker you have to start the
containers serially.  This is because links are resolved at container creation
time.  Worse yet you can't change the environment variables of a running
program, so links cannot be updated.  This is at the very least a hassle because
it introduces a synthetic, implied ordering to the starting of containers.

You can resolve the ordering problem with `docker network`:

```
# run API container
docker run -d \
   --name $NAME \
   pw/api www

# add to network
docker network create pw
docker network connect pw $NAME

# run db container
docker run --name db -d postgres
docker network connect pw db
```

Order no longer matters and you have much more flexibility with how you do
discovery.  But now you need to make a decision about discovery, as the
environment variables will no longer be magically set for you.  I strongly
believe that this is where anyone doing anything moderately serious will end up
anyway.  The serialization of startup is just too finicky to be seriously
considered.

I haven't done enough with service discovery myself to recommend any path
forward, but knowing the name to search for should give you plenty of rope.

---

I hope the ideas and examples above help anyone who is grappling with how to
use Docker.  Any criticisms or other ideas are welcome.
