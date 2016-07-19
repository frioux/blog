---
aliases: ["/archives/1660"]
title: "Smalltalk Best Practice Patterns, Chapters 1 and 2"
date: "2011-08-30T23:29:23-05:00"
tags: [frew-warez, best-practice, patterns, programming, smalltalk]
guid: "http://blog.afoolishmanifesto.com/?p=1660"
---
For work I decided I'd start reading some technical books, taking notes, and then trying to reiterate what I've learned. Yesterday I read the Preface and Chapter 1 and today I read Chapter 2, but sadly it's all still introductory. I might as well discuss what I've read nonetheless.

First though, I should say that I am reading the book because Thomas Doran of Catalyst development recommended it, and it clearly applies to Perl with Moose. I am sure some of it won't be applicable (the whitespace formatting for example) but hopefully it can make me a better programmer.

# Preface

The main point of the book is to go over things that programmers deal with all the time, examples given are naming, where to split up methods, and how to make comprehensible code.

The overall structure of a pattern is:

- Recurring daily programming problem
- Tradeoffs affecting the solution
- Recipe for solution

Patterns (especially the ones in this book) are good for pretty much everyone. Beginners, obviously, as they don't have experience or habits yet and these are "blessed" habits that they can start using immediately. Professional programmers may get a fresh perspective or even more importantly a shared vocabulary for what they already do. Teachers can use patterns as stepping stones to teach students or even just ideas for material to teach. Managers, lastly, can use patterns for communication, so that they can actually understand what their programmers are doing.

# Chapter 1 - Introduction

The title, Smalltalk Best Practice Patterns, can be broken into three parts. Smalltalk is the language used in the book. Best Practice is a legal term which basically means you did what a professional would do, without neglect. And Patterns are, according to the book, decisions that experts make over and over.

Interestingly, the distinction is made between coding and programming, which I always thought was largely archaic. The fundamental point that Beck makes remains though. There is a time for planning, and a time for implementation, and if you run into an issue during implementation **change the plan**.

When programs get huge, hard to understand, and generally unwieldy, the information you should take from this is that you need to fix whatever issue is causing these problems, don't just assume that the plan is set in stone and leave it forever.

The patterns described in the book should help you decrease duplicate code, remove conditional logic (not really sure what he means by that yet,) simplify complex methods, and clean up "structural code," that is, using objects as data structures.

Good programs balance speed of development, project mutability over the lifetime of the system, and "copy pasta," which is my term for making code that should be ok to be cargo culted.

Keep in mind that some patterns on help some of the above items listed. That's reality and part of becoming a great programmer is knowing which thing to optimize for when.

Another thing stressed in the book is that code should be written to be read. That doesn't mean write lots of comments (this is my interpretation) but it means name variables well, name methods well, and don't do confusing things in the code if possible.

The things that all patterns take into account are productivity, life cycle cost (not making something so unmaintainable that you can't do other work too,) time to market, and risk. Again, these things need to be balanced.

According to Beck, good style is not repeating yourself, writing short methods and small objects, things should be modular and replaceable, low coupling which again leads to replaceability, and lastly, segmentation based on rates of change. The last bit I'd never really considered before. A perfect example is Catalyst vs CGI::Application. With Catalyst you have a "context" that changes for each action and gets passed to the controllers. The context has a request and a response. With CGI::Application, on the other hand, the request and response are part of the controller, so the controller gets mutated on each response at a higher rate of change than the controller really needs.

A number of issues aren't discussed in the book. Exception handling is one, as it is confusing and the author didn't have a signification amount of experience with it. Copying objects isn't really discussed as it's usually a performance suck. Become (which I'm guessing is a Smalltalk feature) isn't discussed because it's confusing. Performance isn't discussed as it's typically not worth considering. Overall design isn't discussed; he points to the Gang of Four book for that. Modelling and Requirements are entire books in themselves and thus left out. And lastly UI design is left out, as it's probably an entire field in itself.

The book is organized into 6 parts, philosophy of patterns, patterns for methods, patterns for state, patterns for collections, a brief overview of classes (in Smalltalk I'm guessing,) and formatting (which I might not even read.)

There are three methods for adoption of patterns listed in the book. First is the Bag of Tricks method, where you pick and choose the few that you'll start to implement over time. Next is as a fairly large style guide, complete with justifications. You pick the patterns for your organization, have programmers read them, and then ensure that people use them. Last is the Whole Hog method, where you keep the book in your lap and every time you need to make a choice the book discusses, you look up the appropriate pattern and apply it. I'm hoping to try the latter method, but we'll see if I can keep to that.

To learn a pattern you should focus on the context (patterns before and after the pattern.) You should read the example. Focus on the problem shown and the solution shown. If possible try to find examples of the problem in your own codebase. Lastly, write your own example. I fully intend on writing an example of each pattern in Perl.

# Chapter 2 - Patterns

One interesting point is that patterns are supposed to work where code reuse doesn't. Another interesting fact is that a lot of these patterns are so small that reuse would be meaningless, for example, how do you "reuse" the naming of a method?

One of the main goals for patterns is to increase communication. To increase communication you either need to say more, or have the speaker and listener share more ground so words mean more. The latter is what patterns try to achieve.

By knowing patterns you should be able to understand code that uses such patterns better. Patterns will also help you answer questions that come up constantly during development. Shared patterns also help reduce the friction involved with code review as you just request that a pattern be implemented in a give place. Patterns can also reduce documentation as it is more shared by the writer and reader. Lastly, when joining an existing project, rote application of a handful of patterns can often help general understanding of the project as well as some basic cleanup.

The format for all patterns is: a title/name for the pattern, optionally any patterns that should be read before the current pattern, the problem that the pattern solves or maybe the question it answers, the forces that constrain the pattern, the solution to the problem, discussion or practical application of the pattern, and lastly, any patterns that should be read after the current pattern.
