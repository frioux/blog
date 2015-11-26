---
aliases: ["/archives/259"]
title: "The Beginning of a Roles Based Authorization System for Perl"
date: "2009-02-13T07:08:16-06:00"
tags: ["authorization", "cgiapp", "cgiapplication", "moose", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=259"
---
Today I was talking with a friend about the stuff we are doing at work and I
mentioned to him how I was planning on doing the authorization. Since I had only
thought about it at that point I didn't even know if my idea was valid Perl
syntax, let alone a feasible idea. But enough with the backstory, how about some
real information.

Let's assume that we have a webpage that lets you read user data and write user
data. Theoretically we have already logged the user in, so we know who they are
talking to, and we have a simple database model of the roles the user is
authorized for. That's no fun but it's pretty easy. Three tables: one for the
user, one join table from user to roles, and one that lists roles. So if we
wanted to limit a sub to a user with role 'read\_user' and 'write\_user' we
could do this:

    sub read_user {
      my $self = shift;
      if ($self->user->has_role('read_user') and $self->user->has_role('read_user')) {
        # display user data somehow
      } else {
        # display some form of error
      }
    }

That's really a fine way to do it. It works. It's how most things work. But it
would be no fun to have to write that for essentially **every page on a site**.
That's a drag!

Perl has this thing call attributes; which is basically a way to tag functions.
At first I thought, "Hey, we'll just tag a function with it's roles and have
validation work based on that. So our previous thing would look like this:

    sub read_user : role_read_user role_write_user {
      my $self = shift;
      # display user data somehow
    }

That would be great! But how on earth would you do something like that? I
started off looking at the source to
[AutoRunmode](http://search.cpan.org/~thilo/CGI-Application-Plugin-AutoRunmode-0.15/AutoRunmode.pm)
which basically gave me this idea in the first place. There is some very deep
magic in there, so I decided to keep looking. The source to AutoRunmode
references
[Attribute::Handlers](http://search.cpan.org/~smueller/Attribute-Handlers-0.81/lib/Attribute/Handlers.pm),
originally by Damian Conway (author of
[numerous](http://amazon.com/dp/0596526741/)
[Perl](http://amazon.com/dp/1884777791/)
[books](http://amazon.com/dp/0596001738/)) which allows me to at least do
something when someone includes a handler. That's a start. So I looked at how to
use Attribute::Handlers and after seeing what was possible I decided it would be
easier and more clear to change my goal to this:

    sub read_user : Authorize(qw/role_read_user role_write_user/) {
      my $self = shift;
      # display user data somehow
    }

That way if I use the Attribute::Handlers system I write a single function that
gets a list of roles (amongst other things.) Then came the hard part. How can
you change a function in Perl? Well, it turns out that changing a method is
Kinda Hard, but

<del>Dave Rolsky</del> Stevan Little made
[Moose](http://search.cpan.org/~drolsky/Moose-0.69/lib/Moose.pm), which makes it
totally easy!

So this is the final mockup of how I plan on doing it:

```
package MyClass;
use feature ':5.10';
use Attribute::Handlers;
use Moose;

sub Authorize : ATTR(CODE) {
   my ($class, $globref, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

   # deep magic that gets the name of the function
   my ($function) = ${$globref} =~ /::([^:]+)$/;

   $class->meta->add_before_method_modifier ($function => sub {
         foreach (@{$data}) {
            $class->validate($_);
         }
      });

   return;

}

sub read_user : Authorize(qw/user_read user_write/) {
   my $self = shift;
   say "reading personal files!";
}

sub validate {
   my $self = shift;
   my $role = shift;
   say "validating $role for ".$self->user;
}

sub user {
   my $self = shift;
   return 'frew';
}
```


Debolaz from #perl helped out a lot with this one. The only major thing left is
some way to check all functions with the attribute 'Runmode' and ensure that
they also have the Authorize attribute with at least one thing in there. That
way we can't accidentally forget to authorize people. I don't think that will be
very hard, but even if we can't do it, this is still great.

The only thing I am worried about is whether I can use Moose in a CGI::App
class. Probably, but we'll see.

Hurray for Perl!
