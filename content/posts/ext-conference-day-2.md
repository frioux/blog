---
aliases: ["/archives/527"]
title: "Ext Conference Day 2"
date: "2009-04-16T04:10:09-05:00"
tags: [extjs, javascript, conference]
guid: "http://blog.afoolishmanifesto.com/?p=527"
---
Enjoy day 2:

First off was the Ext 3 Release. They gave some interesting history (Ext 1.0 was released exactly 2 years ago today!) And then mentioned a few features of Ext 3. Mainly it was about Ext.Direct and how it is a solution for communication to/from the server that is apparently a need in the community. I hope to use it myself; but we'll have to see based on the spec. More on that later. As for the designer the plan is not only to make it visual but also reusable, which is pretty exciting for me.

Honestly I was a little disappointed with the release. A lot of time was spent on GWT, which is kinda cool, but only half of the people there could use it, and even less do. I was hoping for a Chuck style release with a button and hype. Oh well :-)

The next thing that I went to was Dissecting Ext's Signature Sample. The app was very cool. I really liked learning about the implementation details. Often I have found the quality of the examples lacking (see [here](http://extjs.com/deploy/dev/examples/dd/dnd_grid_to_grid.html), in particular this horrendous line: [var firstGridDropTargetEl = firstGrid.getView().el.dom.childNodes[0].childNodes[1]; ]), and therefore not good enough to model an application after. Well, this example app was just rife with great examples of how to do things.

First off, the spoke about namespaces. That was pretty much the same as what we already all know.

Second, how about implementing your App object as a singleton? A good idea and makes perfect sense if I'd ever thought of it myself. I also happened to find out about the itemId/getComponent stuff here. Apparently it was around in Ext 2.2, but it wasn't documented. The idea is that you can set an itemId property on an item, and then on the container you can call getComponent('itemId') to find that item. It's kinda like non-global ids. Too bad it was never documented... Now that we have Ext 3.0 there is an even better way though!

Before you had to do this:

    Ext.ux.Foo = Ext.extend(Ext.Foo, {
       initComponent: function() {

          var this.foo = new Blah({...});

          var config = {
              ...
             items: this.foo
          };

          Ext.apply(this, Ext.apply(this.initialConfig, config));
          Ext.ux.Foo.superclass.initComponent.apply(this,arguments);
       },
       someFn: function() { this.foo.bar }
    });

Now you can do this:

    Ext.ux.Foo = Ext.extend(Ext.Foo, {
       initComponent: function() {

          var config = {
              ...
             items: {xtype: 'blah', ref: 'foo'}
          };

          Ext.apply(this, Ext.apply(this.initialConfig, config));
          Ext.ux.Foo.superclass.initComponent.apply(this,arguments);
       },
       someFn: function() { this.foo.bar }
    });

That is pretty excellent right there!

They also mentioned some Ext style stuff. This should be done when you make your own classes. First you list your properties, then overridden methods, and then you end with new methods that are specific to the class. They also mentioned that all strings used in the class should be properties to allow for simple i18n. Nice to know. We also had some good talks about regular old (aka bizarre) javascript OO. Any complex variables defined in the properties (classes, maybe arrays too) are basically class variables. So they only get instantiated on load time and they are shared (for better or worse) by all objects of that type. This has caused issues for me in the past, but I can see where it would be good for performance reasons.

The Ext.DataView class could be excellent for the TemplatePanel that I have created. I have to look into it some more, but something to look at nonetheless.

Plugins basically are a method for doing Mixins with javascript. I won't go into why mixins are a good thing. Just [look it up](http://www.google.com/search?q=mixin). One way or another, this will really help make our classes of higher quality. As for ext 3, we can now use ptype (like xtype) for plugins, and Ext.preg (like Ext.reg) for registering plugins. Excellent!

Ext.Direct sounds like it could clear up a lot of our boilerplate code on the server side....maybe. Basically what it would do is expose choice methods from our model classes. So instead of making four line actions that find a specific model and return the json version of the model, it happens automatically with some configuration. Beside that stuff it also automatically batches queries. So if you load two stores on one page they should automatically be batches into one request and one response. Depending on how hard it ends up being on the server side it could be totally awesome.

Next we had another QA panel. I learned that Ext tends to be getting a foothold anywhere that it is used. Static ids are a bad idea (not news.) Use xtypes for lazy instantiation when you can. Creating usable components is a good idea. HTML is bad; use JSON and Templates instead. Singletons are good. To be an Ext superstar spend 4+ hours per day on the forums. All the Ext superstars are stoked about Ext.Direct. As established too many times already, people don't test with Ext UI stuff. And lastly, most Ext apps are **not** public facing.

Next was User Experience Design with Ext JS. This talk was a big deal. There were tons of people there and it was a very solid presentation. I couldn't take perfect notes because the slideshow and what the presenter said didn't match up for the first few slides. I'll just document what I understood.

First off, user experience is based on psychology; what your users expect etc.

Design is based on decisions and constraints. One perfect example was that in the hotel one of the presentation rooms was way too wide, so most people couldn't see the screen. That was a decision, whether a conscious one or not. Constraints are based on technology, costs, etc.

Design is not art. Or in other words, there is a science to it. That doesn't mean it's not creative. Part of his point here was that design is not graphic design. In fact, he said that you could basically ditch graphic design and still have good applications if you still paid attention to User Experience design.

One tip he gave for User Experience Design was that you shouldn't pretend to be your user, because you just can't. Instead, pretend to be your app and ask yourself how you should interpret what the user is doing. Furthermore, you can't really learn from users without actually watching them. This isn't news to me, but it's still great advice. We use GoToMeeting for this.

Another point was that it's good to think of the user experience with the "Halloween Principle." That is, imagine your user is a mother of three on Halloween. They are in the middle of something fairly complex and then trick or treaters ring the bell. The user gives them candy, goes back to the app, and has no idea what she was doing. Can she remember where she was based on the visual clues in your app?

Another interesting insight that the presenter gave is that if your app has no bugs and the user uses it, they will be happy (and probably rate your app 7/10.) If a user finds a bug and you don't fix it, they will be upset, but probably blame themselves (3/10.) But the important thing is that if there is a bug, and you fix it immediately and give them very personal service, they will be extremely satisfied and even go out of their way to advocate you. I can give you an example of this. Last week I ran into a few bugs with Ext 3.0. I posted about them on the forums and two were fixed in 5 minutes and one was fixed in less than a day. I am extremely happy about that service and I really will tell people about that.

(This is going to be a long post...)

Next up is the idea of flow. Basically a user will be most effective when the difficulty of the things they are trying to do match up with their skill level. So if they are extremely skilled and doing very simple things, they will get bored and be unproductive. On the other hand it's fairly obvious that if you have a very inexperienced user they won't be able to do extremely complex tasks.

Also interesting: a lot of small features matter much more to users than one huge one. This one isn't that hard to understand. Just think about small things in software you use that drives you crazy. And how often do you use that one amazing feature that they added?

WTFs per minute are a good metric for user interfaces.

Don't fall in love with your work because you need to be willing to throw it away.

Don't "bend" (aka train) your users. Change the software so that it is more flexible. Part of that is that basically you need to be able to get to different parts of you software from numerous different angles. Think hotkeys, menubars, right click menus, etc.

Balance items on the screen so everything isn't just on one side or the other.

Match your colors (use kuler for example.)

Align things. This will help your users when they look at different parts of your app.

Make things look 3-D. Your app should look like the user can touch it and the focused things are in the front and non focused are in the back, etc. See [here](http://pages2.marketo.com/demo.html) for demos of the app the presenter made. Note: that is all ExtJS.

Ok, I have lots more to post, but it's midnight and I have a conference to be at at 8:30 tomorrow. I'll post the rest of my notes tomorrow. The sessions tomorrow end much sooner, so it shouldn't be to much.
