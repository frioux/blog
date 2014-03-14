---
aliases: ["/archives/1331"]
title: "How CPAN (and Open Source) works"
date: "2010-05-20T00:57:47-05:00"
tags: ["cpan", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1331"
---
I am writing this post to address a problem that I could see appearing in our community. If it offends you feel free to let me know. If you comment on my blog as a troll, I will delete your comments. Feel free to put them on your blog where they reflect on yourself :-)

Recently a certain member of the community has posted a few blog posts that boil down to "Open Source developers should support their open source work as if it were a job." I will not make a link because I would rather people not read his posts. Normally I feel like the best plan of action for people who make silly statements is to just ignore them, but a good friend of mine pointed out that it would be bad if people got confused and actually bought into this line of thought.

So in foolish manifesto style, I will write the rest of this post with how I think things **should** be done, not who got what wrong.

# Patches Welcome

As a developer of CPAN modules and more tentatively a leader of a small part of CPAN, I will continue to say "Patches welcome." If people are using the software that I have written for CPAN they are developers and can help implement the code that they need for their given use case. I doubt a non-developer would be able to figure out how to install a CPAN module, let alone use it.

Patches are not just for code though! That is where novice developers come in. In the [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) world (and I imagine [Catalyst](http://search.cpan.org/perldoc?Catalyst) and [Moose](http://search.cpan.org/perldoc?Moose)) standard practice is to help a newbie on IRC and then in return ask them for a documentation patch that will have rendered the help session needless. Of course sometimes the documentation needs massaging or you need to guide the newbie as to where the documentation should go, but that's fine! This is how you get new blood into your contributor pool.

And of course the beauty of the "patches welcome" statement is that by definition only people who actually want the feature will send you patches! I would never ask a random user of my module to implement a feature that they do not need. It is because I needed correct sorting in SQL Server that I got involved with DBIx::Class. I did not ask: "How can I make this happen?" I actually asked someone else to fix it for me, and instead this person (ribasushi) guided me on how to do it myself. To restate the point: **patches should be written by the people who will use them.**

# Meritocracy

One of the beauties of the open source world is that ultimately things are (to an extent) a meritocracy. That means that the people who get stuff done have the most say. As a Perl developer I am much more likely to listen to RJBS or Miyagawa about how to do something or even defer to them over some random developer I have never heard of. Of course there are times when things are done democratically. Recently some of us DBIx::Class developers had a vote about something. [mst](http://shadowcat.co.uk/blog/matt-s-trout/iron-man-lost?colour=green&title=how+perl+5+and+perl+6+will+interact+in+5+years) has even stated to us that when it comes to DBIx::Class he is willing to defer to the other developers if everyone else agrees. But ultimately, because writing software takes skill, the people with that skill make the decisions. Not the people who are the prettiest or richest or have the best marketting. I personally like it that way and will do what I can to keep it that way.

I say this because really, open source programming ultimately is not like regular work. Sure, developers fall off of the face of the planet and stop maintaining their software. But if you need the software that they wrote, you have at least two options; the first is that you contact the author and ask if you can take over the project so that you can get it back to a point where you can use it. If that sounds like too much work you clearly do not really need it. Your second option, if the author does not give you the OK to take over the project, is to [fork](http://oreilly.com/catalog/cathbazpaper/chapter/ch05.html#AUTOID-1631) it. Generally this should be avoided, since it can breed bad blood and often your software and the authors can have incompatibilities, but it is an option nonetheless.

I have done both of the above and it was never a huge problem. So again, in Open Source software, the onus is on the **user** not the developer; but that is why I use it, personally. If a developer dies, I as the user will be ok because I can fork the project myself.

# Social norms

As I already said, the main reason for this post is so that developers inside and outside of the community will not be misled. I do not want new developers using my software expecting that they can just make demands and that I will do what they ask. I am not a hostage and neither is my software. I do not work for free. Anyone who expects me to work for free is either lying to themselves, insane, or is a looter stealing from me. I do not respect the opinions of thieves, liars, or lunatics when it comes to responsibility and I do not plan to respect their opinions.

I strongly believe the above, and I hope that we can all have some healthy discussion about it and hopefully come to agreement. I also have some thoughts on how to help increase the communication between various dissenters and those of us who like things the way they are, but I will leave those for another day.

# Update

Turns out that this turned into a meme, so I'll try to collect all of the related links to this topic here. I'm sure that I left some out, but I tried to include all of the ones that popped up in my feed reader. (Note: I'm [not subscribed](/archives/1264) to all of Iron Man, so I might have missed some)

- [chromatic's thoughts](http://www.modernperlbooks.com/mt/2010/05/the-perlegorical-imperative-and-the-will-to-contribute.html)
- [dagolden's thoughts](http://www.dagolden.com/index.php/804/expectations-of-volunteers-in-open-source/)
- [perigrin's thoughts](http://chris.prather.org/patches-welcome.md.html)
- [jjnapiorkowski's thoughts](http://jjnapiorkowski.vox.com/library/post/opensource-free-software-volunteerism-and-support-1.html)
- [nperez' thoughts](http://perl-yarg.blogspot.com/2010/05/iron-man-fail-xenoterracide-is-whiny.html)
