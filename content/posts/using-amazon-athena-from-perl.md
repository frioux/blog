---
title: Using Amazon Athena from Perl
date: 2017-06-12T08:50:18
tags: [ toolsmith, ziprecruiter, perl, aws ]
guid: 496575D0-4EB5-11E7-B5B5-863F19CC4E35
---
At [ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) write "a lot"
of logs, so actually looking at the logs can be a lot of work.  Amazon Athena
provides a nice solution, and recently an API was (finally) provided to allow us
to use it in our code.  I wrote some code recently to leverage the API.

<!--more-->

We have so many logs at ZipRecruiter that we can barely keep an ElasticSearch
cluster with one week of logs running.  That is a frustrating post for another
day, but another option is to use Athena.  Athena is some open source software
put together by Amazon that will do MapReduce jobs on structured data stored in
S3, using SQL as an interface.  What a mouthful.

If none of that made any sense to you, basically it's a slow SQL database on
text files that costs money per query.  It's pretty cheap though, with a [cost
of 5$ per Terrabyte queried](https://aws.amazon.com/athena/pricing/).  We are
spending hugely more than that on our crashy ElasticSearch cluster, and that
doesn't include the (so far, mostly unhelpful) Elastico support contract.

The following is a basic script (which I expect to refactor, improve, etc) that
simply runs a query against Athena and immediately downloads the results.  I
will publish another tiny script on Wednesday that I like to use to work with
the results.

``` perl
#!/usr/bin/env perl

use 5.26.0;
use warnings;

use experimental 'signatures';

use Data::GUID 'guid_string';
use DateTime;
use Getopt::Long::Descriptive;
use Net::Amazon::S3;
use Paws;

my ($opt, $usage) = describe_options(
  '$0 %o <some-arg>',
  [ 'sql=s', "sql to run", { required => 1  } ],
  [ 'database=s', 'db to run in', { default => 'adhoc'  } ],
  [ 's3-output-location=s',
      'S3 Prefix to store to',
      { default  => "s3://sandbox.mystuff.com/$ENV{USER}-test" }
  ],
  [ 'local-output-location=s',
    'Location to download s3 files to', { default  => '.' }
  ],
  [ ],
  [ 'verbose',    'print extra info'            ],
  [ 'help',       'print usage message and exit', { shortcircuit => 1 } ],
  { show_defaults => 1 },
);

print($usage->text), exit if $opt->help;

my $athena = Paws->service('Athena', region => 'us-east-1');

my $query = $athena->StartQueryExecution(
  QueryString => $opt->sql,
  ResultConfiguration => {
    OutputLocation => $opt->s3_output_location,
  },
  QueryExecutionContext => {
    Database => $opt->database,
  },
  ClientRequestToken => guid_string(),
);

my $status;
do {
  $status = $athena->GetQueryExecution(
    QueryExecutionId => $query->QueryExecutionId,
  );
  sleep 1;
} until _is_complete($status);

my $s = $status->QueryExecution->Status;
my $start = DateTime->from_epoch( epoch => $s->SubmissionDateTime );
my $end = DateTime->from_epoch( epoch => $s->CompletionDateTime );
warn sprintf <<'OUT', $s->State, $start, $end if $opt->verbose;
Query %s!
  started at %s
 finished at %s
OUT

if ($s->State eq 'FAILED') {
  warn $s->StateChangeReason . "\n";
  exit 1;
} elsif ($s->State eq 'CANCELLED') {
  warn "query cancelled\n";
  exit 0;
}

warn "results are at " .
  $status->QueryExecution->ResultConfiguration->OutputLocation . "\n"
  if $opt->verbose;

my $a = Paws::Credential::ProviderChain->new->selected_provider;

# Paws::S3 is marked as unstable; the following wouldn't work with IAM roles.
my $s3 = Net::Amazon::S3->new(
  aws_access_key_id     => $a->access_key,
  aws_secret_access_key => $a->secret_key,
);

my ($bucket_name, $key, $file) =
  parse_s3_url($status->QueryExecution->ResultConfiguration->OutputLocation);

my $bucket = $s3->bucket($bucket_name);
my $local = $opt->local_output_location . '/' . $file;

warn "downloading $key to $local\n" if $opt->verbose;

$bucket->get_key_filename( $key, 'GET', $local );

sub _is_complete ($s) {
  $s->QueryExecution->Status->State =~ m/^(?:succeeded|failed|cancelled)$/i
}

sub parse_s3_url ($url) {
  $url =~ s/^s3:\/\///;

  my ($bucket, $key) = split qr(/), $url, 2;

  my ($file) = ($key =~ m(.*?/?([^/]+)$));

  return ($bucket, $key, $file);
}
```

---

It's not a work of art but I am thrilled to finally have this to use to run my
queries.  Note that this is using [Paws](https://metacpan.org/pod/Paws)
[0.33](https://github.com/pplu/aws-sdk-perl/tree/release/0.33) which is not yet
released, but I would be really surprised if the interface changed at all, given
how closely Paws hews to the AWS API.

---

I don't know of any resources you could purchase to learn more about this tech
and I wouldn't know if it was any good anyway.  Instead I'll just link to some
media that I'm enjoying right now.

I just started the eigth book in
<a target="_blank" href="https://www.amazon.com/gp/product/B00HL0MA3W/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00HL0MA3W&linkCode=as2&tag=afoolishmanif-20&linkId=4adf7257ad865045c586e019e34aa593">The Malazan Series</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B00HL0MA3W" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and as usual I'm enjoying it a lot.

In a totally different vein I just ordered
<a target="_blank" href="https://www.amazon.com/gp/product/B018QHQSB8/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B018QHQSB8&linkCode=as2&tag=afoolishmanif-20&linkId=9596369c129826b8979a250e7e65ad88">a thermocouple</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B018QHQSB8" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
in the hopes that it would give me more insight while roasting my coffee and
allow me to make my roasts that much better.
