---
aliases: ["/archives/1261"]
title: "Latest additions to DBIC::Helpers"
date: "2010-01-14T19:30:00-06:00"
tags: ["dbix-class", "dbix-class-helpers", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1261"
---
Yesterday I added a basic but really nice helper to [DBIx::Class::Helpers](http://search.cpan.org/perldoc?DBIx::Class::Helpers). Say hello to [DBIx::Class::Helper::Row::NumifyGet](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::NumifyGet). The reasoning is that often we have bit fields in our database and when we serialize them with JSON we get something like the following:

    { 'bit_field':'0'}

JavaScript has the whole truthy concept like Perl except that in JavaScript "0" is true, while 0 is false. So NumifyGet will automatically "numify" columns with the is\_numeric field set to true. After doing that the json above would become:

    { 'bit_field':0}

Much nicer. Also I added some good docs to [DBIx::Class::Helper::ResultSet::Union](http://search.cpan.org/perldoc?DBIx::Class::Helper::ResultSet::Union) as well as fixing some latent bugs that were in it.

Enjoy!
