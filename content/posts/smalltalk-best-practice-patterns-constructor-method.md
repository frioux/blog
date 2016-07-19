---
aliases: ["/archives/1665"]
title: "Smalltalk Best Practice Patterns: Constructor Method"
date: "2011-09-01T23:28:43-05:00"
tags: [frew-warez, best-practice, patterns, smalltalk]
guid: "http://blog.afoolishmanifesto.com/?p=1665"
---
Sadly reading is going slower than expected due to being so busy with various things in life. Oh well, just a single pattern today.

# Constructor Method

**How do you represent instantiation?**

In addition to a vanilla constructor, add methods for common cases to instantiate typical objects. For strange cases allow the use of accessors.

Using Perl (with Moose) an example might be:

    package Point;

    use Moose;

    has x => (is => 'ro');
    has y => (is => 'ro');

    sub r_theta {
      my ($class, $r, $theta) = @_;

      $class->new(
        x => $r * cos($theta),
        y => $r * sin($theta),
      );
    }

    1;

So now both of the following work:

    my $p = Point->new(5, 6);
    my $v = Point->r_theta(10, 1.4);
