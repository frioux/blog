---
aliases: ["/archives/503"]
title: "DBIx::Class: A Love Story"
date: "2009-04-01T01:57:50-05:00"
tags: ["dbix-class", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=503"
---
Until recently most of the work I have done with DBIC has been very basic. I made a lot of simple classes, done some basic searches, paginated, and that was more or less it. The only thing in there that is really a major change from vanilla DBI was the pagination. Oh the glory of automatic pagination!

Well, recently I have been doing more complex things, and let me tell you, it has been a joy!

First off, Wes told me about the idea of a TO\_JSON method. What I had been doing previously was in the controller I would list the columns I wanted from a class when I turned it into JSON. This is fine for the simple case, when all you want is simple data; but what if you want the data from a related table? Not so great. So I decided to set up TO\_JSON methods for all of the classes. Now we just use whatever that provides in the controller. Sometimes we return more data than we would have otherwise, but since we paginate to 25 records by default that hasn't become a problem. That cut the controller code down by maybe 25%. That's significant in my book!

And then there are complex searches. Here is a scenario I had yesterday: the customer wanted to search in table X, which is related to table Y, based on some criteria for Y. In DBI I would have had to define a join blah blah blah. Because I predefined the relationship from X to Y in the model class, this was my search:

    $self->schema->resultset('X')->search({
          'Y.serial' => { -like => "%$param%" },
       },{
          join => 'Y'
       });

That's it for now, but I am sure this story is not over...
