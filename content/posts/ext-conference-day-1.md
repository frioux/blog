---
aliases: ["/archives/521"]
title: "Ext Conference, Day 1"
date: "2009-04-15T00:46:27-05:00"
tags: [javascript, extjs, conference]
guid: "http://blog.afoolishmanifesto.com/?p=521"
---
For the benefit of my memory, my coworkers, and the rest of the intarwub, I am posting my expanded notes on the Ext Conference 2009. They are supposed to put up slides and video, so hopefully blog posts won't be a major resource, but we'll see.

I must give my impressions of things only barely related to the conference before I get into real content though. We are at the Ritz-Carlton, which is nice. But it's expensive and the amenities are not worth the price. First off, the wifi isn't free. Oh wait, the wifi in your room actually is non existent. So you pay 10$ for 24 hours of tethered connection. The wifi in the conference is free, but guess what, no power plugs aside from the few ones near the wall! My boss said I could get the wifi and expense it, but it's still really slow. Streaming music just doesn't work. I am streaming music fine over my G1 instead and that's fine. Wait, maybe I could listen to the music on the cable TV! Oh wait... that costs too.

On another note, the conference is attended by an extremely diverse crowd. I think it would be safe to say that half of the crowd is not native to the US. There are something like 4 or 5 women though, so not entirely heterogeneous.

So with that aside, real content:

First off Douglas Crockford (you know, the guy who invented JSON?) did a very generic presentation on the future of Javascript. It was fun and encouraging, but won't really help us for a long time. Numerous times throughout the conference it has been mentioned that IE6 is still very much dominant. I am very happy that most of our customers can be convinced to use at least IE7. There was a lot of fun history in Crockford's talk, but I'll leave that out for brevity's sake. The next version of JavaScript (ECMAScript 5) is supposed to improve on a lot of the features of JS.

Browser interoperability is supposed to get a lot better because the implementations (browsers) will not be making as many decisions. Many common practices will be codified as parts of the standard.

Security is supposed to be improved upon significantly. The use strict mode (see next section) will help with that. Also objects can be "hardened" where they cannot be changed after creation. Same with properties on objects. But the global (window) still exists.

The strict mode is going to be optional. You shouldn't use it in cargo culted code as it will probably break your code. It removes a bunch of "bad" features and could theoretically give better performance.

Some syntax has been relaxed. For example, if you do this in IE it will break: \{ class: 'foo' \}. That is part of the spec and it is no longer an issue. Better yet, trailing commas are to be allowed!

All kinds of functions are added to arrays, objects, and functions to make them easier to work with. My favorite of course is a built in map :-)

Regexps are better, JSON parsing is built into the browser.

But of course, IE6, 7, and 8 will be around for a **long** time before we can use this stuff, so don't get excited. Just look forward to the future.

After that happens security needs to be looked into significantly. The current model is insecure if you ever include things like ads from external sites. It seems that a lot of that can be taken care of with [Caja](http://code.google.com/p/google-caja/) though. Interesting!

The next session was What's New in Ext 3. As we all already know there is the lightweight core. It's like JQuery or Prototype in that it's a toolkit for websites as opposed to applications. It's a subset of Ext so you will be able to use it with existing knowledge. It is Open Source (kinda, MIT.) It is unobtrusive and small. It has a great API and an excellent manual.

We have the new ListView, which is like a grid, but way simpler, so much more performant. Instead of a monster like Grid which can do everything, you just add plugins to allow it to do more. This is not supposed to supplant Grid.

Charting is very cool and surprisingly easy. Interesting things about it is that if you have say, a grid that shares a store with a chart, editing a value in the grid and saving it to the store will automatically change it on the chart. Very exciting stuff. Based on YUI charts.

Group tabs are kinda cool, but I doubt we will be using them any time soon. You'll have to look at examples to see what they are.

The row editor for grids looks very cool. I can see using that, but again, you'll need to look at it to see what it is.

Buttons are way better than before. They are sizable, stylable, and most importantly, you can place them anywhere as they can participate in layout.

Toolbars are now real containers, so you can put more stuff in there. Awesome. This allows things like ribbons etc.

BufferedGridView is a way to get better performance out of a grid. It only renders the rows that are visible, so it can make showing large datasets much faster. The only drawback is that the rows must have a static height.

The Debug Console is basically a way to have firebug in IE. Very cool!

HBox and VBox will be replacing Column and Row Layouts respectively. They are very flexible.

Ext ARIA is a way to get accessibility in your ext apps. It is currently not complete. The way you use it is by adding another js file to your include list and it will override a bunch of ext things.

resetBodyCss is a cool way to get your vanilla CSS back when you want it. So all of Exts CSS resets go away when you use this on a given panel.

I also went to the Ext.Data session, but I didn't take very good notes because I already knew most of it from Ext 2. The few things that I learned were that Field classes represent the specific parts of a Record. I hope to override the date field so that it defaults to our date format. There is also a convert function that can be specified in a field on a record. Imagine a renderer, but much more basic. I also learned that mapping allows for mapping to actual objects and not just records. For example, if a record looks like this: \{name: 'frew schmidt', currentLocation: \{ x: 10.23343, y: 4.32325 \}\}, I could define a field like this: \{name: 'yLocation', mapping: 'currentLocation.y'\}. I could see using that in the future.

I also went to the Back to the Basics session. Again, I only wrote down things I didn't already know. So semicolons are optional in JS. Did you know that can cause bugs? Example:

    return {
       foo: 'bar'
    };     return
    {
       foo: 'bar'
    };

The second fails because javascript assumes you forgot a semicolon and puts it there for you.

And: how to make a singleton in JS:

    var Foo = function() {
       var privateGlobalFoo = ...;
        return {
          getFoo: function() {
             return privateGlobalFoo
          }
        }
    }();// <-- note the parens.

Basically the parens run the function and return the value into Foo. If you try to call Foo as a function it will fail. Neat!

And lastly, I went to Ext.util. This session was very packed with info, so I ended up just writing down classes that I didn't already know about to look up later :-) My list was: Ext.KeyMap, Ext.KeyNav, Ext.Editor, and String.format.

Other things I took away from throughout the day: testing is just not done in ext for the most part. A lot of people want it, but it's just not going to happen. Dynamically configured grids are not that unusual. Extremely large datasets are not that unusual. There are lots of .NET and Java users, a few PHP users, and very few perl users. Almost everyone uses JSON and almost no one uses XML. The whole Ext team uses Aptana and maybe one other editor. Ext Designer should come for 3.1. An Ext Marketplace for extensions is planned. Theming Ext 3 will be extremely easy compared to Ext 2. Dynamic loading should be much easier in the future, though probably not core.

I'll post again tomorrow. Hope you enjoyed it!
