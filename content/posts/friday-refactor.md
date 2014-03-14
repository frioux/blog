---
aliases: ["/archives/693"]
title: "Friday Refactor"
date: "2009-05-09T06:42:19-05:00"
tags: ["functional-programming", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=693"
---
It's Friday, so a long post is **not** in order. With that in mind, a simple refactor for your pattern matching skulls and skills:

before:

<pre>
   my @files = File::Find::Rule-&gt;file()-&gt;name('\*.t')
      -&gt;maxdepth( 1 )-&gt;in(
         File::Spec-&gt;catdir(
            $self-&gt;get_directory, 't'
      ) );

   my @total\_results;

   foreach my $file (@files) \{
      push @total_results,
         "<span class="file">$file</span>";
      push @total_results,
         @{ $self-&gt;test( $file ) };
   \}
   return join "\\n", @total\_results;
</pre>

Do you see what I see? We're iterating over a list and generating a new list... And then we are just doing a join on that. Enjoy the nice and functional rewrite.

after:

<pre>
   return join "\\n", map \{
      ( "<span class="file">$_</span>",
         @{ $self-&gt;test( $_ ) } );
   \} File::Find::Rule-&gt;file()-&gt;name('\*.t')
      -&gt;maxdepth( 1 )-&gt;in(
         File::Spec-&gt;catdir(
            $self-&gt;get_directory, 't'
      ) )
</pre>
