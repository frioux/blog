---
aliases: ["/archives/1490"]
title: "Predefined Schema Additions for DBIx::Class"
date: "2010-12-28T21:02:23-06:00"
tags: ["dbixclass", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1490"
---
At [work](http://mitsi.com) we have a tiny set of classes and relationships that we've reused for a few projects now. The idea is that it's a package deal of users, roles, permissions, and a way to map permissions to parts of the application. I'm actually pretty fond of it, but its usage is a **little** awkward and not very flexible. If I could I'd put it on CPAN as that would mean tests, docs, and more importantly, a way to make it more useful for disparate projects.

The way it works right now is as follows:

    package Lynx::SMS::Schema::Result::User;

    use strict;
    use warnings;

    use parent 'MTSI::Schema::Result::User';

    __PACKAGE__->load_components('Helper::SubClass');
    __PACKAGE__->subclass;

    1;

for all of the seven-ish results. That's a little obnoxious, but you need a place to add extra columns and relationships. The problem is if you decide that you want to, say, not use roles the way we decided to, you already have all these bogus relationships tying everything together. So what I'm thinking is that I'll instead put the relationships in a more intelligent schema component with a bunch of options and whatnot. So you could do all of the above, and then in your schema do something like:

    __PACKAGE__->load_components('+MTSI::Schema::Auth');
    __PACKAGE__->auth_setup;

auth\_setup could take a number of arguments toggling which results will get which permissions. Of course for a simple system one could **just** subclass the user result, which already has the password storage stuff that [I've blogged about before](/archives/1286). For a supercomplex system (maybe users can have roles **and** permissions?) all you'd need to do is add the relationships to the user and permission classes, and of course you could do that from the user, from the permission, or from the schema directly, since DBIx::Class is so flexible. Anyway, feel free to comment with other ideas, but I feel pretty good about this direction and hope to have a 0.00001 release soon.
