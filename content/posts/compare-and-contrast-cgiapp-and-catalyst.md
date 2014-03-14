---
aliases: ["/archives/805"]
title: "Compare and Contrast CGIApp and Catalyst"
date: "2009-06-12T04:03:15-05:00"
tags: ["catalyst", "cgiapp", "cgiapplication", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=805"
---
You may remember my post [from before](/archives/762) asking about the differences between these two frameworks. I only got a couple of responses, but they certainly helped me to see what is up.

Basically it boils down to this (as pointed out by mst): CGI::Application is a microframework, and Catalyst is an extremely configurable MVC stack. Before you correct me, Catalyst doesn't actually **provide** the Model or View code; it lets you pick whatever you want to pull that off. But nonetheless it has affordances for both model and view code.

CGI::Application, on the other hand, doesn't even have a built in way to deal with models! I love CGI::Application, but mostly because it keeps our code way more organized than our previous framework; (note, our previous framework were files that had use CGI; somewhere at the top...)

So you could really look at it like this: Catalyst is **extremely** extensible, because of their brilliant design. Maybe large frameworks have to be designed the way Catalyst is; I don't know. I do know that at this point in my career my coding chops are not good enough to have that good of a design/API.

CGI::Application, on the other hand, is simple enough to grasp in an hour or so. It has:

- a "lifecycle" for actions (or in CGIApp-land, **runmodes**)
- Some basic templating affordances
- methods to get at the CGI query object

And that's it! There are plugins that give you extra features, like RESTful dispatching, authorization, and authentication, but out of the box it's just a microframework.

Catalyst, on the other hand, is much more complex. For the ruby people out there it's probably a mix between Rails and merb. Not quite Rails because it's much less opinionated, but not quite merb because it has quite a few features that I don't think merb has.

Recently I have been feeling some of the growing pains of the app that we recently started from scratch at work. It's based on CGI::Application. The reason behind that was that my boss was hesitant to try something new (to us) like Catalist. I had used CGI::Application in TOME and so I had at least a little experience with it, although in TOME we didn't even go close to what we could have done.

Anyway, if you are starting a new project that will be large (for almost any value of large) you probably want Catalyst. If you are making something simple (like WebCritic,) using Catalyst is totally overkill, and CGI::App fits the bill nicely.
