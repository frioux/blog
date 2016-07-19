---
aliases: ["/archives/1696"]
title: "Introducing Catalyst::Controller::Accessors"
date: "2012-05-21T15:48:57-05:00"
tags: [mitsi, announcement, catalyst, cpan, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1696"
---
Ugh, I first released this eight months ago, but I fell off the blogging wagon pretty badly. It's so hard to write when I could be writing code, docs, and tests! So anyway, I'm trying to get caught up on the eight announcements that need to be made as well as a few [DBIx::Class::DeploymentHandler](http://p3rl.org/DBIx::Class::DeploymentHandler) related PSA's. I'll schedule them to get auto posted with at least a few days between so I don't melt your feed reader or bore you too much.

Do you use [Catalyst](http://p3rl.org/Catalyst) chaining? I do and for the most part I really enjoy the structure it brings my applications. Here is a typical example of a chain based controller of mine, structure stolen and mutated from the inimitable t0m:

    package Lynx::SMS::Controller::Accounts;

    use Moose;
    use namespace::autoclean;

    use syntax 'method';

    BEGIN { extends 'Lynx::SMS::RESTController' };

    with 'Catalyst::TraitFor::Controller::DBIC::DoesPaging',
         'Catalyst::TraitFor::Controller::DoesExtPaging';

    sub base : Chained('/') PathPart('accounts') CaptureArgs(0) {
       my ($self, $c) = @_;
       $c->stash->{+__PACKAGE__}{rs} = $c->model('DB::Account');
    }

    sub item : Chained('base') PathPart('') CaptureArgs(1) {
       my ($self, $c, $id) = @_;
       $c->stash->{+__PACKAGE__}{id} = $id;
       $c->stash->{+__PACKAGE__}{thing} =
          $c->stash->{+__PACKAGE__}{rs}->find($id);
    }

    sub accounts :Chained('base') PathPart('') Args(0) ActionClass('REST') {}

    method accounts_POST($c) : RequiresRole('write') {
       my $params = $c->request->data->{data};

       my $foo = $c->stash->{+__PACKAGE__}{rs}->create($params);

       $c->stash->{rest} = { success => 1, data => $foo };
    }

    method accounts_GET($c) : RequiresRole('read') {
       $c->stash->{rest} = $self->ext_paginate(
          $self->search($c,
             $self->paginate($c,
                $self->sort($c, $c->stash->{+__PACKAGE__}{rs})
             )
          )
       );
    }

    sub account :Chained('item') PathPart('') Args(0) ActionClass('REST') {}

    method account_GET($c) : RequiresRole('read') {
       $c->stash->{rest} = {
          success => 1,
          data => $c->stash->{+__PACKAGE__}{thing},
       };
    }

    method account_PUT($c) : RequiresRole('write') {
       my $foo = $c->stash->{+__PACKAGE__}{thing};
       my $params = $c->request->data->{data};
       $foo->update($params);

       $c->stash->{rest} = { success => 1, data => $foo };
    }

    method account_DELETE($c) : RequiresRole('delete') {
       $c->stash->{+__PACKAGE__}{rs}->search({
          id => $c->stash->{+__PACKAGE__}{id},
       })->delete;
       $c->stash->{rest} = { success => 1 };
    }

    1;

So the above works great and given the little idiom up there you get a safely namespaced stash. That's all good, but we can do better.

# Introducing Catalyst::Controller::Accessors

[Catalyst::Controler::Accessors](http://p3rl.org/Catalyst::Controller::Accessors) is a module to abstract the above idiom into actual controller methods. The great thing is that when you use actual methods not only is the result much more clear code, but you can change the method if you need to and have a **much** smaller ripple effect of changes. Without CCA, if you change where you store something in the stash you need to audit every single action that chains off the thing you chained. With CCA such audits should not be needed at all (with one caveat; I'll get to that.)

Catalyst::Controller::Accessors gives you a cat\_has export that works very similar to the has export from [Moose](http://p3rl.org/Moose). Here is the above example rewritten with CCA:

    package Lynx::SMS::Controller::Accounts;

    use Moose;
    use Catalyst::Controller::Accessors;
    use namespace::autoclean;

    use syntax 'method';

    BEGIN { extends 'Lynx::SMS::RESTController' };

    with 'Catalyst::TraitFor::Controller::DBIC::DoesPaging',
         'Catalyst::TraitFor::Controller::DoesExtPaging';

    cat_has rs => (
       is => 'rw',
    );

    cat_has id => (
       is => 'rw',
    );

    cat_has thing => (
       is => 'rw',
    );

    sub base : Chained('/') PathPart('accounts') CaptureArgs(0) {
       my ($self, $c) = @_;
       $self->rs($c, $c->model('DB::Account'));
    }

    sub item : Chained('base') PathPart('') CaptureArgs(1) {
       my ($self, $c, $id) = @_;
       $self->id($c, $id);
       $self->thing($c, $self->rs($c)->find($id));
    }

    sub accounts :Chained('base') PathPart('') Args(0) ActionClass('REST') {}

    method accounts_POST($c) : RequiresRole('write') {
       my $params = $c->request->data->{data};

       my $foo = $self->rs($c)->create($params);

       $c->stash->{rest} = { success => 1, data => $foo };
    }

    method accounts_GET($c) : RequiresRole('read') {
       $c->stash->{rest} = $self->ext_paginate(
          $self->search($c,
             $self->paginate($c,
                $self->sort($c, $self->rs($c))
             )
          )
       );
    }

    sub account :Chained('item') PathPart('') Args(0) ActionClass('REST') {}

    method account_GET($c) : RequiresRole('read') {
       $c->stash->{rest} = {
          success => 1,
          data => $self->thing($c),
       };
    }

    method account_PUT($c) : RequiresRole('write') {
       my $foo = $self->thing($c);
       my $params = $c->request->data->{data};
       $foo->update($params);

       $c->stash->{rest} = { success => 1, data => $foo };
    }

    method account_DELETE($c) : RequiresRole('delete') {
       $self->rs($c)->search({
          id => $self->id($c),
       })->delete;
       $c->stash->{rest} = { success => 1 };
    }

    1;

You still have to pass around $c, as the stash is still being used under the hood, but your access is now hidden and you are free to change that method later if you need to.

Catalyst::Controller::Accessors also has a few other handy features that. Due to the confusing nature of catalyst chaining I actually think that having validation on these accessors is much more helpful than in typical Moose objects, so type constraints are supported:

    use Check::ISA;
    cat_has resultset => (
       is => 'rw',
       isa => sub {
         die 'resultset needs to be a DBIx::Class::ResultSet, but you passed "$_[0]"'
            unless obj($_[0], 'DBIx::Class::ResultSet')
       }
    );

The isa checks are [Moo](http://p3rl.org/Moo) style, so you can use [MooX::Types](http://p3rl.org/MooX::Types) to generate your type subs.

Also note, when you've chained into another controller you probably want readonly access to the values from said controller. Here's how that's done:

    cat_has other_user => (
      is => 'ro',
      namespace => 'MyApp::Controller::Users',
      slot => 'user',
    );

Note that if you change what your stuff is chaining off of you'll obviously need to change this as well.
