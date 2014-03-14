---
aliases: ["/archives/101"]
title: "Splits, panes, and tiles"
date: "2009-02-05T23:30:48-06:00"
tags: ["screen", "user-interface", "vim"]
guid: "http://blog.afoolishmanifesto.com/?p=101"
---
How do you manage numerous windows when you have a gigantic viewing space? Or what if you have a really tiny viewing space? At work I have two 22" monitors and maximization is just too ridiculous to consider and it is typically a huge waste of space.

I decided that if I am going to have a lot of windows open I should look into something that can help me tile things correctly. A lot of the tiling solutions out there are all or nothing. Once you use them you can no longer have overlapping windows, you must use their strange layouts, and if you don't know their hotkeys you can't use your computer. I decided that for now, none of those are an option.

Instead I found a program called [GridMove](http://www.jgpaiva.donationcoders.com/gridmove.html). It allows you to have numerous grids to snap windows into. You can achieve "snapping" with mouse interaction or with various hotkeys. Overall I have been extremely happy with it.

[![Work Splits](/wp-content/uploads/2009/02/splitss-300x93.png "Work Splits")](/wp-content/uploads/2009/02/splitss.png)

I even wrote a tiny [AHK](http://www.autohotkey.com/) script to open programs for one of my projects and place them in the right place.

    #o::

       Run "C:Documents and SettingsfrewMy DocumentsCodeaircraft_ducting"
       WinWait, "C:Documents and SettingsfrewMy DocumentsCodeaircraft_ducting",,3
       sendinput,#6
       Run "C:Program FilesApache Software FoundationApache2.2logserror.log"
       WinWait, BareTail,,3
       sendinput,#5
       Run "C:Program FilesVimvim72gvim.exe" -c "call ACDRI()" -S C:Documents and SettingsfrewMy DocumentsCodeaircraft_ductingsession
       WinWait, GVIM,,3
       sendinput,#4
       Run "C:Program FilesMozilla Firefoxfirefox.exe" -new-window http://localhost:8080/devcgi/init.plx
       WinWait, "Mozilla Firefox",,3
       sendinput,#1

    return

But that's not all! I tend to use splits in my text editor a lot, and with that in mind you may notice the about call to ACDRI() and the S switch. S reloads all of my previous editor settings, including splits, and ACDRI() opens my project file.

    function! ACDRIEnd()
       wincmd h
       wincmd h
       wincmd h
       q!
       mksession! "C:Documents and SettingsfrewMy DocumentsCodeaircraft_ducting"session
       qa
    endfunction

    function! ACDRI()
       Project "C:Documents and SettingsfrewMy DocumentsCodeaircraft_ductingproject"
       set foldlevel=1
    endfunction

And lastly, at home where monitor space is much more of an issue, I tend to have gvim and a console side by side, with numerous splits each. The console splits are achieved with ^a S and ^a |. You can move to the next one with ^a .

[![Linux Laptop Screenshot](/wp-content/uploads/2009/01/ss-300x180.png "Linux Laptop Screenshot")](/wp-content/uploads/2009/01/ss.png)

Anyway, does anyone have any other tips having to do with automated window management?
