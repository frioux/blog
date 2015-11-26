---
aliases: ["/archives/1223"]
title: "WebCritic Revisited"
date: "2009-11-30T03:26:33-06:00"
tags: ["jquery", "perl", "perlcritic", "web-simple"]
guid: "http://blog.afoolishmanifesto.com/?p=1223"
---
As I mentioned [in my last post](/archives/1219) I rewrote one of my personal
apps ([WebCritic](http://github.com/frioux/perlcritic-web)) to use
[Web::Simple](http://search.cpan.org/perldoc?Web::Simple) over the Thanksgiving
holiday. It was exciting, writing one of the first apps to use the brand new
Web::Simple. Of course, that also meant that I had to read incomplete doc, deal
with examples that didn't work, and in general just deal with the whole hassle
of an immature project. Of course that was rewarding though, because I got a
chance to help beef up the doc some, fix the broken examples, and convince mst
to add [a basic
feature](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=catagits/Web-Simple.git;a=commitdiff;h=d3a6160961a582183cfc02efc5e0a09039bd10dd;hp=93e30ba3c4409bccc1a8deb483acab6a8e3fc8c4)
that will allow me to run the server standalone.

There are two cool, unqiue features of Web::Simple that I've used so far. The
first is the use of HTML::Tags, which is undocumented so far, but super easy to
use. See my last, and already linked to, post for an example of that one. Or if
you are curious see [my use of
it](http://github.com/frioux/perlcritic-web/blob/9b654a04c4dd8efece6b8d7b1b55937e1681a1b7/lib/WebCritic/Controller.pm#L10).
The nice thing is that I can write my html all nicely formatted or whatever, and
the server outputs it without extraneous whitespace.

The other feature I've used allows really dumb, static serving for a Web::Simple
app. Normally that would be discouraged, but because my app is meant to be run
by devs from the commandline I kinda need this. Check it out:

    dispatch {
       sub (/) { ... },
       sub (/criticisms) { ... },
       sub (/static/**) {
          my $file = $_[1];
          open my $fh, '<', "static/$file" or return [ 404, [ 'Content-type', 'text/html' ], [ 'file not found']];
          local $/ = undef;
          my $data = <$fh>;
          close $fh or return [ 500, [ 'Content-type', 'text/html' ], [ 'Internal Server Error'] ];
          [ 200, [ 'Content-type' => 'text/html' ], [ $data ] ]
       },
    };

So basically the static matcher just reads in a file under the static location
and spits it back out. I haven't checked what happens if you put '..' in the
path or anything like that, but again, this is for local usage, so I won't
stress much over it.

And because Web::Simple isn't really geared to be a standalone server, I also
redid the view part, which was entirely [ExtJS](http://extjs.com), to use
[jQuery](http://jquery.com). Basically to use the Ext Grid I was loading the
largish Ext javascript, the Ext css, and numerous images. jQuery really solves
different, more basic problems, whereas Ext is an entire UI framework. I love
Ext and think that all commercial, large scale projects should consider it. On
the other hand, Ext has a weird license which makes me nervous including it in
an OS project. Technically that's ok, but if someone were to use my OS app to
make money, I think they might have to pay the Ext people, which doesn't sit
nicely with me. Also it's a huge framework that I was using probably 5% of for
my project.

So instead of using the Ext Grid I just have a sortable table with columns that
can be toggled. I do still miss the qtip (nice mouseover text) and general
organization that I got from using the Ext framework, but I think the former can
probably be solved with some research, and the latter is just my lack of
knowledge coding "bare metal" javascript. Of course it's not really bare metal
since I'm using jQuery, but it's certainly much closer.

In general this has been a lot of fun. Normally I'm a fan of large frameworks.
At work we use (and I love!) ExtJS,
[Catalyst](http://search.cpan.org/perldoc?Catalyst),
[Moose](http://search.cpan.org/perldoc?Moose), and
[DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class). All of them (except
**maybe** DBIx::Class) are probably the largest frameworks in their respective
fields. But I get some perverse pleasure (and I do mean perverse) from using
such a minimalistic toolset. I'd say that the switch to jQuery was warranted as
Ext can significantly slow down the browser. The switch to Web::Simple over
CGIApp was pretty much just for fun, but I learned a lot, and that's certainly
worth something.

Lastly, since revisiting this I realize that I should release it to CPAN. Once
it's complete (which depends on the next release of Web::Simple) I'll release
it. I'd expect my end of that to be done before the end of the week. As for
Web::Simple, I'm not sure what else needs to be done to consider it release
worthy, but I'll be doing what I can to make that happen as well.
