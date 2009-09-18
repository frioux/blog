---
aliases: ["/archives/1162"]
title: "Perl, PostScript, PDF, Printing, and Money"
date: "2009-09-18T00:15:18-05:00"
tags: ["perl", "printing"]
guid: "http://blog.afoolishmanifesto.com/?p=1162"
---
I've been pretty busy/distracted lately. Normally I try to post 3 times a week about the cool things that I'm doing, but I haven't this week because what I am doing isn't that cool!

Basically I started working on the printing subsection of our app at work and it's not looking like a lot of fun. First let me explain what makes it different than anything we've done before. In normal web dev you have the server generate html or _maybe_ a pdf, send that to the user and let them print it. You might do some js to invoke the print dialogue, but beside that your work is done. Unfortunately the situation we are in now is that the users do something with the web app and the **server** prints out some stuff on a predefined printer. This will either happen immediately or via a cron-job, but either way it means we have to interact with printers much more directly than we normally do.

Now printing to a printer is actually not as hard as I thought it would be. We are on a windows system, and the way to do it in windows is basically as follows:

    use strict;
    use warnings;
    use File::Copy;
    copy 'file_to_print.ps', '\\\\printserver\\printer';

Done! That works just fine. The problem is that postscript is (as far as I can tell) no fun and pretty complicated. Of course going from a pdf to postscript is pretty easy using Ghostscript, so basically what it looks like is we should generate a pdf or a postscript file. I looked at using LaTeX a little bit but a 600 megabyte package really seems like overkill. And even then I don't know LaTeX beyond math stuff I did in college. The perl offerings are good, but I am just out of my depth here. Here are the modules I looked at:

- [PDF::API2](http://search.cpan.org/perldoc?PDF::API2) - Very Complete, but I'd need to know how PDF's work to use this
- [PDF::ReportWriter](http://search.cpan.org/perldoc?PDF::ReportWriter) - Good, but I don't know if I have enough control. And I'll still need to learn a ton of XML directives.
- [PDF::Template](http://search.cpan.org/perldoc?PDF::Template) - Pretty much the same as above
- [PDF::FromHTML](http://search.cpan.org/perldoc?PDF::FromHTML) - Again, this (and others like it) are alright, but there are just too many things that I may not be able to do that our layout requires.

I tend to be a fan of doing a lot of stuff in house, mostly because I love to learn and I tend to find the fun parts in things. But this is one of the times when my boss mentioned that we could pay someone else to do this that I am totally behind it. Even if I learned all of the stuff I'd need to know to do this myself, it would **still** take forever.

So here is my plan. I'd like to solicit people from the Perl community for some contract work. We currently have these printouts defined in terms of VB6 Data Designer ... things. I would like to give someone a couple of the definitions, along with example printouts (scans), and screenshots. Conversion to PDF or PS are both fine. I was thinking that we'd use TT to fill in various parts of the new template. If the programmer does something like code in the PS or PDF to loop over data defined in the file, that's ok, as long as it's well commented as none of us know PDF or PS. Also if the coder does it in pure perl with one of the libraries above (except probably FromHTML) I'm fine with that, as I think they are all pretty quality modules. My ultimate goal is to make a conversion tool for the other 32 reports we'll need printed out. If the programmer gets that started that would be awesome. I'm not at work right now, so I can't post the examples, but I will post a couple links to examples tomorrow _to the Catalyst ML_ along with contact information. I think the people who use Catalyst tend to be good coders. (I'm also going to email a few people I've met in person directly.) If you are interested, I will probably have posted everything by 2PM Central Time, so check the ML Archives then.

I hope to hear from you!
