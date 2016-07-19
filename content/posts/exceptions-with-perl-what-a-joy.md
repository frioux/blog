---
aliases: ["/archives/1129"]
title: "Exceptions with Perl, what a joy!"
date: "2009-09-03T03:34:51-05:00"
tags: [mitsi, catalyst, exceptions, perl, try-catch]
guid: "http://blog.afoolishmanifesto.com/?p=1129"
---
Today at work I had to do some validation that we haven't yet had to do for my project at work. I've always thought that for validations exceptions are the way to go. I'll explain everything I did so you guys can benefit/critique.

First off, I used [Exception::Class](http://search.cpan.org/perldoc?Exception::Class) to create my exception classes:

    package ACD::Exceptions;

    use strict;
    use warnings;

    use Exception::Class (

       'ACD::Exception::InvalidBinBox' => {
          description => 'Invalid Bin-Box',
          fields => [qw{bin box}],
       },

       'ACD::Exception::UserException' => {
          fields => 'message',
       },

    );

    use Moose::Util::TypeConstraints;

    class_type 'ACD::Exception::InvalidBinBox';
    class_type 'ACD::Exception::UserException';

    no Moose::Util::TypeConstraints;
    1;

Also note the use of [Moose::Util::TypeConstraints](http://search.cpan.org/perldoc?Moose::Util::TypeConstraints); we'll come back to why I did that in a bit.

The following code is a method from a [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) Result class. Nothing too surprising here. It basically creates an exception if someone tries to use a nonexistent bin or a box that the bin doesn't contain.

    method validate_bin_box {
       my $bin = $self->bin;
       my $box = $self->box;

       my $success = $self->result_source->schema->resultset('BinBox')->single({
          bin     => $bin,
          max_box => { '>=' => $box },
       });

       ACD::Exception::InvalidBinBox->throw( bin => $bin, box => $box  ) unless $success;
    }

Next up is the Catalyst action which calls this method. This is the first part of the code I'm excited about. I'm using [TryCatch](http://search.cpan.org/perldoc?TryCatch) for the syntax sugar here. Note that I get to do a catch based on type of exception. This is why I had to use Moose to define the class\_type's above. You'll also note that I recast the Exception as a "UserException." I'll note why next.

    method update_inventory_part($c) : Local :ActionClass('Role::ACL::Simple') :RequiresRole('inventory_write') {
       my $id         = $c->request->params->{id};
       my ($bin,$box) = split /-/, delete $c->request->params->{location};
       my $part       = $c->model('DB::InventoryPart')->find($id);
       try {
          $part->update({
                %{$c->request->params},
                bin => $bin,
                box => $box
          });
       }
       catch (ACD::Exception::InvalidBinBox $e) {
          ACD::Exception::UserException->throw(message => 'Invalid Bin-Box: '.$e->bin.q{ }.$e->box);
       }
       $c->stash->{json} =  { success => 1 };
    }

And then this is the final (server side) method that wraps it all together. This belongs in the Root controller of our Catalyst app as it takes care of all of our errors. Basically what's going on here is that if there are errors we want to set a 500. We show the error raw if the server is in debug mode or if it is a user error. There is a small subtlety that there can possibly be more than one error. For simplicity's sake we show all the errors if we are going to show one of them.

    method end($c) : ActionClass('RenderView') {
       my $errors = scalar @{$c->error};
       if ($errors) {
          $c->response->status(500);
          my $user_error = 0;
          $user_error    = 1
             if (first { ref $_ eq 'ACD::Exception::UserException'} @{$c->error});

          $c->stash->{json} = {
             status => 'fail',
             reason => ( $c->debug || $user_error)
                ? join ';', map { (ref $_ eq 'ACD::Exception::UserException')?$_->message:"$_" } @{$c->error}
                : 'A server error occured.  Contact developers with date and time this occured',
             user_error => $user_error,
          };
          foreach (@{$c->error}) {
             $c->log->error("$_");
          }
          $c->clear_errors;
       }
    }

I won't show the javascript right now as it's messy and most readers of this blog aren't hardcore Ext users. But basically what happens is that we have a global listener for all connections that fail (aka, don't return with 200 OK) and I have some special code for various cases. For example, I have an unauthenticated case which allows the user to login (and then it seamlessly retries the query,) I have an unauthorized case if somehow the user tries to do something they are not allowed to do, I have a user error case, which will basically display the error verbatim, and then I have a server error message, which will output the raw exception (or the vanilla message above.)

The beauty of all this is that now that I've written the code sufficiently generically I should only need to do an ACD::Exception::UserException->throw(message=>...) to show the user an error window at any point in the program. Pretty sweet huh?
