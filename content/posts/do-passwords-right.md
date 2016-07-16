---
aliases: ["/archives/1286"]
title: "Do Passwords Right"
date: "2010-02-04T05:20:47-06:00"
tags: ["catalyst", "dbix-class", "dbixclassencodedcolumn", "eksblowfish", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1286"
---
You all know not to put your passwords into the database in plaintext. [Catalyst](http://search.cpan.org/perldoc?Catalyst::Runtime) and [DBIx::Class::EncodedColumn](http://search.cpan.org/perldoc?DBIx::Class::EncodedColumn) make doing this super easy and completely secure.

First off, you might want to check out the [wikipedia article](http://en.wikipedia.org/wiki/Cryptographic_hash_function) about cryptographic hash functions. The gist of it though is this: a password stored in plain text is obviously compromised if the passwords file gets into the hands of evildoers. You can "hash" the passwords and they are now harder for the attackers to transform into plain-text. If your password is good it is nearly impossible, but basically what can happen is that the attacker uses the algorithm to generate hashes for every word in the dictionary or whatever and now they basically can crack all the basic passwords.

You can take it a step further and "salt" your passwords ([wikipedia salt article]().) A simple way of doing that is just to concatenate some string onto the end of all of your passwords. This will make dictionary attempts useless unless they know your salt. Typically when using a salt the salt is kept secret.

And then you can have a unique salt per password. Imagine a scheme where the salt is $username$id. It would require the attackers to basically generate a dictionary per user!

The scheme we've settled on uses [Eksblowfish](http://en.wikipedia.org/wiki/Crypt_(Unix)#Blowfish-based_scheme). The [DBIC Component](http://search.cpan.org/~frew/DBIx-Class-EncodedColumn-0.00006/lib/DBIx/Class/EncodedColumn/Crypt/Eksblowfish/Bcrypt.pm) for it actually uses a 16 character randomly generated salt for every password. Nice!

Ok, so how does one apply such sweet, sweet code? First, (always) set up your model. This is a slightly trimmed version of ours:

    package MTSI::Schema::Result::User;

    use strict;
    use warnings;

    use parent 'DBIx::Class::Core';

    use CLASS;

    CLASS->load_components(qw/EncodedColumn/);

    CLASS->table('users');

    CLASS->add_columns(
       id => {
          data_type         => 'integer',
          is_numeric        => 1,
          is_nullable       => 0,
          is_auto_increment => 1,
       },
       username => {
          data_type         => 'varchar',
          size              => 50,
          is_nullable       => 0,
       },
       password => {
          data_type     => 'CHAR',
          size          => 59,
          encode_column => 1,
          encode_class  => 'Crypt::Eksblowfish::Bcrypt',
          encode_args   => { key_nul => 0, cost => 8 },
          encode_check_method => 'check_password',
    });

    CLASS->set_primary_key('id');

    1;

Easy peasy! The encode\_check\_method option for password basically puts a method in your result class that you can call with a plaintext password and it returns true or false if the password is legitimate. The nice thing about that is that if you decide to switch to some other kind of hashing, your controller stays the same. Model code for the win!

Next up, the Catalyst configuration. This was what took me a while to find, but thanks to [mst](http://www.shadowcat.co.uk/blog/matt-s-trout/) I finally found it yesterday. The package we use for auth is the same one everyone uses in Cat: [Catalyst::Plugin::Authentication](http://search.cpan.org/perldoc?Catalyst::Plugin::Authentication). The docs that I was looking for specifically were the ones for [Catalyst::Authentication::Credential::Password](http://search.cpan.org/perldoc?Catalyst::Authentication::Credential::Password). So after reading those docs, the following is the catalyst config snippet one would use for these nice passwords:

       'Plugin::Authentication' => {
          use_session => 1,
          default => {
             credential => {
                class              => 'Password',
                password_type      => 'self_check',
             },
             store => {
                class                     => 'DBIx::Class',
                user_model                => 'DB::User', #<-- DB refers to the name of the
                role_relation             => 'roles',         #     model class we are using
                use_userdata_from_session => 1,
             }
          }
       },

Note: the password\_type of self\_check is what tells the controller to just call $result->check\_password($plaintext).

So there you have it. That's **all the code** you need for secure passwords with Catalyst. If you make a new project and your users passwords get compromised it is **your fault**.

Have a nice day :-)
