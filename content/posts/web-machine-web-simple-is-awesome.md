---
aliases: ["/archives/1750"]
title: "Web::Machine + Web::Simple is awesome"
date: "2012-06-27T15:30:30-05:00"
tags: ["catalyst", "cpan", "perl", "webmachine", "websimple"]
guid: "http://blog.afoolishmanifesto.com/?p=1750"
---
I really like "REST," which the pedantic of you will realize is really just
using more than just basic HTTP. I've gotten used to a handy REST-y pattern with
[Catalyst](https://metacpan.org/module/Catalyst), which, though verbose, is
pretty neat:

    use Catalyst::Controller::Accessors;

    cat_has account => (
       is => 'ro',
       namespace => 'MyApp::Controller::Accounts',
       slot => 'thing',
    );

    cat_has $_ => ( is => 'rw' ) for qw(rs thing id);

    sub base : Chained('/accounts/item') PathPart('contacts') CaptureArgs(0) {
       my ($self, $c) = @_;
       $self->rs($c, $self->account($c)->contacts)
    }

    sub item : Chained('base') PathPart('') CaptureArgs(1) {
       my ($self, $c, $id) = @_;

       $self->id($c, $id);
       $self->thing($c, $self->rs($c)->find($id));
    }

    sub contacts :Chained('base') PathPart('') Args(0) ActionClass('REST') {}

    sub contacts_POST {
       my ($self, $c) = @_;

       my $params = $c->request->data;

       my $foo = $self->rs($c)->create($params);
       $c->stash->{rest} = { success => 1, data => $foo };
    }

    sub contacts_GET {
       my ($self, $c) = @_;

       $c->stash->{rest} = $self->ext_paginate(
          $self->search($c,
             $self->paginate($c,
                $self->sort($c, $self->rs($c))
             )
          )
       );
    }

    sub contact  :Chained('item') PathPart('') Args(0) ActionClass('REST') {}

    sub contact_GET {
       my ($self, $c) = @_;

       $c->stash->{rest} = {
          success => 1,
          data => $self->thing($c),
       };
    }

    sub contact_PUT {
       my ($self, $c) = @_;

       my $foo = $self->thing($c);
       my $params = $c->request->data;

       $foo->update($params);
       $c->stash->{rest} = { success => 1, data => $foo };
    }

    sub contact_DELETE {
       my ($self, $c) = @_;

       $self->rs($c)->search({ id => $self->id($c) })->delete;
       $c->stash->{rest} = { success => 1 };
    }

That's cool. I'm pretty happy with it, except it's frustratingly un-reusable. If
I wanted to make this reusable I'd have to make a parameterized role or
something to make the method names dynamic and then if I want to wrap one of the
methods to change how it works to add validation or something it's all weird and
blah blah blah. It's feasible for sure, but I just decided that would have to
wait for some better tech.

Well, at YAPC this year Stevan Little did a talk about
[Web::Machine](https://metacpan.org/module/Web::Machine). Web::Machine is a nice
... pattern? that was originally implemented in Erlang, then ported to ruby, etc
etc. The cool thing about Web::Machine is that it makes using more of HTTP
extremely easy. For example, if you use it right you get more than just 200 and
500 status codes, and you get lots of nice HTTP headers that have actual
meaning.

Add [Web::Simple](https://metacpan.org/module/Web::Simple)'s super neat
dispatching that allows more comprehensible chaining and I can reimplement the
above, reusably, easily. Note that my example is a little different since I
haven't actually ported anything, just written new stuff. First off, I
implemented two roles, that do the above generically:

    package DU::WebApp::Resource::Role::Set;

    use Moo::Role;

    requires 'render_item';
    requires 'decode_json';
    requires 'encode_json';

    has set => (
       is => 'ro',
       required => 1,
    );

    has writable => (
       is => 'ro',
    );

    has post_redirect_template => (
       is => 'ro',
       lazy => 1,
       builder => '_build_post_redirect_template',
    );

    sub _build_post_redirect_template {
       $_[0]->request->request_uri . 'data/%i'
    }

    sub allowed_methods {
       [
          qw(GET HEAD),
          ( $_[0]->writable ) ? (qw(POST)) : ()
       ]
    }

    sub post_is_create { 1 }

    sub create_path { "worthless" }

    sub content_types_provided { [ {'application/json' => 'to_json'} ] }
    sub content_types_accepted { [ {'application/json' => 'from_json'} ] }

    sub to_json { $_[0]->encode_json([ map $_[0]->render_item($_), $_[0]->set->all ]) }

    sub from_json {
       my $obj = $_[0]->create_resource(
          $_[0]->decode_json(
             $_[0]->request->content
          )
       );

       $_[0]->redirect_to_new_resource($obj);
    }

    sub redirect_to_new_resource {
       $_[0]->response->header(
          Location => $_[0]->_post_redirect($_[1])
       );
    }

    sub _post_redirect {
       sprintf $_[0]->post_redirect_template,
          map $_[1]->get_column($_),
             $_[1]->result_source->primary_columns
    }

    sub create_resource { $_[0]->set->create($_[1]) }

    1;

    package DU::WebApp::Resource::Role::Item;

    use Moo::Role;

    requires 'render_item';
    requires 'encode_json';
    requires 'decode_json';

    has item => (
       is => 'ro',
       required => 1,
    );

    has writable => (
       is => 'ro',
    );

    sub content_types_provided { [ {'application/json' => 'to_json'} ] }
    sub content_types_accepted { [ {'application/json' => 'from_json'} ] }

    sub to_json { $_[0]->encode_json($_[0]->render_item(($_[0]->item))) }

    sub from_json {
       $_[0]->update_resource(
          $_[0]->decode_json(
             $_[0]->request->content
          )
       )
    }

    sub resource_exists { !! $_[0]->item }

    sub allowed_methods {
       [
          qw(GET HEAD),
          ( $_[0]->writable ) ? (qw(PUT DELETE)) : ()
       ]
    }

    sub delete_resource { $_[0]->item->delete }

    sub update_resource { $_[0]->item->update($_[1]) }

    1;

Then I consumed the roles to make the actual resources:

    package DU::WebApp::Resource::Drink;

    use Moo;

    use DU::Util 'drink_as_data';

    extends 'Web::Machine::Resource';
    with 'DU::Role::JsonEncoder';
    with 'DU::WebApp::Resource::Role::Item';

    sub render_item { drink_as_data($_[1]) }

    1;

    package DU::WebApp::Resource::Drinks;

    use Moo;

    extends 'Web::Machine::Resource';
    with 'DU::Role::JsonEncoder';
    with 'DU::WebApp::Resource::Role::Set';

    sub render_item {
       +{
          name => $_[1]->name,
          id   => $_[1]->id,
       }
    }

    1;

And then lastly I wrap it all together with a Web::Simple dispatcher:

    #!/usr/bin/env perl

    package DU::WebApp;
    use Web::Simple;
    use DU::WebApp::Machine;

    use DU::Schema;
    use Module::Load;
    my $schema = DU::Schema->connect(...);

    sub wm {
       load $_[0];
       DU::WebApp::Machine->new(
          resource => $_[0],
          debris   => $_[1],
       )->to_app;
    }

    sub dispatch_request {
      sub (/drinks/...) {
        my $set = $schema->resultset('Drink');
        sub (/data/*) {
           wm('DU::WebApp::Resource::Drink', {
             item     => $set->find($_[1]),
             writable => 1,
           })
        },
        sub (/) {
           wm('DU::WebApp::Resource::Drinks', {
             set      => $set,
             writable => 1,
           })
        },
      },
    }

    DU::WebApp->run_if_script;

There's more to it of course. Just by reading the above you can see that there
are some missing pieces. To see the full thing checkout my little drinkup
program [at github](http://github.com/frioux/drinkup).
