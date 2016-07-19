---
aliases: ["/archives/1717"]
title: "Introducing DBIx::Class::Helper::Schema::LintContents"
date: "2012-06-04T14:12:25-05:00"
tags: [mitsi, announcement, cpan, dbix-class, dbix-class-helpers, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1717"
---
Surprisingly recently we decided to actually clean up our database in my current project at work and add primary, unique, and foreign key constraints. For most projects that's really not that hard, but because our project is a turn key server and it's deployed on hundreds of customers' sites we can't just fire up a database shell and fix any broken constraints before we deploy them. So I made a tool that would quickly and correctly delete all but one of the duplicates of primary and unique constraints, and would delete the dangling children of broken foreign keys. In the process I also had to make a lot of things non-nullable, which should explain what that's part of this module.

# Introducing [DBIx::Class::Helper::Schema::LintContents](http://p3rl.org/DBIx::Class::Helper::Schema::LintContents)

LintContents is a fairly simple tool to find "broken" constraints in your database. I can imagine two major use cases for it. The first, which I hope is less common, is when people do not deploy constraints to their database because "constraints are slow." You can use this tool and the auto methods to generate a report of rows that violate your pseudo-constraints. The other use case is what I used it for: automated fixing of various constraints before such constraints are actually deployed. Because I actually used it with Schema::Loader it does not require you to even make DBIC relationships, though using relationships is certainly supported.

Here is a simplified example of how I used this to pre-clean our database for deployment of such constraints:

    my %pks = (
       Users  => [qw(id)],
      ...
    );

    my %ucs = (
       Users => [qw(name)],
       ...
    );

    my @fks = ({
       from => 'Users',
       columns => {
          group_id => 'id',
       },
       to   => 'Groups',
    },{
       ...
    });

    my %non_nullable = (
       Users => [qw(id name)],
       ...
    );

    sub null_check {
       my ($schema, $table, $non_nullable_columns) = @_;

       my $rs = $schema->null_check_source($table, $non_nullable_columns);
       _delete_row($schema, $table_from, $_) for $rs->all
    }

    sub dup_check {
       my ($schema, $table, $unique_columns, $type) = @_;

       my $rs = $schema->dup_check_source($table, $unique_columns));
       for my $row ($rs->all) {
          my $x;
          if ($x) {
             _delete_row($schema, $table, $sub_row);
          }
          $x++;
       }
    }

    sub fk_check {
       my ($schema, $table_from, $table_to, $columns) = @_;

       my $rs = $schema->fk_check_source($table_from, $table_to, $columns);
       _delete_row($schema, $table_from, $_) for $rs->all
    }

       null_check($schema, $_, $non_nullable{$_}) for sort keys %non_nullable;
       dup_check($schema, $_, $pks{$_}, 'pk') for sort keys %pks;
       dup_check($schema, $_, $ucs{$_}, 'uc') for sort keys %ucs;
       do {
          $change_made = undef;
          fk_check($schema, $_->{from}, $_->{to}, $_->{columns}) for @fks;
       } while $change_made;

Of course there was a **lot** more there in the real thing, because I logged everything that happened, but this should certainly make it clear how you can use this module for awesome.
