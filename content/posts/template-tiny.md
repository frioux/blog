---
aliases: ["/archives/1277"]
title: "Template.Tiny"
date: "2010-01-26T06:53:34-06:00"
tags: ["cpan", "extjs", "javascript", "template-tiny", "template-toolkit", "templatetiny"]
guid: "http://blog.afoolishmanifesto.com/?p=1277"
---
(Sorry if you [heard this
already](https://web.archive.org/web/20111029132249/http://use.perl.org/~Alias/journal/40126?from=rss)
:-) )

At $work we do as much "view" type code as we can in JavaScript with the ExtJS
framework. I have personally found it to be a great framework to work with,
although often it is lacking in the non-UI department. One thing that at first I
really liked about Ext was their
[Template](http://www.extjs.com/deploy/dev/docs/?class=Ext.Template) and
[XTemplate](http://www.extjs.com/deploy/dev/docs/?class=Ext.XTemplate) classes.
But as time went on I got more and more annoyed with those modules.

I've always thought that
[Template-Toolkit](http://search.cpan.org/perldoc?Template) was a really nice
templating library to work with. I hate templating html because of all the weird
little gotchas having to do with CSS and whatnot, but doing almost all that kind
of work in JavaScript I have started missing Template-Toolkit. At some point I
heard about [Template::Tiny](http://search.cpan.org/perldoc?Template::Tiny) and
this past Saturday I thought, "that's like, 160 LOC...I could probably port that
to javascript!"

So I did! It's not really done yet, but the current code is [at
github](http://github.com/frioux/Template-Tiny-js/blob/master/lib/Template.Tiny.js).
I need to finish porting the test suite from Perl 5 to JavaScript so that I can
ensure correctness (I am certain I screwed up some stuff.)

Alias mentioned in his post that I use XRegExp (600 LOC) to help out with the
Regular Expression support in JavaScript for this module. I actually wasn't
going to, since the only thing I needed it for was the /x flag, or to be more
clear telling the parser to ignore whitespace, but I want to keep Template.Tiny
in sync with the Perl version, and I really don't want to strip out all the
whitespace by hand. If someone takes issue with the dep they can fork away :-)

So once it is fully ported I fully intend to use it entirely from now on instead
of the Ext templating. But take note, Ext templates and Template.Tinies (what?)
really solve different problems and have different goals. The following is a
list of Pros and Cons of each:

### Ext.(X)Template

Pros:

- Can be compiled to JavaScript, for speed
- Allows complex expressions in "if" blocks (see Example 1)
- Interesting "topicalizing" feature (Example 2)
- Crashes when you leave out a variable (no mystery as to why a field is blank) (Example 3)
- Can execute arbitrary JavaScript code in a template for complex stuff (Example 4)
- Neat automatic "current item" style variables when you are iterating over an array (Example 5)
- Basic Math Support
- Ability to call functions associated with Template object
- Very cool builtin Renderer support (Example 6)

Cons:

- No else if. If you want something like that you must do if !expr. Lame.
- Crashes when you leave out a variable (mostly that's just annoying)
- This is almost entirely subjective, but having xml as a templating thing is kinda gross.
- Not really open source, so I can't use it in personal projects and have people use my code in a corporate setting

Example 1:

```
var data = { age: 21 };

// XTPL
var tpl = new Ext.XTemplate( "<tpl if="age > 18">Can Vote!</tpl>");
var str = tpl.apply(data);

// TT
var tmp = new Template.Tiny();
var str = tmp.process(
   "[% IF old_enough %]Can Vote![% END %]",
   { old_enough: (age > 18 )}
);
```

Example 2:

```
var data = { person: {first_name: 'fREW', last_name: 'Schmidt', title: 'Mr.' }};
// XTPL
var id = new Ext.XTemplate( "<tpl for="person">{title} {first_name} {last_name}</tpl>");
var str = tpl.apply(data);

// TT
var tmp = new Template.Tiny();
var str = tmp.process(
   "[% person.title %] [% person.first_name %] [% person.last_name %]",
   data
);
```

Example 3:

    var data = { werld: 'fail'};

    // XTPL
    var tpl = new Ext.XTemplate( "Hello {world}");
    var str = tpl.apply(data); // error message

    // TT
    var tmp = new Template.Tiny();
    var str = tmp.process(
       "Hello [% world %]",
       data
    ); // silent failure

Example 4:

    var data = { foo: 1 };

    // XTPL
    var id = new Ext.XTemplate( "{[someComplexRenderer(values.foo)]");
    var str = tpl.apply({ foo: 1});

    // TT
    var tmp = new Template.Tiny();
    var str = tmp.process(
       "[% foo %]",
       { foo: someComplexRenderer(data.foo) }
    );

Example 5:

```
var data = { arr: ['foo','bar','baz']};

// XTPL
var tpl = new Ext.XTemplate('<tpl for="arr">({#}. {.})</tpl>');
var str = tpl.apply(data); // "(1. foo)(2. bar)(3. baz)";

// TT
var tmp = new Template.Tiny();
var idx = 0;
var str = tmp.process(
   "[% FOREACH x IN arr %]([% x.i %]. [% x.var %][% END %]",
   { arr: data.arr.map(function(x) { return { i: idx++, var: x } } }
);
```

Example 6:

    var data = { longtext: "this won't fit!"};

    // XTPL
    var tpl = new Ext.XTemplate('{longtext:ellipsis(5)}');
    var str = tpl.apply(data); // "this ...";

    // TT
    var tmp = new Template.Tiny();
    var str = tmp.process(
       "[% longtext %]",
       { longtext: Ext.util.Format( data.longtext, 5) }
    );

### Template.Tiny

Pros:

- Has IF/ELSE (Example 7)
- Doesn't crash on undefined fields
- Nicely Licenced (Perl License)

Cons:

- No complex expressions, math, or external javascript support
- No topicalizing
- Doesn't crash on undefined fields (could be nice for debugging)
- Probably slower (haven't checked that yet)

Example 7:

```
var data = { jack_slocum: 1 };

// TT
var tmp = new Template.Tiny();
var str = tmp.process(
   "[% IF jack_slocum %]We don't appreciate else-ifs[% ELSE %] Woot![% END %]",
   data
);

// XTPL
var tpl = new Ext.XTemplate(
   '<tpl if="jack_slocum">We don't appreciate else-ifs</tpl><tpl if="!jack_slocum">Woot!</tpl>'
   );
var str = tpl.apply(data);
```

I am planning on making a wrapper for TT for our stuff that will allow an
anonymous function that will do data transformation like above. But as you can
see above XTemplate really has more to offer, it just annoys the heck out of me
on a regular basis :-)
