---
aliases: ["/archives/643"]
title: "Testing with Perl: awesome"
date: "2009-05-07T01:53:06-05:00"
tags: ["perl", "testing", "tests"]
guid: "http://blog.afoolishmanifesto.com/?p=643"
---
Sometimes when I get close to the end of the day and it isn't feasible for me to
start on something new I expand on my current project's test suite. Recently I
worked on one of the (seemingly) more complex ones. Basically it tests one of
our autocompleters to ensure that it will search for the name and also the
public facing id of a certain field. The id part was easy.

The name part was significantly more complex, but not too bad really:

    my @data = $schema->resultset('Customer')->
       autocomplete_search({
          query => 'ame'
       })->all;
    cmp_deeply @data, all(
       array_each(
          methods(
             name => re(qr/.*ame.*/i)
          )
       )
    ), "Name matches query";

So basically what that does is ensure that all of the items in @data have a
method that match the regex listed. It doesn't care how many items are returned
or any of the other details. Elegance!
