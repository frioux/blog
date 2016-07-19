---
aliases: ["/archives/1670"]
title: "Smalltalk Best Practice Patterns - Constructor Parameter Method"
date: "2011-09-03T23:10:06-05:00"
tags: [frew-warez, best-practice, javascript, patterns, perl, smalltalk]
guid: "http://blog.afoolishmanifesto.com/?p=1670"
---
How do you set instance variables from a constructor method?

The fundamental issue here is that often validation is bypassed at construction time, for whatever reason. So one's accessor may look something like this:

    sub x {
       my $self = shift;

       if ($self->constructing) {
         if (exists $_[0]) {
           $self->{x} = $_[0];
         } else {
           return $self->{x}
         }
       } else {
         if (exists $_[0]) {
           die 'too high!' if $_[0] > 100;
           die 'too low!'  if $_[0] < 0;
           $self->{x} = $_[0];
         } else {
           return $self->{x}
         }
       }
    }

Clearly this method is just doing to much. To solve this we make special set methods that are entirely to be used during construction. So in Perl this might look like the following:

    sub _set_x {
      my ($self, $x) = @_;
      $self->{x} = $x;
    }

Interestingly, with Moose we happily side-step this issue, as the default constructor doesn't go through the accessors and already sets the raw values.

----

Ok, so I think I may start trying to apply this stuff to JavaScript instead of Perl. I almost feel like the fact that I have Moose in Perl is cheating. I know that there is Joose in JavaScript, but I've yet to use that in production, and I find that I have a harder time making well factored code in JavaScript than Perl. Part of that is that the underlying libraries I use in JS (ExtJS 3) are not really well factored either, but I still struggle with overall structure.
