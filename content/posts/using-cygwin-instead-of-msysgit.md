---
aliases: ["/archives/1634"]
title: "Using Cygwin instead of msysGit"
date: "2011-08-22T03:18:29-05:00"
tags: ["cywgin", "git", "msysgit", "screen", "windows", "zsh"]
guid: "http://blog.afoolishmanifesto.com/?p=1634"
---
Our [main product](http://lynxguide.com/) at work is a Windows product. The reasons are complicated, but the main reason is that that is what our customers seem to want. What this means is that I do some of my development on a virtual machine. For a long time I was just using [msysGit](https://code.google.com/p/msysgit/). msysGit goes a long way; you have a real bash console, a bunch of standard unix commands, and very good windows integration. On the other hand that's about all you get. After reading [his blog post](http://blog.cachemiss.com/articles/Using%20msysGit%20with%20Cygwin.pod) I spoke with Caelum about getting zsh working with msysgit and he said it was probably just better to use [cygwin](http://www.cygwin.com/)...

There are a handful of reasons to use cygwin, but the main reason I did was for zsh. If you want to follow my path just [get the cywin installer](http://cygwin.com/install.html) and install at least git and ssh. If you are like me you'll also want to install zsh.

A couple other things that are nice to install are screen and mintty. Screen is just great in general and I use it constantly. I should probably do a blog post on just that at some point. mintty solves the constant bother in windows that the console emulator is horrible and can't be resized sensibly.

Make sure to follow the instructions in [Caelum's blog post](http://blog.cachemiss.com/articles/Using%20msysGit%20with%20Cygwin.pod) as they are very helpful overall.

cygwin is certainly not perfect though. First off, it is noticeably slower than the already slow msysgit, which is very disappointing. On top of that the home directory is not the same as the standard windows home directory, which is just obnoxious. For some reason with msysgit I could run the vim installed in program files from the command line, but with cygwin I can't. I even tried making a symlink but those don't work with cygwin, even though they are supported by ntfs.

Either way, it's nice to have zsh and screen and a real terminal. Hopefully this helps someone out there :-)
