---
aliases: ["/archives/770"]
title: "Web Comic Downloaders"
date: "2009-06-02T05:08:31-05:00"
tags: ["automation", "perl", "ruby", "webcomics"]
guid: "http://blog.afoolishmanifesto.com/?p=770"
---
Since the beginning of my serious webcomic journey with xkcd, I think that was
four years ago, I've been writing little scripts to help me get started. The
first type of script is to grab integer-based, monotonically increasing files.
Very easy. Done in Ruby.

    #!/usr/bin/ruby -w

    Fromat = "http://foobar.com/comics/%08d.gif"
    1.upto(986) do |i|
      `wget #{sprintf(Fromat, i)}`
      sleep 1
    end

The next harder are the ones that are based on the date of publication. Usually
though, they will be published Monday-Wed-Fri or something like that, so you can
just increase per day and then check if it's the correct weekday. See more Ruby.

    #!/usr/bin/ruby -w

    Day = 60 * 60 * 24

    Fromat = "http://www.foobar.com/comics/st%Y%m%d.gif"

    t = Time.local(2005, 2, 5)

    MWF = [1,3,5]

    until t == Time.local(2007, 7, 9)
      if MWF.include? t.wday
        `wget #{t.strftime(Fromat)}`
        sleep 3
      end

      t += Day
    end

And then lastly, and hardest of all, are arbitrary files that can only be
ascertained by clicking links. Perl + CPAN to the rescue!!!

    #!perl
    use strict;
    use warnings;
    use feature ':5.10';

    use WWW::Mechanize;
    my $mech = WWW::Mechanize->new( autocheck => 1 );

    sub process_page {
       my @images = $mech->find_all_images(
          url_abs_regex => qr{http://www\.foobar\.com/memberimages/.*\.jpg}i
       );
       foreach (@images) {
          my $url = $_->url;

          if ($url !~ qr/banner/i) {
             say "downloading $url";
             qx{wget $url};
          }
       }
    }

    $mech->get( 'http://www.foobar.com/foo/bar/series.php?view=single&ID=72709' );
    process_page;
    while (
       $mech->follow_link(
          # third link on page matching regex
          n             => 3,
          url_abs_regex =>
             qr{http://www\.webcomicsnation\.com/dmeconis/familyman/series\.php\?view=single&ID=\d+}i
       )
    ) {
       sleep 1;
       process_page;
    }

This last one should be checked on every now and then as it is easy for it to
get stuck in an infinite loop on the last couple comics.

Anyway, enjoy! This set of scripts should take care of all of your webcomic
scraping needs :-)

Note: these are not to avoid ads, but to speed up the initial reading process as
speed is an issue when reading 400 or more strips.
