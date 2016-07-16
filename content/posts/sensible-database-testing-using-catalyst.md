---
aliases: ["/archives/1448"]
title: "Sensible database testing using Catalyst"
date: "2010-11-11T02:36:13-06:00"
tags: ["catalyst", "dbix-class", "perl", "testing"]
guid: "http://blog.afoolishmanifesto.com/?p=1448"
---
I've kinda [fallen off the blogging horse](http://www.tmz.com/2010/09/13/big-bang-theory-kaley-cuoco-horse-accident-broken-leg-cbs-maxim/), but most of that is because I've been writing Open Source code in my freetime. I think generally that's a worthwhile tradeoff, but I like blogging in general, when I have stuff to blog about, so I'm gonna try to mix in more blog posts; at least about what I'm doing.

----

At work I am writing an SMS gateway. This is after writing my first Catalyst app and also after trying to test another Catalyst app, so now that I have that experience under my belt I think I've finally figured out how to do relatively complex tests (including tests that use the database) without going crazy.

The first thing I did was make a subclass of my [DBIx::Class::Schema](http://search.cpan.org/perldoc?DBIx::Class::Schema). It looks something like:

    package A::SMSDB;

    use parent 'Lynx::SMS::Schema';

    use String::Random qw(random_string random_regex);

    sub cat_init {
       my $self = shift;

       $self->deploy;
       $self->prepopulate;
    }

    sub init {
       my $class = shift;

       my $self = $class->connect('dbi:SQLite:dbname=:memory:');
       $self->deploy;
       $self->prepopulate;
       return $self;
    }

    sub prepopulate {
       my $s = shift;
       $s->resultset('Type')->populate([
          ['name'],
          ['SMS'],
          ['Phone'],
       ]);
       # there's more here, but you get the idea
    }

    sub populate_sms {
       my $self     = shift;
       my $args     = shift;
       state %bp    = (
          message_child_to_status_links => [{
             status => { api_callback_id => '002',},
          }],
       );

       my $act      = $args->{account};
       my $amount   = $args->{amount};
       my $child_id = 1;

       $act->messages->create({
           type       => { name => 'SMS' },
           message    => 'THIS IS A TEST!',
           from_email => 'bogus@test.com',
           children   => [map +{
              phone_number => random_regex('1\d{9}'),
              to_name      => random_regex('\w{20}'),
              child_id     => $child_id++,
              %bp,
           }, ( 1 .. $amount )]
        });
    }

    1;

This is generally a good idea even if you aren't using Catalyst. Having a test sub-class of your schema allows you to put various helper methods on your schema just for testing, as well as handy ways to deploy the schema. Since I'm so early on with this project I've been redeploying the database **a lot**, so it's been very helpful to have my tests all just call init at the start of the test.

Speaking of redeploying, I've also been using an in memory SQLite for my tests, which is very handy. At some point later I'll switch it to the deployment database. To connect to an in memory database use "dbi:SQLite:dbname=:memory:" as your dsn and you'll be golden.

The next thing I did was made a special catalyst config file just for tests. This is what it looks like right now:

    {
       "name":"Lynx::SMS",
       "Model::DB": {
          "schema_class":"A::SMSDB",
          "connect_info":{
             "dsn":"dbi:SQLite:dbname=:memory:",
             "xdsn":"dbi:SQLite:dbname=testing.db"
          }
       }
    }

First off, the changed schema\_class means that now $c->model('DB')->schema is my test schema, so I get all those extra methods. Also note the xdsn key in connect info. JSON doesn't natively support comments, so this is my hacky way of putting in an alternate dsn which I use when I want to look at the database after the test has finished (and probably failed.)

Now to get the above to apply, first I save it to "lynx\_sms\_testing.json" and then, before loading up my catalyst app in the test, I put

    use lib 't/lib';
    BEGIN { $ENV{LYNX_SMS_CONFIG_LOCAL_SUFFIX} = 'testing' }

And then after loading catalyst I'll do something along the lines of:

    Lynx::SMS->model('DB')->schema->cat_init;

To generate and populate the database.

Of course a lot of this probably needs to start using some kind of fixture solution and put into a small module in t/lib so that I'm not copying around that BEGIN block in all of my controller tests, but this works for now and I'll factor it into that once I have more than one controller test :-)
