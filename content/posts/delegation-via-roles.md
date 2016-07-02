---
aliases: ["/archives/1315"]
title: "Delegation via Roles"
date: "2010-04-02T05:23:31-05:00"
tags: ["delegation", "moose", "perl", "roles"]
guid: "http://blog.afoolishmanifesto.com/?p=1315"
---
[DBIx::Class::DeploymentHandler](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class-DeploymentHandler.git;a=summary) is nearly ready for prime time, so I'm going to discuss a pattern [mst](http://www.shadowcat.co.uk/blog/matt-s-trout/) described to me that I've found very helpful in developing this project.

### Roles

If you don't already know what roles are you probably don't read very many perl
blogs etc. [chromatic](http://www.wgz.org/chromatic/) has written a
[series](http://www.modernperlbooks.com/mt/2009/04/the-why-of-perl-roles.html)
[of](http://www.modernperlbooks.com/mt/2009/05/perl-roles-versus-inheritance.html)
[blog](http://www.modernperlbooks.com/mt/2009/05/perl-roles-versus-duck-typing.html)
[posts](http://www.modernperlbooks.com/mt/2009/05/perl-roles-versus-interfaces-and-abcs.html)
[where](http://www.modernperlbooks.com/mt/2009/05/more-roles-versus-duck-typing.html)
he discusses the various merits of roles vs whatever your poison is. Maybe read
that. This isn't really about that. What this _is_ about though is that [roles
aren't always the
answer](http://blog.woobling.org/2009/10/roles-and-delegates-and-refactoring.html).

### Delegation

One of the assumptions of roles is that all of the methods in a role share their namespace. So if you compose Role1 and Role2 and they both implement a sleep method you will get an error at compile time saying that the method collides. This is a Good Thing and helps us not shoot ourselves in the foot. When it's a problem is with private methods that the end user typically shouldn't be calling, but happen to collide. As far as I know there is no way to have a role that partially composes with a class. I'm pretty sure that's against the whole spirit of a role.

So instead of using a role to compose in the interface for whatever it is you are doing you can instead use delegation, where object A has-a different object B and uses the public interface of object B. That way private methods of B stay that way and don't collide. The problem is that this can make code a lot more verbose. So instead of

    $dh->deploy

one must do:

    $dh->deploy_method->deploy

That make things a lot more verbose, it gives away the inner workings of $dh, and most importantly it makes overriding parts of $dh harder.

### Roles with Delegation

So basically the pattern goes like this:

#### The Public Interface:

    package HandlesFooing;

    requires 'foo';
    requires 'bar';

    1;

#### The Delegate:

    package Im::A::Delegate;
    use Moose;
    with 'HandlesFooing';

    has foo => (
       is => 'ro',
       isa => 'Str',
       required => 1,
    );

    has bar => (
       is => 'ro',
       isa => 'Str',
       lazy_build => 1,
    );

    sub _build_bar { 'silly }

    1;

#### The Role:

    package WithDelegate;
    use Moose::Role;
    use Im::A::Delegate;

    has foo => (
       is => 'ro',
       isa => 'Str',
       required => 1,
    );

    has bar => (
       is => 'ro',
       isa => 'Str',
       lazy_build => 1,
    );

    has delegate => (
       is => 'ro',
       isa => 'Im::A::Delegate',
       handles => 'HandlesFooing',
       lazy_build => 1,
    );

    sub _build_delegate {
       my $self = shift;
       my $args = {
          foo => $self->foo
       };

       $args->{bar} = $self->bar if $self->has_bar;
       Im::A::Delegate->new($args);
    }

    1;

#### Usage:

    package GetStuffDone;
    use Moose;
    with 'WithDelegate';

    1;

And to use **that** you'd do:

    use GetStuffDone;
    my $gsd = GetStuffDone->new(
       foo => 'frewfrew',
    );

Of course that's totally contrived, but it gets the general pattern across. If you want to see examples in action check out [some](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class-DeploymentHandler.git;a=blob;f=lib/DBIx/Class/DeploymentHandler/WithMonotonicVersions.pm;h=c62dabf9e620c7d0231f837216f39dfde10b332b;hb=HEAD) [of](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class-DeploymentHandler.git;a=blob;f=lib/DBIx/Class/DeploymentHandler/WithReasonableDefaults.pm;h=8a36cf0c047dcd4f98212b0374f35735b6131df2;hb=HEAD) [the](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class-DeploymentHandler.git;a=blob;f=lib/DBIx/Class/DeploymentHandler/WithSqltDeployMethod.pm;h=20f92f719da73c179f79fa4580a2a1ae051aa6d3;hb=HEAD) [roles](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class-DeploymentHandler.git;a=blob;f=lib/DBIx/Class/DeploymentHandler/WithStandardVersionStorage.pm;h=7abe9cf20c6d733a533644a746e8d06977d7b53a;hb=HEAD) from DBIx::Class::DeploymentHandler!

So basically you define your public interface, which isn't a bad idea anyway, and the "handles" key for the delegate's attribute takes the role that defines the public interface. This automatically delegates all the methods required by the role (and probably any defined by the role too.)

If you have private methods you want to reuse make another role and compose that into the delegate's class, but don't put it in the handles section.

I feel like this pattern, even though it yields a lot of boilerplate, helps to make very clean interfaces. Because of this pattern I've made well decomposed classes and testing them is dead easy. I imagine that to test roles normally you make stub classes using the roles. Here I just test the actual delegates alone and then I have an integration test that ensures the class that uses all the roles does the right thing.

Hopefully you'll find this as useful as I have.
