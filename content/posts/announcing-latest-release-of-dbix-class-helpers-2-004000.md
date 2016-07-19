---
aliases: ["/archives/1404"]
title: "Announcing latest release of DBIx::Class::Helpers (2.004000)"
date: "2010-07-30T02:57:07-05:00"
tags: [announcement, cpan, dbix-class, dbix-class-helpers, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1404"
---
I am proud to announce a new release of [DBIx::Class::Helpers](http://search.cpan.org/perldoc?DBIx::Class::Helpers). There are five major changes in this release.

First off, the latest release adds [DBIx::Class::Candy](http://search.cpan.org/perldoc?DBIx::Class::Candy) exports. So if you are using DBIx::Class::Candy to define a result, certain methods will be imported into your namespace. For example, [DBIx::Class::Helper::Row::SubClass](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::SubClass) will export a subclass subroutine into your module. Not huge but nice nonetheless.

Next up, we have four shiny new components. Two are ResultSet components and two are Result components. One of the two ResultSet components was originally going to be in the core of [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class), but I decided to make a helper first to ensure that we iron out the details before we release it in core. That component is [DBIx::Class::Helper::ResultSet::RemoveColumns](http://search.cpan.org/perldoc?DBIx::Class::Helper::ResultSet::RemoveColumns). It does exactly what it sounds like. With it you can do

    $resultset->search(undef, {
       remove_columns => ['id']
    })

and the id column will no longer be selected in your ResultSet. I am sure that it has some quirks, but I am not sure what they would be till people use this. So have at it!

The next component, [DBIx::Class::Helper::ResultSet::AutoRemoveColumns](http://search.cpan.org/perldoc?DBIx::Class::Helper::ResultSet::AutoRemoveColumns), is based upon RemoveColumns. Again, the name should make it clear what it does. Currently it removes typically large columns by default, like text, blob, and the like. See the docs for exactly what it removes. (Note: later on I hope to add a component that adds lazy columns as detailed in [ovid's post here](http://blogs.perl.org/users/ovid/2010/07/lazy-database-columns-and-virtual-vertical-partitioning.html). Ovid if you are reading this I can't comment on your blog.)

Next up is a fairly simple component, [DBIx::Class::Helper::Row::StorageValues](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::StorageValues). It gives you access to the last known stored value of a column. For example:

    my $foo = $resultset->search({ name => 'frew'})
       ->next;
    $foo->name('frioux');
    # prints "frew"
    say $foo->get_storage_value('name');

Building upon that we have my favorite new component: [DBIx::Class::Helper::Row::OnColumnChange](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::OnColumnChange). This module adds powerful hooks for calling methods when a column has been modified. If you enable StorageValues for the column you hook into you get to look at the old value and the new value, which is pretty cool. There are three hooks: [before\_column\_change](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::OnColumnChange#before_column_change), [around\_column\_change](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::OnColumnChange#around_column_change), and [after\_column\_change](http://search.cpan.org/perldoc?DBIx::Class::Helper::Row::OnColumnChange#after_column_change). It automatically takes into account values changing because of accessors as well as by the arguments passed to update. Also note that it allows you to tell it to wrap the call to update and the column change method in a transaction so that you can safely do things to other tables in the method. Anyway, enough talk, here's a small example:

    __PACKAGE__->add_column(relationship_status => {
       data_type               => 'varchar',
       length                  => 30,
       keep_storage_value      => 1,
    });

    __PACKAGE->before_column_change(relationship_status => {
       method    => 'happy_times',
       txn_wrap  => 1,
    });

    sub happy_times {
       my ($self, $old, $new) = @_;
       $self->significant_other->update({ feelings => 'happy' })
          if $new eq 'together' && $old eq 'apart'
    }

So basically if relationship status changes from apart to togehter the significant other gets marked as happy, and all of this is done in a transaction, which is pretty awesome.

Anyway, hopefully this makes your job easier. Have a good Friday!
