---
aliases: ["/archives/1424"]
title: "Announcing DBIx::Class::Storage::PrettyPrint"
date: "2010-09-07T02:17:50-05:00"
tags: [frew-warez, dbix-class, cpan, perl, announcement]
guid: "http://blog.afoolishmanifesto.com/?p=1424"
---
Recently I read [a post by ovid](http://blogs.perl.org/users/ovid/2010/08/pretty-sql-output-on-test-failure.html) where he shows color coding SQL on test failures. I really wanted to steal his code for [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class)'s trace output. For MSSQL it would be especially helpful since our pagination involves two subqueries. ribasushi had pointed out in the past that all we need to do this (and do it correctly) was to refactor a bit of the test code and we'd have a proper parser and deparser.

Anyway, I got it into a state that I think is actually quite usable! Currently it's in a dev release (1.67\_01) of [SQL::Abstract](http://search.cpan.org/perldoc?SQL::Abstract) because we want to iron out any interface issues before blessing it. It's also a little bit of a hassle to use at this point, but that will get worked out when it's cored. To use it, just put the following in your MyApp::Schema:

    use DBIx::Class::Storage::PrettyPrinter;
    my $pp = DBIx::Class::Storage::PrettyPrinter->new({ profile => 'console' });

    sub connection {
       my $self = shift;

       my $ret = $self->next::method(@_);

       $self->storage->debugobj($pp);

       $ret
    }

Now if you set DBIC\_TRACE you'll get color-coded, indented, correctly nesting sql!

If you want to install it the easy way use App::CPAN::Fresh as follows:

    cpanf -dmi SQL::Abstract

And lastly, but arguably most importantly, [a screenshot](/wp-content/uploads/2010/09/example.png).

It's certainly not perfect, I'd like to add some kind of width parameter so that it wraps more nicely. There are lots of configurable bits that aren't documented yet; at some point I'll get that taken care of. Anyway, enjoy!
