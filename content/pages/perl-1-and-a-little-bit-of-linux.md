---
aliases: ["/perl-tutorials/perl-1-and-a-little-bit-of-linux"]
title: "Perl 1 (and a little bit of Linux)"
date: "2009-03-05T04:17:05-06:00"
tags: [perl]
guid: "http://blog.afoolishmanifesto.com/?page_id=373"
---
Hello friends!

This is the part where you learn the basics of Perl! I am not going to tell you
about where it came from or any of that history stuff. If you want, all that is
on Wikipedia. What I AM going to tell you is how to program in it. I highly
suggest you try out all of this code and play with it a little bit so that you
understand it. Seriously, if you get kinda good (just kinda, not even a wizard!)
at perl, you can use it to make a lot of the things you do a lot more
convenient. Like downloading all 1000 of the Dinosaur comics, you don't wanna do
that by hand do you? Didn't think so.

So first off: I will assume you are using Linux. If you are using windows, you
will have to open a command box and run the scripts like this: perl script.pl.

The cannonical way to run a perl program in Linux is to have the first line
start with #! This is how almost all scripting languages in Linux work. So for
perl, you do:

    #!/usr/bin/perl

Any line starting with a # is a comment, but that first one is special, SO DON'T
SCREW IT UP! :-) Anyway, you want to do the classical, first program ever right?
Right! Here it is in all of it's glory!

hello.pl:

    #!/usr/bin/perl

    print "Hello World!\n";

Ok, so you guys who are new to Linux are thinking, "Well Gnarly! But how do I
run it?" Let me tell you a story. When I first started using linux, I wanted to
learn C++. So I bought a book, did the first chapter, and then I couldn't figure
out how to run the file!!! So I will save you about 5 years of grief. (That
wasn't even a joke.) First off, you will want to put the text from above into a
file somehow. You can use like, kate or gedit if you are in kde or gnome, or if
you are in the console pico will probably serve you just fine. If you want to
learn a really good editor that will be on more versions of Unix than just
Linux, try vi. It's kinda hard to learn, but most people who use it really do
dig it. I am using it right now! But I digress. So let's say you are using pico.
You would do the following:

pico hello.pl

```
<type in the text>
Ctrl-X
Yes
<enter>
```

So now you have the file with hello world in it. Now you need to make it
executable. To do this, you type, at the command prompt:

    chmod +x hello.pl

If you want to learn more about chmod, type

    man chmod

and use q to exit.

ok, now to actually run hello.pl, do this:

    ./hello.pl

And everything should be great!

If not, make sure that hello.pl is in the same directory as you.

Ok, so that was pretty easy right? Almost exactly like BASIC from the old days!

Let's learn about variables now. Unlike C, C++, Java, or almost any compiled
language, Perl is a loosely typed language, like almost any other scripting
language. In Perl, you don't say that a variable is an int or a string, you just
kinda say it is.

Before we go on I want to mention that while you are learning you might as well
use the right pragmata. These are things that augment the perl language to do
nice things. The main ones we will use right now are warnings, diagnostics,
strict, and feature. Warnings tells you if something might be wrong, diagnostics
explains the error, strict makes sure you don't get sloppy with your code, and
feature lets you use cool new features. You should always use strict and
warnings. Diagnostics can significantly slow down your program, so only use that
when you are debugging. It really does help though. And feature is just cool.
Now to use those four pragmata, you do the following:

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

Pretty simple!

Ok, so let's talk about the most basic type of variable. The scalar. A scalar
can be a number, a string, or even a reference. It's the most basic of the
variable types. In perl, scalar's start with $. This is easy to remember since $
looks like S. That's called a sigil. I think that BASIC had those too, but I
don't really remember. So, you wanna try and use one right? Heck yes! Now, if we
are using strict, we have to define the scope of the variable before we use it.
That way we can't try to use a variable that is undefined (without strict it
would work, but I think there would be a warning if we were using warnings.)
Check it out:

hello\_v2.pl:

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';
    my $world = "Mars";

    say "Hello $world!";

Cool right? You just saw some variable interpolation in effect! That's a nice
thing about those sigils, they make it so variables can be directly embedded
into strings. Also note the use of **say**; that basically just tacks the
newline on for you.

Now, one of the major sayings with Perl users is that "There's More Than One Way
To Do It," or tmtowtdi (Tim Toady, Larry Wall's IRC nick.) So the following
lines can replace the 'say "Hello $world!\\n";'

    print "Hello ".$world."!\n";
    print "Hello ", $world, "!\n";

There are two different situations going on here. In Perl, you don't say, "fREW"
+ "Station" to get "fREWStation". Instead we use . for that. The idea is that if
you do 5 + 2 it is the same as 2 + 5. On the other hand, "fREW" + "Station" is
NOT the same as "Station" + "fREW". Hence the use of the ., like the dot
product. Follow? Perl 6 will use ~ instead.

The second is what one would do in C or C++ (I think.) The interesting thing is
that this is a PERFECT segue into our next data-type! The List/Array!!!

Ok, so Perl has arrays. Everyone and their mom knows how to use an array, right?
Right! So, as you can see above, print is just fine if you give it a List.
(Note: List = Array.) So how does one define an Array? Like So!

    my @name = ( "fREW", "fROOH", "fRIOUX", "fROUGH", "fiSMBoC");

or you would maybe also write:

    my @name = (
     "Fjord",
     "Curtis",
     "Hawthorne",
    );

or for even less syntax:

```
my @name = qw<gundog frew mumtaz>;
```

Did you notice the bonus comma in there? Yeah, you don't HAVE to do that, it is
just nice if you want to add stuff later. Also note the use of the qw function;
it let's is automatically **q**uote **w**ords. Convenient! Station?

Also, if you haven't already guessed, the sigil for an array is @. If you can't
figure out the mnemonic for that, you will never pass (or never did pass) any
class with any amount of memorization.

Alright, so print takes a list eh? Prove it yo!

list\_hello.pl:

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

    my @message = (
     "Hello ",
     "World",
     "!",
     "\n",
    );

    print @message;

Ok, ok, so we're gellin. That's kinda cool. But who would ever do that? Fjord?
Probably. Me? Doubtful. I don't see why I would! But we all know what Array's
are REALLY good for. I mean, how do we get at individual elements? It's pretty
simple actually. Check it.

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

    my @message;
    $message[0] = "Hello ";
    $message[1] = "World";
    $message[2] = "!";

    say @message;

Ok, two things. First off, we use the $ because this is a scalar now. @message
is an array, but $message[0] is a scalar. We could make it an array, but if we
did that it would then be @message[0]. But that is a more complicated topic for
the perldsc. ;-) Also, as you probably noticed, the brackets refer to which
element you want. Now, some various things that I feel like I should say now. If
you want the index of the last (not the length!) member of a list, you do this:

    $#message

So we would get 2 for the above. So you can do

    $message[$#message]

to get the last one. Neat right?

So you are probably sick and tired of all this "Hello World" jazz right? I know
I would be. In fact, I am! So let's do a little bit of math. Just to show that
it can be done.

ex\_nihilo.pl

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

    my $x = 0;
    print "\$x: ",$x,"\n";

    $x = $x ** $x;
    say '$x: '.$x;

    $x = $x + $x;
    print '$x: ',$x,"\n";

    $x = $x * $x;
    print '$x: ',$x,"\n";

Ok, so I am pretty sure you guys are ok at math, so I'll explain the tricky
bits. First off, \*\* is exponentiation. That's actually pretty standard. Why we
don't use ^ is a mystery to me. Also note the subtle differences above. If you
use double quotes, you need to escape the $ in the string. You have probably
encountered that before with backslashes and whatnot. Conversely, with the
single quotes escaping is unneeded. But because of this, there can be no
interpolation (read: magic) in single quoted strings.

One more data structure before we move on to the control stuff. This is the
granddaddy of perl data structures. The Hash, also known as an associative
array, is a total gnarlbot. Those of you who haven't had data structures: get
stoked. C cowers at Perl's built in hash. What is a hash? It's like an array,
but with strings instead of integers! Let's check it out yo!

hash\_example.pl

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

    my %generations = (
     "Tom", "Aletha",
     "Dan", "Joyce",
     "Harold", "Margret",
    );

    say "$generations{Tom}";

Cool right? First to note is that Hashes use % and \{\} for their stuff. The
reason being that Hashes are special, and % and \{\} look like magic. Also, the
syntax above is a little cumbersome. Perl has a nice thing called a fat comma
that makes the above much more clear.

hash\_example\_redux.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;

    my %generations = (
     Tom => "Aletha",
     Dan => "Joyce",
     Harold => "Margret",
    );

    print $generations{Dan}."\n";

First notice the grand fat comma. It's nice. Also, hashes do NOT go both ways.
You can force them to, but it's inefficient.

Ok, so a couple functions that you should know about hashes, **keys** and
**values**. keys will return a list of the keys in apparently random order. The
order of the keys though will be the same as the order of the values. Example!

Remember how print can take a list? Check it!

i\_have\_the\_key\_to\_an\_n-tu.pl

    #!/usr/bin/perl

    use warnings;
    use strict;
    use diagnostics;
    use feature ':5.10';

    my %meals = (
     Breakfast => 'Cereal',
     Lunch => 'Hotdog',
     Dinner => 'Fairies',
    );

    print "Meals: ";
    my @sand = keys(%meals);
    say "$sand[0] $sand[1] $sand[2]";

    print "What I had: ";
    my @station = values(%meals);
    print "$station[0] $station[1] $station[2]\n"

Ok, so you can't really do a lot of programming with what I have told you so
far.

You want to get input from the user so that you can make a program that will do
madlibs, right? (That was always the second program that I made when I learned a
language.) Right!

First off, how does one get input? Like this!

```
my $frew = <stdin>;
```

is a special filehandle that comes from the standard input, which is usually the
keyboard, but if you are cool cat, it isn't! (or is it?) (Did you advanced
readers get the joke? Didja?)

You will probably notice though, if you are playing around, that when you do
this, the string still has the "\\n" on it. What a hassle! Well, there is an oft
used function for that. **chomp**. Example:

input\_example.pl

```
#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;
use feature ':5.10'l

my $name;

print "Who is dis is? ";
$name = <stdin>;
chomp $name;
say "Why hello, $name, I thought you were out of town!";
```

The above is pretty straightforward. There two things to point out though. One
is that in general, parenthesis in perl are not required, as you can see with
the chomp. But they can't hurt, and sometimes they really are needed. Also,
whenever I do input, I do:

```
chomp($name = <stdin>)
```

That kinda takes out the middle man...or something.

Fun!

madlib.pl

```
#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

my @verbs;
my @nouns;
my @adjectives;

print "Give me three verbs.  Separate them with spaces.\\n";
@verbs = split(' ', chomp <stdin>);

print "Give me three nouns.  Separate them with spaces.\\n";
@nouns = split(' ', chomp <stdin>);

print "Give me three adjectives.  Separate them with spaces.\\n";
@adjectives = split(' ', chomp <stdin>);

say qq("You always $verbs[2]!");
say "That's what my $nouns[1] told me last time this happened.";
say qq("You're always so $adjectives[0].  Let's just $verbs[0]");
say "That's when my mom came in.  She told me she lost her $nouns[2]";
say "and that I should help her find it.";
say "I decided that I would help her, but first I had to $verbs[1].";
say "After that we got the $nouns[0] and found her $nouns[2] right";
say "away!";
say "Then my dad got home and his $adjectives[1] suit was all";
say "$adjectives[2]!";
say "We all had a good laugh after that and went out for pizza.";
```

You'll notice the split command. Basically it takes a string, splits it on the
character that you give it, and returns an array. Also I am sure qq is sticking
out at you. It is basically double-quotes (note the two **q**'s) that lets you
keep your quotes in without escaping them.

Ok, now on to control!

First off, if-then statements.

the general format is

```
if (<expression>) {
 stuff;
}
```

or:

```
if (<expression>) {
 stuff;
} elsif (<expression>) {
 more stuff;
} else {
 even more stuff;
}
```

Now, the first thing I have to tell you is that, unlike C or Java, the braces
are absolutely required. They said it was to reduce ambiguity, which is a little
paradoxical since this like...perl. Oh well.

So expressions are pretty simple. For numbers its just the standards. You know,
==, !=, <=, >=, <, >. But in perl you can't use those for strings. For strings
you have:

== becomes eq != becomes ne <= becomes le => becomes ge < becomes lt > becomes gt

I don't have a clue why you would use any of the ones other than eq and ne, but
whatever. (Actually there are reasons, but we'll leave that to a later lesson!)
So if you had a program with a really cheesy password, it would work like this:

password.pl

```
#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

my $password;

print "Input the password now: ";
chomp($password = <stdin>);
if ($password eq "Station") {
 print "Ok, now you have access to the secret.  The secret is:
SR-71's are hiding at my casa!\n";
} else {
 print "The world is on fire.  Run.\n";
}
```

Ok, so check it now. There are a couple types of loops in perl that I can think
of off hand. First, the while loop.

```
while (<expression>) {
 stuff;
}
```

Pretty standard. Example:

tellme.pl

```
#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;
use feature ':5.10';

my $location = "I don't know!";

while ($location ne "at the house") {
 print "Where's the money punk! ";
 chomp($location = <stdin>);
}

say "Alright, we won't have to break your fingers. Get outta here!";
```

Ok, now this is one of the gnarly things about perl. Let's say you want someone
to type out something really huge, and then you want the first word of each line
they type. Well, this should do the trick: (Note: In linux you have to press
Ctrl-D to tell it you are done. Ctrl-D means end of file.)

wordsmith.pl

```
#!/usr/bin/perl

use warnings;
use strict;
use diagnostics;

my @words;

while (<stdin>) {
 my @tmp\_words = split(' ', $_);
 $words[$#words + 1] = $tmp_words[0];
}

for (@words) {
 print $_.' ';
}
print "\n";
```

This demonstrates a couple concepts. First off, a while() will iterate through
each line. The $\_ is the magical variable that means the current value in the
loop. It's neat! Also note the for. It basically iterates through each item in
@words and prints it out with a space afterwards.

Here is a neat thing that you can do in Perl... If you want to count from 1 to
10 in c you would write:

    for (int i = 1; i < 11 ; i++ )
     printf("%i\n", i);

but in perl you do this!

count.pl

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

    for (1..10) {
     say "$_";
    }

Now basically what 1..10 does is create a list on the fly. You could also do
print 1..10, "\\n"; but the numbers would be all smashed together... How about
this:

    #!/usr/bin/perl

    use strict;
    use warnings;
    use diagnostics;
    use feature ':5.10';

    say join(' ', 1..10);

Ok, there is really a LOT more to go into, but that should keep you busy for a
while. A few other things to mention that might help is that stuff in backticks
(\`) gets executed, so you can use that to run programs. And a very important
program is perldoc. Perl has probably the best language manual of any langauge
currently available. I mean, way better than an API reference like Java and C#
have. Like a full on grammar reference and stuff.

To get started do:

     perldoc perltoc

for the table of contents. Each one of the bold thingers is another thing that
you can look at with perldoc. So like, the first one is Perl, to check that out
do

    perldoc perl

Another really helpful thing is:

     perldoc -f

You can use that with any perl function. Try the following:

     perldoc -f sprintf

or

     perldoc -f chomp

Ok, I have at least two more of these tutorials to post, and maybe more after
that. Hope you like 'em! Stay tuned!
