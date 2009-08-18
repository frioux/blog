---
aliases: ["/archives/1072"]
title: "Perl 6 in Perl 5 FOR THE WIN"
date: "2009-08-18T01:20:01-05:00"
tags: ["cpan", "gather", "perl", "perl-5", "perl-6"]
guid: "http://blog.afoolishmanifesto.com/?p=1072"
---
Today I wanted to generate a list from another list. Typically I would use map for this, but I wanted to iterate over **two** elements at a time, instead of one at a time. (A lot of people said to use **natatime** from [List::MoreUtils](http://search.cpan.org/perldoc?List::MoreUtils), over and over. They didn't read my question very carefully, especially since I specifically said I wanted natatime but with map.)

Anyway, mst pointed out [Perl6::Gather](http://search.cpan.org/perldoc?Perl6::Gather), which works perfectly for this situation! Ah the beauty of Perl 6 in Perl 5. Here are the codez:

    my @list = (
      foo => [qw{bar baz biff}],
    );

    my @new_list = gather {
      while (my ($foo, $bar) = splice(@list, 2, 0) ) {
         take map { "$foo/$_" } @list;
      }
    };

So basically what that does is create an implicit accumulator and every time you call take it adds the arguments to take to the accumulator. In Perl 6 map can iterate over multiple items at once, so this would be silly in that context, but in Perl 5 it's quite helpful!
