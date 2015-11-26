---
aliases: ["/archives/1679"]
title: "Using Catalyst::Plugin::Authentication with an old setup"
date: "2012-01-18T01:04:37-06:00"
tags: ["authentication", "catalyst"]
guid: "http://blog.afoolishmanifesto.com/?p=1679"
---
Recently I took it upon myself to make Catalyst::Plugin::Authentication know
users had logged in after users had logged in in a completely non-Catalyst part
of our app. After LOTS of frustration, code spelunking, and bugging a couple
people in #catalyst (hobbs and t0m) I got it working.

Basically what I did was have the session plugin look at a different cookie and
load information from our own strange brew of session table. It's not perfect,
but I'm much happier with it than I was before. Here's the code:

First, you need to create your own Session Store, our app is called Lynx, so the
namespace reflects that:

    package Lynx::Session::Store;

    use strict;
    use warnings;

    use base qw/Catalyst::Plugin::Session::Store/;

    use DateTime::Format::MSSQL;
    use Catalyst::Authentication::Store::DBIx::Class::User;
    sub get_session_data {
       my ($c, $key) = @_;

       my ($k, $v) = split /:/, $key;

       if ($k eq 'session') {
          if (my $login = $c->model('DB::Login')->single({ access_num => $v })) {
             return {
                __user_realm => 'default',
                __user       => {
                   # this must be the primary key
                   user => $login->userid,
                },
             }
          }
       } elsif ($k eq 'expires') {
          if (my $cookie = $c->request->cookie('Access_Num')) {
             if (my $login = $c->model('DB::Login')->single({ access_num => $v })) {
                my $ex = DateTime::Format::MSSQL->parse_datetime($login->last_accessed)->epoch + 720 * 60 - DateTime->now(time_zone => 'local')->offset;
                return $ex;
             }
          }
       }
    }

    sub store_session_data { }
    sub delete_session_data { }
    sub delete_expired_sessions { }

    1;

We have stub methods for the session stuff that we don't support. Eventually I
may fill those out, but what's more likely is that we remove this code entirely
and just use what's provided by CPA.

Next is get\_session\_data, which gets arguments like session:1234 and
expires:1234. They are meant to return the session data and the expiry time
(seconds since epoch) respectively. Clearly I had to do a lot of really weird
stuff with datetime to get that expiration date from our database, but it works,
so that's cool. You may store your expiration directly. Who knows.

So far, so weird. Then I had to figure out how to "inflate" the session. The
keys \_\_user\_realm and \_\_user are hardcoded in CPA, and I kinda think they
should change to just current\_user\_realm and current\_user, or maybe
catalyst-plugin-authentication-user. Whatever. But the fact is they are what
they are. The value for \_\_user\_realm is which realm is currently selected. I
imagine the vast majority of people should have that set to default, as they
typically only have a single realm (we actually have two, but I didn't realize
till this code broke in a special way.) The value for \_\_user is **not** a user
object, but instead what get's passed to the auth store's from\_session method.
Note that the DBIx::Class store actually will only use the primary key, so if
you change the primary key of your user class this thing will break. I am
**mostly** sure about that, but it's a pretty deep stack trace at that point.

Next up I made a Session subclass:

    package Lynx::Session;

    use strict;
    use warnings;

    use base qw/Catalyst::Plugin::Session/;

    sub sessionid {
       my $c = shift;

       my $access_num;
       if (my $cookie = $c->request->cookie('Access_Num')) {
          $access_num = $cookie->value;
       }

       return $access_num;
    }

    1

This is clearly pretty basic. I just overrode sessionid to look at our cookie to
get the sessionid.

After that I just loaded the plugins I needed and configured CPA:

    ...
    use Catalyst qw(
       Authentication
       +Lynx::Session
       Session::State::Cookie
       +Lynx::Session::Store
    );
    ...
       'Plugin::Authentication' => {
          default => {
             credential => {
                class => 'Password',
                password_field => 'password',
                password_type => 'clear'
             },
             store => {
                class => 'DBIx::Class',
                user_model => 'DB::User',
             },
          },
       },
      ...

Note that the credential is unused in my use case as catalyst doesn't do the
actual authentication at all.

Hope this helps someone!
