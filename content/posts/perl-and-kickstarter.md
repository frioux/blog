---
title: Perl ❤ Kickstarter
date: 2015-08-03T20:43:25
tags: [frew-warez, ziprecruiter, perl]
guid: "https://blog.afoolishmanifesto.com/posts/perl-kickstarter"
---
Today my boss, knowing that I am interested in weird modern cooking, sent me a
link to the [Imperial
Spherificator](https://www.kickstarter.com/projects/spherificator/imperial-spherificator),
which lets you make whatever kind of caviar you want, like mint or coffee
liqueur or Tabasco.  I want to make some Worcestershire and soy sauce!  Anyway,
when he showed it to me there were no available "VERY EARLY BIRD" (or other
limited variants) left.  But to him there was one available, which is crazy
because higher levels had been paid for.

My theory is that someone cancelled their order, thus freeing up one of the
early bird specials.  After seeing that I made a joke about writing a Perl
script to scrape the page and let me know when someone else cancels so that I
could get a low price option.  My boss asked if there was a `Net::Kickstarter`,
and it turns out that there's actually a
[`WWW::Kickstarter`](https://metacpan.org/pod/WWW::Kickstarter)!

So then I had to do it; I wrote a program as a one liner entirely, to poll the
reward levels and alert me when there were any units available.  Here it is,
reformatted to not be crazy wide:

```perl
#!/usr/bin/perl

use 5.22.0;
use warnings;

use WWW::Kickstarter;

my $ks = WWW::Kickstarter->new;
$ks->login('frioux@gmail.com', $ENV{KS_PASS});
while (1) {
   sleep 30;
   say $_->text . "\a " . $_->id . " " . $_->backers_count
      for grep {
         $_->id =~ /^41951(16|33|52)$/ and
         $_->backers_count != $_->max_backers
      } $ks->project('imperial-spherificator')->rewards
}
```

And then, less than 2 hours later, a console beep let me know within a minute
that a unit was available, and I backed it!  Thanks Perl!
