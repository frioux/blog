---
aliases: ["/archives/1582"]
title: "DBIx::Class Extended Relationships"
date: "2011-08-05T06:59:50-05:00"
tags: [mitsi, dbix-class, perl, cpan]
guid: "http://blog.afoolishmanifesto.com/?p=1582"
---
Since the dawn of time [DBIx::Class](https://metacpan.org/module/DBIx::Class) relationships were simply a set of columns related to each other via equality. For the most part this is good enough, but DBIx::Class aims at 100% power for all databases (unlike some other ORMs... :-) .)

In May what we internally called "extended relationships" was added to DBIx::Class. [(docs here)](https://metacpan.org/pod/DBIx::Class::Relationship::Base#Custom-join-conditions) Basically this allows you to use the full power of [SQL::Abstract](https://metacpan.org/module/SQL::Abstract) to define your join conditions. Just today I finally had a chance to use it. My join condition is simply "tableA.user = tableB.user OR tableA.shared = 1". Here is how I defined it:

    has_many output_devices => '::OutputDevice', sub {
       my $args = shift;

       my $shared = { "$args->{foreign_alias}.shared" => 1 };
       return ([
          { "$args->{foreign_alias}.user" =>
             { -ident => "$args->{self_alias}.user" } },
          $shared,
       ],
       $args->{self_rowobj} && [
          { "$args->{foreign_alias}.user" => $args->{self_rowobj}->user },
          $shared,
       ]);
    };

There are two interesting things to point out.

It's a coderef. This is so that we can parameterize various salient bits, like the aliases for the tables and, if it exists, the row object. There are a few other things passed, but I didn't need them here.

The other interesting thing is that instead of returning a single join condition, I returned two conditions. The first is simply a join condition, which might be used if you were to call search or related\_resultset. The second is a where clause to allow more basic SQL to be used when you already know one side of the join clause. So instead of doing something silly like "JOIN Foo ON Foo.bar = me.bar WHERE me.bar = 1" we can simply use "FROM Foo where Foo.bar = 1". Also note that a handful of helpful methods in DBIx::Class (create\_related and friends) require the second condition to be defined and fairly simple.

It is definitely more verbose to use join conditions like this, but having the ability is great.
