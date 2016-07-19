---
aliases: ["/archives/706"]
title: "Dallas.p6m: May 2009"
date: "2009-05-15T05:41:35-05:00"
tags: [dallas, perl, perl-6]
guid: "http://blog.afoolishmanifesto.com/?p=706"
---
We had the second Dallas.p6m on May 12, 2009. Along with me there were two of my coworkers, s1n, Graham Barr, and Patrick Michaud. We discussed a lot of things. One of which was the difference between **subs and methods** in Perl6. And the fact that you can't imply self. This should explain it:

    class A {

       sub foo {
          say 'foo';
       }

       method bar($o:) {

          # much to s1n's chagrin, you can't
          # have baz() imply self.baz.  These
          # are his options

          say 'bar';
          self.baz;
          $o.baz;

          # great for when you have a lot
          # of object methods close by

          given self { .baz; }

          # this is the same as above but it's
          # not scoped.  Good for short methods

          $_ = self;
          .baz;

          # not really recommended as it
          # doesn't seem to be for anything
          # but attributes.
          $.baz;
       }

       method baz {
          say 'baz';
       }
    }

    my $a = A.new;
    A::foo;
    #A::bar; # dies

    #$a.foo; # dies
    $a.bar;
    A.bar;
    # note: there may be a distinction between
    # class and instance methods, but for now
    # you use the same method for both

I also asked Patrick if he thought that Perl 5 in Perl 6 would really happen and
if so how. He said it would happen, but probably not soon. There are really
three options. The first is to embed Perl 5 in Parrot. This is really the "best"
option as it would have 100% compatibility (except weird XS stuff,) and I think
Patrick said that it had been prototyped, so that's encouraging. The next option
would be to reimplement most of Perl 5 in Perl 6. This would never get close to
100% but it would still be an option. The last option would be to have major
parts of CPAN reimplemented in Perl 6, thus making compatibility far less
important. Important CPAN modules would be DBI, a good templating system, a web
framework ([in
progress](https://web.archive.org/web/20090515195235/http://use.perl.org/~masak/journal/38973)),
and some form of GUI toolkit.

Somehow we got into a discussion about Mojo, the framework Graham uses at $work. It is modeled after Rails and is supposed to be simple to port to Perl 6. The most important thing about it, as far as I can tell, is that it has **no dependencies**. Graham made it sound like a lightweight framework, but I guess he just meant the no deps thing. CGI-Application (what I use) totals to 7k lines. Mojo, on the other hand, totals to 50k. Not _exactly_ lightweight, but low dependencies is an interesting goal.

And then two thirds of us are going to YAPC::NA, so we talked about that some. Very exciting things coming up!
