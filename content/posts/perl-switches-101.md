---
aliases: ["/archives/1883"]
title: "Perl Switches 101"
date: "2013-08-16T02:16:21-05:00"
tags: [frew-warez, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1883"
---
The backstory to this post is a little weird in that it involves [rjbs](http://rjbs.manxome.org/rubric) much more than usual. A couple weeks ago I was playing D&D with rjbs and Abigail, and before the game got started somehow we ended up talking about [Masterminds of Programming](http://www.amazon.com/gp/product/0596515170/ref=as_li_ss_tl?ie=UTF8&camp=1789&creative=390957&creativeASIN=0596515170&linkCode=as2&tag=afooman-20)![](http://ir-na.amazon-adsystem.com/e/ir?t=afooman-20&l=as2&o=1&a=0596515170). The book is pretty good so far, you should totally read it! Anyway, the book has a chapter on [AWK](https://en.wikipedia.org/wiki/AWK) and for some reason I mentioned to rjbs that I need to buckle down and learn AWK. He told me instead that I should just use perl and it's many switches that save time when using it on the commandline. I have learned the few that he told me were critical and will document them here. Enjoy!

# -e/-E

I wouldn't be surprised if I used this more than 50 times in a day. I can't imagine someone not knowing this one, but you have to learn it at some point right? **-e** merely runs the perl code that follows it. **-E** runs the following perl code with all optional features turned on. So for instance if you run in ye olde perl 5.8 you'd write

    perl -e'print "1\n"'

In any of the many many more recent perls, you could write

    perl -E'say 1'

# -n

The **-n** switch basically wraps code in a while loop, iterating over the default filehandle. Here's a silly example:

    ls | perl -nE'say "frew: $_" if m/frew/'

That will print "frew" and the filename if any of the files that were listed have frew in the name. I run this exact command on midnight every Wednesday.

The code is

    use 5.18.1; # or whatever... maybe there's a better way to write this
    no strict; # off for cli
    while (<>) {
       print "frew: $_" if m/frew/ # no newline because there is one from the input
    }

# -p

This is the same as **-n** except it adds 'continue \{ print \}' to the end. If you didn't know, continue code gets run even if the user did "next". The idea here is that now you can mutate $\_ and turn perl into a filter. Here's another silly example:

    ls | perl -pE'$_ = "* $_"'

This would transform the output of ls into a markdown list. That's kinda useful I guess. The full code is

    use 5.18.1;
    no strict;
    while (<>) {
       $_ = "* $_"
    } continue { print }

# -i

This one is subtle but awesome enough that I've used it both today and [yesterday](https://github.com/frioux/app-adenosine/commit/efde246fcfb497e1a928cb7c7a709da754a83e92), having only learned it on Tuesday, I say that's pretty good. This basically changes STDIN and STDOUT into an in place file edit.

So let's say you have a file that has dos line endings and inexplicably you bill joy's vi, so you can't just set ff to unix (this happened to me today.) Here is how you could fix the file:

    perl -pi -E's/\r//g' dumbwin32file

Isn't that great? Ok you'll notice that I didn't just write **-piE**. That's because **-i** takes an optional argument, which is the extension of the backup of the file you munged. The default, as I said, is in place, but if for some reason you are stuck in 1989 and don't have version control, you could use **-pi.bak -E**. How about you just use git though?

# -l

This is a bit of a weird one. I haven't needed it, but I can come up with contrived examples that use it. Basically, it chomp while reading and adds newlines while writing. So you could match on exact values and replace $\_ entirely I guess...

    perl -plE'$_ = $_ eq "foo" ? 1 : 0'

# -a

This one is kinda fun. Basically it (by default) splits $\_ on qr/\\s+/ into @F. So you can use it like cut -d' ' except with multiple spaces. Here's an example!

    ls -lh | perl -plaE'$_ = "$F[8] is owned by $F[2]"'

I've wanted this for a long time, so hurray!

Here's the expanded code

    use 5.18.1;
    no strict;
    while (<>) {
       chomp;
       our @F = split qr/\s+/, $_;
       $_ = "$F[8] is owned by $F[2]";
    } continue { print "$_\n" }

# -F

This is really just a mutator for **-a**. The argument you pass it changes the split param. So you might use it like this:

    cat /etc/passwd | perl -pla -F':' -E'$_ = "$F[0] uses $F[6] as a shell"'

The code expands to

    use 5.18.1;
    no strict;
    while (<>) {
       chomp;
       our @F = split qr/:/, $_;
       $_ = "$F[0] uses $F[6] as a shell";
    } continue { print "$_\n" }

There are others, (-M, which I use all the time, for example) but those will have to wait for another post. Enjoy!
