---
title: CSV Databases in Perl
date: 2017-06-14T07:28:15
tags: [ ziprecruiter, perl, sql, csv, toolsmith ]
guid: FEF36992-50B4-11E7-8475-F3F419CC4E35
---
On Monday [I wrote about using Amazon Athena from
Perl](/posts/using-amazon-athena-from-perl/).  That's only step one though,
because often I find myself needing to dig further.

<!--more-->

Athena provides results as CSV.  I have a couple tools I use to interact with
CSV.  The older, [which I've mentioned
before](/posts/day-to-day-tools/#csv2json-https-github-com-frioux-dotfiles-blob-c109ceb28ef9ab34ac35ca07d943049763fdacb5-bin-csv2json),
is a filter that reads CSV on STDIN and writes JSON on STDOUT.  I use it with
normal shell tools and `jq`:

``` perl
#!/usr/bin/env perl

use strict;
use Text::xSV;
use JSON::XS;

my $CSV = Text::xSV->new();
my $JSON = JSON::XS->new->canonical->utf8;
$CSV->read_header();
while (my $row = $CSV->fetchrow_hash) {
    print $JSON->encode($row) . "\n";
}
```

Then I might do something like:

```
cat foo.csv | csv2json | jq .username
```

The above is handy for little scripts, but what I've been enjoying lately is
actual SQL, so I have a script to use CSV as a database. I think I'm calling it
`csvsh`.  It wraps [`dbish`](https://metacpan.org/pod/DBI::Shell) and leverages
[DBD::CSV](https://metacpan.org/pod/DBD::CSV) and does some annoying backbends
to ease the use of the tool.

``` perl
#!/usr/bin/env perl

use strict;
use warnings;

use autodie;

use Term::ANSIColor;

my $csv = shift or die "usage: $0 <path-to-csv>\n";

my $dir = $csv =~ s(^(.*/)([^/]+))($1/.$2)r;

unless (-d $dir) {
  mkdir $dir;
  link $csv, "$dir/_";
}

chdir $dir;

open my $fh, '<', '_';
my $header = <$fh>;
close $fh;

print colored(['bold'], "table is _, columns are $header");

system 'dbish', 'dbi:CSV:f_dir=.';

END {
  chdir q(..);
  unlink "$dir/_";
  rmdir $dir;
};
```

I want to make it support a `--sql` argument at some point but haven't gotten
around to it yet.  Here's an example session of `csvsh`:

```
$ csvsh ~/Downloads/3d5f3e2c-f9eb-48bc-9a3f-628a739e011d.csv
table is _, columns are "eventname","eventsource","eventtype","sourceipaddress","cnt"
Useless localization of scalar assignment at /home/frew/.plenv/versions/5.26.0/lib/perl5/site_perl/
5.26.0/DBI/Format.pm line 377.
DBI::Shell 11.95 using DBI 1.636

WARNING: The DBI::Shell interface and functionality are
=======  very likely to change in subsequent versions!


Connecting to 'dbi:CSV:f_dir=.' as ''...
@dbi:CSV:f_dir=.> SELECT SUM(cnt), eventname FROM _ GROUP BY eventname;
SUM,eventname
68,'DescribeInternetGateways'
4,'GetBucketVersioning'
68,'DescribeApplications'
68,'DescribeDBSecurityGroups'
253,'DescribeAutoScalingGroups'
68,'DescribeSpotInstanceRequests'
460,'DescribeAccountAttributes'
3,'DescribeRegions'
260,'GetSendQuota'
68,'DescribeCacheSecurityGroups'
68,'DescribeEnvironments'
68,'DescribeNetworkInterfaces'
264,'GetAccountSummary'
136,'DescribeAddresses'
68,'DescribeVpcs'
68,'DescribeSubnets'
[ ... ]
```

It's a little noisy at startup, but it still works pretty well.

---

As with Monday's post I don't have much I can link to that adds to this
information, so I'll duplicate the stuff I'm interested in this week:

(The following includes affiliate links.)

I just started the eigth book in
<a target="_blank" href="https://www.amazon.com/gp/product/B00HL0MA3W/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00HL0MA3W&linkCode=as2&tag=afoolishmanif-20&linkId=4adf7257ad865045c586e019e34aa593">The Malazan Series</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B00HL0MA3W" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and as usual I'm enjoying it a lot.

In a totally different vein I just ordered
<a target="_blank" href="https://www.amazon.com/gp/product/B018QHQSB8/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B018QHQSB8&linkCode=as2&tag=afoolishmanif-20&linkId=9596369c129826b8979a250e7e65ad88">a thermocouple</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B018QHQSB8" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
in the hopes that it would give me more insight while roasting my coffee and
allow me to make my roasts that much better.
