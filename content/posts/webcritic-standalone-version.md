---
aliases: ["/archives/629"]
title: "WebCritic: standalone version"
date: "2009-05-05T02:21:34-05:00"
tags: ["perl", "perlcritic", "webcritic"]
guid: "http://blog.afoolishmanifesto.com/?p=629"
---
Ok, you guys asked for it. I have updated [WebCritic](/archives/596) to be a lot leaner and meaner. Get the new version at the [same great place](http://github.com/frioux/perlcritic-web/tree/master).

It now runs entirely in **it's own lightweight server**. No apache or mod\_perl needed. It now uses CGI::Application::Server. It no longer uses CGI::Application::Dispatch, as my end goal no longer requires it. CAS fills the gap that CAD did for me. I also removed all of the lines that needed perl 5.10 because I wasn't actually using any perl 5.10 features. If I ever **do** use perl 5.10 features though I will leave it as an exercise to the user to backport the code. Because it's a user run server I no longer run a separate critic server. This makes the whole system a lot easier to run as a user. It defaults to criticizing the directory that it is run from and port 5053.

I plan on making a real page for it soon and putting it on CPAN in less than a month. Enjoy!
