---
aliases: ["/archives/704"]
title: "Windows Agony: Con"
date: "2009-06-03T01:22:09-05:00"
tags: [mitsi, con, subversion, virtual-machine, windows, computer-h8, war-stories]
guid: "http://blog.afoolishmanifesto.com/?p=704"
---
At $work I manage the subversion repositories for all of the software that we
develop. It's certainly not something that I'm great at, but I've used it longer
than most so I am the most qualified to deal with it.

Furthermore, at work we use this tool (Freescale?) which, when it creates a
project, creates a Boot directory and a Con directory. Ok, so I had helped our
head honcho EE create a repository to store his project data and versions. He's
puttering along and he thinks, "Hey, I want to 'save' this version so I can go
back to it later!" So I explain to him tags and how to set it up and all this
jazz. Well, it turns out that when we made the repo initially we did not make
tags, trunk, and branches, like we should have. We just put everything in the
root of the repo. Foolish! So anyway, I tell him that we can reorganize it
fairly easy and we do that. So we make the changes, delete the old directory,
and recheckout from trunk...

It failed. It could not check out the directory! Some of you may be able to
guess why: in Windows you cannot (easily) create a directory named "con" (or
com, or a few others.) So we are having the hardest time getting it to check
out. Meanwhile he has to make a release for the customer and I am under the gun.
So he pulls up a copy he made (how?) and gets back to work and I try to figure
out how to deal with this in my office. At this point he has asked me to just
revert the changes.

So I go back to my office, try checking it out a few different ways and have no
luck. So finally I get an idea, I figure I'll check it out in a **virtual
machine** with Linux installed! So I do that, I run the reverse merge to undo
all of our changes, and I check everything back in. It worked!

So the moral of the story? Don't name folders "con."
