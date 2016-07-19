---
aliases: ["/archives/267"]
title: "Rakudo Autobuilder"
date: "2009-02-16T05:02:57-06:00"
tags: [perl, perl-6, rakudo]
guid: "http://blog.afoolishmanifesto.com/?p=267"
---
First off, if you did not already know, rakudo is the first implementation of perl6. There is no plan for an official Perl 6 implementation, so we have to give this implementation a name other than perl6.

Anyway, I know that you are all working diligently on perl6 like I am, so I know that you are having trouble because you have to rebuild parrot and rakudo which is kindav a hassle. Let's remedy that now! (Much of this information was taken from [this post](http://perlgeek.de/blog-en/perl-6/where-rakudo-lives.writeback) by Moritz.)

First you'll want to get your initial checkouts. I'll presume that you have git, subversion, and everything else required to build rakudo already installed on your unix based computer :-) Also, I will assume you check them out into ~/dev. I actually have a ~/personal and a ~/scripts that I check this stuff out into for my laptop and desktop respectively, but the point is, they both get checked out to the same directory.

So to checkout both you'll do this:

    cd ~/dev
    git clone git://github.com/rakudo/rakudo.git
    svn co https://svn.parrot.org/parrot/trunk parrot

So now you should have a ~/dev/rakudo and a ~/dev/parrot. Now make a script called build\_rakudo.sh inside of ~/dev and fill it with these lovingly crafted characters:

    #!/bin/bash

    cd ~/dev/parrot

    # clear out any old cruft that used to be there.
    # this isn't always necessary, but sometimes it
    #  is and we want this to be entirely automated
    make realclean

    # updated the source
    svn up

    # configure it for your local system
    perl Configure.pl

    # and build it!
    make

    cd ~/dev/rakudo

    # remove the old symlink so make realclean
    # doesn't delete our checkout/build
    rm parrot

    # see above
    make realclean
    git pull

    # make a symlink of the above parrot
    # directory in the rakudo sourcetree
    ln -s ../parrot parrot

    # see above
    perl Configure.pl
    make

    # I just do this so that I can run perl6
    # and have an "interactive" perl6 it isn't
    # really interactive, but it's better than
    # write, execute loops
    make perl6

And then I'd recommend doing a crontab -e and adding

    0 17  *   *   *     sh /home/foo/dev/build_rakudo.sh

so that it gets built every day, starting at 5 pm, so it's ripe for work when you get home :-)

And one last thing: working on perl6 locally can be kindav a drag because it doesn't tell you the result of all of your lines when you are using the fake-o interactive mode. A nice thing to do is this:

    sub p($anything) { $anything.perl.say }

That way if you give it an array, it will print out the array as an array instead of some weird tab delimited stringification or whatever.

Happy hacking!
