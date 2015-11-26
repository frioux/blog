---
aliases: ["/archives/1113"]
title: "Turns out there really are Computer Gremlins!"
date: "2009-08-27T21:29:15-05:00"
tags: ["catalyst", "perl", "win32"]
guid: "http://blog.afoolishmanifesto.com/?p=1113"
---
Ok, this is just too crazy to not record and relate. By now anyone who has read
much of my blog or interacted with me should know that I use a significant
amount of javascript on my current project at work. Because I like to keep
everything nicely organized, 95% of the time each class has it's own file. That
means I have to tell the server every time I add a new class. No big deal
really.

So yesterday I created a new form, and I added it to the list. When I refreshed
the page the form failed to load. Well, that could have easily been an error in
the syntax or even runtime logic of the form, so I start looking for firebug
errors and whatnot and don't see any. So I look at the debug output of
[Catalyst::View::JavaScript::Minifier::XS](http://search.cpan.org/perldoc?Catalyst::View::JavaScript::Minifier::XS)
to make sure that it tried to include that file. It didn't! Ok so clearly I
didn't save the file with the list of JS files. So I ensure that I've saved it.
Still no luck. So I change another part of the list, a file that **is** loading,
to see if that gets taken out of the list. Maybe I misspelled the filename you
know? Nope. List remains the same. Ok, so then this must not be the canonical
list. So I change a fundamental part of the list, to see if everything still
works after I change that. Nope, now nothing works, showing that this list
clearly isn't nothing.

Bizarre. So I go home, assuming that I was just tired. Today at work, after
working on a bunch of other stuff, I get back to it. So first I output the list
itself, to make sure that it's what I think it is. It is. Then, I open up the
code behind Catalyst::View::JavaScript::Minifier::XS. I added some debug stuff
where it loads the files and look at the output. Nothing prints out. That's
weird... So I change it from a warn to a $c->log etc. Still no output. So I'm
editing the wrong file, obviously. I go to rename the system version of this
file so I know it's using my local copy (I have changes that haven't been
accepted by upstream yet.) Oh wait...it's already renamed from yesterday...

So that's weird. Ok, so I put some debug statements right next to where it
already has some debug statements... Lo and behold they output! Ok so clearly I
am missing something. I put debug statements before the block where I am already
outputing debug statements from: no luck. I put them after. No luck. I change
the code so that all the filenames get "frew" added to the end to see if CVJMX
will throw an error or even change the output messages. STILL NO CHANGES.

I should point out that I have checked that I am using my local server and
editing local files numerous times by the way.

Ok, so I am clearly insane at this point, as that's more likely than file
changes being scoped to a 3 line block. On a whim I decide to restart my
computer. Start the Catalyst Dev server with the same command (from history) as
before, without file changes. Everything worked.

All I have to say is: jfkasl;fkdasfkojqwklmdcszkljcvsxlkv
m,w;ejriopjewiojc4weojejoifevjoirjivoi
