---
aliases: ["/archives/536"]
title: "Ext Day 2, Part 2"
date: "2009-04-17T03:53:39-05:00"
tags: [extjs, javascript, conference]
guid: "http://blog.afoolishmanifesto.com/?p=536"
---
Ok, the next session I went to on Day 2 was the session on Refactoring. Refactoring is one of the few high quality buzzwords that I hear regularly, so I was excited to hear what the talk would go over. It was very much Ext specific, but the final changes to the component that we "Extified" were amazing.

First off, what does it mean to Extify a component? The comp needs to fit into the Component Model, which is mostly a lifecycle issue. Typically this will be extending an existing component or creating a new one by inheriting from Component. Refactoring also involves clean code, consistent code, and hardest of all, documented code. And part of that which is fairly Ext specific is that the configuration should be elegant; or the config needs to be predictable and not have too many options.

Unfortunately this session was like drinking from a firehose, so I couldn't take notes more than that. For the most part though it involved simple changes like moving view changes out of the component entirely and into CSS. Documentation should be done with [ext-doc](http://ext-doc.org), which I look forward to setting up at work. Config option names need to be thought through carefully so that they match well with the rest of the framework. Other nice things that were done is to allow a store to be defined as a store, a store config, an array, or a store id. Keep your eyes peeled for the notes from this presentation. Should be excellent.

The next session I went to was another usability session. I am of the opinion that it's hard to have too many of these. This session was a lot more hands-on, specific ideas than the other session.

His first recommendation was to show that background events are occurring. First go look at [Forever21](http://www.forever21.com/). Make your browser window 1024x768. Go to a product and add it to your cart. The part of the page that shows that the item has been added to the cart is **not** where you clicked, and probably isn't even in view. Did anything happen? Is the page just going slow? Nope. You added it every time you clicked.

Now, on the other hand, check out this [Ext sample](http://www.extjs.com/deploy/dev/examples/menu/menus.html). Note how when you use the menus messages pop up fairly unobtrusively. Also note that the time the messages are displayed can be increased and they can be set up to go away when the user clicks them. Much nicer!

In that same vein, try to avoid modal browser feedback as it freezes not just your whole app, but often the whole browser. Also avoid feedback about trivial events that the user does not care about. If at all possible, make actions easy to undo. For the actions that cannot be undone, warn your user.

Speed matters for all applications. There are some easy ways to make ext applications very snappy. Use xtypes possible as they allow for lazy instantiation on rendering. When waiting for the server, a basic load mask should be used for .5s or more. If it takes 5s or more, use a spinner or some other kind of progress indicator. If it takes more than 10s a real progress bar should be used. Note that real progress bars can still be faked by precalculating how long certain sets of data take.

The help tool for the title of a panel can be used for easy context sensitive help. In general the user shouldn't need help, but it doesn't hurt to make it available.

Also, your app should stay out of the user's way. UI inconsistencies can confuse the user and slow them down. Try your best to be consistent across your application. I chimed in here to mention that we actually put UI standards in code by making classes to inherit from. That way you actually have to do **more** work to make a part of the application look different.

Labels and messages need to be well thought out. Don't **ever** let a user see lorem ipsum or even just poorly worded text. Don't be vague in your text ("invalid input" etc.) Maintain your tone (informal vs. formal style.)

Be careful about button placement. Ok/Cancel should always be in the same order. Ok should actually normally be a verb, like "Create" or "Destroy." Also the cancel action should be demarcated somehow. A red icon works, or some people even go so far as to make the positive action a button and the negative action a link.

As you grow your application beware of making too much clutter. The example given in the talk was Google vs. iGoogle. Switching between the two is easy and you aren't forced to use iGoogle at all.

You should favor clarity and predictability over cleverness and coolness. For example, the speaker mentioned making a wizard where a regular form made more sense. The form is easier for the user and less work to implement.

In general layouts should flow left-to-right, top-to-bottom. So more general things should come first in that ordering. And furthermore try not to make user interfaces extremely busy. A 40% data density is optimum. Again, try to keep your UI balanced.

The use of ellipsis (...) in menus to point out which commands bring up new dialogs is a good convention. Shortcut keys for menu commands should be underlined, and the shortcuts should be mentioned in tooltips as well. 10 or more items in a menu are too many. Use submenus etc. Often used items should be closer to the top of the menu. Often used commands should have icons, but too many icons can look cluttered.

Use grouping in grids to reduce clutter. Use cell renderers to highlight important information. In editable grids, make it clear which fields are not editable. As we all know, too many rows and columns is bad, even though every user everywhere wants it.

In forms you shouldn't use check boxes for radio buttons and vice versa just because you prefer the appearance. That is very confusing for users.

Also with treepanels it's a good idea to preserve tree state to save the users from having to open the sub trees all the time.

Next up was "Ask the Ext Team." I learned a lot from this panel. First off, creating manager classes to decouple classes can help with complex interaction. Or you could use the new Ext 3 bubbling feature. Another really cool idea they mentioned was making your top level ns inherit Observable and make it a singleton, and then allow things to communicate through that. I \*love\* that idea.

LongPollingProvider can allow for Comet (faked push.)

Ext is corporately located in Tampa, but there are devs in DC, Australia, and other places.

Good places to learn about Ext are the [wiki](http://extjs.com/learn) and the [forums](http://extjs.com/forum/).

The Ext team recommends extending classes only when you are actually making your own functionality as opposed to just configuring a class. (I humbly disagree :-)) You **do** need to buy a new license to use Ext 3.

Component.mon is a replacement for on that does some memory management for you. The listeners config doesn't use it, but it doesn't have to.

Also interesting to note: the presenters actually used Ext for the slides. It was very cool and made very good sense for their use case.

HBox and VBox are **really** cool and will help with layouts immensely.

After that we all went out in the courtyard to talk. It was a lot fun to talk to some of the other devs. I even met a few that I ended up riding to the airport and eating with the next day :-)

And that's it for Day 2. Stay tuned for the exciting conclusion: Day 3!
