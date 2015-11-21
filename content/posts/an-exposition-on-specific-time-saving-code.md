---
aliases: ["/archives/1282"]
title: "An Exposition on Specific Time Saving Code"
date: "2010-01-29T08:19:18-06:00"
tags: ["cpan", "dbic", "dbixclass", "extjs", "javascript", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1282"
---
I write a lot of ExtJS grids at work. I have written JavaScript classes for our Ext grids that generate as much as possible automatically, but the actual column definitions of the grids are almost always unique. The project I am on now is nearing our first real deploy, and we're late, so things have been really, really busy.

It wasn't until recently that I realized just how much time I spent working on grids and their related records (representation of the rows of a grid.) Although even if I'd known just how much I do this at the beginning of the project, I certainly didn't know [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) as much as I do now, in addition to the other 4 non-core modules that I'll mention.

Because I've been working all these super long hours (12-14 a day), often after a frustrating day I'll try to code something more relaxing and rewarding at home or at work but not during work. So today I decided to finally take the plunge and do what I've been pondering for a few months and write some code to generate Ext scaffolding for me. So I'm going to walk you through the script that I wrote (and will probably work on more as time goes by.)

This isn't a full module, not even in my repo yet, so it's all just in one file. Here's the boilerplate intro:

    #!perl

    use strict;
    use warnings;

    use feature ':5.10';

    use Syntax::Keyword::Gather;
    use String::CamelCase ();
    use Lingua::EN::Inflect ();
    use List::Util;
    use Statistics::Basic 'mean';

That's pretty basic. We use a bunch of modules that I've used in at least 1 other project before and was happy with.

    use FindBin;
    use lib "$FindBin::Bin/../local/lib", "$FindBin::Bin/../lib";
    use ACD::Schema;
    use Config::JFDI;
    my $config = Config::JFDI->new(name => 'acd', path => "$FindBin::Bin/../acd");
    my $config_hash = $config->get;
    my $connect_info = $config_hash->{Model}{DB}{connect_info};
    my $schema = ACD::Schema->connect($connect_info);

That's the code to parse any kind of Catalyst config file and the grab a new schema based on it. It's a ton of biolerplate but I live with it.

So next up is a basic inflection function that gives us all the different forms of a word we might need. It starts with either "single\_foo" or "SingleBar" and gives us six variations based on that:

    sub inflect {
       my $word = shift;

       my $return = { singular => {}, plural => {}};
       if ( defined $word->{camel}) {
          $word = $word->{camel};
          $return->{singular}{camel} = $word;
          $return->{singular}{noncamel} = String::CamelCase::decamelize($word);
       } else {
          $word = $word->{noncamel};
          $return->{singular}{camel} = String::CamelCase::camelize($word),
          $return->{singular}{noncamel} = $word;
       }
       $return->{singular}{human} = join(
          q{ }, map ucfirst $_,
          split /_/, $return->{singular}{noncamel}
       );

       $return->{plural}{noncamel} = join( q{_}, split / /,
          Lingua::EN::Inflect::PL(
             join q{ },
             split /_/,
             $return->{singular}{noncamel}
          )
       );
       $return->{plural}{camel} = String::CamelCase::camelize(
          $return->{plural}{noncamel}
       );
       $return->{plural}{human} = join( q{ }, map ucfirst $_, split /_/,
          $return->{plural}{noncamel}
       );
       return $return
    }

So that uses [String::CamelCase](http://search.cpan.org/perldoc?String::CamelCase) and [Lingua::EN::Inflect](http://search.cpan.org/perldoc?Lingua::EN::Inflect) combined with join and split mostly.

We're *almost* ready to generate a record. But first we need to define a mapping from the data type in the database to the data type that Ext uses:

    my $types_xform = {
       int => 'int',
       float => 'float',
       varchar => 'string',
       bit => 'boolean',
       datetime => 'date',
       money => 'float',
    };

Ok, now let's look at the code to generate an Ext.record:

    sub generate_record {
       my $schema = shift;
       my $source_name = shift;

       my $source = $schema->source($source_name);

       return qq{Ext.ns('ACDRI.record');

    ACDRI.record.$source_name = Ext.data.Record.create([\n} .
       join(qq{,\n}, sort { $a cmp $b } gather {
          for (map [$_, $source->column_info($_)], $source->columns) {
             my ($column, $info) = @{$_};
             take "   {name: '$column', type: '$types_xform->{$info->{data_type}}'}";
          }
       }) .  "\n]);";

    }

So what's going on here is that we get the [source](http://search.cpan.org/perldoc?DBIx::Class::ResultSource) from the [schema](http://search.cpan.org/perldoc?DBIx::Class::Schema). The source could be considered something like a table definition, although it can also point at a view or whatever too. Then we start generating the string representing our record, and then we use a join/[gather](http://search.cpan.org/perldoc?Syntax::Keyword::Gather) combo to get the column data the way we want it.

We could certainly just use a more complex map instead of the for+gather that we have, but I personally feel than any map where you \*must\* use the block form is cumbersome. So we join together all of the strings that gather took, and then append the end of the definition, and voilà, we have a record!

Here's example output on our Customer source:

    Ext.ns('ACDRI.record');

    ACDRI.record.Customer = Ext.data.Record.create([
       {name: 'color_code', type: 'string'},
       {name: 'comments', type: 'string'},
       {name: 'id', type: 'string'},
       {name: 'last_edited_date', type: 'date'},
       {name: 'name', type: 'string'},
       {name: 'price_approval_required', type: 'boolean'},
       {name: 'sales_representative_id', type: 'int'}
    ]);

If you're still following along you should be fine with the next, much more impressive functionality.

I'd like to have the script do as much as possible to speed up my work, so let's see how far we can take this. First, I made a mapping from type to renderer, so that things that are datetimes use our custom datetime renderer, same with booleans:

    my $renderer_from_type = {
       datetime => 'ACDRI.fn.Renderers.dateTime',
       bit => 'ACDRI.fn.Renderers.bool',
    };

Next, I wrote a function that would try it's best to guess how wide a column should be based on it's header and the average width of the strings inside of it:

    sub avg_width {
       my ($rs, $col, $header) = @_;
       List::Util::max (
          mean(map +( defined($_) ? length "$_" : 0 ), $rs->get_column($col)->all), # average width of field
          length $header                                                            # col header
       );
    }

Now finally we have the grid function:

    sub generate_grid {
       my $schema = shift;
       my $source_name = shift;

       my $source_names = inflect({ camel => $source_name });
       my $source = $schema->source($source_name);

       return qq\`/*global Ext */
    /*global ACDRI */
    /*global MTSI */
    Ext.ns('ACDRI.ui.grid');

    /**
     * \@class ACDRI.ui.grid.$source_names->{plural}{camel}
     * \@extends MTSI.ui.Grid
     */
    ACDRI.ui.grid.$source_names->{plural}{camel} = Ext.extend(MTSI.ui.Grid, {
       title: '$source_names->{plural}{human}',
       record: ACDRI.record.$source_names->{singular}{camel},
       updateConfig: {
          xtype: 'ACDRI.ui.form.$source_names->{singular}{camel}'
       },
       addConfig: {
          xtype: 'ACDRI.ui.form.$source_names->{singular}{camel}',
       },
       initComponent: function () {
          //this.sortInfo = {
          //   field: 'part_id',
          //   direction: 'asc'
          //};
          var config = {
             url: '$source_names->{plural}{noncamel}',
             itemName: '$source_names->{singular}{human}',
             columns: [\` .
       join (qq{, }, gather {
          for (map [$_, $source->column_info($_)], $source->columns) {
             my ($column, $info) = @{$_};
             my $colnames = inflect({ noncamel => $column });
             my $renderer = $renderer_from_type->{$info->{data_type}}
                ? "\n            renderer: $renderer_from_type->{$info->{data_type}},"
                : '';
             my $width;
             given ($info->{data_type}) {
                when ('varchar') {
                   $width = int 7*avg_width(
                      $source->resultset, $column, $colnames->{singular}{human}
                   );
                }
                when ('datetime') {
                   $width = List::Util::max(
                      int 7 * length $colnames->{singular}{human},
                      57
                   );
                }
                default {
                   $width = int 7 * length $colnames->{singular}{human};
                }
             }
             take qq[{
                header: '$colnames->{singular}{human}',
                dataIndex: '$column',
                sortable: true,
                hidden: false,$renderer
                width: $width
             }];
          }
       }) .  qq\`]
          };

          Ext.apply(this, Ext.apply(this.initialConfig, config));
          ACDRI.ui.grid.$source_names->{plural}{camel}.superclass.initComponent.apply(this, arguments);
       }
    });

    Ext.reg('ACDRI.ui.grid.$source_names->{plural}{camel}', ACDRI.ui.grid.$source_names->{plural}{camel});
    \`;
    }

We see nearly the same structure here that we did with the record, except much more intricate. Notice the code to generate the width uses the magic constant 7. As I played with this I found that 7 seemed to work for the font that Ext uses by default (Arial?) Optimally I would actually use some kind of metrics package to ask it for the width of all of the strings that I generated in the function above and average that, instead of averaging character lengths. But this seems to work really, really well, so the ROI is pretty good.

Also note the code to pick and insert the renderer. It's not complex or anything, but it yields very convenient results. Here's the output of running this one on the same source we used for the record:

    /*global Ext */
    /*global ACDRI */
    /*global MTSI */
    Ext.ns('ACDRI.ui.grid');

    /**
     * @class ACDRI.ui.grid.Customers
     * @extends MTSI.ui.Grid
     */
    ACDRI.ui.grid.Customers = Ext.extend(MTSI.ui.Grid, {
       title: 'Customers',
       record: ACDRI.record.Customer,
       updateConfig: {
          xtype: 'ACDRI.ui.form.Customer'
       },
       addConfig: {
          xtype: 'ACDRI.ui.form.Customer',
       },
       initComponent: function () {
          //this.sortInfo = {
          //   field: 'part_id',
          //   direction: 'asc'
          //};
          var config = {
             url: 'customers',
             itemName: 'Customer',
             columns: [{
                header: 'Comments',
                dataIndex: 'comments',
                sortable: true,
                hidden: false,
                width: 226
             }, {
                header: 'Color Code',
                dataIndex: 'color_code',
                sortable: true,
                hidden: false,
                width: 70
             }, {
                header: 'Id',
                dataIndex: 'id',
                sortable: true,
                hidden: false,
                width: 35
             }, {
                header: 'Last Edited Date',
                dataIndex: 'last_edited_date',
                sortable: true,
                hidden: false,
                renderer: ACDRI.fn.Renderers.dateTime,
                width: 112
             }, {
                header: 'Name',
                dataIndex: 'name',
                sortable: true,
                hidden: false,
                width: 136
             }, {
                header: 'Price Approval Required',
                dataIndex: 'price_approval_required',
                sortable: true,
                hidden: false,
                renderer: ACDRI.fn.Renderers.bool,
                width: 161
             }, {
                header: 'Sales Representative Id',
                dataIndex: 'sales_representative_id',
                sortable: true,
                hidden: false,
                width: 161
             }]
          };

          Ext.apply(this, Ext.apply(this.initialConfig, config));
          ACDRI.ui.grid.Customers.superclass.initComponent.apply(this, arguments);
       }
    });

    Ext.reg('ACDRI.ui.grid.Customers', ACDRI.ui.grid.Customers);

Note that there are probably some things that we could do a little better. For instance, we should probably check for text fields and not include them in the grid. We could also be clever and look for anything ending with \_id and have it hidden by default. But in general, the above is very nice results. At the very least you are probably going to need to reorder the columns (although you could give some kind of grid\_order\_id to the column definition in the Schema::Result code, but I don't think that's worth it.)

So I hope someone else enjoyed reading this as much as I did writing it. After I've exhausted all of the little Ext things I can use this for (form, etc) I will probably look into messing with [DBICx::AutoDoc](http://search.cpan.org/perldoc?DBICx::AutoDoc) to add in Dia outputs.
