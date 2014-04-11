---
aliases: ["/archives/1727"]
title: "DBIx::Class::DeploymentHandler + Backups"
date: "2012-06-06T16:30:34-05:00"
tags: ["cpan", "dbixclass", "dbixclassdeploymenthandler", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1727"
---
Given that [DBIx::Class::DeploymentHandler](http://p3rl.org/DBIx::Class::DeploymentHandler) is a widely misunderstood and confusing module to the point that [a friend of mine](http://jjnapiorkowski.typepad.com) wrote [DBIx::Class::Migration](http://p3rl.org/DBIx::Class::Migration) a module to wrap it up more nicely, I've decided that some blog posts showcasing how I use DBICDH are in order. If you don't already know, DBICDH was written by me, and designed my [mst](http://shadow.cat/blog/matt-s-trout/), myself, [ribasushi](https://metacpan.org/author/RIBASUSHI), and [Rob Kinyon](https://metacpan.org/author/RKINYON). The latter two claim to barely remember our discussions early on, but I'll credit them as having helped me design what I made.

# "Ancient" History

The application I almost exclusively work on is a turnkey security (ish) "thing." Historically the way our database deployments worked was as follows; one of our engineers puts the latest version of the software on the customer's server. Next the engineer runs a script that updates the database, amongst other things. The way the script works is that it has a list of all columns along with their types that are in our schema. If the script finds that a column is not in a given table, it creates it; if the column has the wrong type, it changes it; if there are extra columns, it makes them nullable.

For the most part that works extremely nicely. There are no database versions. There are no version collisions. Branching is easy, etc. The first problem is that the tool had no way to make any kind of constraints, including the primary key kind. I can't speak for MySQL, but SQL Server, which is what we use, really suffers when it doesn't know about primary or unique columns. If id is primary, where id = 1 should be a row lock. If the engine doesn't know id is primary, it has to do larger locks, which cause slowness and other problems.

The second, more major problem with our tool was that our customers' databases were almost entirely in an unknown state. One customer even had hand deployed foreign key constraints that cause our app to do all kinds of silly things. The upshot of this is that I tend to be pretty paranoid when it comes to our database migrations. You'll see more of that in one of my other DBICDH posts, but that brings me to the topic of the post at hand...

# DBIx::Class::DeploymentHandler and Backups

For our very first migration, which I've dubbed pre-modern, or 0, I made it so that our tool would make a backup of the data. Because we don't know what our customers' database looks like, it is imperitive that we ensure that their data is safe by backing it up before running our giant (596 lines Perl + 197 lines DDL) initial migration.

When we made our second migration, I decided it wouldn't hurt to just make a backup for every migration. Doing this required me to subclass DeploymentHandler and even copy/paste/mutate some code, but it works fine and I'll eventually factor out the redundant bits anyway. Here's what I came up with:

    package Lynx::DeploymentHandler;

    use strict;
    use warnings;

    use DateTime;
    use Lynx::Util;

    use base 'DBIx::Class::DeploymentHandler';

    sub upgrade {
      my $self = shift;
      while ( my $version_list = $self->next_version_set ) {
         $self->upgrade_single_step({ version_set => $version_list })
      }
    }

    sub upgrade_single_step {
       my $self = shift;

       my ( $from, $to ) = @{$_[0]->{version_set}};
       Lynx::Util::backup_database({
          schema => $self->schema,
          backup_file => DateTime->now->ymd . "-upgrade-$from-$to"
       });

       my $g = $self->schema->txn_scope_guard;

       my $ret = $self->next::method(@_);
       my ($ddl, $upgrade_sql) = @{$ret||[]};

       $self->add_database_version({
         version     => $to,
         ddl         => $ddl,
         upgrade_sql => $upgrade_sql,
       });

       $g->commit;
       $ret
    }

    1;

I've left out the downgrade code, but you can probably figure out what it looks like based on the code above. It's pretty simple. The main change I made in my copy pasta was to move the transaction into the single step method. The reason for this is that SQL Server does not allow backups to take place within a transaction.

So that's **protip 1** for DBIx::Class::DeploymentHandler. Expect more to come, hope this helps, etc.
