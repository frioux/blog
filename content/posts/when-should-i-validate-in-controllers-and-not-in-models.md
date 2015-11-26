---
aliases: ["/archives/819"]
title: "When should I validate in controllers and not in models?"
date: "2009-06-17T00:55:53-05:00"
tags: ["dbic", "dbixclass", "mvc", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=819"
---
I've been told numerous times by people that I believe are smarter than me that
I should do validation in my controllers and not my models. mst said that some
validation, like low level primary key type stuff, can be in models, because it
has to be. But if I recall correctly almost everyone was against validating
things like email addresses in my models.

I just read [this article](http://use.perl.org/~Alias/journal/39126) and a lot
of what alias says seems to make good sense to me. But if what he says is true
that means it would be **best** if I validated as much as possible in my model,
and then bubbled up any errors to the controller via exceptions or something
like that. That would also make it simpler for me to generalize things that need
to be a certain type value on creation, but should never change after creation.

So tell me, dear internet, why **shouldn't** I validate as much as possible in
my models?
