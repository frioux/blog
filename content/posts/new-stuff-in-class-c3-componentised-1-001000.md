---
aliases: ["/archives/1601"]
title: "New Stuff in Class::C3::Componentised 1.001000"
date: "2011-08-10T06:59:21-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=1601"
---
I'm very excited to **finally** announce a feature that I've toyed with in [Class::C3::Componentised](https://metacpan.org/module/Class::C3::Componentised) for over a year now.

New in the [current release](https://metacpan.org/module/FREW/Class-C3-Componentised-1.001000/lib/Class/C3/Componentised.pm) of Class::C3::Compontised is [Class::C3::Componentised::ApplyHooks](https://metacpan.org/module/Class::C3::Componentised::ApplyHooks). The gist is that you can run code, or more importantly methods, against the class being injected into.

I wouldn't be surprised if few people reading this actually know what Class::C3::Componentised is actually used in; the answer is [DBIx::Class](https://metacpan.org/module/DBIx::Class). The upshot of this new feature is that you could write a component to add columns or relationships much more nicely than before.

A simple example and usage of it is as follows:

    package MyApp::Schema::ResultComponents::TimeStamp;

    use base 'DBIx::Class::TimeStamp';

    use Class::C3::Componentised::ApplyHooks;

    AFTER_APPLY {
      my $class = shift;

      $class->add_columns(
        timestamp => {
          data_type     => 'datetime',
          set_on_create => 1,
        }
      );
    }

    1;

    package MyApp::Schema::Result::User;

    use base 'DBIx::Class::Core';

    __PACKAGE__->table('users');

    __PACKAGE__->load_components('+MyApp::Schema::ResultComponents::TimeStamp');

    ...;

    1;

There are two caveats.

You cannot simply "use base" a component with Apply Hooks. The hooks just won't run. There are ideas on how to solve that, but maybe that's a feature.

The second is that you must load\_components **after** table is set. The simple solution at this point is to yuse [DBIx::Class::Candy](https://metacpan.org/module/DBIx::Class::Candy), as it runs the table code at compile time. I hear that another solution is in the mix as well, which will basically make add\_columns et al create the underlying result source on demand, but we'll see if that materializes.

Either way, it will be interesting to be able to use this internally as it easily lets me share table definition data in a cleaner way than I did before. Hopefully you find it useful as well.
