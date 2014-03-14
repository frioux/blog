---
aliases: ["/archives/1140"]
title: "Moose Test Refactoring"
date: "2009-09-07T21:06:58-05:00"
tags: ["moose", "perl", "speed", "tests"]
guid: "http://blog.afoolishmanifesto.com/?p=1140"
---
I've taken care of a significant portion of the [refactoring that I'm doing](/archives/1124) to disable meta-tests for the Moose test suite. I've done all the tests up until the 100 series (which are examples.) The following is an example of how it's done:

    #!/usr/bin/perl

    use strict;
    use warnings;

    use lib 't/lib';

    use Test::More tests => 23;
    use Test::Exception;

    use MetaTest;

    {
        package Foo;
        use Moose;
        use Moose::Util::TypeConstraints;
    }

    skip_meta {
       can_ok('Foo', 'meta');
       isa_ok(Foo->meta, 'Moose::Meta::Class');
    } 2;

    meta_can_ok('Foo', 'meta', '... we got the &meta method');
    ok(Foo->isa('Moose::Object'), '... Foo is automagically a Moose::Object');

    skip_meta {
       dies_ok {
          Foo->meta->has_method()
       } '... has_method requires an arg';

       dies_ok {
          Foo->meta->has_method('')
       } '... has_method requires an arg';
    } 2;
    can_ok('Foo', 'does');

    skip_meta {
       foreach my $function (qw(
                                extends
                                has
                                before after around
                                blessed confess
                                type subtype as where
                                coerce from via
                                find_type_constraint
                                )) {
           ok(!Foo->meta->has_method($function), '... the meta does not treat "' . $function . '" as a method');
       }
    } 15;

Typically there will be some skip\_meta blocks scattered throughout a test. As it stands the skip\_meta (and skip\_all\_meta variant) will skip if the SKIP\_META\_TESTS environment variable is set. As I said before, if people want to change that it's only defined in one place so we can change how it's done fairly easily.

There are a few places I'm not sure I need to skip yet, like things in the Moose::\*::Meta namespace. But I know for sure to skip the ->meta stuff, so that's what I've been doing. The 100 tests are quite a bit more complex, which is why I haven't finished any yet. I certainly plan to, and hope to take care of them soon. But in the meantime mst can get started on Antlers as a good amount of the tests should work for him now.

If anyone wants to help out let me know, and we can make Moose faster sooner!
