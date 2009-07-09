---
aliases: ["/archives/907"]
title: "Form Validation Sucks."
date: "2009-07-09T00:55:44-05:00"
tags: ["formvalidation", "perl", "rant", "validation"]
guid: "http://blog.afoolishmanifesto.com/?p=907"
---
This is just a rant.

I am so sick of validating forms. I do all that I can to make it easy and whatnot, but it still comes back to spite me! Here are two examples of things that are dumb:

#### Checkboxes

So html checkboxes are SO DUMB. If they are checked, the value is set to 'on.' That's annoying alone, but if the checkbox is **not** set it doesn't even get submitted! Anyway, that's pretty annoying. I made a little utility function that lets me just do something like this:

    $self->fix_checkbox($_) for (qw{is_foo is_bar});

That works ok I guess. It just feels ghetto.

#### Blank != NULL

This is less about forms and more just about how suck I am of this stupid stuff. So let's say you have some numbers fields in your db. If a person wants to leave the number blank, it gets submitted as ''. Unfortunately that is not a valid number. So you have to convert the '' to undef to get it to store into the database as a NULL. That's annoying right? No?

Blah. I'm done.
