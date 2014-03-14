---
aliases: ["/archives/977"]
title: "Initial Impressions of Catalyst Book"
date: "2009-07-23T01:14:21-05:00"
tags: ["book", "catalyst", "cpan", "moose", "testing"]
guid: "http://blog.afoolishmanifesto.com/?p=977"
---
I am just getting through chapter four of [the Catalyst book](http://www.amazon.com/Definitive-Guide-Catalyst-Maintainable-Applications/dp/1430223650?&camp=2486&linkCode=wey&tag=enligperlorga-21&creative=8882) and there are already a whole lot of things worth mentioning. My internet is currently at 50% packet loss because our wifi router is busted so this is pretty painful for me. So we'll keep it short.

### Moose

The book has a nice (very short) introduction to [Moose](http://search.cpan.org/perldoc?/Moose). Not only is this good because Catalyst is now based on Moose, but also I would say you **probably** want your OO code to be based on Moose. There are times when you probably don't want to use Moose, but there are also times when you don't want to use strict. As a rule, use Moose for OO code.

### CPAN

There is also a very good introduction to usage of [CPAN](http://search.cpan.org). A lot of us think that CPAN is our programming platform. Knowing how to use it is **extremely important**. It includes not just finding stuff on CPAN, but also ascertaining the quality of those modules, and how to install them. Very good information for a perl programmer.

### Tesing Methodology

In chapter 4 mst discusses how he writes tests (which can be slightly supplemented with his latest blog post) and it's actually quite helpful. Some people write tests after writing their code and run the risk of forgetting to test at all (that's me!) Other people are all hardcore TDD and write tests first, but that assumes that they have already thought through the interface for what they are writing. mst posits that it's better to write your code, and "test" it from test files as you go. And test in this case means warns, Data::Dumps, whatever. After it works how you expect, you then take those warns and whatnot and translate them into ok's, is's, and cmp\_deeply's. It's really much nicer than the alternative: build it all and see if it works. Try it!

### Diffs

Lastly, I really like how they represent code as diffs instead of monolithic code. Writing large swaths of code doesn't work that well in real life. It works much better to do tiny changes and make sure they still compile, do what you want, etc.

But the book certainly isn't perfect! There are some weird code layout issues, (p34, 36, 39, etc) and I am pretty sure I saw at least one syntax error (END\_\_ instead of \_\_END\_\_).

So far though, I would say that the book is better than most programming books. Really, a lot of programming books need to be more like this, instead of focusing entirely on the arcana of one framework they should help you be a better programmer overall.
