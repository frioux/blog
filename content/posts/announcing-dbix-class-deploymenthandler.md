---
aliases: ["/archives/1352"]
title: "Announcing DBIx::Class::DeploymentHandler"
date: "2010-06-11T03:33:54-05:00"
tags: [frew-warez, announcement, cpan, dbix-class, dbix-class-deploymenthandler, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1352"
---
Do you remember when you first realized that you were not the only person with a perspective in the world? I do. I was 5ish and I remember looking into the car to the left of me and seeing another person looking at me from their respective car. I remember thinking, "This is not what it is like from their point of view." I distinctly remember reevaluating things all day that day. I am sure that I was still just as selfish and childish as I was before that moment, but it certainly changed my point of view.

----

I am proud to announce, after three months of work, that
[DBIx::Class::DeploymentHandler](http://search.cpan.org/perldoc?DBIx::Class::DeploymentHandler)
is at a point where I'd call it stable and usable. DBICDH is a much more
flexible replacement for DBIx::Class::Schema::Versioned. Castaway did a great
job with making Schema::Versioned, and without it there is no way I would have
gotten started on DBICDH, but it is my sincere hope that this will be the
recommended tool instead of Schema::Versioned from now on. Rob Kinyon and
[mst](http://www.shadowcat.co.uk/blog/matt-s-trout/) had significant influence
on the overall API and design, so it is at least influenced by Very Smart
people. ribasushi helped a **lot** later on by pointing out poorly named methods
and directories as well as helping me use
[SQL::Translator](http://search.cpan.org/perldoc?SQL::Translator) correctly
since he knows all of its weaknesses and strengths.

Major features this has over DBIx::Class::Schema::Versioned:

- Multiple files for migrations
- Perl files in migrations
- Shared Perl/SQL for different databases
- Downgrades
- Not to mention extreme customizability

So try it out today! I am looking forward to getting bug reports soon :-)

Oh also, if it does not quite do what you want...

**PATCHES WELCOME**! :-D
