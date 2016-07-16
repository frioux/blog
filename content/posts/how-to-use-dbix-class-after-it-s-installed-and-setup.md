---
aliases: ["/archives/65"]
title: "How to use DBIx::Class after it's installed and setup"
date: "2009-01-10T22:40:57-06:00"
tags: ["dbix-class", "perl"]
guid: "http://blog.afoolishmanifesto.com/archives/65"
---
This is how I think a lot of code probably looks. Although it should be in methods and stuff, here is at the very least how to do just the basics:

    #!/usr/bin/perl
    use strict;
    use feature ":5.10";
    use MyApp;
    use MyApp::DB;
    use JSON;
    use Scalar::Andand;

    my $schema = MyApp::DB->connect(@MyApp::DBConnectData);

    #find a given shop
    my $shop = $schema->resultset('Shop')->find(51311);
    say $shop->ShopNo;
    say $shop->OrderNo;
    say $shop->AgentRequestedFirst;
    say $shop->AgentRequestedLast;
    say '';

    #find all shops where the AgentRequestedLast starts with Dy
    my $rs = $schema->resultset('Shop')->search({
            AgentRequestedLast => {'LIKE', 'Dy%'},
        },{
            rows => 10,
            order_by => ['AgentRequestedLast',
                        'AgentRequestedFirst', 'ShopNo DESC']
        });

    # output pages 1, 3, and 6
    foreach (1,3,6) {
        say '';
        say "Page: $_";
        my $paged = $rs->page($_);
        while (my $shop = $paged->next() ) {
            #Note: I added this method to my Shop class
            say $shop->as_string;
            # Note: Andand is awesome.
            #Thanks groovy, raganwald, and Leon
            say $shop->ShopperDueDate->andand->day_name();
        }
    }

    # and to get some sweet, delicious JSON
    $rs = $schema->resultset('Shop');
    use DBIx::Class::ResultClass::HashRefInflator;
    $rs = $rs->search({
            AgentRequestedLast => {'LIKE', 'Dy%'},
        },{
            rows => 10,
            order_by => ['AgentRequestedLast',
                      'AgentRequestedFirst', 'ShopNo DESC'],
            columns => [qw/AgentRequestedLast
                                 AgentRequestedFirst ShopNo/]
        });
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $data = {data=>[]};
    while (my $shop = $rs->next() ) {
        push @{$data->{data}}, $shop;
    }
    say to_json($data);
