---
aliases: ["/archives/63"]
title: "Ruby style functional programming in Perl!"
date: "2009-01-09T08:10:49-06:00"
tags: ["autoboxcore", "functional-programming", "perl", "ruby"]
guid: "http://blog.afoolishmanifesto.com/archives/63"
---
So recently I was asking if andand exists in perl ([here](http://perlmonks.org/?node_id=734774) and [here](http://stackoverflow.com/questions/422837/is-there-an-andand-for-perl)) and someone implemented it! How awesome is that? See it [here](http://search.cpan.org/perldoc?Scalar::Andand).

Anyway, so I looked at the code and figured, "Well heck, if it's that easy, I should do this for map and join on arrays!"

It was already done! The [autobox::Core](http://search.cpan.org/~swalters/autobox-Core-0.6/Core.pm) module does it already! You have to use more javascript-y syntax instead of regular perl-ish, but I think it makes things more clear anyway.

Example:

    #!/usr/bin/perl
    use feature ":5.10";
    use autobox::Core;
    my @foo = (1,2,3);

    say join( ',', map { $_ * 2 } @foo );
    say @foo->map(sub { $_ * 2 })->join(',');

To be perfectly clear, you would probably think of the first one as: we are joining the results of the map that multiplies each item by two and the second one as: multiply each item by two and then join them with a comma.

Anyway, I am \*so\* stoked to use this at work.
