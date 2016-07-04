---
aliases: ["/archives/939"]
title: "Speed, OO, Black Magic, and YAGNI + RTFM"
date: "2009-07-16T02:17:42-05:00"
tags: ["black-magic", "oo", "performance", "perl", "rtfm", "yagni"]
guid: "http://blog.afoolishmanifesto.com/?p=939"
---
At work we have a certain customer who has a database with something like 250 report tables. They are generated and maintained purely in code and if you ever touch one manually it's for a one-off script or something. Anyway, we recently started using [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) at work and part of that meant accessing those report tables with DBIC.

The first step was to use [DBIx::Class::Schema::Loader](http://search.cpan.org/perldoc?DBIx::Class::Schema::Loader,), which looks at the table structure and generates a bunch of perl files. Then we just use DBIC as normal. Unfortunately this is in a CGI environment, without mod\_perl, or FastCGI or any of that stuff. That means not only is this loading all 250 files (each 25~ K in size,) but also parsing them etc. Just to be clear, we have a 15 second startup time. Have fun telling your customer that that's better in an AJAX context.

So that was just **Not Okay**. I asked in #dbix-class and Rob Kinyon suggested
that I make a YAML file that would represent all of the tables. He couldn't give
me code and it was Friday, but I did get my code to add columns on the fly, so
it couldn't be much harder to go from there, could it?

Of course it could! It always will in such a context. So I asked again, what would be the best way to generate in memory classes of a single data structure, in #dbix-class. castaway recommended subclassing DBIx::Class::Schema::Loader to do what I wanted. So that took a few hours to get to work, including figuring out how everything worked. That was really pretty exciting because it was a Good Way to do what I wanted. Too bad there are some Schema::Loader implementation issues.

Turns out that after making our full data structure it took _longer_ to load the classes into memory than to leave them on the hard drive. I should have realized this would be the case, but for some reason I blocked it out: S::L works by writing temporary files and having perl include them, so really we were reading just as much data but also writing it too. At this point I have spent about 10 hours total on this project and it's absurdly slow. My boss was not very happy. The irony was that I had used the initial success of the subclass of S::L for leverage in a certain bargain, which I hope to post about soon.

I spoke with ilmari, the person who wrote S::L and he was telling me how to make S::L do everything in memory, but I couldn't get it to work and my boss (quite reasonably) was breathing down my neck.

So pure, unadulterated Black Magic it was. I would write all the code as a string and then include that with strange require tricks. I can't take credit for this really, as I got a lot of help from people on [StackOverflow](http://stackoverflow.com/questions/1128117/how-do-i-create-an-in-memory-class-and-then-include-it-in-perl). Anyway, here is how that could be done:

    #!/usr/bin/perl

    use strict;
    use warnings;
    use feature ':5.10';

    my $data_struct = [{
          table => 'Foo',
          columns => [qw{foobar foobaz}],
       },{
          table => 'Rpt1',
          columns => [1..20],
       }];

    $data_struct = [map { { table => "EPMS::Schema::Result::".$_->{table}, columns => $_->{columns} } } @{$data_struct} ];

    my $tables = [ map { $_->{table} } @{$data_struct} ];
    my $columns = { map { $_->{table} => $_->{columns} } @{$data_struct}};

    foreach my $class (@{$tables}) {
        no strict 'refs';
        *{ "${class}::INC" } = sub {
            my ($self, $req) = @_;
            return unless $req eq $class;
            my $data = qq!
                package $class;
                use feature ':5.10';
                sub foo {
                   my \$self = shift;
                   say "\$self:".\$self->columns;
                }
                \$columns = [!.join(',', map { qq['$_'] } @{ $columns->{$class} } ).qq!];
                sub columns {
                   my \$self = shift;
                   return join ',', \@{\$columns};
                }
                1;
            !;
            open my $fh, '<', \$data;
            return $fh;
        };
       my $foo = bless { }, $class;
       unshift @INC, $foo;

       require $class;
    }

That works, but it was still actually pretty slow, surprisingly.

I also tried concatenating all of the files into a single file and it was still more or less just as slow.

So finally I broke down and did the unthinkable: I RTFM'd on DBIx::Class::Schema to see if there were any clues. The clue that I got out of it was the following bit:

> register_class
>
> ...
>
> You will only need this method if you have your Result classes in files which are not named after the packages (or all in the same file). You may also need it to register classes at runtime.

So what I could do is generate all the classes with code, but really simply, without all the column metadata since the DB is the single point of truth in this context, and then load the ones we'd need on the fly!

It was easy as pie. Use a template to generate the classes and write them to files (we used the namespace EPMS::Schema::NonDefaultResult, so that it's clear that it's result, but not loaded by the load\_namespaces method of the schema.) Then I just added a method to our Schema that would do the following (from memory):

    sub load_report {
       my ($self, $report_num) = @_;
       eval "require EPMS::Schema::NonDefaultResult::Rpt$report_num";
       $self->register_class("Rpt$report_num", "EPMS::Schema::NonDefaultResult::Rpt$report_num");
    }

And that was basically it. I also wrote a little bit of code to short circuit if the report is already loaded. Anyway, it works reasonably quickly and isn't too ghetto! So the moral of the story is probably to RTFM before you try crazy stuff.
