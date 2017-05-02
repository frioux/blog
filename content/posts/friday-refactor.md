---
aliases: ["/archives/693"]
title: "Friday Refactor"
date: "2009-05-09T06:42:19-05:00"
tags: [mitsi, functional-programming, perl]
guid: "http://blog.afoolishmanifesto.com/?p=693"
---
It's Friday, so a long post is **not** in order. With that in mind, a simple refactor for your pattern matching skulls and skills:

<!--more-->

before:

```
my @files = File::Find::Rule->file()->name('*.t')
   ->maxdepth( 1 )->in(
      File::Spec->catdir(
         $self->get_directory, 't'
   ) );

my @total_results;

foreach my $file (@files) {
   push @total_results,
      "<span class="file">$file</span>";
   push @total_results,
      @{ $self->test( $file ) };
}
return join "\n", @total_results;
```

Do you see what I see? We're iterating over a list and generating a new list... And then we are just doing a join on that. Enjoy the nice and functional rewrite.

after:

```
return join "\n", map {
   ( "<span class="file">$_</span>",
      @{ $self->test( $_ ) } );
} File::Find::Rule->file()->name('*.t')
   ->maxdepth( 1 )->in(
      File::Spec->catdir(
         $self->get_directory, 't'
   ) )
```
