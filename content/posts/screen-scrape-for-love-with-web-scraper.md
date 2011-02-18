---
aliases: ["/archives/1515"]
title: "Screen Scrape for Love with Web::Scraper"
date: "2011-02-18T01:22:45-06:00"
tags: ["cpan", "perl", "webscraper"]
guid: "http://blog.afoolishmanifesto.com/?p=1515"
---
My fiancée and I have not yet picked out a date for our wedding, but we do know that we want it outdoors. We have scoped out a number of locations that can handle indoor and outdoor weddings just in case there is bad weather, but we'd prefer to have perfect weather.

After some searching I found NOAA's [NSSL](http://data.nssl.noaa.gov/dataselect/), which has ridiculous amounts of data. Instead of most websites, which give you the average high temperature and average low temperature for a given day of the year from the past three years, this gives hourly measurements for basically anything back to 1910. Of course some stations are newer and whatnot, but it's a lot of data.

Their website only lets you get one day of data at a time, so I wrote a screen scraper using the excellent [Web::Scraper](http://search.cpan.org/perldoc?Web::Scraper). Here's most of it:

    #!/usr/bin/env perl

    use Modern::Perl;
    use JSON;
    use URI;
    use Web::Scraper;

    # http://www.unidata.ucar.edu/cgi-bin/gempak/manual/apxA_index
    my %data_to_grab = (
      SMPH => 'wind-speed',
      TMPF => 'temperature',
      RELH => 'humidity',
    );

    my $data_str = join ';', sort keys %data_to_grab;

    my $weather = scraper {
        # there isn't a class, so we find the table with width 90
        process "table[width=90] tr", "datas[]" => scraper {
          process "td:nth-child(2)", 'when' => 'TEXT';
          my $i = 2;
          for (sort keys %data_to_grab) {
             $i++;
             process "td:nth-child($i)", $data_to_grab{$_} => 'TEXT';
          }
        };
    };

    sub moar_data {
       my ($y, $m, $d) = @_;
       my $res = $weather->scrape( URI->new(sprintf 'http://data.nssl.noaa.gov/dataselect/nssl_result.php?datatype=sf&sdate=%4i-%02i-%02i&hour=00&sdate2=%4i-%02i-%02i&hour2=23&outputtype=list&param_val=%s&area=&area=@DFW', $y, $m, $d, $y, $m, $d, $data_str));

       warn sprintf "%4i-%02i-%02i\n", $y, $m, $d;
       sleep 3 + rand(2);
       grep {
          # undefined when means there wasn't actualy an observation
          defined $_->{when} &&
          # ignore headers
          $_->{when} ne 'YYMMDD/HHMM'
       } @{$res->{datas}}
    }

    my @end = (
       map {
          my $year = $_;
          (map { moar_data($year, 9, $_) } (1..30)),
          (map { moar_data($year, 10, $_) } (1..31)),
       } ( 1990..2010 )
    );

    print to_json(\@end, { pretty => 1 });

The scraper object grabs a bunch of the data from TD's in the table, skipping the first TD. I made the moar\_data function which just takes year, month, day so that I could get more data. It outputs all the data as json, my prefered data format.

If you did the math at home, you realized this is a ridiculous amount of observations; something along the lines of 14 thousand observations. That means you can't just look at it. So I also wrote a little tool to slice and dice the data. Check it out:

    #!/usr/bin/env perl

    use Modern::Perl;
    use JSON;
    use List::Util qw(min max);
    use Statistics::Basic qw(mean stddev);

    my $field = $ARGV[0];

    die "please choose a field to research" unless $field;
    die "$field is not a valid field!" unless grep { $_ eq $field }
       qw(wind-speed temperature humidity);

    # expected format:
    #   [
    #      {
    #        wind-speed => 123,
    #        temperature => 123,
    #        when    => 'YYMMDD/HHMM',
    #      },
    #      ...
    #   ]

    my $data = from_json(do {
       local $/ = undef;
       open my $fh, 'weather.json';
       <$fh>
    });

    # final format:
    # MMDD/HHMM => [{...}],
    my %by_day;

    for (@$data) {
      my $when = $_->{when};
      $when =~ s/^\d\d//; # remove the year part
      $by_day{$when} = [] unless $by_day{$when};
      push @{$by_day{$when}}, $_;
    }

    say 'datetime ,mean ,stddev,min,max ';
    for (sort keys %by_day) {
       my @list = map $_->{$field}, grep {
          # this is weird, -9999.00 is apparently what they used
          # before they had undef?
          defined $_->{$field} &&
          $_->{$field} != -9999.00
       } @{$by_day{$_}};
       my $avg    = sprintf '%3.2f', mean \@list;
       my $min    = sprintf '%3.2f', min @list;
       my $max    = sprintf '%3.2f', max @list;
       my $stddev = sprintf '%3.2f', stddev \@list;
       say "$_,$avg,$stddev,$min,$max";
    }

Anyway, this was a fun project and a nice little valentines day surprise. Hope someone finds it useful :-)
