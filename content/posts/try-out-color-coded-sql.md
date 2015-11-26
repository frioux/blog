---
aliases: ["/archives/1428"]
title: "Try Out Color Coded SQL"
date: "2010-09-21T00:27:11-05:00"
tags: ["cpan", "dbixclass", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1428"
---
Thanks to [arcanez](http://warpedreality.org/), my color coding SQL Logging has
been
[merged](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=dbsrgits/DBIx-Class.git;a=commitdiff;h=b6cd6)
into DBIC's master!

That means you can easily try out the new color coding! All you need to do to
try it out is clone our master from git:

    git clone git://git.shadowcat.co.uk/dbsrgits/DBIx-Class.git

Make sure you install any new deps. The main one will be SQL::Abstract 1.68.

    cpanm --installdeps .

And then use that as your lib directory when you run your server or whatever:

    perl -I ~/DBIx-Class/lib scripts/foo_server.pl -rd

Now, you won't notice a difference till you set the DBIC\_TRACE\_PROFILE
variable. It sets the color profile to use. If you are on Linux and install the
ANSIColor package, you probably want to set it to "console". If you are in win32
or do no want to install ANSIColor, set it to "console\_monochrome". Both
profiles **fill in placeholders** for you, for excellent readability, so that's
extremely helpful.

If you would like to make a nicer colorscheme, or more importantly want to use
modern 256 color consoles, feel free! The documentation for that is available at
[SQL::Abstract::Tree](http://search.cpan.org/perldoc?SQL::Abstract::Tree#new).
The best way to define one of those is to make a json file (I do ~/dbic.json)
and populate it with the profile information you like, and then set
DBIC\_TRACE\_PROFILE to the full path of the file. That way you can experiment
with various profiles and when you think you have one that's worth sharing, send
it to me and I'll probably merge it in!

Anyway, we hope to cut a new release in a week or two, with lots of other great
new stuff, so feel free to wait if you'd prefer.
