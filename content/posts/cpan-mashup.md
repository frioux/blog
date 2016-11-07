---
aliases: ["/archives/786"]
title: "CPAN Mashup?"
date: "2009-06-09T01:16:06-05:00"
tags: [cpan, perl]
guid: "http://blog.afoolishmanifesto.com/?p=786"
---
One of the common issues I hear about CPAN is that it's so sprawling that people do not know which modules to use and which not to use. Hopefully part of that issue will be solved by the [Enlightened Perl](https://web.archive.org/web/20160410034951/http://www.enlightenedperl.org/index.html) Core, but that will only go so far. Recently there were a [couple](http://lastofthecarelessmen.blogspot.com/2009/06/lost-in-cpan.html) [posts](http://lastofthecarelessmen.blogspot.com/2009/06/guide-to-cpan-needed.html) regarding this issue. (Note: They are in reference to a post I made and they are from the same guy.) I even recently had a discussion regarding this with my boss recently because we needed some barcode generation code. _(We ended up using [Barcode::Code128](http://search.cpan.org/~wrw/Barcode-Code128-2.01/lib/Barcode/Code128.pm) but we spent a lot of time trying to get GD::Barcode to do what we wanted.)_ Furthermore I chatted with the EPCore guys regarding this and they all helped me think through a lot of these issues; I have a muddled mind :-)

I think a solution to this problem is feasible. I imagine a web service that will help recommend various packages for given tasks. I have the following (pie in the sky) goals in mind:

- Automated and Objective (as much as possible)
- Easy to Use
- Fast
- Configurable scoring (for people who don't like the default metrics)

Here are some possible sources of data to make this all work:

- [CPAN Testers](http://static.cpantesters.org/)
- CPAN Deps
- [Github watches](http://ruby-toolbox.com/)
- [CPAN Ratings](http://cpanratings.perl.org/)

CPAN Testers is obvious. It has massive amounts of data and it can at least tell you if a module is good by it's own measure. It might be worthwhile to look into some kind of scaling based on tests (configurable of course.) The idea there is that if a module has never failed because it has no tests that shouldn't count.

CPAN Deps isn't even completed. I've only heard this [name dropped](http://www.modernperlbooks.com/mt/2009/06/minimalism-for-maintenance-ecosystems-for-efficacy-a-graph-for-all.html), but the idea is clear. With it you could find out what modules are **effectively** core in that lots of people depend on them. You could use this in a PageRank style way in that modules that have a high score help add to the score of modules they depend on.

The Github watches link that I posted is where I originally got the idea for this. I'm not really sold on it, but mst liked it so much I figured I'd keep it in the list; I wish I could give you a link to the actual conversation. He hated the idea of using "failhub" :-) I **do** like the idea, but I am certainly not as smart or motivated as mst.

And last but certainly not least, CPAN Ratings. CPAN Ratings is an excellent idea, but it needs some love. Part of that has to do with it's actual implementation (at the very least it's ugly,) but the real issue is the use of it. More people need to use it. I don't know how to do that other than to use it myself. I think it might be good if, after using a module for at least an iteration, I rated it. If one were to rate a module too soon the results could become inflated. And as a side-note, I personally think we should use OpenID instead of BitCard, but it's not worth changing a bunch of stuff just for that.

And then I was thinking that we could use a combination of module name searching, tags added to META.yml, and tags added manually. So DBIx::Class would theoretically add the ORM tag (and others possibly) to their META.yml, and then someone would manually add the tag to Class::DBI. Then when people search for ORM they would at least find those two. They would then get a score based on the previous five metrics. I would say have anything with a score beneath a certain number not even displayed, but have a link that would allow the display; and maybe a user option that would permanently display hidden items.

I think this is something that would certainly be worth attempting. It wouldn't be easy, and the stuff I've said above is certainly riddled with errors, but that shouldn't stop us. What do you guys think? Other ideas for data sources? Implementation ideas? Tuits?
