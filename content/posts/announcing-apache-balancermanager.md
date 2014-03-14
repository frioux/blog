---
aliases: ["/archives/1806"]
title: "Announcing Apache::BalancerManager"
date: "2013-01-11T02:12:08-06:00"
tags: ["apachebalancermanager", "cpan", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1806"
---
At work I use [Apache](/archives/tag/apache) as it's the best thing out there for perl on windows. One of the features of Apache when you are using it as a load balancer is it's UI for controlling the Balancer Manager. One of my coworkers remarked that it would be nice to have an API for that so that when we restart workers we could tell the balancer manager first so that the worker would not get dispatched to until it finished restarting. Well OK!

# [Apache::BalancerManager](http://metacpan.org/module/FREW/Apache-BalancerManager-0.001002/lib/Apache/BalancerManager.pm)

Apache::BalancerManager gives you an easy to use, object-oriented interface for interacting with Apache's Balancer Manager. Here's a real example from our server code:

    use Apache::BalancerManager;
    my $m = Apache::BalancerManager->new(
       url => 'http://127.0.0.1/balancer-manager',
    );

    sub restart_service {
       my $service = sprintf 'LynxWeb%02i', $_[0];
       my $member = $m->get_member_by_location(
          sprintf 'http://127.0.0.1:50%02i', $_[0]
       );

       $member->disable;
       $member->update;
       system(qw(net stop $service));

       system(qw(net start $service));
       $member->enable;
       $member->update;
    }

The module automatically finds all the available members and creates objects to wrap each of them. There are a number of methods for each, for example one might modify load\_factor if a server is under too much load. Ultimately though, I'm pretty sure the use case above is the best one, as the balancer manager is limited in what it can do. (Members can't be added at runtime, for example.)

Anyway, this makes me a little bit less afraid to roll out updates to our live site, so I figured others might appreciate it too.

**Caveat:** I've only tested it with Apache 2.2. It may be broken on 2.4. Patches are welcome!

Enjoy!
