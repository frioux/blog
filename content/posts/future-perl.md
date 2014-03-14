---
aliases: ["/archives/633"]
title: "Future Perl"
date: "2009-05-07T01:10:36-05:00"
tags: ["perl"]
guid: "http://blog.afoolishmanifesto.com/?p=633"
---
This is mostly stuff I've gathered from [this talk](http://www.shadowcat.co.uk/catalyst/talks/postgresql-WEST-2008/-files/perl5s-alive.xul) and updated slightly.

First off, have you ever tried to teach a programmer perl? I have. Note this:

    sub foo {
       my ($self, $bar,$baz) = @_;
       #...
    }

    # or often
    sub station {
       my $self = shift;
       #...
    }

The following is more palatable to most coders (also I like it better:)

<pre>
use <a href="http://search.cpan.org/search%3fmodule=Method::Signatures::Simple">Method::Signatures::Simple</a>;
method foo($bar, $baz) \{
   #...
\}

method station \{
   #...
\}
</pre>

That's right, no fiddling with @\_ at all. Sweet! Also note: this is not implemented with sketchy source filters. It's quite robust. There is also [MooseX::Method::Signatures](http://search.cpan.org/search%3fmodule=MooseX::Method::Signatures) (and [MooseX::Declare](http://search.cpan.org/search%3fmodule=MooseX::Declare) which uses that) which can do even more, like defining named and optional params and type constraints.

I've already [mentioned](/archives/570) [IO::All](http://search.cpan.org/search%3fmodule=IO::All), so I'll just say that it's been endorsed by Matthew S. Trout, so you don't have to tell me that the Right Way is to use some crufty C based interface or some weird old perl module that has capital letters in the functions and method parameters.

Next up, [Moose::Autobox](http://search.cpan.org/search%3fmodule=Moose::Autobox). I've also [mentioned](/archives/63) [autobox](http://search.cpan.org/search%3fmodule=autobox), which this module uses, but Moose::Autobox goes further and defines some roles that your classes can also use to make them act like arrays etc. I wouldn't be surprised if DBIx::Class 0.09x used some of these roles. Anyway, here's a real example:

    use Method::Signature::Simple;
    use Moose::Autobox;

    method criticisms {
       return {
          data  => $self->files_criticized->values->map(sub { @{ $_->{criticisms} } })
       };
    }

Not quite Perl 6/Ruby, but still much clearer than the original (at least to this function programmer!)

And the of course there is the recently released (four months ago!) [TryCatch](http://search.cpan.org/search%3fmodule=TryCatch). I haven't used this module at all, but I look forward to it. It could really streamline some of the stuff we do at work.

Lastly, [CLASS](http://search.cpan.org/search%3fmodule=CLASS) is a tiny nicety. All it does is replace \_\_PACKAGE\_\_ with CLASS; the code looks cleaner with it and it's certainly shorter and easier to type.

I think we'll be seeing a lot more of this kind of stuff in the near future. [Devel::Declare](http://search.cpan.org/search%3fmodule=Devel::Declare) seems to have mostly matured, so these modules will probably continue to crop up.

Anyway, woohoo! The future!
