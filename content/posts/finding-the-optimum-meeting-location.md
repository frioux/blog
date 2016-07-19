---
aliases: ["/archives/868"]
title: "Finding the Optimum Meeting Location"
date: "2009-06-30T02:01:16-05:00"
tags: [frew-warez, perl, geocoding]
guid: "http://blog.afoolishmanifesto.com/?p=868"
---
So I just got back from a family reunion. My family is all about Modern::Reunion, or maybe Enlightened Reunion, or maybe Reunion foo + i. So with this reunion at the end a survey (done with Google Docs) was sent out. My mom asked me if I could somehow find the weighted middle of where everyone (42~ people) lives. So I was all: CENTROID.

First off, [Centroid](http://en.wikipedia.org/wiki/Centroid) on Wikipedia. What we want is the first equation, which is surprisingly simple: average!

Next up: a way to get a Cartesian coordinate from an address: GEOCODING! I found the excellent Perl module [Geo::Coder::Yahoo](http://search.cpan.org/perldoc?Geo::Coder::Yahoo). Basically I just followed the instructions in the module to get everything set up. The hardest part is getting an API key, which is actually super easy!

So check out the sweet codez!

    #!perl

    use strict;
    use warnings;
    use feature ':5.10';
    use Data::Dumper;
    use Geo::Coder::Yahoo;
    use List::Util 'sum';

    sub average {
       my @items = @_;
       return sum(@items)/scalar(@items);
    }

    my $geocoder = Geo::Coder::Yahoo->new(
       appid => 'apikey'
    );
    my @addresses = ({
          # grands
          address => 'dsadfsfds1',
          weight  => 2,
       },{
          # Alexa
          address => '1fdsfdsfdsMI 48105',
          weight => 1
       },{
          # Clare
          address => 'fdsfdsfds91',
          weight => 1
       },{
          # Rod and Anne
          address => '3fdsfdsfds822',
          weight => 2
       },{
          # Art
          address => ' Plano, TX 75075',
          weight => 1
       },{
          # Harrison et al
          address => '1fdsfdsfds64',
          weight => 6
       },{
          # Seth
          address => '131fdsfds024',
          weight => 1
       },{
          # Dan and Kristie
          address => '90fdsfsdfds16',
          weight => 4
       },{
          # Kim + kids
          address => '16fdsfsdfds9564',
          weight => 3
       },{
          # Jason
          address => '6 Brafdsfdsfds465',
          weight => 1
       },{
          # Mark and Beth
          address => '262fdsfds3233',
          weight => 2
       },{
          # Cindy and Farel
          address => '551fdsfdsfds87',
          weight => 4
       },{
          # Josh
          address => 'Pfdsfds2-5216',
          weight => 1
       },{
          # Annie and Jon
          address => '17fdsfds7045',
          weight => 7
       },{
          # Anthony + Ruthanne
          address =>
       'Afdsawfsdss, Costa Rica Central America',
          weight => 5
       },{
          # Fans
          address => '328fdsfdsfds75',
          weight => 5
       },{
          # Priscilla and Danny
          address => '70fdsfdsfds05',
          weight => 3

          # Missing:
          # Andrew
          # Erin and Abner
       });

    my @longitude;
    my @latitude;

    foreach my $a (@addresses) {
       my $data = $geocoder->geocode(
          location => $a->{address}
       );
       for (1..$a->{weight}) {
          warn "Weird results: ".Dumper($data)
             if (scalar @{$data} != 1);
          push @longitude, $data->[0]->{longitude};
          push @latitude, $data->[0]->{latitude};
       }
    }

    my $avg_longitude = average(@longitude);
    my $avg_latitude  = average(@latitude);

    say "Avg Longitude: $avg_longitude";
    say "Avg Latitude: $avg_latitude";

You'll want to note the weights. This makes it so that larger families affect the location more.

Another thing to realize is that the choice of algorithm is certainly arbitrary. I could set up some weird multiplier so that the older a person is the more they count for. Same with the very young. Also distance could matter more the further you get, but that would mean calculating the centroid **first**, multiplying the distance from the centroid, and then recalculating the centroid. But this will work for fine for now.

Anyway, here's to using computers to make our lives better!

**update**: How did I forget to include the results?! Thanks Colin! It turns out the center is a pretty boring locale: 50ish miles south of Birmingham, AL. And that's with 7 people in Costa Rica and 2 in Hawaii!

**update**: After updating the dataset as per my cousins ideas the location is reasonably modified. We end up with the intersection of SC, NC, and GA. Also, removing my step-siblings from the dataset (they probably wouldn't come to a reunion) puts the center in the southeastern edge of the Nantahala National Forest in NC.
