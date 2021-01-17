---
title: steambox 2021 Edition
date: 2021-01-16T15:44:44
tags: [ "perl", "steam" ]
guid: b3a580ab-8da8-452b-9ed4-0e1c192141bd
---
I made my steambox start up faster and fixed a race condition with Perl.

<!--more-->

[Last week I replaced SteamOS with Ubuntu 20.04](https://twitter.com/frioux/status/1347986465649610753).
Overall the process was a significant improvement, but startup went from taking
(just a guess) about 1 minute to 1m30s.  This was *just* annoying enough that I decided
to do some optimization.

For starters, I used `systemd-analyze critical-chain`:

```
$ systemd-analyze critical-chain
The time when unit became active or started is printed after the "@" character.
The time the unit took to start is printed after the "+" character.
                                                     
graphical.target @29.207s        
└─multi-user.target @29.207s            
  └─kerneloops.service @29.057s +149ms
    └─network-online.target @29.032s                 
      └─NetworkManager-wait-online.service @19.647s +9.384s
        └─NetworkManager.service @12.449s +7.196s
          └─dbus.service @12.447s                  
            └─basic.target @12.377s                                                                       
              └─sockets.target @12.377s                                                                   
                └─snapd.socket @12.376s +637us
                  └─sysinit.target @12.288s
                    └─snapd.apparmor.service @11.931s +357ms
                      └─apparmor.service @10.857s +1.073s
                        └─local-fs.target @10.856s
                          └─boot-efi.mount @10.745s +110ms
                            └─systemd-fsck@dev-disk-by\x2duuid-CE5A\x2d9A09.service @10.522s +185ms
                              └─dev-disk-by\x2duuid-CE5A\x2d9A09.device @10.522s
```

From the above I noted that a full third of the startup was blocking on the
network.  You can disable the `NetworkManager-wait-online.service` and you'll
start up possibly without access to the internet.  I did that (and a couple more rounds) and was
still annoyed at how long it would take to get up and running.

The next step (of course) was to replace my harddrive with an SSD.  I got (affliate link) a 
<a target="_blank" href="https://www.amazon.com/gp/product/B078DPCY3T/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B078DPCY3T&linkCode=as2&tag=afoolishmanif-20&linkId=3b16bba2c884b97944e6706c51b13220">Samsung 860 EVO</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B078DPCY3T" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
Since I had installed Ubuntu only a week ago just reinstalled again.

After this bootup was way faster.  The desktop is ready in less than 20s and
steam is ready for me to get going by 30s.  There's a catch though.  Now, the
system is so fast that Xorg starts *before* the nvidia module is loaded!  This
means that out of the box, when my desktop is shown it's 640x480 and with no
acceleration.  Oops.

I tried some obvious things (declaring the nvidia persistence service as a dep
for the display manager, declaring the nvidia's pci device as a dep for the
display manager) and neither worked.  The driver was still not loaded.  So I wrote some perl:

```perl
#!/usr/bin/perl

use strict;

my $child_pid = open(my $dmesg, "-|", "dmesg -w")
  or die "Can't start dmesg: $!";

while (<$dmesg>) {
    if (m/nvidia-modeset:/) {
        print "saw nvidia modeset line, we're ready!\n";
        print $_;
        kill 'INT', $child_pid;
        exit 0;
    }
}
```

Then I wired that in as a service:

```ini
[Unit]
Description=nvidia ready

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nvidia-ready

[Install]
WantedBy=display-manager.service
```

The last line defines it as a prerequisite for the display manager.  With this
in place the display manager will not start until nvidia's driver writes
something about modes to the kernel ring buffer.  Here's the output of
`journalctl` showing this in action:

```
Jan 16 15:05:39 steamos kernel: nvidia-modeset: Loading NVIDIA Kernel Mode Setting Driver for UNIX platforms  460.32.03  Sun Dec 27 18:51:11 UTC 2020
Jan 16 15:05:39 steamos nvidia-ready[574]: saw nvidia modeset line, we're ready!
Jan 16 15:05:39 steamos nvidia-ready[574]: [    5.504909] nvidia-modeset: Loading NVIDIA Kernel Mode Setting Driver for UNIX platforms  460.32.03  Sun Dec 27 18:51:11 UTC 2020
Jan 16 15:05:39 steamos systemd[1]: tmp-sanity\x2dmountpoint\x2d816689313.mount: Succeeded.
Jan 16 15:05:39 steamos systemd[1]: nvidia-ready.service: Succeeded.
Jan 16 15:05:39 steamos systemd[1]: Finished nvidia ready.
Jan 16 15:05:39 steamos systemd[1]: Starting Light Display Manager...
```

Now it works!  I'd be happy if it were even less than 30s but this is fast
enough that it tends to be ready as soon as the TV is fully on.

---

(Affiliate links below.)

Recently <a target="_blank"
href="https://www.amazon.com/gp/product/0136820158/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136820158&linkCode=as2&tag=afoolishmanif-20&linkId=6a3d6adabe2966efd8a3b13205d9e0c9">Brendan
Gregg's Systems Performance</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136820158"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" /> got its second edition released.  [He wrote about it
here](http://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html).
I am hoping to get a copy myself soon.  I loved the first edition and think the
second will be even more useful.

At the end of 2019 I read
<a target="_blank"
href="https://www.amazon.com/gp/product/0136554822/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136554822&linkCode=as2&tag=afoolishmanif-20&linkId=9b27a122197fb141065f7276321e4c43">BPF
Performance Tools</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136554822"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.
It was one of my favorite tech books I read in the past five years.  Not only
did I learn how to (almost) trivially see deeply inside of how my computer is
working, but I learned how *that* works via the excellent detail Gregg added in
each chapter.  Amazing stuff.

