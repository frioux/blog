---
title: Detecting who used the EC2 metadata server with BCC
date: 2018-06-21T21:46:03
tags: [ iam, perl, bcc, instrumentation, linux ]
guid: b60f09b4-d993-4c2e-a79f-ba7e8cade0c4
---

Recently at work we had a minor incident involving exhaustion of the EC2
metadata server on some of our hosts.  I was able to get enough detail to
delegate the rest to a team to fix the issue.

<!--more-->

AWS EC2 has this thing called the metadata server.  As far as the user can tell
it runs inside the hypervisor and is exposed directly to your host via an http
server at 169.254.169.254.  You can use `curl(1)` to get basic info about your
server, like what instance type it is, for example.

The metadata server *also* hosts per instance authentication data.  Your hosts
reach out to the metadata server, get some auth material, and use that auth
material for each request that interacts with AWS.

This means that if you somehow *exhaust* the metadata server processes will not
be able to authenticate with AWS.  I haven't dove in deeply to understand if
it's a rate limit or a concurrency limit, but I can say that in any case we ran
into it.

## Detecting the Bad Actor

Initially I was going to use `tcpdump(1)` to figure out what was happening, but
as far as I know it does not expose process ids, and even if it did I suspect
you'd have to do a dump per process.

My go to for "stuff lower level than `strace(1)` is
[BCC](https://github.com/iovisor/bcc).  BCC is a Linux-ish DTrace; and I say
that in every sense.  Just like Zones are a single, standalone thing in Solaris,
and containers are a combination of two or more complex Linux features, BCC
takes advantage of two or more compilers, kprobes, uprobes, and surely more.  I
don't know everything there is to know about BCC, but generally speaking I don't
have to because there is a nice suite of tools to give you what you want.

I loaded up the [tool
listing](https://github.com/iovisor/bcc/tree/master/tools), searched for `tcp`,
and the second tool is `tcpconnect`.  Here's a basic example:

``` bash
$ sudo /usr/share/bcc/tools/tcpconnect
PID    COMM         IP SADDR            DADDR            DPORT
15100  curl         4  10.1.18.45       192.30.255.112   80  
15110  curl         4  10.1.18.45       216.58.192.14    80  
```

In the actual incident though I only wanted `169.254.169.254`, so I changed my
command to:

``` bash
$ sudo /usr/share/bcc/tools/tcpconnect | grep -F 169.254.169.254
```

I stopped getting any output at all, but from experience I know that's because
that `tcpconnect` is now buffering.  [Dominus recently had a blog post that
discusses this](https://blog.plover.com/Unix/stdio-buffering.html), including
solutions, so I tweaked the command to be:

``` bash
$ sudo stdbuf -oL /usr/share/bcc/tools/tcpconnect |
       stdbuf -oL grep -F 169.254.169.254
```

I should figure out if I can just do something like `exec stdbuf -oL $SHELL`,
but anyway the above works.  So now the output will be something like this,
printed as the connections are made:

```
15100  curl         4  10.1.18.45       169.254.169.254    80
15110  curl         4  10.1.18.45       169.254.169.254    80
```

## Getting More Detail

This is great, but our processes set their name and the COMM field above
truncates it.  Side note: if you are running a fork based service, *set your
process name to something relevant*.  It's really useful and basically free.

In Perl you can set it by simply doing `$0 = "..."`.

My next step was to add a dash of Perl to grab the full process name.  Here's
what I ended up with:

``` bash
$ sudo stdbuf -oL /usr/share/bcc/tools/tcpconnect |
    stdbuf -oL grep -F 169.254.169.254 |
    stdbuf -oL perl -pae'$F[1] = `cat /proc/$F[0]/cmdline`;
      $_ = join("\t", scalar(localtime), @F) . "\n"'
```

Perl's `-a` flag makes it act a bit like `awk(1)`, in that it tokenizes input on
whitespace and populates `@F` with your data.  So `$F[0]` is the pid, `$F[1]`
becomes the untruncated name.  I also added the timestamp. Here's a (sanitized) example of the output:


```
Wed Jun 20 14:21:33 2018        perform-queued-tasks-manager send-welcome-email      4       10.0.1.186      169.254.169.254 80                          
Wed Jun 20 14:21:33 2018        perform-queued-tasks-manager send-welcome-email      4       10.0.1.186      169.254.169.254 80                          
Wed Jun 20 14:21:33 2018        perform-queued-tasks-manager send-welcome-email      4       10.0.1.186      169.254.169.254 80                                  
Wed Jun 20 14:21:33 2018        perform-queued-tasks-manager send-welcome-email      4       10.0.1.186      169.254.169.254 80                                  
Wed Jun 20 14:21:33 2018        perform-queued-tasks-manager send-welcome-email      4       10.0.1.186      169.254.169.254 80   
```

---

I've wanted to use low level Linux instrumentation in anger for years, and the
fact that I did without thinking much about it is delightful.  Thankfully I
don't need this kind of information very often, but having it available is
great.

---

I don't think there is a book about BCC (yet.)  I think the closest thing would
be Brendan Gregg's
<a target="_blank" href="https://www.amazon.com/gp/product/0133390098/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0133390098&linkCode=as2&tag=afoolishmanif-20&linkId=20dafcbf13582f9fe5049d9fde39dd79">Systems Performance</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0133390098" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's got a ton of detail and a good helping of methodology that will help with
the kind of stuff that one tends to use BCC for.

BCC is very much implemented atop Linux, so it is worth knowing Linux and Unix
if you ever need to do something more advanced than use an out-of-the-box tool.
I suggest reading
<a target="_blank" href="https://www.amazon.com/gp/product/1593272200/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593272200&linkCode=as2&tag=afoolishmanif-20&linkId=afca82c8c1ccaa7f97bd25b0c8e6a062">The Linux Programming Interface</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593272200" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
for that kind of information.
