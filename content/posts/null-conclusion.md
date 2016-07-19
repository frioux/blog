---
aliases: ["/archives/932"]
title: "NULL Conclusion"
date: "2009-07-14T04:32:48-05:00"
tags: [mitsi, perl, database-design]
guid: "http://blog.afoolishmanifesto.com/?p=932"
---
So a couple perl giants I have already heard of responded to my [previous post](/archives/909) regarding NULL's in the database.

> NULL means “this piece of information exists but is unknown to us”. Follow this simple rule when deciding whether to allow things to be NULL or not and you’re basically sorted – and the standard SQL logic will suddenly work with you rather than against.
>
> Until you do a LEFT JOIN and discover that it uses NULLs for “doesn’t exist” in there … but anyway …

--[mst](http://www.shadowcat.co.uk/blog/matt-s-trout/)

> I’ve a [blog
> entry](https://web.archive.org/web/20110907042506/http://use.perl.org/~Ovid/journal/27927)
> about this. Basically, NULLs can lead to queries which are logically
> impossible to get correct answers for. They’re rare, but I’ve hit them on
> larger queries and they’re a nightmare to debug.
>
> There’s also the problem of what a NULL is supposed to represent. Is the data
> unknown? Is it not applicable? Is it something else entirely? I often see NULL
> values in a databsae where people have tried to overload the meaning of NULL
> and it’s done on an ad hoc basis. For example, consider a “salary” field in a
> database. Why would it be NULL? Are they unemployed? Are they a volunteer? Do
> you simply not know it? Are they hourly and therefore not salaried? A NULL
> value could potenitally have four different meanings.

--Ovid

I personally think that they both make good points. I lean the direction of mst, which is that NULL's are ok, but all they mean is that you don't know that piece of information. Treating them as more information than that is probably a bad idea. Normally I'd just make a bit field to represent other information about the field, like why it's NULL or something like that. In general fields should only be NULL when they are optional, which should probably be rare.

Although, Ovid links to an article (from the article he wrote) that advocates the removal of *all* NULL's which I think is relatively extreme. But it resonates with the coder inside of me. The same coder who thinks it's a good idea to make a new class for everything and do everything with method dispatching instead of if-else's. I'd like to point out that this part of me has never won out against pragmatism, but I'm sure it will happen someday.

Anyway, I present to you two options from the luminaries above. I find both of the options very attractive and I will probably take mst's route in general, but I think that [the link Ovid gave](http://web.onetel.com/~hughdarwen/TheThirdManifesto/Missing-info-without-nulls.pdf) is surprisingly compelling. It would make the data very consistent, but the cost would be lots of JOIN's, tables, and classes representing those tables.

The answer may be some place in the middle; I don't know. One way or the other, ponder the path of your feet; then all your ways will be sure. No one ever got to be a good programmer by blindly following some random blogger.
