---
aliases: ["/archives/1668"]
title: "Creating a pseudo attribute with DBIx::Class"
date: "2011-09-04T06:59:25-05:00"
tags: ["dbix-class", "orm", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1668"
---
I'm surprised I haven't actually blogged this before. I had to do it recently for the first time in a long time and I figured I'd share the secret sauce.

At work we just added a complete permission system on top of our existing user system, but we didn't want to make the UI as flexible as the underlying code. We ended up making a single role (which has all permissions) called "Full Control". Without that role all you get is the stuff configured directly for your user; that is, your user gets a dashboard. So instead of making a grid of roles etc etc we just made a single checkbox on the user edit form. Of course I could have put in controller code to handle this special case, but I'm trying to get better at factoring code correctly. (As an aside: two years ago I would have also put all of this in the model; the frustrating thing is that Fat Model Skinny Controller only really works for relatively small apps. I'll try to do a blog post on why I think that at another point later :-) )

Anyway, first off, here's the full\_control accessor I made:

    sub full_control {
       my $self = shift;

       if (exists $_[0]) {
          my $full_control = $_[0];
          if ($full_control) {
             $self->set_roles({ name => FULL_CONTROL });
          } else {
             $self->user_roles->delete;
          }
          return $full_control
       } else {
          $self->roles->search({ name => FULL_CONTROL })->count
       }
    }

Not a whole lot going on. If an argument is passed we set the user's roles based on the truthiness of the argument. Because the system is currently just the one role we delete all roles for clearing it. Later on if we make the system more full featured we'll have to change this up a bit of course. If no argument is passed we just return the count of full control roles, as that approximates truthiness just fine.

Next up are the "insert" and update wrappers. I quote insert because I actually override new:

    sub update {
       my ($self, $args, @rest) = @_;

       my $full_control = delete $args->{full_control};

       my $ret = $self->next::method($args, @rest);

       $ret->full_control($full_control);

       return $ret
    }

    sub new {
       my ($self, $args, @rest) = @_;

       my $full_control = delete $args->{full_control};

       $args->{user_roles} = [ { role => { name => 'Full Control' } } ] if $full_control;

       my $ret = $self->next::method($args, @rest);

       return $ret
    }

The code for update should be abundantly clear. We just update the object, calling our accessor afterwards. The new code is a little bit more messy. Basically, instead of trying to use the accessor on new (which is wrong as new doesn't actually imply an insert) we just leverage the excellent MultiCreate which DBIx::Class provides for us.

And that's it! I hope this helps you get your job done that much faster/better :-)
