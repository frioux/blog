---
title: "Docker Simplifications: Bugtowne City"
date: 2015-04-03T07:26:06
tags: [frew-warez, docker, bugs]
guid: "https://blog.afoolishmanifesto.com/posts/docker-simplifications-bugtowne-city"
---
I have a [fairly complex docker
container](https://github.com/frioux/offlineimap/tree/1710b4f2522eb9d49dc995dbfc1881d5690c019e)
that I run on all of my machines.  I would like to simplify it in a number of
ways and for some reason I decided that it would be interesting to start on that
project last night.  The simplifications that I want to do are as follows:

 * Have all three daemons log to `/proc/1/fd/1`; this would remove one of my
   volumes and let me view logs with just `docker logs offlineimap`

 * Start docker with `docker run ... -u 1000` instead of doing a sudo inside of
   the container.  To some extent this should simplify things by removing a
   silly wrapper process, but also it should make things a little bit more
   secure.

 * Generate all config files at startup time so that parts of them can be based
   on env vars; this *might* allow me to remove the .netrc volume.

 * Finally, I based my image off of phusion, which is based off of ubuntu.  This
   means that my image is 320M; non-trivial!  It pulls in perl, python, and
   python3.  If I rewrite my ~30 line perl program in python and don't use
   python3, with a docker image based on alpine my container could easily shrink
   to 50M.  The main thing missing there is the phusion init script that reaps
   zombie processes.  Someone should rewrite that in Go or something.

So sadly, I had really weird problems with writing to init's STDOUT.  I know it
*can* work:

_Terminal 1_:

    $ docker run --rm --name tmp --privileged -it debian bash
    root@38655f5d1154:/#

_Terminal 2_:

    $ docker exec -it tmp bash
    root@38655f5d1154:/# echo "woo" > /proc/1/fd/1

_Terminal 1_:
    root@38655f5d1154:/# woo

But when I tried to use it from my container I got a lot of permission problems,
likely because the processes were running as uid 1000.  So *then* I figured that
I'd switch to the second issue to consolidate the uid usage within the container
and come back to the logging thing.

Note also that I used `--privileged` above.  I suspect that this is due to some
AppArmor stuff.  I've already had to modify my AppArmor profile for Docker; I
will track down the real modification so I don't have to use `--privileged`, but
this got me going faster for now.

Unfortunately I ran into other weird issues with that!  I got this error running
with `-u 1000`:

    *** Killing all processes...
    Traceback (most recent call last):
      File "/sbin/my_init", line 334, in <module>
        main(args)
      File "/sbin/my_init", line 252, in main
        import_envvars(False, False)
      File "/sbin/my_init", line 61, in import_envvars
        for envfile in listdir("/etc/container_environment"):
      File "/sbin/my_init", line 49, in listdir
        return sorted(os.listdir(path))
    PermissionError: [Errno 13] Permission denied: '/etc/container_environment'

So I figured I needed to fix the perms of that directory, so I added this to the RUN statements inside the Dockerfile:

    RUN chown 1000:1000 /etc/container_environment -R

I can then do a `docker run -itu 1000 mycontainer bash` and I see this:

    user@1d0d69fe032e:/$ ls -dlh /etc/container_environment
    drwx------ 2 user user 4.0K Apr  2 23:32 /etc/container_environment
    user@1d0d69fe032e:/$ ls -lh /etc/container_environment
    ls: cannot open directory /etc/container_environment: Permission denied

I don't see why I wouldn't be able to open that directory...  Also, if I start without the `-u 1000` everything looks fine:

    root@54d1f1699037:/# ls -lh /etc/container_environment
    total 12K
    -rw-r--r-- 1 user user  2 Jan 20 10:08 INITRD
    -rw-r--r-- 1 user user 11 Jan 20 10:09 LANG
    -rw-r--r-- 1 user user 11 Jan 20 10:09 LC_CTYPE

The maintainers of phusion told me that this is likely a kernel bug, which is
*great.*  So my plan next is to see if I can boot up a newer kernel and still
reproduce the problem.  I *might* be able to ditch phusion, as I want to switch
to alpine anyway, but I wanted to make a single change at a time.

Anyway, all of the above are things that *should* work.  If I get them to work
I'll make other posts detailing how.
