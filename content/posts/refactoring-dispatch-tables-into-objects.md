---
aliases: ["/archives/1648"]
title: "Refactoring Dispatch Tables into Objects"
date: "2011-08-25T06:59:57-05:00"
tags: [mitsi, dispatch-tables, objects, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1648"
---
One of the cool ways of doing things in Perl is to use a dispatch table. The most obvious dispatch table is a hash of subroutines:

    my $x;

    my $table = {
       GET => sub { return $x  },
       PUT => sub { $x = $_[0] },
    };

    sub dispatch {
       my ($method, $data) = @_;

       if (my $fn = $table->{$method}) {
          $fn->($data)
       } else {
          die 'METHOD NOT ALLOWED!'
       }
    }

This is a pretty cool thing to be able to do easily. But what's even cooler is that we can refactor the dispatch table into a package, which allows us to make objects that can override bits of the dispatch table:

    package Table {
       sub new { bless {}, $_[0] }
       sub GET { return $_[0]->{x}  }
       sub PUT { $_[0]->{x} = $_[1] }
    }

    package SubTable {
       use parent 'Table';
       sub DELETE { delete $_[0]->{x} }
    }

    my $table = SubTable->new;
    sub dispatch {
       my ($method, $data) = @_;

       if (my $fn = $table->can($method)) {
          $table->$method($data)

          # the following would also work and would be
          # marginally faster
          # $table->$fn($data)
       } else {
          die 'METHOD NOT ALLOWED!'
       }
    }

Note that one thing you might consider is prefixing the methods with "public\_" or something like that; just in case your dispatcher object as private methods you don't want web browsers executing. Generally though I'd just not put such methods in my dispatcher, but I haven't yet made anything super complex using this pattern. I **am** using the pattern for a pluggable dashboard system at work, but the methods there are all called GET\_foo or POST\_bar, so users can't run methods I didn't specifically make for HTTP.
