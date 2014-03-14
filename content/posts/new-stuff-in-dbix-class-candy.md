---
aliases: ["/archives/1527"]
title: "New Stuff in DBIx::Class::Candy"
date: "2011-03-09T18:05:31-06:00"
tags: ["cpan", "dbixclass", "dbixclasscandy", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1527"
---
I'm extremely proud to announce a fairly major release of DBIx::Class::Candy, 0.002000. Not only are the tests much more complete as well as the underlying code much more comprehensible, but the usage of the Candy can now be **even** sweeter.

To get the full features of DBIx::Class::Candy you'll want to first create the following base class:

(Of course you can call this sugar if you hate my naming scheme or rainbows if you love it.)

    package MyApp::Schema::Candy;

    use parent 'DBIx::Class::Candy';

    sub base () { 'MyApp::Schema::Result' }
    sub perl_version () { 12 }
    sub autotable () { 1 }

    1;

Now a basic id, name table would look like this:

    package MyApp::Schema::Result::Permission;

    use MyApp::Schema::Candy;

    primary_column id => {
      data_type => 'int',
      is_auto_increment => 1,
    };

    unique_column name => {
      data_type => 'varchar',
      size => 30,
    };

    1;

id got set to the pk, name got a unique constraint, the table was named permissions, perl 5.12 features were imported, the base class was set to MyApp::Schema::Result. How awesome is that! Not that you can do the same thing as above without a subclass if you like still:

    package MyApp::Schema::Result::Permission;

    use DBIx::Class::Candy
       -base => 'MyApp::Schema::Result',
       -perl5 => v12,
       -autotable => v1;

    primary_column id => {
      data_type => 'int',
      is_auto_increment => 1,
    };

    unique_column name => {
      data_type => 'varchar',
      size => 30,
    };

    1;

I should give credit where credit is due. Getty had lots of ideas for improvements, but the first one I implemented (due to how easy it was and how much I liked it) was primary\_column. mst had the idea of automatically generating the table name and using a subclass of candy to avoid boilerplate. Enjoy!
