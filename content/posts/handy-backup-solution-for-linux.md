---
aliases: ["/archives/1459"]
title: "Handy Backup Solution for Linux"
date: "2010-11-27T01:04:53-06:00"
tags: [mitsi, backup, bup, git, linux, lvm]
guid: "http://blog.afoolishmanifesto.com/?p=1459"
---
At [work](http://mitsi.com/) I was recently given an external hard drive for backup purposes. Most of my coworkers are using some windows program to get the job done, but of course I can't use that since I am using Linux. I spoke with ribasushi, who knows all kinds of crazy weird things about administering a Linux machine, and he told me that the core to any good backup solution for Linux is [LVM](http://en.wikipedia.org/wiki/Logical_Volume_Manager_%28Linux%29). He uses it for no hassle MySQL backups too, so it's not limited to full system backups like I did.

# LVM

The high level explanation is basically that LVM abstracts away hardware to an extent that the actual used partitions span multiple harddrives or multiple partitions or whatever. You don't really have to worry about it. The layers introduced by LVM are

- physical volumes (PV) - what would normally be considered partitions; actual partitions on the harddrive
- volume groups (VG) - a collection of one or more physical volumes
- logical volumes (LV) - the new, kernel level partitions which are partitions of a volume group

Thanks to the extra abstraction that LVM gives us, we can get atomic snapshots of any LV. Additionally, I don't use this regularly but we will when we set this up, you can migrate a live LV from one PV to another PV, as long as the VG that the LV is on is contained on both PV's. What a mouthful! Ok, let's just get started :-)

## Set up the LVM

The first thing I did was format the external usb to be entirely a Linux LVM drive. I used cfdisk for that. The partition type for Linux LVM is 8E.

The rest of this is a bunch of commands, so I'll do all of them with comments.

    # install lvm2
    sudo apt-get install lvm2
    # format the partition we made in the last step
    pvcreate /dev/sdc1
    # create the VG named vg0 comprising /dev/sdc1
    vgcreate vg0 /dev/sdc1
    # create two logical volumes, both on vg0 and of size 10 gigs, with names root and home
    lvcreate -L10G -n root vg0
    lvcreate -L10G -n home vg0
    # format the partitions on the new LV's
    mkfs -t ext4 -m 1 -v /dev/vg0/root
    mkfs -t ext4 -m 1 -v /dev/vg0/home
    # edit the fstab to include the new partitions and create mountpoints
    # you could also do this without fstab and just use mount
    vi /etc/fstab
    mkdir /tmproot /tmphome
    # mount partitions
    mount /tmproot
    mount /tmphome
    # the following will copy all of the files from one partition to another,
    # without descending into other partitions, and preserving ownership etc
    rsync --progress --numeric-ids -AXHpoghax -- / /tmproot
    rsync --progress --numeric-ids -AXHpoghax -- /home/ /tmphome

At this point you need to fiddle with grub and fstab to get your computer to boot into the new PVs. This part isn't exactly hard, but I found it to be a hassle. Make sure to have a boot CD handy so that if you mess it up you can boot into the cd, mount the pv, chroot into that, and fix stuff from there. If you didn't already know the commands to do what I just said I think the basic dance is:

    sudo apt-get install lvm2
    # enable access to vg0
    vgchange vg0 -Ay
    mkdir /foo
    mount /dev/vg0/root /foo
    mount -o bind /dev /foo/dev
    mount -o bind /proc /foo/proc
    chroot /foo

Now here's the crazy part:

    # format original harddrive with swap, boot, and the rest LVM
    cfdisk /dev/sda
    # format and populate the new boot partition
    mkfs -t ext2 -m 1 -v /dev/sda2
    mount /dev/sda2 /tmpboot
    rsync --progress --numeric-ids -AXHpoghax -- /boot/ /tmpboot
    # format the new PV partition
    pvcreate /dev/sda3
    # extend your VG named vg0 to be on /dev/sda3
    vgextend vg0 /dev/sda3
    # move the root (and presumably home) you are running on from the usb drive to the internal harddrive!
    # (note how fast and low cpu it is; this is almost 100% dma)
    pvmove /dev/sdc1 /dev/sda3
    # change the logical volume such that it will only span the drive it now resides on
    # this is not required obviously but I did it because my internal drive is a 10K RPM drive
    lvchange -Cy /dev/vg0/root
    lvchange -Cy /dev/vg0/home

# bup

[bup](https://github.com/apenwarr/bup) is a program to make backups. It uses the git format but not the git porcelain, so it is even more performant. I won't go into all the awesome things about bup. If you want to read about those, [click the link](https://github.com/apenwarr/bup). Before you use bup you need to install it; the [instructions are here]().

The first thing you need to do is create a partition for your backup to reside on; you don't want to back up root to itself. Also, the default bup location is ~/.bup, which I think is silly. We'll take care of both of those things here:

    # create and format 300 Gig partition on /dev/vg0/backups, contiguous on the external drive
    lvcreate -L300G -Cy --name backups vg0 /dev/sdc3
    mkfs -t ext4 -m 1 -v /dev/vg0/backups
    # add /dev/vg0/backups to /etc/fstab for /var/back
    vi /etc/fstab
    mount /var/back
    # create and initialize the bup dir
    mkdir /var/back/bup
    BUP_DIR=/var/back/bup bup_init

Lastly you may want to use the following tiny script that I run daily to create the backups:

    #!/usr/bin/bash

    export DATE=$(date +%s)
    # /var/back is an LV mounted on a separate external drive (sdc)
    export BUP_DIR=/var/back/bup
    # the first (and only) argument should be either "root" or "home" as those are
    # the names of my LV's
    export NAME=$1

    # create a snapshot of the given partition, with 500M reserved for possible CoW
    # after experimenting I found that 200M was safe, but clearly 500M is safer,
    # so I stuck with that
    lvcreate --size 500M -Cy --snapshot --name tmp_back_${NAME}_$DATE /dev/vg0/$NAME /dev/sdc1
    mount /dev/vg0/tmp_back_${NAME}_$DATE /tmp/back
    # bup does not maintain ownership or mtimes, so we tar everything before putting it in bup
    tar -cvf - /tmp/back | bup split -n $NAME -vv
    umount /tmp/back
    # this step is surprisingly important, if you don't clear out old snapshots
    # your system will slow to a crawl
    lvremove /dev/vg0/tmp_back_${NAME}_$DATE -f

I run that with cron once a day at 6AM. At some point I hope to set up something else to profile the space usage and maybe make a handy graph of it. Anyway, hope you enjoyed this and find it useful!

---

If you're interested in learning more about Git, I cannot recommend
<a  href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=73f85964b6ab98ea870583701b7e77aa">Pro Git</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
enough.  It's an excellent book that will explain how to use Git day-to-day, how
to do more unusual things like set up Git hosting, and underlying data
structures that will make the model that is Git make more sense.
