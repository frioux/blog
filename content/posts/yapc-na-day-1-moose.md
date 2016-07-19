---
aliases: ["/archives/844"]
title: "YAPC::NA - Day -1: Moose"
date: "2009-06-22T01:24:43-05:00"
tags: [mitsi, moose, perl, yapc]
guid: "http://blog.afoolishmanifesto.com/?p=844"
---
Today was the first day (for me) of YAPC::NA. It was pretty cool! A coworker and
I convinced our work to pay for us to go to YAPC and go to the Moose
Masterclass. The class was very good. I thought that the slides were very
complete and that the exercises were great for a professional conference.
Basically he would present a major section of Moose (there were 4 or 5 I think)
and then he would tell us to get going on the Classes for that given library. We
would get instructions from comments in the base unit test file and then we
would just run the unit tests to see if we were doing the right thing. There
were some discrepancies between the comments in the tests and the tests
themselves, but I'd say that's pretty standard for comments. Anyway, the slides
were all just webpages and the rest was of course just perl code. So [check it
out
here!](http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=gitmo/moose-presentations.git;a=tree;f=moose-class;h=bf7414ec002044b931af188fc28abc566e0463cd;hb=refs/heads/master)

I actually found the most intriguing part of the talk to be
[MooseX::Types](http://search.cpan.org/perldoc?MooseX::Types). Unfortunately
that is **not** included in the slides linked about as it was done by Jonathon
Rockway. I can't yet find slides for it. But the important thing is that Types
are awesome with Moose. It's fairly trivial to write new types. He wrote a type
for Social Security Numbers and then showed us how to use it and how to make a
thing that would automatically coerce integers into the SSN type. Very cool
stuff! I am very excited for when I get to use that in the future.

Another thing that must be mentioned. There is always someone in a talk who
wants to be heard more than the presenter. Or maybe they just act that way. I
don't know. But we had one of those in our talk. There was a point at which our
presenter was showing how to have a singleton as an attribute to a class and
apparently this guy zoned out when he was showing it. Furthermore he didn't
notice that the code

    package Person;
    use Moose;

    my $highlander_bank =
        Bank->new( name => 'Spire FCU' );

    has bank => (
        is      => 'rw',
        default => sub { $highlander_bank },
    );

had the word highlander in it. Anyway, he tried to correct the presenter about
this and before the presenter got a chance to respond MST yelled at the dude and
said, "THERE CAN ONLY BE ONE! THAT'S WHY IT'S CALLED A HIGHLANDER!" It was
hilarious.

So yeah, that's day minus-one for YAPC. I will write about everything I go to so
that you can be ok with the fact that you are stuck at work or whatever :)
