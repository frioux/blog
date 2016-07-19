---
aliases: ["/archives/1494"]
title: "Announcing Config::ZOMG"
date: "2011-01-12T06:44:24-06:00"
tags: [announcement, frew-warez, config-jfdi, config-zomg, cpan, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1494"
---
For a while now I've wanted to tear [Config::JFDI](http://search.cpan.org/perldoc?Config::JFDI) up. Since I first used it it's always been too heavy and had too many little weird things. Well, I did that last night and it ended up getting three times faster! I've released the fork as [Config::ZOMG](http://search.cpan.org/perldoc?Config::ZOMG) (I considered GTFO and STFU, but thought better of it.)

For the most part it's the same as Config::JFDI of course, but basically what I did was remove the substitution and install\_accessor features, removed isa checks, and switched from Any::Moose to Moo with inlined defaults. One other major thing I did was took out the superfluous API bits. I see no reason for $config->load, $config->get, and $config->config to do the exact same thing, so now you just get load.

If you are unfamiliar with all of this basically what this means is that you can create a file myapp.json and myapp\_local.json and it will load both of those and merge them, with local winning. Also it will work with almost any other file format out there (yaml, perl, Config::General, etc) supported but Config::Any.

Here's how to use it:

    use Config::ZOMG;
    my $config_hash = Config::ZOMG->open( path => './myapp' );

    # or if you want to keep the object around (maybe to use the reload feature)

    my $config = Config::ZOMG->new( path => './myapp' );
    my $config_hash = $config->load;

Anyway, if you are interested make sure to check out the docs, since there are actually more features as is, but **my** usage is basically as above.

I have some plans for the future that I think are exciting, like instead of just a universal config file reader, a universal writer as well. I'll keep you all posted.

Oh and if you are interested in a tiny, unscientific benchmark, check this out:

    helena [6555] ~ $ time perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'
    perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'  0.53s user 0.05s system 99% cpu 0.583 total

    helena [6556] ~ $ time perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'
    perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'  0.52s user 0.05s system 99% cpu 0.580 total

    helena [6556] ~ $ time perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'
    perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'  0.54s user 0.03s system 97% cpu 0.577 total

    helena [6556] ~ $ time perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'
    perl -MConfig::JFDI -E'Config::JFDI->open(path => "./dbic")'  0.51s user 0.06s system 98% cpu 0.575 total

    helena [6556] ~ $ time perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'
    perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'  0.16s user 0.02s system 98% cpu 0.187 total

    helena [6557] ~ $ time perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'
    perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'  0.18s user 0.01s system 95% cpu 0.201 total

    helena [6557] ~ $ time perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'
    perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'  0.16s user 0.02s system 96% cpu 0.183 total

    helena [6557] ~ $ time perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'
    perl -MConfig::ZOMG -E'Config::ZOMG->open(path => "./dbic");'  0.15s user 0.03s system 97% cpu 0.180 total

and the file (dbic.json) looks like:

    {
       "profile":"console",
       "log_sprintf": {
          "caller_depth":2,
          "caller_clan":"^Try::Tiny|^DBIx::Class|^Log::Sprintf",
          "format": "%l%n%m%n",
       },
       "no_repeats":1,
       "placeholder_surround":["\u001b[30;46m","\u001b[0m"]
    }
