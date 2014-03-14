---
aliases: ["/archives/1910"]
title: "Hash Your Passwords! Finale"
date: "2013-11-09T21:55:50-06:00"
tags: ["authenpassphrase", "password-hashing", "password-storage", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1910"
---
A little over a year ago [I posted](/archives/1695) what I hoped would be my last article about hashing passwords in Perl. [One of the commentors mentioned a library](/archives/1695#comment-2876), though, which in my mind makes things so much easier that it makes the topic worth revisiting.

So, as before, here is a DBICDH/DBICM conversion script:

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers 'schema_from_schema_loader';
    use Authen::Passphrase::BlowfishCrypt;

    # PROTIP: generally code reuse in migrations is *not* a good idea as changing
    #         the reused code could break future runs of the migrations, or worse,
    #         make the output subtley different, thus meaning regenerated servers
    #         could have frustratingly different results

    schema_from_schema_loader({
       naming => 'v7',
       constraint => qr/^users$/i,
    }, sub {
       my ($schema) = @_;

       $_->update({
          password => Authen::Passphrase::BlowfishCrypt->new(
             cost => 14,
             salt_random => 1,
             passphrase => $account->password,
          )->as_crypt,
       }) for $schema->resultset('User')->all
    });

Here's a one time script you can use if you don't have a migration tool:

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers 'schema_from_schema_loader';
    use Authen::Passphrase::BlowfishCrypt;
    use MyApp::Util;

    my $schema = MyApp::Util::dbic_connect();

    $_->update({
       password => Authen::Passphrase::BlowfishCrypt->new(
          cost => 14,
          salt_random => 1,
          passphrase => $account->password,
       )->as_crypt,
    }) for $schema->resultset('User')->all

Here's a one time, non-DBIC script if you don't have a migration tool:

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers 'schema_from_schema_loader';
    use Authen::Passphrase::BlowfishCrypt;
    use MyApp::Util;

    my $dbh = MyApp::Util::dbi_connect();
    my @users = @{$dbh->selectall_arrayref('SELECT "id", "password" FROM "Users"')};

    $dbh->do(
       'UPDATE "Users" SET "password" = ? WHERE "id" = ?', undef,
          Authen::Passphrase::BlowfishCrypt->new(
          cost => 14,
          salt_random => 1,
          passphrase => $_->[1],
       )->as_crypt, $_->[0]
    ) for @users;

The following is the really nice reason to use Authen::Passphrase instead of what I mentioned before, because I don't have to hack up private data to authenticate a user. Note that because we are just using Authen::Passphrase, it will actually correctly match many many kinds of hashes. So if you are silly and decide to hash your passwords with MD5 (DON'T!) this code will still work just fine.

    require Authen::Passphrase;
    if (Authen::Passphrase->from_crypt($hashed_pw_from_db)->match($pw_from_user)) {
       grant_access($user);
       exit;
    }

Finally, here is the configuration for your DBIC result that will use Authen::Passphrase:

    package My::Schema::Result::User;

    use My::Schema::Candy -components => [qw( PassphraseColumn)];

    primary_column id => {
       data_type         => 'int',
       is_auto_increment => 1,
    };

    column name => {
       data_type   => 'varchar',
       size        => 50,
    };

    column password => {
       data_type => 'varchar',
       size => '100', # 59 is almost surely sufficuent, but extra won't hurt
       passphrase => 'crypt',
       passphrase_class => 'BlowfishCrypt',
       passphrase_args => {
           cost        => 14,
           salt_random => 1,
       },
       passphrase_check_method => 'check_password',
    };

    1;

Aside from having a nicer API, Authen::Passphrase has some neat features that can help you as you work on your codebase. As mentioned before, it can handle a number of different password formats. So for instance, in my tests I have all my test users created like this:

    $schema->resultset('User')->create({
       name => "test$$",
       password => Authen::Passphrase::AcceptAll->new
    });

So in my tests I don't need to worry about hashing passwords or even getting the password correct. Similarly, if you wanted to lock out a user and you didn't already have a build in way, you could use Authen::Passphrase::RejectAll.

In closing, please, please, hash your passwords for the sake of your users. As you can see above it's really not that much work for you, the developer. Don't end up like PerlMonks, LinkedIn, Yahoo, or eHarmony. You don't want to be the guy who has to cop to being lazy and doing it wrong. [**Stop being stupid, and do it right.**](http://www.quora.com/Driving/What-are-some-parallel-parking-tips)
