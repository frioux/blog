---
aliases: ["/archives/1477"]
title: "Announcing Log::Sprintf and Log::Structured"
date: "2010-12-08T05:13:21-06:00"
tags: ["cpan", "logging", "logsprintf", "logstructured", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1477"
---
I just released [Log::Sprintf](http://search.cpan.org/perldoc?Log::Sprintf) and [Log::Structured](http://search.cpan.org/perldoc?Log::Structured) to CPAN. They are both very simple modules, but they allow some powerful stuff.

Log::Sprintf will convert a hashref into a string given a specification **almost** conformant to Log::log4perl's log specs. The example from the SYNOPSIS is as follows:

     my $log_formatter = Log::Sprintf->new({
       category => 'DeployMethod',
       format   => '[%L]\[%p]\[%c] %m',
     });

     $log_formatter->sprintf({
       line     => 123,
       package  => 'foo',
       priority => 'trace',
       message  => 'starting connect',
     });

Also it was made with subclassing in mind from the start, so it is easy to add more flags as needed.

Log::Structured is a more generic tool but arguably more powerful. All it does is generate a "simple" (easily serializable) data structure and call a coderef that you give it with the data structure. What I hope to do with that is log to standard error using Log::Sprintf, but then log to a file using newline separated JSON documents. That means I can parse the log file DEAD easily and do what I want with it. Here's the SYNOPSIS (after Log::Sprintf-ification) for that:

     use Log::Structured;
     use Log::Sprintf;

     my $formatter = Log::Sprintf->new({ format => "[%d]\[%F:%L]\[%p]\[%c] %m" });

     my $structured_log = Log::Structured->new({
       category            => 'Web Server',
       log_category        => 1,
       priority            => 'trace',
       log_priority        => 1,
       log_file            => 1,
       log_line            => 1,
       log_date            => 1,
       log_event_listeners => [sub {
          warn $formatter->sprintf($_[1])
       }, sub {
          open my $fh, '>>', 'log';
          print {$fh} encode_json($_[1]) . "\n";
       }],
     });

     $structured_log->log_event({ message => 'Starting web server' });

     $structured_log->log_event({
       message => 'Oh no!  The database melted!',
       priority => 'fatal',
       category => 'Core',
     });

Anyway, hope you find a handy use for these!
