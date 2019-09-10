---
aliases: ["/archives/1921"]
title: "Use Docker to test your code! (and a subtle announcement)"
date: "2014-02-22T22:34:51-06:00"
tags: [frew-warez, dbix-class-helpers, docker, toolsmith]
guid: "http://blog.afoolishmanifesto.com/?p=1921"
---
Lately I've been working on code to [unify disparate SQL into a small set of
abstractions](https://github.com/frioux/DBIx-Class-Helpers/commits/dt). There is
a lot to do, and while testing generated SQL is nice, actually running that SQL
and examining the results is the best way to test the code.

In the past I would have installed a bunch of database engines locally. More
recently I'dve used [Travis](http://travis-ci.org/frioux) [to test against a
bunch of
databases.](https://github.com/frioux/DBIx-Introspector/commit/95524d7808f7305598d368af3022727ef985c010)
I still think that's a good idea, but pushing to CI to test your code sucks. CI
should be for those who forgot to test their code, basically.

So I finally knuckled down and set up a neat little Docker thing to test against
PostgreSQL and MySQL. Using [a
tutorial](http://docs.docker.io/en/latest/examples/postgresql_service/) I wrote
[ a Dockerfile to make a blank PostgreSQL
database](https://github.com/frioux/DBIx-Class-Helpers/blob/dt/Dockerfile) and I
found [a mysql one](https://index.docker.io/u/orchardup/mysql/) that I could use
out of the box.

So now, instead of running my tests with "prove -lr t", I can do
"[dockerprove](https://github.com/frioux/DBIx-Class-Helpers/blob/dt/dockerprove)
-lr t", and it will do the same thing, and run against MySQL and PostgreSQL!
Awesome!

At some point I'll do the same thing for [DBIx::Introspector](/archives/1847),
[DBIx::Class](https://metacpan.org/pod/distribution/DBIx-Class/lib/DBIx/Class.pod),
and maybe others. I'd like to make a more generic tool but I'm struggling with
how to do that. Ideas are welcome!
