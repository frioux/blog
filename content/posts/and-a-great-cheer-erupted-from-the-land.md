---
aliases: ["/archives/1219"]
title: "And a Great Cheer Erupted from The Land!"
date: "2009-11-25T05:25:34-06:00"
tags: [perl, web-simple]
guid: "http://blog.afoolishmanifesto.com/?p=1219"
---
Guys! [Web::Simple](http://search.cpan.org/perldoc?Web::Simple) got released today! I fully intend on porting my personal CGIApp projects to Web::Simple immediately after writing this post. It really allows for a lot more possibilities, and not just the super sexy dispatching that is documented.

One thing I found interesting is that mst didn't document the tags stuff anywhere at all. There used to be examples, but they seem to be gone. For a taste of those, see the [tests](http://cpansearch.perl.org/src/MSTROUT/Web-Simple-0.001/t/tags.t).

For those unwilling to click the link, LOOK:

```
sub quux {
  use HTML::Tags;
  <html>, <body id="spoon">, "YAY", </body>, </html>;
}
```

Also not included is Zoom, which I can't seem to get to since shadowcat servers are DOWN. Zoom seems like something that should at least be referenced by Web::Simple. Zoom seems like the future of HTML templating to me; basically it uses xpath or css selectors to fill in values, instead of just putting text in text. This is good because it doesn't just encourage the production of good HTML, but it also understands the actual structure of HTML, so it allows you to do cool things like OO generation of templates, which you can't to with plaintext nicely.

Anyway, here I go! Hope you enjoyed this small survey of the new msTechnology :-)
