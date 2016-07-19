---
aliases: ["/archives/899"]
title: "Model Based Security"
date: "2009-07-08T02:47:02-05:00"
tags: [mitsi, dbix-class, model, orm, perl, programming]
guid: "http://blog.afoolishmanifesto.com/?p=899"
---
So this is probably old hat to those people who are already big on architecture or know a lot about design patterns, but I thought it was a pretty clever implementation of data security. Anyway, first I'll start off with how I actually did it, and then maybe talk about it in the abstract.

So here's the idea, I have a user, and that user should only be able to view a certain set of messages. The messages are linked to groups which the users are linked to. So users have groups, and then groups have messages. So to display the messages we do something like this:

    my $to_display =
       $user->groups->related_resultset('messages');

And then you can use that kind of code to limit other things which would more easily cause security issues:

    my $message =
       $user->groups->related_resultset('messages')
          ->find($id);

The fact that DBIC allows you to chain your searches is really what allows this kind of thing to happen. Of course, it could be emulated with most data structure based ORM's by modifying the data structure that gets passed to the search or find method.

(I am pretty sure that you could do this just as easily with [DBIx::Class::Schema::RestrictWithObject](http://search.cpan.org/~groditi/DBIx-Class-Schema-RestrictWithObject-0.0001/lib/DBIx/Class/Schema/RestrictWithObject.pm), but chaining off of user makes a lot of sense to me, so for now that's how I'll pull that off.)

Now before we get into a more general discussion I'd like to point out that because of DBIC's implementation (and possible emulation of it already previously mentioned) this shouldn't really be too much of a performance hit. Of course, the more related\_resultset based chaining you do the more tables you are joining into the query, and that's where you will start seeing performance issues.

Ok, so the general approach:

It seems to me that it wouldn't be too hard to make a Highlander (Singleton) that would basically have methods for all of your ResultSet's (or tables in SQL-talk.) It would contain any user credentials that are needed to get at any data. The idea would be to have it throw an exception if you were to try to instantiate it without all of the data needed to do your security stuff. Really that's just good OO; any instantiated object should be complete.

Now I have to point out that this really isn't a complete solution. My friend [Fjord](http://curtis.hawthorne.name/blog/) works on [Birdstack](http://birdstack.com) and they need to support the hiding of specific columns, of specific rows, depending on a number of criteria. It's possible that he could do this for birdstack, but that would end up making each optional column a join table, which would be slow and cumbersome. I don't remember how he solved the issue, but I imagine that the best way to pull it off would be with a Highlander class that filtered each Result (row) coming from each ResultSet. I guess it would need to return specialize read-only classes or something.

One way or another, I think that no matter what, this fine grained control of public vs private data is going to be hard to manage and slow in a regular RDBMS. An object database might be able to handle it better, but I haven't really thought much in that vein yet.

So with that I say to you peace be within your walls and security within your towers and racks!
