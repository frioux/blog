---
aliases: ["/archives/1480"]
title: "Powerful benchmarking with Perl and ab"
date: "2011-08-12T06:59:59-05:00"
tags: [mitsi, ab, benchmarking, performance, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1480"
---
One of my projects at [work](http://www.lynxguide.com) was to make an SMS (and voice actually) gateway. The gist is that instead of our customers each having an account with whatever text message company, they go through us. The benefit is that with a larger pool of users for the text messages users can have a lot more flexibility with how they use their messages. Most gateways sell you messages per month, and we sell yearly messages.

One of the major uses of our software is for duress; that is, sending text messages to all the students at a college in an emergency (note: sending SMS in an emergency is a really bad idea, but people want to do it ...) Because of this we really want to put a premium on how many we can send at a time. Our old gateway (non-persistent Perl, weird database, bad API) was excruciatingly slow.

To test the speed of our server when sending a large number of messages from a single server I wrote the following script to test a number of different situations.

    #!/usr/bin/env perl

    use strict;
    use warnings;

    use JSON;

    use Getopt::Long::Descriptive;

    my ($opt, $usage) = describe_options(
      'benchmark.pl %o',
      [ 'concurrent|c=i', 'number of concurrent connections', {default => 5 } ],
      [ 'destinations|d=i',   "number of destinations to submit", { default => 100 } ],
      [ 'total-iterations|n=i',   "number of iterations to run", { default => 100 } ],
      [],
      [ 'help|h|?',       'print usage message and exit' ],
    );

    print($usage->text), exit if $opt->help;

    open my $fh, '>', 'testtest';
    print {$fh} to_json({
       message    => 'HELP! BUILDING IS ON FIRE!',
       destinations => [map +{
          phone_number => 1000000000 + $_,
          child_id     => $_,
       }, 1..($opt->destinations)]
    });

    system(
       'ab',
       qw(-T application/json),
       '-n' => $opt->total_iterations,
       qw(-p testtest),
       '-c' => $opt->concurrent,
       'http://10.6.1.56:3000/api/1/test/sms'
    );

So we have a handful of nice commandline options, we generate a file of JSON, and then we have [ab](https://httpd.apache.org/docs/2.2/programs/ab.html) run the actual speed test.

One of the really neat things you can do is have perl run more than one ab instance at a time, this allowing you to test multiple urls, which ab doesn't support natively.

Anyway, good luck speed testing the hotspots in your app!
