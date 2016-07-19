---
aliases: ["/archives/1300"]
title: "Announcing Log::Contextual"
date: "2010-02-23T04:45:11-06:00"
tags: [frew-warez, announcement, cpan, log-contextual, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1300"
---
I really should have posted this sooner. Certainly before I began my [next project](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class-DeploymentHandler.git). Oh well.

I am proud to announce the next bit of mstware! [Log::Contextual](http://search.cpan.org/perldoc?Log::Contextual) is a small module for making your life easier when it comes to logging. Instead of bringing yet another logging infrastructure into the mix (see [Log::Log4perl](http://search.cpan.org/perldoc?Log::Log4perl) and [Log::Dispatch](http://search.cpan.org/perldoc?Log::Dispatch)), this module is a thin wrapper around any logging system you choose to use. (Note: we are working with authors of major logging packages to work seamlessly with L::C, but at the time of writing most need some form of adapter.)

There are a few major features worth noting. First off, ridiculously convenient interface. Once you've set up your logger (presumably in the startup of your app or whatever) all your logging code will look like the following:

    use Log::Contextual qw( :log );
    sub hello_world {
      log_trace { 'entered hello world' };
      # ...
    }

Another great thing is that, like [Devel::Dwarn](http://search.cpan.org/perldoc?Devel::Dwarn), all of the logging functions are [identity functions](http://en.wikipedia.org/wiki/Identity_function); that is, they return their arguments. That means you can do cool things like the following:

    use Log::Contextual qw( :log );
    sub hello_world {
      my ($arg1, $arg2) = log_trace { "entered hello world with args $_[0], $_[1]" } @_;

      # ...
    }

Of course, in Perl you may be passing around complex references and the above will get cumbersome fast, so we added shortcuts specifically for logging out data structures:

    use Log::Contextual qw( :dlog );
    sub hello_world {
      my ($arg1, $arg2) = Dlog_trace { "entered hello world with args $_" } @_;

      # ...
    }

The automatic stringification is done with [Data::Dumper::Concise](http://search.cpan.org/perldoc?Data::Dumper::Concise), so you will get reasonably indented output for free.

In a separate package we are going to provide a module to basically turn the logging functions into no-ops at compile time, thus giving you the ability to have your code run just as fast if it never had the logging functions in in the first place. I'll post more on that once it's released.

So what are you waiting for? Go log stuff!
