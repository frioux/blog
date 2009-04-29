---
aliases: ["/archives/596"]
title: "PerlCritic for Web Developers"
date: "2009-04-29T04:12:11-05:00"
tags: ["perl", "perlcritic"]
guid: "http://blog.afoolishmanifesto.com/?p=596"
---
I like to continually move towards perfection in my code. perlcritic is a tool based on the book [Perl Best Practices](http://www.amazon.com/gp/product/0596001738?ie=UTF8&tag=afooman-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596001738)![](http://www.assoc-amazon.com/e/ir?t=afooman-20&l=as2&o=1&a=0596001738) by Damian Conway. It's basically lint for perl.

perlcritic is fine as it is if you spend all day on the console, but I usually spend my whole day in Firefox and vim. The only use for my console is checking in source and using irssi. There are a few other things I use the console for, but the point remains, I spend more time in Firefox than I do in the shell. The same is true of my coworkers: we are a windows shop; without installing cygwin using the console is fairly painful. And if it's a hassle for me there is **no way** I can convince my coworkers to use it.

So I developed [WebCritic](http://github.com/frioux/perlcritic-web/tree/master). At some point I'll make a real website for it, but for now this will have to work. I have other things I want to work on more, but I am using this daily at work so I presume that people might use it :-) . Anyway, it depends on:

    IO::All
    Perl::Critic
    CGI::Application
    CGI::Application::Dispatch
    Moose

After checking it out from github you'll want to start the critic server. It's just a tiny server that keeps criticisms around for files that haven't changed. With a fairly small codebase that took the load time down by a factor of 10. It also means that you don't have to give the world access to your code. Just have the user owning the code run the server and your real webserver will talk with the mini server.

Now as to how to set up the real webserver...

I've been using Apache for the whole thing, so it's been fairly simple getting it all going. If you want help getting it going with IIS I can help. Just leave a comment. Anyway, the config that I use for apache is in the devdocs dir in the repo. Just Include it in your main apache conf file. In ubuntu you only have to make a symlink to it in /etc/apache/sites-enabled.

You also need to start my mini server. I haven't set up any script to autostart it as I prefer to start it as a user. Basically all you need to do is cd into the repo dir and run

<pre>perl bin/server.pl <directory-to-monitor></directory-to-monitor></pre>

The first time that it checks through the code it will take a while (mine takes 15 seconds,) but after that it should be pretty quick.

After getting all this going you should just have to go to http://localhost:5000/critic and you'll get a nice listing of all of the criticisms from perlcritic. You can put a .perlcriticrc file in the dir that the server monitors to customize perlcritic. Note that all the columns are sortable and there are more columns that are hidden by default. Most importantly, the javascript will automatically query the webserver for data every 30 seconds, but if you want to know **now** press Alt+R while the page has focus and the page should reload the data (but not the page itself!)

Enjoy!
