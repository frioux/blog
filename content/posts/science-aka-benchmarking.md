---
aliases: ["/archives/1191"]
title: "SCIENCE (aka benchmarking)"
date: "2009-10-02T01:38:30-05:00"
tags: ["benchmarking", "perl", "science"]
guid: "http://blog.afoolishmanifesto.com/?p=1191"
---
Recently we were doing something at work where we needed to get to a location deep in an HoH. We already had a solution that worked alright, but it was copy pasted in a couple places, it wasn't tested, and it wasn't documented. So I looked around on CPAN and found [Hash::Path](http://search.cpan.org/perldoc?Hash::Path). It did exactly what we wanted, but the code was recursive instead of iterative (like our solution.) Because we weren't going too deep I just installed it and figured I'd look at the actual differences later.

Well, I think last week I felt the urge to see what the difference actually was, empirically speaking. The following is my test case:

    #!perl
    use strict;
    use warnings;
    use Time::HiRes 'gettimeofday';
    use Hash::Path;
    use feature ':5.10';

    sub generate_giant_thing {
       my $items = shift;
       my $top_level_data_structure = {};
       my $current = $top_level_data_structure;
       for (0..( $items - 1 )) {
          $current->{"f$_"} = {};
          $current = $current->{"f$_"};
       }
       $current->{"f$items"} = 1;
       return ($top_level_data_structure, [ map "f$_", (0..$items) ]);
    }
    my ($foo,$path) = generate_giant_thing(500);

    sub our_path {
       my $data_set = shift;
       my @hash_keys = @_;
       my $levels = scalar @hash_keys;
       my $return_value =  $data_set->{$hash_keys[0]};
       for (1..($levels - 1)) {
          $return_value = $return_value->{$hash_keys[$_]};
       }
       return $return_value;
    }
    {
       my $before = gettimeofday;
       say our_path($foo, @{$path});
       my $after = gettimeofday;
       warn 'Our Time: '.sprintf('%0.3f', $after - $before).' seconds';
    }

    {
       my $before = gettimeofday;
       say Hash::Path->get($foo, @{$path});
       my $after = gettimeofday;
       warn 'HP Time: '.sprintf('%0.3f', $after - $before).' seconds';
    }

Ours stayed pretty close to 0.001 seconds, whereas the other version went a little slower (I think up to like, .010 s) but ran out of stack before I could test much deeper. So I put the testcase [on RT](http://rt.cpan.org/Public/Bug/Display.html?id=50024) in the hopes that the developer checked his email. He does and he updated the module just a couple days later! Pretty cool, huh?
