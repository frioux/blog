---
aliases: ["/archives/1700"]
title: "Introducing Catalyst::ActionRole::DetachOnDie"
date: "2012-05-23T15:45:46-05:00"
tags: [mitsi, announcement, catalyst, cpan, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1700"
---
In my last post I introduced [Catalyst::Controller::Accessors](http://p3rl.org/Catalyst::Controller::Accessors), which is mostly aimed at users who do a lot of chaining. This module is similarly targeted for chaining users. Anyone who has used chaining for more than a few weeks will know that exceptions in chains are stupid; an exception will **not** stop the chain, but merely end the current part of the chain, add to $c->errors, and run the next part of the chain. I would understand this if it were something that you could choose to turn on in a per-chain basis or something, but as a default it's horrible.

This module solves that problem. It just detaches the chain and sets $c->errors when an exception is thrown. To use it you just need to do the following in your controllers (base controller anyone?):

    package MyApp::Controller::Foo;
    use Moose;

    BEGIN { extends 'Catalyst::Controller::ActionRole' }

    __PACKAGE__->config(
       action_roles => ['DetachOnDie'],
    );

    ...;

If for some reason you can't use the excellent [Catalyst::Controller::ActionRole](http://p3rl.org/Catalyst::Controller::ActionRole) you can use the ActionClass version as follows:

    package MyApp::Controller::Foo;
    use Moose;

    BEGIN { extends 'Catalyst::Controller' }

    __PACKAGE__->config(
       action => {
          '*' => { ActionClass => 'DetachOnDie' },
       },
    );

    ...;
