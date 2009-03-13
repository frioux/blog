---
aliases: ["/archives/452"]
title: "Perl 6: Explained!"
date: "2009-03-13T05:14:26-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=452"
---
I was hoping to work on the setting for Rakudo some today, but it just wasn't happening due to my own inferiorities. I decided instead to try to read some of the setting code so that I can be less inferior in the future. I hope you enjoy learning some Perl 6!

First we'll start with a simple one: Str.lcfirst.

        our Str multi method lcfirst is export {
            self gt '' ?? self.substr(0,1).lc ~ self.substr(1) !! ""
        }

**our Str multi method lcfirst is export**: **our** means public; **Str** means it returns a string; **multi** means it can be defined with other method signatures etc; **method lcfirst** is the name of the method; and **is export** means it also becomes a function.

**self gt ''**: this just returns true if the current string is greater than '', which will be true if it's not blank.

The **??** thing is Perl 6's tertiary, **?? !!**; which is **? :** in most languages. I think **?? !!** is a lot easier to remember because it's like, "is this true??then do that; !!otherwise do something else." Thanks Larry :-)

So if the current string isn't empty, we do **self.substr(0,1).lc ~ self.substr(1)**. This is the meat of the function. This basically says, starting at the beginning of the string (0) give me a 1 character string, then lowercase it, and then concatenate it with a string starting at the first character that goes all the way to the end.

And if the string is empty we just return empty. That wasn't so hard was it? Next up: **split!**

        our List multi method split($delimiter, $limit = *) {
            my Int $prev = 0;
            my $l = $limit ~~ Whatever ?? Inf !! $limit;
            my $s = ~self;
            if $delimiter eq '' {
                return gather {
                    take $s.substr($_, 1) for 0 .. $s.chars - 1;
                }
            }
            return gather {
                my $pos = 0;
                while $l > 1
                      && $pos < $s.chars
                      && defined ($pos = $s.index($delimiter, $prev)) {
                    take $s.substr($prev, $pos - $prev);
                    $prev = [max] 1 + $prev, $pos + (~$delimiter).chars;
                    $l--;
                }
                take $s.substr($prev) if $l > 0;
            }
        }

I won't explain anything again if I already explained it once. So the first new thing we see here is an actual method signature. **$delimiter**: this means we have a $delimiter value passed in. **$limit = \***: somewhere Larry Wall wrote that he imagined a language called STAR in which verbs would all be \* and they would just DWIM. This is related to that idea. We'll get to it when we use $limit.

**my Int $prev = 0**: we are defining $prev to be only an integer and it starts off as 0.

**my $l = $limit ~~ Whatever ?? Inf !! $limit**: \* has a special relationship to Whatever. Whatever is a type of \*, so \* **does** Whatever. The idea is that we are matching $limit with whatever, which in this case means only true if the user passed in a value for $limit. Otherwise $limit gets set to Inf, which unsurprisingly means infinity. A little weird. I may clarify this later.

**my $s = ~self**: We are coercing self into a string here.

**return gather**: gather/take is a really cool control structure that lets you generate an array without any temporary variables. So you pass gather a block and then any time take is called in the block it pushes the value passed to take onto the generated array. Pretty awesome right?

So the first gather is called if our delimiter is '', which means get the string as an array. We iterate from 0 to the last character in the string, and give the value of the character (single character string) to take. Fairly simple besides grokking gather/take and wondering where $\_ came from till you see the for later on in the line.

The next half of the method basically repeats over the whole string looking for delimiters. It has the following conditions: we haven't split more than we originally intended (limit) and we haven't gone past the end of the string and we have a position on the next delimiter in the string

Then we **take** the string starting at the previous delimiter till the position of the current delimiter. I personally would have defined $prev inside of the second gather as that is the only place that it's used, but that's just me :-)

Next we set $prev to the maximum of one more than the last delimiter and the current delimiter + the length of the delimiter. This is a really strange line of code, but so it goes. First off, we are using the reduce operator ([]) to find the max. I would have used just max as we are only comparing two things; not a big deal of course. I also cannot think of a time when the first option would even be greater than the second, only equal to it. I am probably wrong though...

Then we decrement $l, which is our max amount of splits.

And then we end by taking the rest of the string if there are any "splits" left. Again, the if statement there seems superfluous. But I could be wrong.

I tested my theories about extra code and it still seems to work fine. Here is my new and imFrewved method :-)

        our List multi method split($delimiter, $limit = *) {
            my $l = $limit ~~ Whatever ?? Inf !! $limit;
            my $s = ~self;
            if $delimiter eq '' {
                return gather {
                    take $s.substr($_, 1) for 0 .. $s.chars - 1;
                }
            }
            return gather {
                my Int $prev = 0;
                my $pos = 0;
                while $l > 1
                      && $pos < $s.chars
                      && defined ($pos = $s.index($delimiter, $prev)) {
                    take $s.substr($prev, $pos - $prev);
                    $prev = $pos + (~$delimiter).chars;
                    $l--;
                }
                take $s.substr($prev);
            }
        }
