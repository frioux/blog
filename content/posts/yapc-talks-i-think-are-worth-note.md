---
aliases: ["/archives/1358"]
title: "YAPC Talks I Think Are Worth Note"
date: "2010-06-23T17:47:56-05:00"
tags: ["cpan", "perl", "yapc", "yapcna"]
guid: "http://blog.afoolishmanifesto.com/?p=1358"
---
So I just got back from my second YAPC. **Again** I had to leave early, but not
as early as last time, so that's good. Instead of summarizing every single talk
I went to, I'd like to highlight some of my (most and least) favorites.

# Day 1

## [Not Quite Perl (NQP) A lightweight Perl 6](http://pmichaud.com/2010/pres/yapcna-nqp/slides/start.html)

I can't help but follow this since I see Patrick fairly regularly in our
Dallas.p6m meetings; which is really half Perl 5 and half Perl 6. NQP is an
amazing bootstrapping language for Perl 6 that is actually already self-hosting
(written in itself!!!) and can do a lot of neat things. And of course Patrick is
an excellent and humble speaker, which always helps.

Take a look at the slides (linked to above, page up and page down for next and
prev slides) for more information.

For a language as minimal as they could get away with it's extremely pretty.
Note: For all the talks mentioned here, slides != talk.

## [Plack - Perl web framework & server superglue](http://www.slideshare.net/miyagawa/plack-at-yapcna-2010)

Plack is very cool tech, even though Perl is late to the concepts it brings us.
The cool thing about the talk was that it starts off really slow and then ramps
up to some really amazing middleware that just blows my mind. Miyagawa was an
excellent speaker and had lots of fun little jokes in his talks too.

## Fey and Fey::ORM

I was told to go to this talk by ribasushi with the sole idea of stealing ideas
for DBIx::Class. I was generally unimpressed with the ORM part, but Fey is far
better than SQL::Abstract it seems like. Rolsky is very adamant about having no
magic in his core, which is fine, but it typically means baseline code will be
ugly. It's certainly a trade off. He has a really cool autojoin feature, which I
envy but also know that ribasushi already wants to implement that to an extent.
Our $rs->as\_query is cool, but he has something like that for EVERYTHING, which
yields some interesting results. Of course this is due to his thoughts that
pretty stuff belongs in a sugar layer. He has much more powerful relationships,
which I envy for now but I also know that we have a branch in progress to give
us arbitrarily complex (???) relationships. It seems like he has a global
schema, which is too bad, but that's just how things work sometimes. He wants to
keep per db stuff out of the core, which I can certainly see being a good thing,
but I also think it's good that we try to keep all of our per db code up to
snuff, so theres a tradeoff there.

Overall I thought rolsky was very honest about the fact that Fey (and Fey::ORM)
is about doing things differently due to taste and that's completely fine. I
**definitely** envy his SQL generation code, but I'd rather SQLA2.

## [Lightning Talks 1](http://yapc2010.com/yn2010/talk/2551)

### [A/B testing with Perl‎](http://yapc2010.com/yn2010/talk/2924)

Look around at some docs on AB testing. The stuff they did with this was
amazing. Forget hallway testing. This is where it's at for usability.

### [perlopquick - a quick reference for Perl 5
operators‎](http://yapc2010.com/yn2010/talk/2864)

Ever want to look up how //= works? Not easy. Check out perlopquick. Awesome
stuff for the future of core docs.

# Day 2

## Perl for CS Grad Students

For this talk I have to give a little bit of background. This year it was
attempted to film every single one of the talks unless the speaker explicitly
said not to. Cameras et al were paid for by the conference's budget. Of course,
cameras are not all you need. You also need someone to run the cameras. It turns
out that **ONE MAN** (his name is Krishna) did **ALL** of that for all **five**
tracks. Of course the videos won't be perfect, but if this becomes a trend it
would be a great thing for all of perl.

The speaker of this talk, like probably 33% of all the speakers in general, had
technical difficulties getting his mac to work exactly how how wanted with the
projector. He (reasonably) got frustrated at this and the wasted time it caused.
What bothers me is that krishna was setting up the camera (and mic) as he did in
every room every morning and walt said, "Why are you even here?" to krishna,
presumably thinking that he was staff of the college (which is of course a great
reason to treat a person poorly) and continued to lash out complaining about his
technical difficulties. I guess to put a positive spin on this I got to know
krishna better for it and I think we all owe him a beer or curry or whatever for
all of his hard work (and apparently taking abuse) for doing WAY too much A/V
for one person.

The talk was ok.

## Iron Mad: The Iron Man Forfeit Talk‎

This was mst's Iron Man forfeit talk. Watch the video, it's hilarious. I'm not
sure much more can be said :-)

## perl5i: Perl 5 Improved‎

I heard about perl5i last year and I thought it was neat. Now I think it's
excellent enough that I might use it in code at work. One thing I think is very
good about it is the fact that you **must** use a version number when using the
module, because it is expressly backwards **in**compatible. Take a look at the
module. Very fun.

## [Lightning Talks 2](http://yapc2010.com/yn2010/talk/2552)

### [Reframing the Death of Perl‎](http://yapc2010.com/yn2010/talk/2935)

This basically looked at the psychological term called "framing." The gist of
the talk: when you say "Perl is not dead" people see "perl is dead." So instead
you have to completely reframe and say "Perl is alive" etc. We ended up all
yelling perl is alive and scaring prospective students that were visiting Ohio
State. Awesome.

### [Musical Intervals and Chords](http://yapc2010.com/yn2010/talk/2705)

This was a talk by ology about (duh) music. Very cool stuff. I wish I could have
talked with him more than I did for the few minutes that I did, and especially I
wish I had discussed the music stuff with him. Unfortunately he ran out of time
in his talk, but what he did say was getting very cool :-)

### [How I mastered English with Perl](http://yapc2010.com/yn2010/talk/2693)

This was a hilarious talk by a man who moved to the US from Japan and learned
some english with perl. It focused on Lingua::EN::Inflect, using CPAN as a
dictionary, and adorable daughters.

## Auction

Not really a talk per se, but still a fun time. Apparently the auction usually
takes hours, but this only took 1.5 hours, so not really that bad, and still a
lot of fun. I got some O'Reilly coasters (beer mats for you brits) and wes got
the new Effective Perl book + autographs. Very cool.

# Day 3

## [Path::Dispatcher](http://yapc2010.com/yn2010/talk/2642)

This talk was interesting in structure. It started off fairly slowly but got
super cool as it built on itself. It made me want to start writing CLI apps. The
fact that it yields such a nice API makes it hard for me to justify why I like
the way that catalyst does it's dispatching (all spread out) but I do think that
different ways of doing things are valid. I would love to write some kind of
text adventure game with this. Maybe I'll use it to create a Perl tutorial game?

## [Cool Perl 6 you can do today](http://www.pmichaud.com/2010/pres/yapcna-perl6/slides/start.html)

Again, this was Patrick. This talk makes me want to start writing my one off
scripts in Perl 6. Unfortunately some of my more interesting "one off scripts"
involve creating a DBIC schema and shoving data into an sqlite database so that
I can get a feel for my data. Either way, check out the slides, very cool stuff.
Also note: I downloaded and installed rakudo in the talk and actually played
with it. It's been a while since I've done that and I assure you it's only
gotten easier.

All in all it was a great conference. I liked it better than last year despite
the stress of three (supposed to be) forty minute talks. I'll discuss that in my
next post :-)
