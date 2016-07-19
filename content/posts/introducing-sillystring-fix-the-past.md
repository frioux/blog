---
aliases: ["/archives/502"]
title: "Introducing SillyString: fix the past!"
date: "2009-04-02T05:02:45-05:00"
tags: [mitsi, perl, dbix-class, sillystring]
guid: "http://blog.afoolishmanifesto.com/?p=502"
---
So in the project we are doing at work right now the customer has a fairly old dataset. Old enough that it originally was impossible to properly capitalize all of your words. I do a search and get a list of customers:

    AMERICAN AIRLINES
    SOUTHWEST AIRLINES
    A.O.G.
    L3 COMMUNICATIONS
    ...

_Why are you yelling at me?!_ I want to say.

Yesterday I had 30 minutes left in the day and I figured that I might as well do something that would make me feel good. I decided to make a DBIC inflator that would fix this issue. The idea is that in your DBIC setup you don't just have Core, but also +ACD::SillyString and then when you configure your columns this takes care of recapitalizing things. You just add silly\_string => 'title\_case' to your column definition and it will DWIM. Maybe eventually I'll add support for sentences. Also after I clean it up I'd like to put it on CPAN. We'll see!

    package ACD::SillyString;

    use strict;
    use warnings;
    use base qw/DBIx::Class/;

    __PACKAGE__->load_components(qw/InflateColumn/);

    sub register_column {
      my ($self, $column, $info, @rest) = @_;

      $self->next::method($column, $info, @rest);
      return unless defined($info->{silly_string});

      my $type = lc $info->{silly_string};

      if ($type eq 'title_case') {

        $self->inflate_column($column => {
              inflate => sub {
                my ($value, $obj) = @_;
                if ($value eq uc $value or $value eq lc $value) {
                   $value =~ s/(\w)(\w+ ?)/\U$1\L$2/g;
                }
                return $value;
              }
        });
      }
    }

On thing that I really like about this code is that it only applies to strings which are all uppercase or all lowercase. That way if the customer does correctly capitalize things, or wants to change the way that the code is capitalized by the model, they can. It really makes everything look a lot more professional.
