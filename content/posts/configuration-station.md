---
title: Configuration Station
date: 2015-02-19T21:16:27
tags: [mitsi, frew-warez, "moo", "moose", "perl", "configuration"]
guid: "https://blog.afoolishmanifesto.com/posts/configuration-station"
---
We've all dealt with and implemented configuration systems.  I've set up a few
different kinds over time.  I think the very first was something like the
following:

    package MyApp::Util;

    use strict;
    use warnings;
    use JSON;

    our @DBI_PARAMS = do {
       open my $fh, '<', "C:/inetpub/myapp.json"
          or die "couldn't open myapp.json: $!";
       @{decode_json(<$fh>)}
    };

    ...

    1;

It certainly leaves a lot to be desired!  At the minimum it at least gave us
something better than hardcoded settings, but that's almost all it gave us.

My next config was something like this:

    package MyApp::Util;

    use strict;
    use warnings;

    sub config {
       open my $fh, '<', "C:/inetpub/myapp.json"
          or die "couldn't open myapp.json: $!";
       decode_json(<$fh>)
    }

    1;

This is better; it's not global so you can do more with the config.  You can
have it return a hash instead of just setting a bunch of variables.

Next there was the Catalyst way (and also Config::JFDI/Config::ZOMG):

    my $config = Config::ZOMG->new(
       name => 'my_app',
       path => 'C:/inetpub',
    );
    my $config_hash = $config->load;

This gives the subtle (and dubious, in my mind) benefit of allowing the user to
have the normal config and a separate file with overrides in it, usually called
the local config.

Finally I have something that I think is superior to all of the above; it has
two parts.

First, the loader:

    package Proof::ConfigLoader;

    use utf8;
    use Moo;
    use warnings NONFATAL => 'all';

    use experimental 'signatures';

    use JSON::MaybeXS;
    use IO::All;
    use Try::Tiny;
    use Module::Runtime 'use_module';
    use namespace::clean;

    has _env_key => (
       is => 'ro',
       init_arg => 'env_key',
       required => 1,
    );

    has _location => (
       is => 'ro',
       init_arg => undef,
       lazy => 1,
       default => sub ($self) {
          $ENV{$self->_env_key . '_CONFLOC'} || $self->__location
       },
    );

    has __location => (
       is => 'ro',
       init_arg => 'location',
       default => 'ca/conf.json',
    );

    has _config_class => (
       is => 'ro',
       init_arg => 'config_class',
       required => 1,
    );

    sub _io ($self) { io->file($self->_location) }

    sub _read_config_from_file ($self) {
       try {
          decode_json($self->_io->all)
       } catch {
          warn "Couldn't load config from file <".$self->_io.">. Using env conf.\n";
          {}
       }
    }

    sub _read_config_from_env ($self) {
       my $k_re = '^' . quotemeta($self->_env_key) . '_(.+)';

       +{
          map {; m/$k_re/; lc $1 => $ENV{$self->_env_key . "_$1"} }
          grep m/$k_re/,
          keys %ENV
       }
    }

    sub _read_config ($self) {
       {
          %{$self->_read_config_from_file},
          %{$self->_read_config_from_env},
       }
    }

    sub load ($self) { use_module($self->_config_class)->new($self->_read_config) }

    sub store ($self, $obj) {
       $self->_io->print(encode_json($obj->as_hash))
    }

    1;

As you might be able to see, the API for the above is pretty simple.  The
general use case is just:

    my $loader = Proof::ConfigLoader->new(
       env_key => 'PROOF',
       config_class => 'Proof::Config',
    );
    my $config = $loader->load;

and every now and then:

    $loader->store($config);

And next, the actual config object:

    package Proof::Config;

    use utf8;
    use Moo;
    use warnings NONFATAL => 'all';

    use JSONY;

    use namespace::clean;

    use experimental 'signatures';

    has root_http_path => (
       is => 'ro',
       default => '/cert',
    );

    has port => (
       is => 'ro',
       default => 80,
       coerce => sub { $_[0] + 0 },
    );

    has data_root => (
       is => 'ro',
       default => sub { 'ca' },
    );

    has csr_dir => (
       is => 'ro',
       lazy => 1,
       default => sub { shift->data_root . '/csr' },
    );

    has cert_dir => (
       is => 'ro',
       lazy => 1,
       default => sub { shift->data_root . '/certs' },
    );

    has sms_ip => ( is => 'ro' );

    has key_file => (
       is => 'ro',
       lazy => 1,
       default => sub { shift->data_root . '/Class-2-CA.key' },
    );

    has cert_file => (
       is => 'ro',
       lazy => 1,
       default => sub { shift->data_root . '/Class-2-CA.crt' },
    );

    has root_cert_file => (
       is => 'ro',
       lazy => 1,
       default => sub { shift->data_root . '/rootCA.crt' },
    );

    has crl_file => (
       is => 'ro',
       lazy => 1,
       default => sub { shift->data_root . '/crl/crl.pem' },
    );

    has sugar_connect_info => (
       is => 'ro',
       required => 1,
       coerce => sub {
          return $_[0] if ref $_[0];
          JSONY->new->load($_[0])
       },
    );

    has sms_connect_info => (
       is => 'ro',
       required => 1,
       coerce => sub {
          return $_[0] if ref $_[0];
          JSONY->new->load($_[0])
       },
    );

    has internal_ip => (
       is => 'ro',
       required => 1,
       coerce => sub { qr/$_[0]/ },
    );

    sub as_hash ($self) {
       return {
          map { $_ => $self->$_ }
          qw(
             root_http_path port data_root csr_dir cert_dir sms_ip key_file
             cert_file root_cert_file crl_file sugar_connect_info
             sms_connect_info internal_ip
          )
       }
    }

    1;

The config object should be pretty clear too; one of the things I've striven for
(made obvious by my use of JSONY) is to allow all of the settings to be defined
with strings in environment variables without a lot of effort.

I came up with this after having a chat with rjbs about this problem.  He
pointed out that if you use an object instead of just a hash you can easily add
defaults, coercions, etc.  I think he was right on the money!

The other thing I really like about this setup is that it merges both a
serialized file and the environment, and the environment wins.  This means that
if I wanted to, for example, run two of the same thing on different ports I can
easily just set an env var instead of having to come up with a way to have two
separate config files or something silly like that; it would be as simple as:

    PROOF_PORT=8080 perl bin/server.pl &
    PROOF_PORT=8081 perl bin/server.pl &

As a bonus, this makes it trivial when needing to modify settings within a
containerized application, as `docker run` allows passing of environment
variables.

I'm not in love with the `store`/`as_hash` thing, but the alternative is to use
Moose and the MOP which I think is likely too much for a config that is likely
to be used in a CGI and CLI context.

One of these days I might release the loader, but I would like to use it a bit
longer before committing to the API.
