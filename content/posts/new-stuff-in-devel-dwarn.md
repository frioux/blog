---
aliases: ["/archives/1396"]
title: "New stuff in Devel::Dwarn"
date: "2010-07-23T04:04:37-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=1396"
---
Yesterday I released a new (major version of) [Devel::Dwarn](http://search.cpan.org/perldoc?Devel::Dwarn), or what is technically Data::Dumper::Concise. But those in the know call it Devel::Dwarn.

If you did not already know, Devel::Dwarn is sugar + good defaults for Data::Dumper. Check it out. Drool. Use it.

Anyway, I figured the new changes were worth mention on the internet, so here goes:

First off, Dwarn now pays attention to list context, so in list context it uses the original behavior, but in scalar context it does what DwarnS does. One of my coworkers got bit by the Dwarn vs DwarnS distinction so much that he only uses DwarnS now. Hopefully this will remedy that issue.

Next up is that Dumper (and also Dwarn because it uses Dumper) no longer returns an object when passed zero arguments. If you used that I'm sorry; but it just bit most of us when we tried Dwarn(@foo) and @foo was an empty list. Sorry, it's gone!

Last, is the brand new DwarnN. DwarnN is a neat debugging tool which will label your output by the variables passed in. So if you do DwarnN $foo it will print '$foo => ' . Dumper($foo). Not world changing, but still very helpful!

Hopefully this will ease your job that much more!
