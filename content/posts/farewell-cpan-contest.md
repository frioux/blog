---
title: Farewell, CPAN Contest
date: 2015-12-16T12:48:24
tags: [frew-warez, cpan, perl]
guid: "https://blog.afoolishmanifesto.com/posts/farewell-cpan-contest"
---
[In August I write about being tired](/posts/chains-of-gid/) of [The CPAN
Contest](http://onceaweek.cjmweb.net/current).  I decided recently that once I
hit 200 releases I'd stop and put my efforts elsewhere.

I am not giving up on CPAN or Perl; but I do not think timeboxed releases are
best for individuals.  Though I am very pleased to be able to write, test, and
document a new CPAN module over the course of a couple hours.

## Looking Back

Now seems like a good time to look back on the past few years; both before the
contest and during.

Here are some modules that I released before the contest started:

 * DBIx::Class::Helpers, including
   [::ResultSet::SetOperations](https://metacpan.org/pod/release/FREW/DBIx-Class-Helpers-2.032000/lib/DBIx/Class/Helper/ResultSet/SetOperations.pm),
   which is still the only way to do `UNION`s etc in DBIx::Class.
 * [Log::Contextual](https://metacpan.org/pod/release/FREW/Log-Contextual-0.006005/lib/Log/Contextual.pm)
 * [DBIx::Class::DeploymentHandler](https://metacpan.org/pod/release/FREW/DBIx-Class-DeploymentHandler-0.002218/lib/DBIx/Class/DeploymentHandler.pm)
 * [DBIx::Class::Candy](https://metacpan.org/pod/release/FREW/DBIx-Class-Candy-0.005001/lib/DBIx/Class/Candy.pm)

I also wrote over a hundred blog posts; some classics are:

 * [DBIx::Class Extended Relationships](/posts/dbix-class-extended-relationships/)
 * [Screen Scrape for Love with Web::Scraper](/posts/screen-scrape-for-love-with-web-scraper/)
 * [The Rise and Fall of `mod_perl`](/posts/the-rise-and-fall-of-mod_perl/)

And I did some other unreleased work, like:

 * [A huge amount of git migrations](https://github.com/frioux/Git-Conversions)
 * [A web view of Perl Critic](https://github.com/frioux/perlcritic-web)
 * [A weird app to track tea drinking](https://github.com/frioux/teatime)

Not bad!  Here are some modules that I released during the contest:

 * [DBIx::Introspector](https://metacpan.org/pod/release/FREW/DBIx-Introspector-0.001005/lib/DBIx/Introspector.pm)
 * Many more DBIx::Class::Helpers, most especially
   [DBIx::Class::ResultSet::DateMethods1](https://metacpan.org/pod/release/FREW/DBIx-Class-Helpers-2.032000/lib/DBIx/Class/Helper/ResultSet/DateMethods1.pm)
 * [Sub::Exporter::Progressive](https://metacpan.org/pod/release/FREW/Sub-Exporter-Progressive-0.001011/lib/Sub/Exporter/Progressive.pm)

And maybe one of the most interesting OSS things I've ever done:
[drinkup](https://github.com/frioux/drinkup).

## How The Sausage is Made / Thanks

There are a number of tools that make the overall process of releasing new or
updated modules as simple as possible.  A few spring to mind:

### `Dist::Zilla`

Rik's [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) was by and large the
most motivating and generally helpful tool in this process.  No other tools even
come close to providing the build time assistance that `Dist::Zilla` does.  I
remember when I released my very first CPAN module being incredibly intimidated
by Module::Install (which I think I can look back on as a kind of lucky guess.)
[The version that I used](https://metacpan.org/release/RJBS/Dist-Zilla-1.092680)
was recent for the time, but four major versions have been released since then!

On top of `dzil` I use a number of plugins, though not a huge amount.  If you
want to see a definitive list, [my current kit is shown
here](https://metacpan.org/source/FREW/DBIx-Class-Candy-0.005001/dist.ini).

### Github and a constellation of tools surrounding it

I have released open source code on a bunch of platforms.  Until just now I'd
never really considered how many.  I've used all of

 * Sourceforge
 * Rubyforge
 * A Blog Post Containing All The Code
 * Google Code
 * Savannah
 * Github

I remember when I signed up for Savannah they told me: "How about you write your
code first, and then you can host it here."  What a joke.

It's crazy how many of those services are just gone now!

When I started using Github they didn't even have issues, you had to use an
ascillary service called [Lighthouse](https://lighthouseapp.com/).  Anyway,
Github provides a lot of awesome features but mostly for me it boils down to:

 * I can create repos, forks, issues etc from the CLI (Using [git
   hub](https://github.com/ingydotnet/git-hub))
 * I can easily see my personal "todo list" at `https://github.com/issues`

The former means that I don't have to deal with a bloated browser or web
interface because I do this stuff so often.  In fact, when I come up with an
idea for a new project my current process is:

`git hub repo-new frioux/My-Idea && git hub issue-new frioux/My-Idea`

And then it'll show up in that central place.  Pretty cool huh?

### Testing

Many have reasonably noted that CPAN Testers is one of the few things that Perl
has and no other community has yet to emulate.  While that's true, for the vast
majority of people, actually testing on different platforms is overkill.  For
most of my modules, I pay more attention to
[TravisCI](https://travis-ci.org/frioux/), as it will test all major versions of
Perl every time I push.  Before each release I wait for travis tests to finish
just in case I missed some odd Perl 5.8 thing.

On top of that, I have a [powerful Docker
setup](https://github.com/frioux/DBIx-Class-Helpers/blob/2555eb6263474b26fca96f861c02844d9481b121/maint/with-dbs)
for
[DBIx::Class::Helpers](https://metacpan.org/release/FREW/DBIx-Class-Helpers-2.032000)
that actually runs live tests against all of `SQLite`, `mysql`, `PostgreSQL`,
and `Oracle`.  If you care to, you can even set environment variables to point
at a `SQL Server` instance as well, but I don't do that and I suspect no one
else does either.

## What's next?

I want to spend less time on libraries and more time on applications, for one.
It would be great if I were able to finally finish and use `drinkup`, though as
a parent I no longer have the time to really focus on cocktails like I used to.

I want to make some video games.

I want to get back to blogging on a weekly basis, whether the Iron Man software
ever works or not.

I want to play more with weird languages like Rust and OCaml.

Most of all, I want to enjoy my limited free time.  If I do decide to write a
module and publish it; great, but I don't want it to be a chore.  I'd say *most*
of the time when I release a new module it is fun and maybe at least a tiny bit
useful, but there are plenty of times when I've had to scrabble to come up with
something to release.
