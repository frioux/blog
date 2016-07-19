---
aliases: ["/archives/1273"]
title: "Solution on how to serialize dates nicely"
date: "2010-01-21T16:27:00-06:00"
tags: [mitsi, datetime, dbix-class, perl, serialization]
guid: "http://blog.afoolishmanifesto.com/?p=1273"
---
So after discussing [this problem](/archives/1269) with the inimitable ribasushi we came up with a good solution. It's not quite generic, but it solves the current problem very nicely. First, we subclass DateTime:

    package MTSI::DateTime;
    use strict;
    use warnings;

    use parent 'DateTime';

    sub TO_JSON { shift->ymd }

    1;

Next, in the base class we use for all of our Result classes in our Schema, we override \_inflate\_to\_datetime to rebless the returned value into our subclass:

    package ACD::Schema::Result;
    use strict;
    use warnings;

    use parent 'DBIx::Class::Core';

    __PACKAGE__->load_components(qw{
       TimeStamp
       Helper::Row::NumifyGet
    });

    use MTSI::DateTime;

    sub _inflate_to_datetime {
       my $self = shift;
       my $val = $self->next::method(@_);

       return bless $val, 'MTSI::DateTime';
    }

    1;

And lastly, in our JSON view, we ensure that convert\_blessed is on so that json will automatically call our TO\_JSON method:

    package ACD::View::JSON;

    use Moose;
    extends 'Catalyst::View::JSON';

    use JSON::XS ();

    has encoder => (
       is => 'ro',
       lazy_build => 1,
    );

    sub _build_encoder {
       my $self = shift;
       return JSON::XS->new->utf8->convert_blessed;
    }

    sub encode_json {
       my($self, $c, $data) = @_;
       $self->encoder->encode($data);
    }

    1;

And that's all there is to it! Thanks Perl for allowing me to rebless my objects :-)
