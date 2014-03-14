---
aliases: ["/archives/518"]
title: "Vim Feature of the Day"
date: "2009-04-05T02:45:48-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=518"
---
We all know programmers who, when they need to copy/paste more than one thing, just use a temporary window to keep track of the copied data. Well vim has that feature **solved**.

First off, we have multiple copy/paste buffers, known as registers. So I can copy and paste three different things into three different registers. To copy a line to register a, use **"ayy**. Then to paste that line you would use **"ap**. So we have plenty of registers. It gets better! What if you want to copy a bunch of stuff into one register? Well, first I would clear it with **:let @a = ''**, but that's not required. Anyway, you can add to a register by using **"Ayy**. This will copy the current line onto "a. So you can do this over and over to add to the "a register!

But that requires too much work. Yesterday I wanted to add all lines with the word "name" into "a. Here is how I can do that with one line: **:g/name/y A**.

Awesome!
