---
aliases: ["/archives/1695"]
title: "Hash your passwords!"
date: "2012-09-03T19:37:51-05:00"
tags: ["cpan", "dbixclass", "dbixclassencodedcolumn", "passwords", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1695"
---
More than two years ago I blogged about how to [correctly store passwords](/archives/1286). [Recently a number of high profile websites have had their password storage compromised](http://arstechnica.com/security/2012/08/passwords-under-assault/). The storage method I blogged about **two years ago** is still hugely better than what LinkedIn (SHA1, no salt) and I think Gawker had. If you aren't already securely storing passwords, this post should get you going on a conversion.

First off, here's a [DBICDH](http://search.cpan.org/~frew/DBIx-Class-DeploymentHandler-0.002201/lib/DBIx/Class/DeploymentHandler.pm)/[DBICM](http://search.cpan.org/~jjnapiork/DBIx-Class-Migration-0.026/lib/DBIx/Class/Migration.pm) compatible conversion script

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers 'schema_from_schema_loader';
    use Crypt::Eksblowfish::Bcrypt;

    # hashing code taken from DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt

    # PROTIP: generally code reuse in migrations is *not* a good idea as changing
    #         the reused code could break future runs of the migrations, or worse,
    #         make the output subtley different, thus meaning regenerated servers
    #         could have frustratingly different results

    my $cost = 8;
    my $nul  = 0;

    $nul = $nul ? 'a' : '';
    $cost = sprintf("%02i", 0+$cost);

    my $settings_base = join('','$2',$nul,'$',$cost, '$');

    my $encoder = sub {
      my ($plain_text, $settings_str) = @_;
      unless ( $settings_str ) {
        my $salt = join('', map { chr(int(rand(256))) } 1 .. 16);
        $salt = Crypt::Eksblowfish::Bcrypt::en_base64( $salt );
        $settings_str = $settings_base.$salt;
      }
      return Crypt::Eksblowfish::Bcrypt::bcrypt($plain_text, $settings_str);
    };

    schema_from_schema_loader({
       naming => 'v4',
       constraint => qr/^users$/i,
    }, sub {
       my ($schema) = @_;

       $_->update({ password => $encoder->($account->password) })
          for $schema->resultset('Users')->all
    });

Of course if your passwords are not hashed, I would be blown away if you are using DBICDH or DBICM. I understand that beginning to use a migration tool is a huge step. So here's a one-time migration perl script you can use that does not involve DBICDH or DBICM:

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers 'schema_from_schema_loader';
    use Crypt::Eksblowfish::Bcrypt;
    use MyApp::Util;

    my $cost = 8;
    my $nul  = 0;

    $nul = $nul ? 'a' : '';
    $cost = sprintf("%02i", 0+$cost);

    my $settings_base = join('','$2',$nul,'$',$cost, '$');

    my $encoder = sub {
      my ($plain_text, $settings_str) = @_;
      unless ( $settings_str ) {
        my $salt = join('', map { chr(int(rand(256))) } 1 .. 16);
        $salt = Crypt::Eksblowfish::Bcrypt::en_base64( $salt );
        $settings_str =  $settings_base.$salt;
      }
      return Crypt::Eksblowfish::Bcrypt::bcrypt($plain_text, $settings_str);
    };

    my $schema = MyApp::Util::dbic_connect();

    $_->update({ password => $encoder->($account->password) })
       for $schema->resultset('Users')->all

Are you not even using DBIC? You just use straight DBI? I still want you to not have an excuse:

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::ScriptHelpers 'schema_from_schema_loader';
    use Crypt::Eksblowfish::Bcrypt;
    use MyApp::Util;

    my $cost = 8;
    my $nul  = 0;

    $nul = $nul ? 'a' : '';
    $cost = sprintf("%02i", 0+$cost);

    my $settings_base = join('','$2',$nul,'$',$cost, '$');

    my $encoder = sub {
      my ($plain_text, $settings_str) = @_;
      unless ( $settings_str ) {
        my $salt = join('', map { chr(int(rand(256))) } 1 .. 16);
        $salt = Crypt::Eksblowfish::Bcrypt::en_base64( $salt );
        $settings_str =  $settings_base.$salt;
      }
      return Crypt::Eksblowfish::Bcrypt::bcrypt($plain_text, $settings_str);
    };

    my $dbh = MyApp::Util::dbi_connect();
    my @users = @{$dbh->selectall_arrayref('SELECT "id", "password" FROM "Users"')};

    $dbh->do(
       'UPDATE "Users" SET "password" = ? WHERE "id" = ?', {},
          $encoder->($_->[1]), $_->[0]
    ) for @users;

Of course, it doesn't matter if your data is converted but your application cannot support the new method. If you are just using Catalyst + DBIC use my [original blog post](/archives/1286) on this subject. If, like us, you have a mixture of DBIC, CGI, and Catalyst, you'll want to do a bit more work. In our CGI scripts we can't load up our DBIC schema as it slows most of the website down way too much, so instead I hacked around it and just loaded up the user class:

    require My::Schema::Result::User;
    my $u = My::Schema::Result::User->new({});

    $u->{_column_data}{password} = $hashed_password_from_database;

    if ($u->check_password($password)) {
       grant_access($user);
       exit; # don't you miss CGI?
    }

Lastly, if you are not using DBIC at all, you'll want to make a couple little utility functions like this for hashing passwords:

    package MyApp::Util;

    use strict;
    use warnings;

    # ...

    # again, based on DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt
    my $cost = 8;
    my $nul  = 0;

    $nul = $nul ? 'a' : '';
    $cost = sprintf("%02i", 0+$cost);

    my $settings_base = join('','$2',$nul,'$',$cost, '$');

    sub check_password { hash_password($_[0], $_[1]) eq $_[1] }

    sub hash_password {
       my ($plain_text, $settings_str) = @_;
       require Crypt::Eksblowfish::Bcrypt;

       unless ( $settings_str ) {
          my $salt = join('', map { chr(int(rand(256))) } 1 .. 16);
          $salt = Crypt::Eksblowfish::Bcrypt::en_base64( $salt );
          $settings_str =  $settings_base.$salt;
       }
       return Crypt::Eksblowfish::Bcrypt::bcrypt($plain_text, $settings_str);
    }

To use the above you do either of the following:

    hash_password('>=6char$')     check_password('>=6char$', $hashed)

# No Excuses

I've done all the hard work for you. Stop waffling. Stop irresponsibly storing your passwords in **any** other way. If you're already hashing your passwords, but you aren't salting them, [chromatic has a post on how to take care of this](http://www.modernperlbooks.com/mt/2012/02/upgrading-user-password-hashes-in-place.html). If you are storing your passwords insecurely it is **your fault** if your passwords get into the wrong hands and cracked. **Fix it today.**
