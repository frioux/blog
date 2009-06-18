---
aliases: ["/archives/828"]
title: "Why you should validate in your controllers and not your models"
date: "2009-06-18T04:29:28-05:00"
tags: ["mvc", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=828"
---
Okay, I got some responses based on my [question](/archives/819) yesterday about why validation shouldn't be in the model of an MVC-based app.

This is what I got out of the responses:

### Models don't know about the current user (or other higher level information)

This means that if you have some kind of time based input the timezone modifications need to happen in the controller. Or the even better example is that sometimes a user can change more of a model than another user based on the user's permissions or roles. Personally I would just have a method on the model that had specific columns enabled and disabled, and then it would throw exceptions based on what columns the user tried to set. I can't say for sure whether or not that is a scalable methodology. But it seems reasonable.

### The earlier you validate the better, or fail fast

General programming practices often say that you should fail fast. This makes sense because you then have less time for bad data to be in the system. The problem is that assumes that you validate your data in the controller. If your model does validation, (again, assuming you validate at all) you should never be able to have bad models. But if you create some model at more than one place in your Controller, then you have to validate in both. I personally don't think that this is a good argument.

### If you do decide to do model based validation you need a structure to deal with that

Basically the issue here is that models shouldn't return error messages that the user reads. The reason being that the model doesn't know what language the user speaks, or in what context the user will read the message, and therefore, can't give the user the correct language error message. So instead the controller gets some kind of error code from the model and translates that into an error message. Not really a hard thing to do, but certainly something to keep in mind.

### Do all validation in the database

And then there is the other end of the spectrum, which says that you really shouldn't validate in your database **or** your model. I can see why that is really the best solution, but I think it needlessly ties a lot of dependencies on your specific database. Good luck writing a database independent trigger (or whatever) that ensures that a given input is an email address. Or a valid url or even something more complex. Honestly, I worked on a project like this in college, and it was nice that we always knew for a fact that our application wasn't saving bad data because the DB wouldn't let it, but we also had one guy who **just did database coding**. I like Perl. I like Javascript. I use DBIx::Class because I am happy to not write direct SQL. Writing code in the DB to validate my inputs just sounds painful.

### Conclusion

I have decided that I am going to try to integration my validation with my models. I know there are places where I will have to do validation in the controller, and that I also need to have the controller relay the messages from the model to the user, but it still seems to me that the controller doing validation should be the exception rather than the rule.
