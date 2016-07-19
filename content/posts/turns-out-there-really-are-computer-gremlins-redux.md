---
aliases: ["/archives/1118"]
title: "\"Turns out there really are Computer Gremlins!\" redux"
date: "2009-09-01T01:53:36-05:00"
tags: [mitsi, catalyst, science, perl, win32]
guid: "http://blog.afoolishmanifesto.com/?p=1118"
---
So after some experimenting at work I found out what the culprit of my [previous
post](/archives/1113) was. I still have no idea why some parts of the code
changed, and others didn't. I imagine that part of that had to do with bad
technique (see [Scientific
Method](http://en.wikipedia.org/wiki/Scientific_method).) Anyway, it has
something to do with the extremely sketchtowne
[Catalyst::Restarter::Win32](http://search.cpan.org/perldoc?Catalyst::Restarter::Win32).
I'm not criticizing Rolsky's code here, it's just the nature of using Perl 5 in
Windows. Fork is just one of those things that don't quite work right, so we
must resort to hacks.

I recently contributed a little bit of code to the module to fix a small bug I
noticed; it looks like I'll be contributing more.

Also, if you don't believe me, here's the way to prove it to yourself that at
least something is wrong: open up the process manager or whatever it's called in
windows, and watch the processes, sorted by name. Use the restarter and change a
file so that it will restart the dev server. Note that a new process (perl.exe)
starts, but the old one never goes away. Do this a few times till it becomes
obvious. Then kill the server. Note that the other processes never go away. This
seems to be something to do with the "totally hack-tastic" \_fork\_and\_start.
It never kills the current process? Or something? I need to do more research and
playing around. Hopefully I can get it to stop confusing me.

In other news, if you are on Windows, you probably should not use the Restarter
till it gets fixed.
