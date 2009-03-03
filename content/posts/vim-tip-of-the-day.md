---
aliases: ["/archives/365"]
title: "Vim Tip of the Day"
date: "2009-03-03T16:37:08-06:00"
tags: ["vim"]
guid: "http://blog.afoolishmanifesto.com/archives/365"
---
I post on forums and mailing lists fairly often, and when I copy and paste code I tend to shift all the code to the left 6 or more characters so that the forum won't see unnecessary indentions. Well, today I found the solution: blockwise selection. To do this in vim you will just type Ctrl-V and you are in blockwise selection mode.

You also probably want to do a :set virtualedit=block so that you can highlight characters that don't exist.

Anyway, it's nice because instead of highlighting _lines_ it highlights a square, so you just start at the beginning line and all indents are removed like **magic!**
