---
aliases: ["/archives/602"]
title: "Moose makes Perl OO Sexy!"
date: "2009-05-01T04:46:53-05:00"
tags: [frew-warez, mitsi, moose, perl, webcritic, perl-critic]
guid: "http://blog.afoolishmanifesto.com/?p=602"
---
We should have all heard of Moose by now as a great way to do OO with Perl. While I was working on WebCritic I decided that it would be a good idea to hook my OO stuff up Moose style. I figure that even if I were to just write code and then disappear I might as well write 2009 code instead of 1999 code so that if it ever gets copied it will bless the copier instead of curse them.

One reason that Moose is great is that it makes things that you do all the time very succinct and obvious. For example, before:

    sub directory {
       my $self = shift;
       my $dir = shift;
       if ($dir) {
          $self->{directory} = $dir;
       }
       return $self->{directory};
    }

after:

    has directory => (
       is => 'rw',
       isa => 'Str',
       required => 1,
    );

That's not a lot shorter, but it is more clear. Plus we get some extra error checking for free.

There's also some cool options that allow you to write cleaner code. Before:

    sub critic {
       my $self = shift;
       my $dir = $self->directory;
       if ( !$self->{critic} ) {
          $self->{critic} = Perl::Critic->new(
             -e "$dir/.perlcriticrc"
             ? ( -profile => "$dir/.perlcriticrc" )
             : ( -severity => 'brutal', -theme => 'core' )
          );
       }
       return $self->{critic};
    }

After:

    has critic => (
       is => 'ro',
       lazy => 1,
       builder => '_build_critic'
    );

    sub _build_critic {
       my $self = shift;
       my $dir = $self->get_directory;
       return Perl::Critic->new(
          -e "$dir/.perlcriticrc"
          ? ( -profile => "$dir/.perlcriticrc" )
          : ( -severity => 'brutal', -theme => 'core' )
       );
    }

The boilerplate in the first version goes away in the new version. Much nicer.

And lastly, check this out, before:

    sub new {
       my $class = shift;
       my $args = shift;
       my $self = {};
       bless $self, $class;
       my $directory = $args->{directory}
          or croak q/didn't pass a directory into constructor/;
       $self->{files_criticized} = {};
       $self->directory( $args->{directory} );
       return $self;
    }

after:

    # nothing!

That's right! All of that goes away and gets created automatically by Moose. The error checking is done automatically. Instantiation is done automatically. And heck, it will even work with a hash or hashref as the instatiation data!
