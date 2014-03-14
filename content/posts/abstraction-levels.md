---
aliases: ["/archives/1807"]
title: "Abstraction Levels"
date: "2013-01-05T20:53:43-06:00"
tags: ["abstraction", "perl", "programming"]
guid: "http://blog.afoolishmanifesto.com/?p=1807"
---
One of the decisions we developers must make when writing our modules is at what level to abstract our code. I, for instance, write a lot of [DBIx::Class](http://metacpan.org/module/GETTY/DBIx-Class-0.08204/lib/DBIx/Class.pm) components, which is, for the purposes of this discussion, about the same as a role (and I will just use the term role for the rest of the article.) For a long time that was my standard _modus operandi_, but I've started to think that that is a bad default and that I need to consider more carefully what to use.

# Abstraction Levels

The abstraction levels that I deal with on a regular basis are:

1. Roles
2. Objects
3. Subroutines

I cut my CPAN teeth on roles because they are the generally accepted form of code reuse in DBIx::Class. For instance if you want your Result Class to inflate columns of the data type datetime you use the [DBIx::Class::InflateColumn::DateTime](http://metacpan.org/module/GETTY/DBIx-Class-0.08204/lib/DBIx/Class/InflateColumn/DateTime.pm) role. But what bothers me about roles is that you **must** define a class and instantiate an object to use them "correctly." You could Perl it up and use their subroutines directly, but that forces me to ask myself: "why not make an exporter that actually gives you the subroutine in question?" Indeed, why not do **that** as a matter of course?

I actually have a lot of helpers that I think would be good to migrate **away** from roles. For instance, what if you do not want to forever use the [::SetOperations](http://metacpan.org/module/FREW/DBIx-Class-Helpers-2.016003/lib/DBIx/Class/Helper/ResultSet/SetOperations.pm) role which lets you use unions in a DBIx::Class::ResultSet, but instead just want to union two resultsets that you don't control? If I were to factor the ::SetOperations methods into simple subroutines it would be very simple to create roles that make methods out of the subs.

And then of course there is the object path. Generally I think it is fairly easy to decide when to use an object; if it's a standalone module an object is probably fine. Additionally, if something is complex enough to be more than a single method, an object makes perfect sense, as that way users can make subclasses and override behavior.

Another related issue that I have trouble with is what should be instance level in an object or role and what should not be. Sometimes I think I made too much instance level in [DBIx::Class::DeploymentHandler.](http://metacpan.org/module/FREW/DBIx-Class-DeploymentHandler-0.002203/lib/DBIx/Class/DeploymentHandler.pm) I've fixed that any time I've found it (the version to install used to only be able to be set at instantiation time, instead of when the install method was called, for example) but I worry about the fact that I even got that wrong in the first place. A **lot** of thought went into that module.

I think I need to start asking myself "how permanent does this need to be?" So if something is complicated enough, it needs to call other methods so they can be overridden etc; that can't be a subroutine. But the vast majority of my helpers could easily be simple subroutines, as override points would be overkill. The same goes for instance data. Setting instance data so that it can default method arguments is probably sensible, but forcing the user to re-instantiate to change a value (as my accessors are nearly always read only) is again probably too much.

What do you think? Do you have rules of thumb you use when designing your API's?
