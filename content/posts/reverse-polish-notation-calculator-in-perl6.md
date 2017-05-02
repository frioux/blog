---
aliases: ["/archives/359"]
title: "Reverse Polish Notation Calculator in Perl6++"
date: "2009-03-03T15:17:31-06:00"
tags: [perl, perl-6]
guid: "http://blog.afoolishmanifesto.com/?p=359"
---
Apparently Patrick Michaud, pumpking of rakudo, read my
[post](/posts/perl-5-to-perl-6-a-reverse-polish-notation-calculator/) yesterday
and he came up with an [even better
solition](https://web.archive.org/web/20100113121021/http://use.perl.org/~pmichaud/journal/38580)!

<!--more-->

I'd read his post if I were you, but here was the code he got it down to (after adding the R meta op :-) ):

        my %op_dispatch_table = {
            '+'    => { .push(.pop + .pop)  },
            '-'    => { .push(.pop R- .pop) },
            '*'    => { .push(.pop * .pop)  },
            '/'    => { .push(.pop R/ .pop) },
            'sqrt' => { .push(.pop.sqrt)    },
        };

        sub evaluate (%odt, $expr) {
            my @stack;
            my @tokens = $expr.split(/\s+/);
            for @tokens {
                when /\d+/     { @stack.push($_); }
                when ?%odt{$_} { %odt{$_}(@stack); }
                default        { die "Unrecognized token '$_'; aborting"; }
            }
            @stack.pop;
        }

        say "Result: { evaluate(%op_dispatch_table, @*ARGS[0]) }";

Brilliant!
