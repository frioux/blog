---
aliases: ["/archives/1530"]
title: "DBIx::Class::Helper::Row::RelationshipDWIM: Awesome!"
date: "2011-03-15T14:34:25-05:00"
tags: [mitsi, cpan, dbix-class, dbix-class-helpers, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1530"
---
Thanks to some idle chatting in the #dbix-class channel on irc.perl.org I came up with [DBIx::Class::Helper::Row::RelationshipDWIM](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::RelationshipDWIM). The gist of it is that you get to type

    __PACKAGE__->has_many(addresses => '::Address', 'person_id' )

instead of

    __PACKAGE__->has_many(addresses => 'MyApp::Schema::Result::Address', 'person_id' )

That yields a total sugar (with candy) of the following:

    package Lynx::SMS::Schema::Result::MessageParent;

    use Lynx::SMS::Schema::Candy;

    primary_column id => {
       data_type         => 'int',
       is_auto_increment => 1,
    };

    column account_id => { data_type => 'int' };
    column type_id => { data_type => 'int' };

    column caller_id => {
       data_type => 'int',
       size      => 11,
       is_nullable => 1,
    };

    column message => {
       data_type => 'nvarchar',
       size => 1000,
    };

    column when_created => {
       data_type     => 'datetime',
       set_on_create => 1,
    };

    column voice_id => {
       data_type     => 'int',
       is_nullable   => 1,
    };

    belongs_to account => '::Account', 'account_id';
    belongs_to voice => '::Voice', 'voice_id';
    belongs_to type => '::Type', 'type_id';
    has_many children => '::MessageChild', 'message_parent_id';

    1;

Pretty nice.
