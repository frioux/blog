---
aliases: ["/archives/909"]
title: "Should you have NULL's in your database?"
date: "2009-07-12T07:34:52-05:00"
tags: [mitsi, perl, database-design]
guid: "http://blog.afoolishmanifesto.com/?p=909"
---
So [recently I made a post](/posts/form-validation-sucks) regarding NULL's and '' with respect to numeric fields in a database. I asked questions on a couple different mailing lists for help and one of the interesting responses I got was that [You Shouldn't Have NULL's In Your Database Unless Required](http://www.bennadel.com/blog/85-Why-NULL-Values-Should-Not-Be-Used-in-a-Database-Unless-Required.htm).

Now, I totally understand that _for strings_, which is all the noted article actually discusses. But my issue wasn't with a string, it was with a number. I'd say that 0 is not the same as NULL when it comes to data. How many kids to you have? Oh you didn't answer. That must mean none. Seriously?

I think for non-text fields, converting '' to NULL makes perfect sense. After all, when someone does a submit from the browser it **must be a string** so unless you are doing something special you have to convert and filter and validate the input as a string anyway.

So tell me I am wrong. Show me a good reason **why non-string field's shouldn't be NULL**. I am certainly not as smart as other programmers, but I haven't seen a good argument yet.

(Note: I meant to post this before but I apparently forgot to press publish :-/)
