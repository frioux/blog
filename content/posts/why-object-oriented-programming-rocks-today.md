---
aliases: ["/archives/71"]
title: "Why Object Oriented Programming Rocks (today)"
date: "2009-01-21T22:19:38-06:00"
tags: ["extjs", "javascript", "object-oriented-programming"]
guid: "http://blog.afoolishmanifesto.com/archives/71"
---
I am in the beginning of writing a web application with [ExtJS](http://extjs.com/products/extjs/). ExtJS is a javascript ui framework that's extremely object oriented. I read once that it's a good idea to predefine your user interface objects as (effectively) classes. One of the reasons for this is that it uses far less memory in our browsers. That's a pretty good reason. Another reason is that you end up with smaller bits of code to work with at a time, thus allowing you to focus better on the task at hand.

Well just now my boss asked me to add an image beneath a treeview. That basically involves making a panel that has a treeview and an image. Well, instead of having to go through the code and basically do it, all I had to do was change my ACDRI.ui.LeftPanel from a special treeview to a Panel that has an ACDRI.ui.NavigationPanel (what it used to be) and an image. The original code was actually entirely unchanged except for the name. Furthermore, if we decide to go back it will require exactly one line of code to change. Excellent!
