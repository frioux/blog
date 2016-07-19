---
aliases: ["/archives/482"]
title: "Implementing map with Perl 6 and Perl 6"
date: "2009-03-16T03:51:39-05:00"
tags: [perl, perl-6, functional-programming]
guid: "http://blog.afoolishmanifesto.com/?p=482"
---
Hopefully everyone reading this blog knows the function map. Map _maps_ one array onto another with a simple function. For example, if I had a list of names at my old school and I wanted a list of emails I could do something like this:

    my @names = ('frew schmidt', 'bob barr', ); # etc...
    my @emails = map { s/\s+//; "$_\@letu.edu" } @names;

I think that's pretty great. I thought it would be cool to reinvent the wheel and implement map in Perl 6. One of them will be implemented the typical way and the other will be the Perl 6 (as far as I can tell) way.

Here's the obvious way:

    sub map1(Code $fn, @list) {
        my @new_list;
        for @list {
            @new_list.push($fn($_));
        }
        return @new_list;
    }

    map1({ $_ * 2 },[ 1,2,3,4,5 ]).perl.say;
    map1(sub ($f) { $f + 2 },[ 1,2,3,4,5 ]).perl.say;

Pretty simple. We make a new list; iterate over the original list and push the value returned from the code onto the new list. But look at how much we have to think about the new list! The important part is the operation, not the list, or at least that's what I think.

With that in mind, map round 2:

    sub map2(Code $fn, @list) {
        gather {
            for @list {
                 take $fn($_);
            }
        }
    }

    map2({ $_ ** 2 },[ 1,2,3,4,5 ]).perl.say;
    map2(sub ($f) { $f ** 2 },[ 1,2,3,4,5 ]).perl.say;

Gather/take, as mentioned previously, abstracts the idea of creating a new list.

And as for a question that Sol mentioned previously about gather and take:

> ... is gather / take just syntactic sugar, or is it implementing lazy evaluation, or is it even opening up the possibility of threading?

I think that gather/take is really just a pretty syntax. I think that it depends on what is inside of your gather for what is possible. You could even iterate over the contents of a file inside of a gather, in which case I am sure you couldn't do threads. I guess lazy evaluation is theoretically possible though... But that would depend both on what is inside of the gather and what uses it.
