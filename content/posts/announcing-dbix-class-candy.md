---
aliases: ["/archives/1390"]
title: "Announcing DBIx::Class::Candy"
date: "2010-07-21T05:17:28-05:00"
tags: ["cpan", "dbixclass", "dbixclasscandy", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1390"
---
Over a year ago I read [this blog post](http://www.dmclaughlin.com/2009/04/19/ugly-perl-a-lesson-in-the-importance-of-api-design/). To be honest at the time I thought it was mostly silly and I still feel that way. The things that are important to me in an ORM are capabilities, not subjective prettiness of code. But, I also get tired of typing repetitive things, **especially** \_\_PACKAGE\_\_->. That's just too many shift keys! So after working on a few different modules and accruing various bits of knowledge here and there I learned what I needed to to create a sugar layer for [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) that doesn't throw the baby out with the bath-water.

----

I am proud to announce the initial, development version of [DBIx::Class::Candy](http://search.cpan.org/perldoc?DBIx::Class::Candy), which should be coming to a CPAN mirror near you very soon. If you just can't wait, use [cpanf](http://search.cpan.org/perldoc?App::CPAN::Fresh) to get it **right now**. The basic gist of it is that you can use:

     package MyApp::Schema::Result::Artist;

     use DBIx::Class::Candy;

     table 'artists';

     column id => {
       data_type => 'int',
       is_auto_increment => 1,
     };

     column name => {
       data_type => 'varchar',
       size => 25,
       is_nullable => 1,
     };

     primary_key 'id';

     has_many albums => 'A::Schema::Result::Album', 'artist_id';

     1;

instead of

     package MyApp::Schema::Result::Artist;

     use strict;
     use warnings;
     use base 'DBIx::Class::Core';

     __PACKAGE__->table('artists');

     __PACKAGE__->add_columns(
       id => {
         data_type => 'int',
         is_auto_increment => 1,
       },
       name => {
         data_type => 'varchar',
         size => 25,
         is_nullable => 1,
       }
     );

     __PACKAGE__->set_primary_key('id');

     __PACKAGE__->has_many( albums => 'A::Schema::Result::Album', 'artist_id' );

     1;

There are a few other features, like having it turn on 5.10 or 5.12 features, use a non standard base, and more. [**Check it out now!**](http://search.cpan.org/perldoc?DBIx::Class::Candy)
