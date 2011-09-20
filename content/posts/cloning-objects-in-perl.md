---
aliases: ["/archives/1675"]
title: "Cloning Objects in Perl"
date: "2011-09-20T06:59:37-05:00"
tags: ["clone", "clonehooker", "moose", "moosexclone", "perl", "storable"]
guid: "http://blog.afoolishmanifesto.com/?p=1675"
---
Recently I needed to do some deep cloning of some objects at work. I think I ended up looking at all of the major ways to do it, and I figure I might as well discuss them here.

# What is deep cloning?

Nearly everyone should be able to answer this, but it doesn't hurt to define it anyway. Deep cloning means you clone other things the current object is related to, recursively. So while a shallow clone of a hashref (in Perl) would be merely:

    my $clone = { %{ $other_hash_ref } };

That doesn't do if the things in the hash get mutated and are also references, because in that case you'll be modifying parts of the other hash, possibly surprisingly.

# Isn't this solved?

Well yes. If it's something as basic as a simple data structure you can just use [Storable](https://metacpan.org/module/Storable). The code for above would become:

    use Storable 'dclone';
    my $clone = dclone($other_hash_ref);

Storable has been core enough for long enough that if it's not core you need to upgrade ;-)

# What's your problem?

Sadly just default Storable isn't good enough. I needed to deeply clone the objects, but **not** clone any related schemata. That is, the objects had a [DBIx::Class::Schema](https://metacpan.org/module/DBIx::Class::Schema) object attached to them and for various reasons I do not want to clone that at all. The correct way to deal with such an issue is to define the two Storable hooks as follows:

    my @stack;
    sub STORABLE_freeze {
       my ($self, $cloning) = @_;

       die q(you can't freeze this thing silly!) unless $cloning;

       my %ret = %$self;

       my %frame;
       $frame{schema} = delete $ret{schema};
       push @stack, \%frame;

       return \%ret
    }

    sub STORABLE_thaw {
       my ($self, $cloning, $ice) = @_;

       die q(you can't thaw this thing silly!) unless $cloning;
       my %frame = %{pop @stack};
       my $new = $self->new({
          %$self,
          map {
             $_ => $frame{$_}
          } keys %frame,
       });

       %$self = %$new;
    }

This is a little more generic than you probably need, and came from my prototype module, [Clone::Hooker](https://github.com/frioux/Clone-Hooker/blob/master/lib/Clone/Hooker.pm), but I gave up on that as well as Storable.

# Why did you give up on Storable?

Two reasons; first, defining the hooks above might be a bad thing. Storable is something that someone other than me may use, and by defining the hooks above I am changing the relatively generic interface of Storable for my module. Second, there's a better alternative that I ended up using.

# WHAT DID YOU DO?!

I ended up settling on the handy [MooseX::Clone](https://metacpan.org/module/MooseX::Clone). Obviously it is for Moose modules only, but all of my modules are Moose objects in this case. It's very simple to use, here's how it works for me:

       package Dashboard;

       use Moose;

       with 'MooseX::Clone';

       has gadgets => (
          is => 'rw',
          isa => 'ArrayRef',
          traits => [qw(Clone)],
       );

       1;

       package Gadget;

       use Moose;

       with 'MooseX::Clone';

       has schema => (
          is => 'ro',
       );

       1;

       my $d = Dashboard->new(
          gadgets => [
             Gadget->new(
                schema => $schema,
             )
          ]
       );

       my $cloned_d = $d->clone;

This avoids the "global" nature of changing the interface of Storable, is fairly unobtrusive in my code, and works well.
