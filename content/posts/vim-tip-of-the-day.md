---
aliases: ["/archives/580"]
title: "Vim Tip of the Day"
date: "2009-04-23T15:12:47-05:00"
tags: ["vim"]
guid: "http://blog.afoolishmanifesto.com/?p=580"
---
Every now and then I want to run a given vim command on a bunch of lines. In the past I would have either executed the command and then pressed **j.** (Hi J-Dot!) to go down and repeat the command. Or if the command were more complex I would have used a macro and done it over and over with **@@**.

Well, for simple stuff on a range there is an easier way! Lets say you want to delete the first two words of a bunch of lines you have highlighted. This is all you have to do:

    '<,'>:normal d2w

SWANK.
