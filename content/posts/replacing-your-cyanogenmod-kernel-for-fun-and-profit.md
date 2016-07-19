---
title: How to replace your CyanogenMod Kernel for Fun and Profit
date: 2014-08-28T15:37:55
tags: [frew-warez, "cyanogenmod", "t0lte", "ftrace", "perf"]
guid: "https://blog.afoolishmanifesto.com/posts/replace-cyanogenmod-kernel-fun-profit"
---
I've recently been on a journey of discovery with respect to
"observability" tools. I'm sure many other Linux users have felt the
lust after DTrace that first the relatively obscure Solaris (and kids)
and now the totally non-obscure OSX users have.  After watching various
presentations about DTrace features I've kept my ear open for features
that are similar on Linux.  [Last month I posted about `strace` and
`sysdig`](https://blog.afoolishmanifesto.com/posts/a-few-of-my-favorite-tools/).
Both `strace` and `sysdig` are pretty coarse compared to what can be done
with DTrace, though both are pretty great.

Some time last week I was reading [Julia Evans'](http://jvns.ca) [Blog post
about `perf`](http://jvns.ca/blog/2014/05/13/profiling-with-perf/).
I followed her bread crumbs to [Brendan Gregg's](http://www.brendangregg.com) [Perf
Page](http://www.brendangregg.com/perf.html).  I went on to read myriad
posts and slides by Gregg that made me hungry to learn more about `perf`
and eventaully `ftrace`.  See more links in the bibliography.

I can't say much about either `perf` or `ftrace` yet, but I can say that the
place where I get the most inexplicable performance results are on [my
phone](http://wiki.cyanogenmod.org/w/T0lte_Info).  So after reading all those
posts about a low-level observability tool that should work on nearly any vesion
of Linux, I set out to try it out on my phone.

## Building custom kernels for CyanogenMod

My phone runs on [CyanogenMod](http://www.cyanogenmod.org/), which has
a fairly well put together set of documents on how to [build your own
ROM](http://wiki.cyanogenmod.org/w/Build_for_t0lte) or even [replacement
kernel](http://wiki.cyanogenmod.org/w/Doc:_integrated_kernel_building).
I followed the instructions linked, but had to deviate in a handful of places.
I'll list the variations and notes for myself here.

First off, once you get to the step where you `source build/envsetup.sh`, you
need to be running `bash`.  I use `zsh` normally so this didn't work for me for
a while for no obvious reason.

Instead of manually extracting the proprietary blobs, someone on irc mentioned
that an easier way was to put the following XML in
`.repo/local_manifests/roomservice.xml`:

    <project name="TheMuppets/proprietary_vendor_samsung" path="vendor/samsung" remote="github" />

As alluded to above, all I really wanted to do was tweak the kernel config to
enable `CONFIG_FTRACE`.  The way I did that was to enter the directory the
kernel source is in: `~/android/system/kernel/samsung/smdk4412`, then copied the
default config for my phone (`arch/arm/configs/cyanogenmod_t0lte_defconfig`) to
`.config`.  After that I could run `make menuconfig` as normal.  For ease of
examination I forked the kernel repo and stored the distinct changes I made to
the config [here](https://github.com/frioux/android_kernel_samsung_smdk4412).

After making tweaks with `make menuconfig`, I copied `.config` back to
`arch/arm/configs/cyanogenmod_t0lte_defconfig`.  To build the boot image I ran
the following set of commands (which I put in a bash script:)

    #!/bin/bash

    set -e

    cd ~/android/system
    make clean
    cd kernel/samsung/smdk4412
    make mrproper
    cd ~/android/system
    make -j8 bootimage

Note that I do not use `mka`.  Some of the android build manuals recommend
`mka`, but I found it was much less reliable than regular `make`, so I abandoned
it.

## Installing the custom kernel on Samsung devices

This was not only the scariest, but most frustrating part of the whole process.
The CyanogenMod docs mention using `installboot`, but for reasons I have yet to
figure out that didn't work for me.  I suspect because I didn't build a whole
ROM but just the kernel.  Anyway PsychoI3oy on #cyanogenmod-dev mentioned that
[heimdall](http://glassechidna.com.au/heimdall/) would be the easiest way
to install the ROM.  Unlike Ye Olde Odin, heimdall is open source and thus
is happily in the Ubuntu repos.  So I just installed heimdall (`sudo apt-get
install heimdall-flash`), booted my phone into download mode (HOLD VolDown +
Power + Home, then VolUp when you see the prompt), download the PITfile (it's
sorta like a partition table? `sudo heimdall download-pit --file t0lte.pit`),
boot into download mode again, and upload the boot image: `sudo heimdall flash
--pit ~/t0lte.pit --BOOT ~/android/system/out/target/product/t0lte/boot.img`.
Note that the string `BOOT` can be found by looking at `heimdall print-pit --file
t0lte.pit`

After installing the boot image, you still need to install the related modules.
In my case everything except for wifi worked fine without the modules, but
still, you need wifi.  So after boot, you enable debug mode by clicking
'Settings -> About Phone -> Build Number' a million times, then enable adb, then
run the following commands:

    adb root
    adb remount
    for i in $OUT/system/lib/modules/*;
    do
        adb push $i /system/lib/modules/
    done
    adb shell chmod 644 /system/lib/modules/*

## Profit!

After installing the new kernel, I fired up the Terminal Emulator and ran a few
commands to see some basic tracing in action just so I could know it's working:

    su
    cd /sys/kernel/debug/tracing
    echo function > current_tracer
    cat trace
    # tracer: function
    #
    #           TASK-PID    CPU#    TIMESTAMP  FUNCTION
    #              | |       |          |         |
                  GC-7351  [003]  2168.905602: get_pageblock_flags_group <-free_hot_cold_page
                  GC-7351  [003]  2168.905604: free_hot_cold_page <-__pagevec_free
                  GC-7351  [003]  2168.905605: free_pages_prepare <-free_hot_cold_page
                  GC-7351  [003]  2168.905606: get_pageblock_flags_group <-free_hot_cold_page
                  GC-7351  [003]  2168.905608: free_hot_cold_page <-__pagevec_free
                  GC-7351  [003]  2168.905609: free_pages_prepare <-free_hot_cold_page
                  GC-7351  [003]  2168.905611: get_pageblock_flags_group <-free_hot_cold_page
                  GC-7351  [003]  2168.905612: free_hot_cold_page <-__pagevec_free
                  GC-7351  [003]  2168.905613: free_pages_prepare <-free_hot_cold_page
                  GC-7351  [003]  2168.905615: get_pageblock_flags_group <-free_hot_cold_page
    [...]

    echo function_graph > current_tracer
    cat trace
    # tracer: function_graph
    #
    #     TIME        CPU  DURATION                  FUNCTION CALLS
    #      |          |     |   |                     |   |   |   |
     1)   1.792 us    |                            } /* _raw_spin_unlock_irqrestore */
     1) + 13.792 us   |                          } /* samsung_gpiolib_4bit_input */
     1) + 31.041 us   |                        } /* gpio_direction_input */
     1) + 34.292 us   |                      } /* i2c_gpio_setscl_dir */
     1)               |                      i2c_gpio_getscl() {
     1)               |                        __gpio_get_value() {
     1)   2.209 us    |                          s3c_gpiolib_get();
     1)   5.709 us    |                        }
     1)   9.250 us    |                      }
     1) + 54.000 us   |                    } /* sclhi */
     1)               |                    i2c_gpio_getsda() {
     1)               |                      __gpio_get_value() {
     1)   2.291 us    |                        s3c_gpiolib_get();
     1)   5.542 us    |                      }
     1)   9.083 us    |                    }
     1)               |                    i2c_gpio_setscl_dir() {
     1)               |                      gpio_direction_output() {
     1)               |                        _raw_spin_lock_irqsave() {
     1)   1.917 us    |                          __raw_spin_lock_irqsave();
     1)   5.167 us    |                        }
     1)   1.750 us    |                        gpio_ensure_requested();
    [...]

    echo nop > current_tracer

## Problems

Unsurprisngly the above tracing slows the phone down noticably.  `function` does a
little, `function_graph` does a *lot*.  You can filter the traced functions
though so that it's not as hardcore.  I'll leave that for another post, but a
lot can be done to hone in on what you really care about.

The other frustrating thing is that Android for my phone is pinned to version
3.0 of the Linux kernel.  While 3.0 works and can do the tracing I want to do,
there are some really nice additions to tracing in the kernel since then.
[Apparently some builds of
Android](https://android.googlesource.com/kernel/common.git/+refs) have newer
kernels.  Maybe something to keep an eye out for?

## Close

And that's it!  None of the stuff I did in this post was actually that
difficult, but figuring out what to do when I was stuck got frustrating at
times.  I'm really excited to work on ftrace stuff to figure out what's actually
going on on my phone and learn more about the Linux kernel.

Hope you enjoyed it!

**Note:** I intend to update the bibliography over time as I find more resources
that help me with ftrace, so consider checking back.

## Bibliography

[Julia Evans' Post](http://jvns.ca/blog/2014/05/13/profiling-with-perf/) which
started this whole thing

### Steve Rostedt's articles on LWN about Ftrace (Rostedt is the author of Ftrace)

* [Debugging the kernel using Ftrace - part 1](http://lwn.net/Articles/365835/)
* [Debugging the kernel using Ftrace - part 2](http://lwn.net/Articles/366796/)
* [Secrets of the Ftrace function tracer](http://lwn.net/Articles/370423/) - Some
  really great stuff in here about how to use "raw" Ftrace
* [trace-cmd: A front-end for Ftrace](https://lwn.net/Articles/410200/) - Really
  interesting post about `trace-cmd`; shows what can be done with Ftrace to make
  it more user friendly

### Brendan Gregg's Stuff

* [`perf` page](http://www.brendangregg.com/perf.html)
* [`perf-tools` page](https://github.com/brendangregg/perf-tools) - a set of
  lightweight "frontends" to perf\_events and Ftrace.
* [Linux Performance Page](http://www.brendangregg.com/linuxperf.html) - this
  page has a TON of resources linked from it. If you want to learn a ton,
  consider starting here and really grokking it all
