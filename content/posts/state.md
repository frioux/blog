---
aliases: ["/archives/1323"]
title: "\"state\""
date: "2010-04-25T15:38:18-05:00"
tags: ["5-10", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1323"
---
Yesterday I was reading [this post](http://www.modernperlbooks.com/mt/2010/04/state-and-the-syntax-of-encapsulation.html) by chromatic and I **finally** understood what state does. If you look at the [perldoc for state](http://perldoc.perl.org/functions/state.html) you will see why. There is quite a dearth of examples there.

Anyway, here's a real world example from our code base which uses state in a slightly different way from what is probably typical.

Before:

    {
       # predeclare a day's duration as well
       # as the set of weekdays to save time
       my $day = DateTime::Duration->new(days => 1);
       my $weekdays = none(1..5);

       method date_due($start_date, $max_days) {
          my $ret = $start_date + DateTime::Duration->new(days => $max_days);
          while($ret->dow eq $weekdays) { $ret -= $day }
          return $ret;
       }
    }

After:

    method date_due($start_date, $min_days) {
       # state declares the variables the first time that date_due is run
       state $day = DateTime::Duration->new(days => 1);
       state $weekdays = none(1..5);

       my $ret = $start_date + DateTime::Duration->new(days => $min_days);
       while($ret->dow eq $weekdays) { $ret -= $day }
       return $ret;
    }

I agree with chromatic on this one; it's not lifechangingly better, but given enough usage I think it could make things much more clear.
