---
aliases: ["/archives/274"]
title: "Paranoid Deletion in DBIx::Class"
date: "2009-02-17T16:49:01-06:00"
tags: [mitsi, dbix-class, perl]
guid: "http://blog.afoolishmanifesto.com/?p=274"
---
In the most well designed databases that I've used we never really deleted anything from the database. We would just mark a field as deleted and then just make sure to filter out the deleted data when we searched and it was all groovy. You could easily readd the item and you never truly lost much data.

Well, now that I am using an ORM I'd like a similar feature in my current database and I'd like it to be as automatic as possible. The first thing I did was, in the Model class, override the delete method. Easy peasy:

    package ACD::Model::CustomerBillingAddress;
    use base DBIx::Class;

    __PACKAGE__->load_components(qw/PK::Auto Core
       InflateColumn::DateTime/);

    __PACKAGE__->table('CustomerBillingAddresses');

    __PACKAGE__->add_columns(qw/
        customer_id
        id
        # ...
        creation_date
        deletion_date
        phone
        fax
        email
        /);

    __PACKAGE__->set_primary_key(qw/customer_id id/);

    __PACKAGE__->belongs_to('customer' =>
      'ACD::Model::Customer', 'customer_id');

    sub delete {
       my $self = shift;
       $self->update({
          deletion_date => \"GETDATE()"
       });
    }

    1;

And then to filter out the deleted rows I just did this in my Contoller's search function:

    $search->{deletion_date} = \"IS NULL";

(I have a Controller based function because it also turns all the data into json, paginates it, etc.)

But setting that in every single model class is Bad Design. What if I decided to switch to a boolean instead of a date? So I did some research and found out that with [Components](http://search.cpan.org/perldoc?DBIx::Class::Manual::Component) I could change the delete method. So here is a component that does what I want:

    package ACD::ParanoidDeletion;
    use base qw(DBIx::Class);
    use strict;
    use warnings;
    use feature ':5.10';

    sub delete {
        my $self = shift;
        $self->update({
            deletion_date => \"GETDATE()"
        });
    }

    1;

That's pretty cool! And then to use it I just add this line to my model classes:

    __PACKAGE__->load_components(qw/
       +ACD::ParanoidDeletion
       PK::Auto Core InflateColumn::DateTime/
    );

Now there is really only one thing left that bugs me about this current interface. When searching I have to remember to filter out the deleted items. Again: bad design! So after more research and help from people in #dbix-class I came up with this solution. First we make a new ResultSet class:

    package ACD::ParanoidResultSet;
    use strict;
    use warnings;
    use base 'DBIx::Class::ResultSet';

    sub search {
        my $self = shift;
        $_[0]->{deletion_date} = \"IS NULL";
        return $self->next::method( @_ );
    }

    1;

That override's the search method and add's deletion\_date IS NULL to the sql query. The next::method call is what would be super in java, except not quite the same because it allows for multiple inheritance.

And then, this is the best part, to have the models automatically use this resultset we add the following method to our ParanoidDeletion Component:

    sub table {
        my $class = shift;
        $class->next::method( @_ );
        $class->resultset_class('ACD::ParanoidResultSet');
    }

and that's basically it! The only real thing left to do is allow the user of the class to specify which column will be set on deletion and then package it up and send it to CPAN!

Enjoy!
