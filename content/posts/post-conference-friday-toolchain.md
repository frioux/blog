---
aliases: ["/archives/548"]
title: "Post Conference Friday Toolchain"
date: "2009-04-18T08:32:29-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=548"
---
Today at work I put to use a lot of the stuff that I learned at the conference this week. The first thing I did was install [JSLint Multi](http://code.google.com/p/jslint-multi-widget/). I already use Yahoo! Widgets for the weather and an analog clock, so it wasn't a big deal to install some widget.

My biggest problem with JSLint is that it's hassle city to run. Part of that had to do with my own lack of knowledge about how to use it. So this tool will basically run JSLint on a bunch of files, just drag files and folders into the widget and it will automatically watch them. Whenever a file changes it will run JSLint on the file and if it turns red something was wrong. Just click on the file and it will show the first error for that file. The main thing that you may notice is that it doesn't know about the Ext namespace. To take care of that put this at the top of files that use Ext:

    /*global Ext */

Also, you probably want to configure JSLint Multi so that it tests what you want. For example, by default it doesn't allow ++ or -- because that could be "too clever." I'm a programmer. So are my colleagues. We know what ++ and -- does. Disallowing ++ and -- seems totally dumb. So I tweaked a bunch of stuff so that it matches more what we do.

Up next: vim customizations! While I was working on doing some of the basic changes I noticed that a lot of them could at least be highlighted so as not to happen again. I cooked up this little snippet and put it in after/ftplugin/javascript.vim:

    match Error /,\_s*[)\]}]\|[:,]\[^ ]\|[^0-9]\.[0-9]\+\|=\@!===\@!\|!==\@!/

That will highlight trailing commas, numbers without an initial numeral (.5), ==, !=, and some spacing issues like foo:'bar' or ('foo','bar'). It gives some false positives, but for now it's helpful. I hope to tweak it some more so that it doesn't look at strings or whatever.

After diving in to the addicting behavior of vim customization I realized that I have always been annoyed by how vim won't indent automatically for [ or ]. This actually is the case for both Javascript and Perl. It turns out that it's not super easy to configure, but I figured it out anyway. I emailed the maintainers of the given indent files and hopefully my changes will be merged into the real version. Ah shoot. While I was writing that sentence the Perl message bounced back. The Javascript one uses IndentAnything as Javascript has a slightly weird syntax. Anyway, [here](http://afoolishmanifesto.com/javascript.vim) [they](http://afoolishmanifesto.com/perl.vim) are if anyone is interested in them.
