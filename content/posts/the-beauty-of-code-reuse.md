---
aliases: ["/archives/1069"]
title: "The Beauty of Code Reuse"
date: "2009-08-14T03:30:43-05:00"
tags: ["catalyst", "cgiapp", "cgiapplication", "code-reuse", "extjs", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1069"
---
I'm probably preaching to the choir here, but it must be said: code reuse is
most excellent!

Today I got a somewhat complex feature working for our customer, and almost all
of it was features I'd already written, and due to the organization of our
system I could easily reuse most of the code.

Our customer fixes airplane parts. When they fix a part they need to document
every single thing they did to the part. We have each operation (more or less)
that can be done already defined so that they can at least save those keystrokes
(they are actually operation templates.) But there are a **lot** of operations
and a typical work order will be around 50 operations, so choosing the same
operations over and over is a waste of time. So we have a feature that lets them
look at other work orders that were fixing the same type of part and copy
operations (and materials) from that.

It was really easy to use the existing view for operations and materials because
the front end is entirely comprised of JS classes. I even used an instance of
the work scope grid to list all of the work scopes that are for the given part.
The nice thing was that so far I've written **no new server side code** yet. And
for the classes I didn't use inheritance; I used a role style object
modification by doing what Moose people would see as an after method on new
(called a plugin in ExtJS). With the plugins I could simply change the store to
ask for a given part-type's work orders, hide extra columns, and add listeners
to update the operations and materials when a user clicked a row.

Don't think this is all just JS praise; Perl and Catalyst were help too. But
really the benefit here was the use of any web framework in general. Because I'm
using a framework I can easily find server side actions that do what I need
(which the grids were already tied to in their base classes, but still.) In our
other projects I'd be hard pressed to give you a list of all of our "actions,"
whereas with CGIApp I can easily make a list of runmodes myself, and with
Catalyst the server will make a list for me.

Excellent!
