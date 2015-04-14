---
title: Announcing DBIx::Class::Candy::ResultSet
date: 2015-04-14T12:26:27
tags: ["DBIx::Class", "DBIx::Class::Candy", "DBIx::Class::Helpers", "perl", "cpan"]
guid: "https://blog.afoolishmanifesto.com/posts/announcing-dbix-class-candy-resultset"
---
Hello all!

I just released [DBIx::Class::Candy
0.003000](http://metacpan.org/release/FREW/DBIx-Class-Candy-0.003000), which
comes with
[DBIx::Class::Candy::ResultSet](https://metacpan.org/pod/release/FREW/DBIx-Class-Candy-0.003000/lib/DBIx/Class/Candy/ResultSet.pm).
This should completely resolve the issues I mentioned in [my previous
post](/posts/mros-and-you).  This is how I use it:

```perl
package Lynx::SMS::Schema::Candy::ResultSet;

use strict;
use warnings;

use parent 'DBIx::Class::Candy::ResultSet';

sub base { 'Lynx::SMS::Schema::ResultSet' }

1;

```

```perl
package Lynx::SMS::Schema::ResultSet::MessageChild;

use Lynx::SMS::Schema::Candy::ResultSet;

...

1;
```

If anyone runs into any issues let me know.  Sorry that perl didn't use `c3`
from day one!
