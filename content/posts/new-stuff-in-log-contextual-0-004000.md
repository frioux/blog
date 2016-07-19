---
aliases: ["/archives/1591"]
title: "New Stuff in Log::Contextual 0.004000"
date: "2011-08-07T06:59:10-05:00"
tags: [frew-warez, log-contextual, cpan, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1591"
---
I just released [Log::Contextual 0.004000](https://metacpan.org/module/FREW/Log-Contextual-0.004000/lib/Log/Contextual.pm) and it has a handful of great features.

It now supports arbitrary levels, so where before you simply had:

- trace
- debug
- info
- warn
- error
- fatal

Now you can have any levels by just saying

    use Log::Contextual -levels => [qw(lol wut zomg)], ':log';

which would import functions for log levels lol, wut, and zomg.

But the really exciting thing is that now you can make a base class of Log::Contextual and set defaults for all of the different import options:

    package MyApp::Log::Contextual;

    use parent 'Log::Contextual';

    use Log::Log4perl ':easy';
    Log::Log4perl->easy_init($DEBUG);

    sub arg_logger { $_[1] || Log::Log4perl->get_logger }

    1;

The $\_[1] in arg\_logger is whatever logger the user passed in when they said "use MyApp::Log::Contextual -logger => ...". You can choose to allow them to override the logger like I did above, or you can force them to always use the logger that you set.

You can also use the arg\_levels, arg\_default\_logger, and arg\_package\_logger methods, but I doubt anything other than arg\_logger and arg\_levels will be common.

Anyway, I hope people find this release as exciting as I do; I know it will make my code a lot nicer.
