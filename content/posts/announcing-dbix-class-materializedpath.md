---
aliases: ["/archives/1758"]
title: "Announcing DBIx::Class::MaterializedPath"
date: "2012-09-10T19:55:21-05:00"
tags: ["cpan", "dbixclass", "dbixclassmaterializedpath", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1758"
---
Have you ever wanted to store trees in your database? How about store them and avoid melting your database server at retrieval time? Did you want to use materialized path and were sad when there were no quality modules to do it with DBIx:Class?

# [DBIx::Class::MaterializedPath](http://search.cpan.org/~frew/DBIx-Class-MaterializedPath-0.001000/lib/DBIx/Class/MaterializedPath.pm)

I recently had a need for storing tree-ish data in a table and [I got it working with extended relationships and a helper or two](https://github.com/frioux/drinkup/commit/8705745a7b5ca72e86f44637aef9249d4ddfc86f). On the airplane on the way to and from YAPC I got the code factored into it's own module and then a few weeks later I got docs done.

Less talk more rock! Here's an **real life** example of how to use this!

    package DU::Schema::Result::Ingredient;

    use DU::Schema::Candy;

    primary_column id => {
       data_type => 'int',
       is_auto_increment => 1,
    };

    column kind_of_id => {
       data_type => 'int',
       is_auto_increment => 1,
       is_nullable => 1,
    };

    column materialized_path => {
       data_type => 'varchar',
       is_nullable => 1,
       size => 255,
       accessor => '_materialized_path',
    };

    unique_column name => {
       data_type => 'nvarchar',
       size => 50,
    };

    column description => {
       data_type => 'ntext',
       is_nullable => 1,
    };

    __PACKAGE__->load_components('MaterializedPath');

    sub materialized_path_columns {
       return {
          kind_of => {
             parent_column => 'kind_of_id',
             parent_fk_column => 'id',
             materialized_path_column => 'materialized_path',
             parent_relationship => 'direct_kind_of',
             children_relationship => 'direct_kinds',
             full_path => 'kind_of',
             reverse_full_path => 'kinds',
             include_self_in_path => 1,
             include_self_in_reverse_path => 1,
          },
       }
    }

    belongs_to direct_kind_of => '::Ingredient', 'kind_of_id', {
       join_type => 'left',
       proxy => {
          direct_kind_of_name => 'name',
       },
    };
    has_many direct_kinds => '::Ingredient', 'kind_of_id';
    has_many inventory_items => '::InventoryItem', 'ingredient_id';
    has_many links_to_drink_ingredients => '::Drink_Ingredient', 'ingredient_id';

    1;

This module works and I really like the api, but there are two caveats. It uses recursion and uses the new \_\_SUB\_\_ 5.16 feature to do it. I'll take a patch to fix this as long as after the patch, when using 5.16 it still uses the core version and not whatever other module does it for < 5.16. The second is that the order of the tree is not guaranteed. There's this hack people have used where you order by the length of the materialized path, but it's totally a hack. "1.2.3" sorts the same as "123.4", which is wrong. So I'll be ok with the sort thing as an option, but I'd much rather a real solution at some point.
