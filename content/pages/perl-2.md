---
aliases: ["/perl-tutorials/perl-2"]
title: "Perl 2"
date: "2009-03-12T04:11:50-05:00"
guid: "http://blog.afoolishmanifesto.com/?page_id=445"
---
Station Teammates,

First and foremost, functions, or as perl calls them, subroutines. (I don't
think there's a difference. If there is, let me know).

Here's the syntax:

sub\_ex.pl

    #!/usr/bin/perl
    use warnings;
    use diagnostics;
    use strict;

    sub frew {
      print "hello world!\n";
    }

    frew;

Obviously not very useful, nor is it a very good sub name. Oh well, you get what
you pay for, right?

Ok, one thing you will probably notice immediately is that in perl you don't
have parameter definitions like in almost every other language you have ever
used. How do you get at your params?! Chill man, it's really not that bad. Let's
try again, k?

sub\_param\_the\_man.pl

    #!/usr/bin/perl
    use warnings;
    use strict;
    use diagnostics;

    sub greet_the_man {
     my $name = $_[0];
     print "Will the real $name please stand up?\n";
    }

    greet_the_man("slim shady");

I want to point out a few things here. First off, eminem is terrible. I am not a
fan. But it would be nice if he would stand up.

So the $\_[0] thing there, do you notice what that is? It's an element in an
array. That is, the array is @\_. This is where parameters get stored. @\_ is a
pretty gnarly guy in general. So gnarly in fact, that everyone loves him! I'll
get into why everyone loves him in a bit. But in the meantime...

You will probably never ever see code that looks like that in real life. It just
isn't done. Remember how arrays are like, multiple things and stuff? Well, in
perl you can use arrays just like stacks. That is, you can add stuff on, and
take stuff off, and all that cool stuff. There is a command that will take stuff
off of the front of an array called "shift". So the first line in that sub could
be written like this:

     my $name = shift(@_);

Again, you will never see that in code either. "Why!?" you scream with your
small mouselike voices! BECAUSE EVERYONE LOVES @\_!!! But of course you still
don't understand. The reason that everyone loves @\_ is because when a function
is called without arguments, @\_ is given to it. So finally, it would more
realistically get written like this:

     my $name = shift;

It takes a little getting used to, but seriously guys, we do that a lot. (Almost
every single function in perl has something like that.)

There are a couple other functions in perl that can help you out with arrays.
unshift will add stuff to the front of an array. pop will take an item off the
end of the array and return it. push will add things to the end of the array.
Another good thing is sort. It's a little complicated, but I think you guys
would do good to learn it.

Just calling sort on an array will sort it asciibetically (I hate that term).
You can change the order of sorting by passing perl a block, which is like a
bitesized piece of code (note: not byte. That's just terrible.) So, you wanna
sort it alphabetically like a real American? Check this out bro!

     sort { uc($a) cmp uc($b) } @stuff;

What that does is uppercase everything in $a and $b and CoMPare them as strings.
Wanna reverse it? EASY!

     sort { uc($b) cmp uc($a) } @stuff;

But numbers?

     sort { $a <=> $b } @stuff;

This whole concept is actually really gnarly. As a mere bunny, like you fellas,
I thought it was silly. But now that blocks are my buds, I think this is great!
(for more details see perldoc -f sort.)

Ok, so another little bonus thing that I have hardly ever seen used in perl. You
actually CAN force perl to have parameters like in c. They aren't as structured
since perl isn't but it can't hurt. (Note: we don't do this in perl, but it
might be a good idea to look into it?)

There is this thing called a reference. A reference is like,
"0x00hahbcha001953"! Which is a place in the RAM. Anyway, the reason that these
kind of things exist is for efficiency. You don't wanna have a 100 element array
and pass the values. Think of the waste! So we pass a reference instead. So
like, I have this reference...

dumb\_ref\_example.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;

    # Scalar
    my $name = "frew";

    # Scalar Ref.
    my $name_name = \$name;

    print '$name: '.$name."\n";
    print '$name_name: '.$name_name."\n";
    print '$$name_name: '.$$name_name."\n";

Ok, here are some other misc. things that are good to know.

join will put a bunch of things together with stuff inbetween. Example:

join\_for\_life.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;

    # I am a math major too.
    my @friends = ('1', '2', '3', '4', '5', '6',);
    my $factorial = join '*', @friends;
    print "$factorial\n";

We mostly use that to generate some SQL. Not that hard.

die is a good one to know. You could do this:

i\_could\_just\_die.pl

```
#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

chomp(my $enemy = <stdin>);
die "CATHERINE IS NOT MY ENEMY!\n" if $enemy eq 'Catherine';
print "You're dumb $enemy.\n";
```

basically die is an error message. It's throwing an exception. Fjord tell's me
that perl's exception handling is not exactly exceptional.... Get it?

map is something that we use. It basically says, "Ok, what's up?" for each item
in a list, and then makes a new list based on what is up. Want proof? How is
this thug!

mapped.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;

    my @ages;

    for (0..20) {
     $ages[$_] = int(rand(100)) + 1;
     print "age: $ages[$_]\n";
    }

    my @old_enough = map { $_ if ($_ >= 21);} @ages;

    for (@old_enough) {
     print "$_ is old enough.\n" if ($_);
    }

Basically what this does is returns an array of ages that are greather than 21
and leaves them undefined if they are less. That's another use of a block there!

A typical use of a map is to define a hash. The perldoc -f map has a pretty good
example of that.

Ok, I assume you have all heard of the tertiary operator. I am a pretty big fan
of it. It's great for little tiny tests.

plural.pl

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

    sub num {
     my $tmp = shift;
     say (($tmp == 1)?"Singular":"Plural");
    }

    num 1;
    num 10;

REGULAR EXPRESSIONS!!!!

Ok, a little tiny bit of background. Regular expressions are usually just called
regex, and often the plural is regexen. They are used often in scripting
languages and generally available everywhere in Unix. A true regular expression
(which perl does not have) is an extremely minimal language class. I won't
explain what that means because you probably just want to get up and get gnarly,
but just know that the Regular Expressions that you are learning are super
powerful.

Regular expressions are like a tiny language of their own. Perl extends the
standard definition of regular expressions so that they are a little easier to
write. Basically regular expressions are tools for locating and identifying
strings. They are not the most efficient thing on a computer (indeed, they can
be quite the opposite) but they are good for us programmers, and we have things
to do, unlike the computer.

So let's start off with an extremely simple example that you would surely never
do.

born\_to\_regexen.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;
    use feature ':5.10';

    my $name = "fREW";

    say $name;

    $name =~ s/REW/ROOH/;

    say $name;

    $name =~ s/ROOH/ROUGH/;

    say $name;

    $name =~ s:ROUGH:RIOUX:;

    say $name;

Ok, so there are a few things to take note here. The =~ is basically the regex
operator. I'll show more examples later. A mnemonic from Dr. Fjord: it always
goes $x =~ regex because regexen are magic, just like the ~. I used to mix those
up when I was a small turtle.

The s/// is a special regexy function that searches (hence the s) and replaces.
The above regexen that I use are about as lame as it gets, but it gets the point
across. Also note from the third example, you don't have to use /. Often if you
are dealing with directories in unix you will use colons like I did above.
Sometimes I make a game out of it and try to use the weirdest characters as
possible to separate.

Note re Magic: if you just have s/stuff/morestuff/ it will use the $\_. ie $\_
=~ s/frew/you/ === s/frew/you.

So you guys are all like, regex? More like, regsucks! I won't fault you. You
just don't know better yet! Let's try out a more formidable example.

formidable.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;
    use feature ':5.10';

    my $name = "fR";

    for (1..20) { $name .= 'O'; }
    $name .= 'H';

    if ($name =~ m?fROOH?) {
     say "$name is one of the many names of fREW, according to m?fROOH?.";
    } elsif ($name =~ m%fROOO*H%) {
     say "$name is one of the many names of fREW, according to m%fRO*H%.";
    }

Interesting. fROOH is too strict, because any number of O's is correct, as long
as there are two or more...

So to explain a number of mysteries, the .= syntax is pretty standard. Basically
$frew .= 'frew' === $frew = $frew.'frew'; m// is more simple than s///. It just
returns true if the string Matched the regex. You can actually leave off the m,
but if you do that, you have to use /// and no special characters.

So how does that regex work? It's simple really. fROO means match those, O\*
means match any number, including zero, O's, and H means match an H.

Let's add another tiny bit of niceness here. When you find yourself doing
if-else's based on a single value, try given and when!

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;
    use feature ':5.10';

    my $name = "fR";

    for (1..20) { $name .= 'O'; }
    $name .= 'H';
    given($name) {
       when (/fROOH/) {
          say "$name is one of the many names of fREW, according to m?fROOH?.";
       }
       when(/fROOO*H/) {
          say "$name is one of the many names of fREW, according to m%fRO*H%.";
       }
    }

This uses the smart match, ~~ instead of =~. That means that if you didn't use a
regex above it would use == instead of =~. Very cool! It matches based on $\_,
and given sets $\_.

A more perly way to do that would be m/fROO+H/. + means 1 or more. So OO\* ===
O+

Well I have a problem with the above code. It doesn't match fREW or fRIOUX!

Simple.

round\_two.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;
    use feature ':5.10';

    my @names = ('fREW', 'fROOOOOOH', 'fRIOUX', 'fROUGH', 'fRU', 'fRUE',
    'Haribold fREW bangfodder', 'Buckethead');

    for (@names) {
       when (/fR(EW|OO+H|IOUX|OUGH|U|UE)/) {
        say "$_ matches!!!";
       }
       default {
        say "$_ is not fREW's name.";
       }
    }

Ok, lets dissect that. The fR obviously matches fR. The parenthesis are special,
and do a few things. The first thing they do is let us have alternatives, like
above. | means or for a regular expression. You can remember that because often
or === ||. Although the precedence varies I think.

Now, do you see the problem with the above program? Haribold fREW bangfodder is
not my name, my name is just inside of it. So we use what are called Anchors.
Let's see the new version:

round\_awesome.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;

    my @names = ('fREW', 'fROOOOOOH', 'fRIOUX', 'fROUGH', 'fRU', 'fRUE',
    'Haribold fREW bangfodder', 'Buckethead');

    for (@names) {
       when (/^fR(EW|OO+H|IOUX|OUGH|U|UE)$/) {
        say "$_ matches!!!";
       }
       default {
        say "$_ is not fREW's name.";
       }
    }

The difference is pretty small, so I'll point it out. The ^ means match at the
beginning of the string, and the $ means match at the end.

Ok, so those are the basics of regular expression. Wanna learn the really cool
stuff? Lets!

Once I wrote an AIMBot that would deliver messages to people when they got
online. The way it read the messages from people was like this: Tell
"screenname" I said "message" And it would check to see if they were online and
if they were it would tell them the message and who said it. The sourcecode is
online and probably broken if you want it:
http://frew.livejournal.com/74274.html

Anyway, here is a simplified version of my parser for your knowledge. We will
build from there.

parser.pl

```
#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;
use feature ':5.10';

while (<stdin>) {
   given($_) {
      when (/^tell '([a-zA-Z_]+)' i said '(.*)'$/) {
         say "Screenname: $1\nMessage: $2\n";
      }
      default {
         say "<$_> doesn't match!";
      }
   }
}
```

Play with that. It is pretty cool right? A couple things. First off, that weird
[a-zA-Z\_] is a character class. Basically what it does is match any lowercase,
uppercase, or underscore character. You could do:
[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\_], but the - does what
you would guess. Character classes basically allow you to match any of a certain
type of characters. [aeiouAEIOU] could be a vowel character class. Now, there is
a simpler, more perly way to do what I did above. In perl, \\w is the same as
[a-zA-Z\_]. It means word character. Similarly, . is one of those shortcuts. It
means match (almost) ANY character. I am pretty sure that it will not match
newlines, unless you do something funny.

Now the really cool part. The groups [ these: () ] automatically store what they
matched into numbered variables. Hence why we have $1 and $2. Be careful with
stuff like (()()). I think the big one is $1 and the inner ones are $2 and $3.
Either way it's weired. Also note: $0 is the entire match, but that's not very
useful normally. A couple other gnarly features:

\\1 through \\9 refer to previous matches. So you could do: /(.+)\\1/ and it
would only match things like, 'frewfrew' or 'harry sally harry sally '. This is
actually what makes perls regular expressions not actually regular expressions.
They are called backreferences and you will respect them. Yes, that is MISTER
\\1 to you punk!

Well, the regex above is a little picky. So how about we modify it so that
people will have to pay less attention.

parse\_one\_more.pl

```
#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;
use feature ':5.10';

while (<stdin>) {
   given($_) {
      when (/^tell\s+'(\w+)'\s+i\s+said\s+'(.*)'$/i) {
         say "Screenname: $1\nMessage: $2\n";
      }
      default {
         say "&lt;$_&gt; doesn't match!";
      }
   }
}
```

New stuff: \\s is a whitespace character class. So we now accept any number of
spaces, tabs, or other space things I don't know about. the i after the
terminating slash means case-insensitive. Good! Try it!

Bonus feature: Because we have the ' anchored to the end there, someone can
type:

Tell 'yourmom' i said ''What's you're deal man?''

And it will work. It's just a little weird to me though.

So now you know most of what you need to know for simple regexen. There is
really a lot more that you can do, but that should keep you fascinated for a
while. It would benefit you to skim perlre (perldoc perlre) and get a feel for
it. For example, there are character classes for numbers, but I'll let you try
to find that in perlre.

Have fun!
