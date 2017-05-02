---
aliases: ["/archives/1033"]
title: "For Arcanez"
date: "2009-07-30T23:52:54-05:00"
tags: [frew-warez, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1033"
---
So I have some cool posts enqueue but they are not done and longish, so I
figured I'd post about this bug in the interaction between Perl 5.10's switch
statement and [List::Util](http://search.cpan.org/perldoc?List::Util)'s first
method.

<!--more-->

Here is a test script:

```
#!perl
use strict;
use warnings;
use feature ':5.10';

use List::Util qw{first reduce};
use Test::More 'no_plan'; # thanks mst
use Test::Deep;

my @numbers = (1..10);

cmp_deeply [ grep { $_ % 2 == 0 } @numbers], [2,4,6,8,10], 'grep works';
is((first { $_ % 2 == 0 } @numbers ), 2, 'first works');
is((reduce { $a + $b } @numbers ), 55, 'reduce works');

given (1) {
   when (1) {
      cmp_deeply [ grep { $_ % 2 == 0 } @numbers], [2,4,6,8,10], 'grep works';
      is((first { $_ % 2 == 0 } @numbers ), 2, 'first works');
      is((reduce { $a + $b } @numbers ), 55, 'reduce works');
   }
}
```

Here's the output:

```
ok 1 - grep works
ok 2 - first works
ok 3 - reduce works
ok 4 - grep works in when
not ok 5 - first works in when
#   Failed test 'first works in when'
#   at t.pl line 20.
#          got: undef
#     expected: '2'
ok 6 - reduce works in when
1..6
# Looks like you failed 1 test of 6.
```

So keep this in mind! This almost drove me crazy recently when I was working on some code at work. I had replaced a grep with a first as a performance optimization, but the code stopped working. Fortunately, Graham Barr had mentioned this issue at one of the Perl 6 meetings, and I remembered it when I found that first was at fault.
