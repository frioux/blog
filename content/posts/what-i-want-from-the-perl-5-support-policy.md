---
aliases: ["/archives/707"]
title: "What I want from the Perl 5 support policy"
date: "2009-05-14T04:33:40-05:00"
tags: ["perl", "support-policy"]
guid: "http://blog.afoolishmanifesto.com/?p=707"
---
This is in response to chromatic's post [Writing Perl 5's Support
Policy](http://www.modernperlbooks.com/mt/2009/05/writing-perl-5s-support-policy.html)

I want to be able to use the support policy as a reason to convince customers
with lots of Perl installs that they need to update. A big part of this means an
**easy upgrade**.

Probably most of the people using Perl 5 are in Unix. That makes it easier for
you folks. On Windows installing Perl is no simple task, either ActivePerl
**or** Strawberry Perl.

For example, at $work we use Apache/mod\_perl. _(I don't wanna hear your
"FastCGI! FastCGI! FastCGI!", none of you people have actually helped me so
far!)_ Let's say I want to use the shiny new Perl 5.11. I install it. Awesome.
Wait! mod\_perl doesn't work! Ok, reinstall that. Oh wait! All of my XS/compiled
modules don't work! etc etc. I understand the fact that Windows is a second
class citizen here, but in Unix you probably have the same issue. You just made
some kind of package to install it all at once or something. That's great, but
does it help me? Is updating really supported?

On a side note a point that my boss made when we discussed this issue is the
fact that the community may not support Perl 5.8 in the future, but if companies
will pay for it, ActiveState will probably support it. This is good for the
customers and helps the community, so I'd say that's really a win-win.

Anyway, those are my thoughts. Take 'em or leave 'em.
