---
aliases: ["/archives/543"]
title: "Ext Day 3"
date: "2009-04-17T03:55:28-05:00"
tags: ["extjs", "javascript"]
guid: "http://blog.afoolishmanifesto.com/?p=543"
---
The end! Ok not quite. So this was the last day of the conference. It was shorter than the other days and most of us had to checkout anyway. Still exciting!

First off we got an awesome demo of the Designer. It looks like it will be extremely useful for exploring the framework and playing with layouts. You can edit multiple components at once, as if it were an IDE. You can even load data into grids on the designer. The bad news is that it looks like the Designer will be a service or an Air app that you buy. I understand the motivation behind that, but it's still frustrating.

The next talk I went to was the Application Deployment talk. Very good information, but little of it was new to me. First off, Yahoo has written a lot of best practices for website performance. Take a look at those. YSlow is based on those and can tell you if you are following some of those best practices. YSlow 2.0 is in development and will be made of unicorn's and rainbows. Typically you should skip your overall score and just look at the specific items. Gzip is good to use. Putting versions on your filenames can really help with performance (more on this later.) CSS should be in the header and as much JS as possible should be in the body. This will allow you to load basic JS and render the page before all of the JS is loaded. Minify your JS. ETags probably won't actually help you unless you are huge.

Firebug network monitor is your friend. Fiddler (.NET app) can help for some esoteric things like file uploads or flash interaction that won't show up in firebug. JSLint is an amazing tool that can help you write better code. Some of the people there wrote a [Yahoo Widget](http://code.google.com/p/jslint-multi-widget/) that will automatically run JSLint on any files that have been changed. Very cool!

You should use parseInt(foo, 10) instead of just parseInt(foo). Why? Because parseInt defaults to **octal**.

JS Builder is a .NET app written by the ext people that will compress your javascript files nicely. It can also be run from the CLI for batch usage.

CSS Sprite generation can significantly reduce your server pings. Also it can reduce images a lot due to boilerplate png stuff in icons (30%!) Use [this](http://spritegen.website-performance.org) to automate the process.

You need a favicon because browsers will always check for it. Be careful about giving it a big expire time because you cannot always just rename it as older browsers only check for favicon.ico.

And that was basically it! I didn't go to the next session because we were **way** over time and I had to check out. In general I really enjoyed the conference and think I learned a lot from it. The only major problem I had was the Ritz stuff I mentioned before. Other things they did were really cool. For example: to ask questions in the panel you posted them online and you could vote them up and then they would answer the ones with the highest votes. This was good because people who talk really slow had less of a chance to slow us down etc. I think they should have given the field a max length, as too many words are just confusing anyway.

I give the conference 4.5/5 stars. Great in almost every way :-)
