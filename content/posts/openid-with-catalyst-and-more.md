---
aliases: ["/archives/913"]
title: "OpenID with Catalyst and more"
date: "2009-07-29T01:49:12-05:00"
tags: ["catalyst", "dbic", "dbixclass", "openid", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=913"
---
Blah blah blah perl marketing navel gazing wasting time blah blah blah perl is alive blah blah blah.

Ok, now that we're done wasting time, here's how to do something that (hopefully) will be useful!

I am working on a small Web Application in my increasingly rare spare time, and I decided I'd like to use OpenID for the authentication. Because of the structure of Catalyst applications this isn't exactly easy as pie, but if you read this post it will be for you!

First off you have to install [Catalyst::Authentication::Credential::OpenID](http://search.cpan.org/perldoc?Catalyst::Authentication::Credential::OpenID) (and dependencies) **but wait!** there are some issues you have to deal with first!

Catalyst::Authentication::Credential::OpenID depends on [LWPx::ParanoidAgent](http://search.cpan.org/perldoc?LWPx::ParanoidAgent), which has a few issues. See [this RT](http://rt.cpan.org/Public/Bug/Display.html?id=41946) for a patch that will solve it. When you run cpan (perl -MCPAN -eshell) run the command:

    o conf /prefs/

Wherever the directory is, save the yaml from the RT page to that directory.

Then install Catalyst::Authentication::Credential::OpenID the usual way and everything should work nicely. After the install is done you'll need to configure Catalyst to use the module. Here is my config:

       # in MyApp.pl
    __PACKAGE__->config(
       authentication => {
          realms => {
             openid => {
                ua_class => "LWPx::ParanoidAgent",
                ua_args => {
                   whitelisted_hosts => [qw/ 127.0.0.1 localhost /],
                },
                credential => {
                   class => "OpenID",
                   store => {
                      class => "OpenID",
                   },
                },
             },
             dbic => {
                credential => {
                   class => 'Password',
                   password_field => 'password',
                   password_type => 'none'
                },
                store => {
                   class => 'DBIx::Class',
                   user_model => 'DB::User',
                }
             }
          }
       }
    );

Note that I also have a realm for DBIx::Class. This is because I need to store actual data about the user and not just the fact that they have logged in with OpenID. I currently have my database set up such that a user can have more than one OpenID. I don't have a UI for this, but I hope to add one eventually. Here are my DBIC Models:

    package MyApp::Schema::Result::OpenID;
    use parent 'DBIx::Class';
    use CLASS;

    CLASS->load_components(qw{Core});

    CLASS->table('OpenID');

    CLASS->add_columns(
       openid_url => {
          data_type   => 'varchar',
          size        => 255,
          is_nullable => 0,
       },
       user_id => {
          data_type      => 'int',
          is_nullable    => 0,
          is_numeric     => 1,
          is_foreign_key => 1,
       },
    );

    CLASS->add_unique_constraint([ 'openid_url' ]);

    CLASS->set_primary_key( 'openid_url' );

    CLASS->belongs_to(
       user => 'Glimmer::Schema::Result::User',
       'user_id'
    );

    "Any Non-False Value";

That should be fairly obvious what it does, especially if you know DBIC already. Normally I leave my DBIC models pretty bare, but in this project I am generating the DB from the model, so I should make it as complete as possible.

    package MyApp::Schema::Result::User;
    use parent 'DBIx::Class';
    use CLASS;
    use Method::Signatures::Simple;

    CLASS->load_components('Core');

    CLASS->table('User');

    CLASS->add_columns(
       id => {
          data_type         => 'int',
          is_nullable       => 0,
          is_auto_increment => 1,
          is_numeric        => 1,
       },
       fullname => {
          data_type   => 'varchar',
          size        => 140,
          is_nullable => 1,
       },
       nickname => {
          data_type => 'varchar',
          size      => 70,
       },
       email => {
          data_type   => 'varchar',
          size        => 140,
          is_nullable => 1,
      },
    );

    CLASS->add_unique_constraint([ 'email' ]);
    CLASS->add_unique_constraint([ 'nickname' ]);

    CLASS->set_primary_key( 'id' );

    CLASS->has_many(
       open_ids => 'Glimmer::Schema::Result::OpenID',
       'user_id'
    );

    use Gravatar::URL;
    method icon {
       return gravatar_url(email => $self->email);
    }

    "Hello world";

Not really a lot going on there either.

    #in MyApp::Controller::Root
    method complete_openid_login($c) :Private {
       my $user = eval { $c->model('DB::OpenID')->find($c->user->url)->user };

       if (!$@) {
          $c->authenticate({ id => $user->id }, 'dbic');
          return;
       }

       given ($@) {
          when (qr/Can't \s+ call \s+ method \s+ "url" \s+ on \s+ an \s+ undefined \s+ value/ixm) {
             $c->detach('/auth/login');
          }
          when (qr/Can't \s+ call \s+ method \s+ "user" \s+ on \s+ an \s+ undefined \s+ value/ixm) {
             $c->detach('/auth/create');
          }
          default { die $@ }
       }
    }

This method, complete\_openid\_login, is really the flesh and blood of this login system. We call it after a person logs in with OpenID (see next section). The main thing to point out is that authenticate method call. It will set the $c->user object up to hold the correct User object, which is a good thing. A secondary thing to point out is that I am using perl's vomitous exception handling for flow control. It's just as valid to use regular if-else stuff, but I like the way this works conceptually. Hopefully as time goes on the string error messages can be replaced with actual Error objects. More on that in the coming months.

    # in MyApp::Controller::Auth
    method login($c) :Local {
       if ( $c->authenticate ) {
          $c->forward( '/complete_openid_login' );
          $c->res->redirect( $c->uri_for('/') ) if ( $c->get_user );
       } else {
          $c->detach('r_login');
       }
    }

    method create($c) :Local {
       $c->detach('r_create')
         if ($c->request->method ne 'POST');

      $c->forward('captcha_check');

      my $params = $c->req->params;

      if (!$c->stash->{recaptcha_ok}) {
        $c->stash->{user_message}->{content} =
          q/YOU AREN'T A HUMAN!!!/;
        $c->stash->{user_message}->{type} = 'bad';
        $c->detach('r_create');
      }

      $c->model('DB')->schema->txn_do(sub {
          eval {
            my $user = $c->model('DB::User')
              ->create({
                map { $_ => $params->{$_} }
                  qw{ nickname email }
              });

            $user->add_to_open_ids({
              openid_url => $c->user->url
            });
          };
        });
      $c->forward('list')
        if (! $@);

      given ($@) {
        when (qr/column \s+ email \s+ is \s+ not \s+ unique/ixm) {
          my $email = $params->{email};
          $c->stash->{user_message}->{content} =
            "The email address '$email' is taken";
          $c->stash->{user_message}->{type} = 'bad';
          $c->detach('r_create');
        }
        when (qr/column \s+ nickname \s+ is \s+ not \s+ unique/ixm) {
          my $nickname = $params->{nickname};
          $c->stash->{user_message}->{content} =
            "The nickname '$nickname' is taken";
          $c->stash->{user_message}->{type} = 'bad';
          $c->detach('r_create');
        }
        default {
          $c->stash->{user_message}->{content} = $_;
          $c->stash->{user_message}->{type} = 'bad';
          $c->detach('r_create');
        }
      }
    }

Most of the above is fairly unremarkable. We've got the login method which hopefully needs no explanation, and we've got the create method, which is what creates the DBIC model of the user. The vast majority of it is error handling. A lot of that could be taken care of with something like FormFu, but I haven't crossed that bridge yet, so I can't bring you across it either.

The one thing I should probably mention from the above is the captcha\_check bit. I use ReCaptcha to ensure that my users are humans (for now I will discriminate against the machines!) It's pretty easy to set up and it works quite nicely. I may post on that at some point too.

And lastly, here is what I came up with for the OpenID login screen. I used [this Simple OpenID Selector](http://code.google.com/p/openid-selector/) to help with the logging in for the user. I've modeled mine off of what was used on StackOverflow.

OpenID is service that allows you to log-on to many different websites using a single indentity.

Find out [more about OpenID](http://openid.net/what/) and [how to get an OpenID enabled account](http://openid.net/get/).

<form action="[% c.uri_for('/auth/login') %]" id="openid_form" method="post"><input class="openid-identifier" id="openid_identifier" name="openid_identifier" type="text" /> <input id="submit-button" type="submit" value="Login" /><fieldset>
    <legend>Alternately, click your account provider</legend>
    <div id="openid_choice">
      <div id="openid_btns">
      </div>
    </div>
    <div id="openid_input_area">
    </div>
  </fieldset>
  <div style="clear: both; margin-bottom: 20px">
  </div>
  <p>Don't forget to <b>enable OpenID support</b> with your preferred provider first!</p>
</form>

That's pretty basic. Nothing very special except for the research of where to get the js to do what I did.

And that's it! You don't have to email users to activate their account, you don't have to worry about storing passwords securely, and they don't have to remember another pair of credentials to use your site!
