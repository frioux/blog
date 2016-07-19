---
aliases: ["/archives/1269"]
title: "What is the right way to serialize X object generically?"
date: "2010-01-21T03:03:01-06:00"
tags: [mitsi, perl, serialization]
guid: "http://blog.afoolishmanifesto.com/?p=1269"
---
Background: dates in our database automatically get "inflated" to
[DateTime](http://search.cpan.org/perldoc?DateTime) objects. That works pretty
much perfectly. We use JSON to serialize all of our objects to go to our
JavaScript stuff on the client side. The way that works is basically like the
following:

    # this should probably be called something more generic, like serialize
    # but this decision was made by someone else and I'm not going to
    # spend time solving that for now
    sub TO_JSON {
       my $self = shift;
       return {
          map +( $_ => $self->$_),
             qw{id name when_created}
       };
    }

which expands to:

    {
       id => 1,
       name => 'frew',
       when_created => DateTime->new(...),  # <-- not ok
    }

Problematically, DateTime has no TO\_JSON method. I see two solutions to this,
both of which kinda suck.

### Monkey Patch

I could do something like:

    no strict 'refs';
    *DateTime::TO_JSON = sub { shift->ymd };
    use strict;

but we all know that Monkey Patching is Sketch Towne City. Since perl is a
prototypical language there is certainly a way to do something like:

    my $f = DateTime->now;
    $f::TO_JSON = sub { shift->ymd };

but I couldn't really figure out how to do it. And even if I could that
(probably easy with [Class::MOP](http://search.cpan.org/perldoc?Class::MOP)) I'd
still have to make hooks to do that to all to all of our DateTime objects (which
still sucks.) And then I could effectively do the same thing...

### Subclass DateTime

    package DateTime::Frew;
    use parent 'DateTime';

    sub TO_JSON { shift->ymd };

And then do some kind of trickery in DBIC-land to make the DateTime
instantiation able to use other classes. But that's not as simple as it might
sound (due to design issues in DBIC that are not easy to solve as far as I can
see.)

I'm pretty sure that there is a good solution that I'm missing. What is it? Can
anyone tell me?
