---
aliases: ["/archives/1415"]
title: "Reactions to porting Log::Contextual to Perl 6"
date: "2010-08-11T04:24:34-05:00"
tags: [log-contextual, perl, perl-5, perl-6, rakudo]
guid: "http://blog.afoolishmanifesto.com/?p=1415"
---
Today we had our Dallas.p6m meeting, which was a lot of fun as usual. This meeting was especially interesting because Rakudo \* was released since we last met. In the meeting I discussed my little project to port [Log::Contextual](http://search.cpan.org/perldoc?Log::Contextual) to Perl 6. First off, [here's the code](http://github.com/frioux/LCP6).

There are plenty of positives and negatives to Rakudo \*. First the positives!

## Positives

### It works!

It's pretty cool that the tests actually pass! Not all of them of course though...

### Pretty Syntax

People may not take this seriously, but . is better than ->. Seriously. Plus there are types etc.

### Built in Exporter

So.... this may or may not be a feature. It works for the simple stuff. Is it as flexible as [Sub::Exporter](http://search.cpan.org/perldoc?Sub::Exporter)?

### Private methods

In Perl 5 if you want to define a private method you use \_ as a prefix. First off that's an idiom, not part of the language, yadda yadda yadda. More importantly, it's not really private, just marked as "don't use this." With Perl 6 it's (almost) truly private. Nice.

### Meaningful Whitespace

A lot of people are gonna hate this one; but it's meant to solve the "print (5 + 6) \* 12" issue. It has a lot of other implications too, which again, are going to bother people. Now I can name a method log-debug instead of log\_debug or lord forbid logDebug. Nice!

### "Everything's an Object"

Arguably the best feature of Ruby. Perl 6 does it now. Neat!

## Negatives

### Subroutine signatures are enforced

This is hard for me. In Perl 6, a block (denoted "\{ ... \}") should take zero arguments unless you explicitly state otherwise (with $^a etc.) You may not notice that in most places, but Log::Contextual uses that kind of stuff constantly. I expected it to be like Method::Signatures::Simple which just sets values to undef if they are not passed. Anyway, I can live with this, it's just different.

### Captures vs Parcels

This is more like Javascript and Ruby, both of which I've used with joy, so I'm sure it will be fine. The gist of it is that when you do:

    sub foo (@bar, $baz) { ... }

    my @biff = 1,[2,3];
    foo @biff;

You will get an error because @biff binds to @bar and $bar is not set. If you want to use an array for arguments you have to do "foo |@biff". Much nicer than javascript's apply, and the same as Ruby's \*.

### Glacially Slow

This is not surprising at all. Not even really a complaint, but must be noted. To run the entire testsuite for Perl 5 takes 1.5 seconds. To run a **single** test for the Perl 6 version it takes more than 10 seconds. I learned in the meeting that I could precompile my modules and save a lot of time; like, three orders of magnitude difference.

### Incomplete

Again, this is expected. Still annoying. Features I miss are lack of temp (which Patrick pointed out that I can **almost** replace it with dynamic variables, and soon I will be able to all the way), lack of caller, and write access to the symbol table.

### Things are... different

My main example is that in Perl 6 undef == Any(). Patrick explained it. It makes sense. It's still weird.

### Docs aren't done yet

I couldn't figure out how to get Roles to work. I'm not really sure how it is supposed to work. Am I supposed to use the role in the class that "does" the role? What about the code that is checking if it "does" the role? I thought I tried all permutations. What a hassle.

### The Perl 6 meta object protocol is not Perl 5's Class::MOP

There are subtle differences between Class::MOP and Perl 6's MOP. Do not assume that they are the same. You will get bitten. On the other hand, it has a great shortcut! Perl 5: $class->meta->foo. Perl 6: $class^.foo.

Those are the major issues I noticed.

If you are interested, by the way, Log::Contextual has three major features that you might like. First, it returns the arguments you pass it, so you can use it in the middle of subroutine calls and whatnot. Next, it has convenience methods for automatically printing out stringified data structures. Nice! And lastly, (but arguably the whole point) is that it has a great interface based on lisp-y principles. I really should give it it's own blog post at some point...
