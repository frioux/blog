---
aliases: ["/archives/1663"]
title: "Smalltalk Best Practice Patterns - Chapter 3 - Behavior - Methods"
date: "2011-09-01T00:05:58-05:00"
tags: ["behavior", "best-practice", "methods", "patterns", "smalltalk"]
guid: "http://blog.afoolishmanifesto.com/?p=1663"
---
Today I had to spend time taking care of passport stuff for my upcoming honeymoon, so I only got to read a handful of pages. I'll post my notes nonetheless.

Methods are more important that state because, correctly factored, methods paper over any changes in state over time. Most of us who took OO classes in college had this hammered into our brains :-)

Methods should be written to get something done, but should also be written to communicate with the reader. Method names like "task\_1", "task\_2", etc are completely useless for a regular person, and should be named as to what they actually do.

Small methods are expensive in that they cost more CPU cycles and typically cause the novice trouble in following the structure of a program. On the other hand, more methods means more human readable names, easier maintenance (pinpointing changes,) and method overrideability is much more feasible with small methods.

# Composed Method

**How do you split your program into methods?**

As already mentioned, large methods are faster and easier for the reader to follow, but small methods with good names work well in the long run. A seasoned programmer is able to see a method and assume what it does without needing to read the code for it. On top of that, small methods with good names allow you to communicate the structure of your code to the reader. Also, small methods are a must for inheritance.

**Split your program into methods that do a single identifiable task.**

A Perl example might be something like:

    sub run_app {
      my $self = shift;

      $self->intialize_app;
      $self->app_loop;
      $self->shutdown_app;
    }

The **Composed Method** patter can be used in a top down fashion, that is, write your higher level methods in an almost pseudo-code fashion, and then fill in the details of the lower level methods as you work. You may also opt to use the bottom up approach of writing a larger method and splitting it into smaller methods as you notice repetition or other reusable structures. Or lastly (and I think the most new idea to me) you can use this to find holes in your API. So if an object is calling more than one method on another object, the second object probably needs to implement a method that will encapsulate the multiple calls.
