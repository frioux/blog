---
aliases: ["/archives/1672"]
title: "Shortcut Constructor Method & Conversion"
date: "2011-09-07T17:31:41-05:00"
tags: [frew-warez, best-practice, patterns, smalltalk]
guid: "http://blog.afoolishmanifesto.com/?p=1672"
---
I left my book and notes at work yesterday, hence the late post.

# Shortcut Constructor Method

**What is the external interface for creating a new object when a Constructor Method is too wordy?**

Sometimes creating an object is exorbitantly wordy. The example that the author gives (in javascript) is the following:

    var p = new Point({ x: 1, y: 2 })

**Add methods to a lower level object that can construct your objects. Take care to only do this rarely.**

This can't be done with the example given in javascript, but the idea is to do something like the following:

    var p = ( 1 x 2 )

Personally, I'm very wary of this idea. I see the value, but even operator overloading, which is a step HIGHER level than this, is usually viewed skeptically. I **do** think it's a good idea to make shortcut methods to instantiate related objects, but that's a far sight better than creating a method on all integers. If you **do** monkey-patch something like integer, it would be best if it were done dynamically, so only the code in your own project sees it.

# Conversion

**How do you convert an object's format to another object's format?**

This is (at least to me) quite obvious. Some would think that they should add methods to every object to convert to other formats. So one might monkey-patch the DOM stuff to return a jquery DOM thing with the asJQDom method or something like that. Of course doing that means you're going to end up with a ton of random conversion methods.

**Convert objects by merely instantiating the second object type**

This just seems so obvious I almost feel bad even writing it...
