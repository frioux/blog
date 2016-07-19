---
aliases: ["/archives/1704"]
title: "Introducing JavaScript::Dependency::Manager"
date: "2012-05-28T14:35:03-05:00"
tags: [mitsi, announcement, cpan, javascript, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1704"
---
Nearly a year ago my grandfather passed away. He had some form of dementia for a long time and I personally wasn't hit very hard by it, but as is the custom I went home to visit my family when it happened. On the drive down I listened to [Childhood's End](https://en.wikipedia.org/wiki/Childhood%27s_End) and [Rendezvous with Rama.](https://en.wikipedia.org/wiki/Rendezvous_with_Rama) At work I'd been tackling the problem of users with custom dashboards and possibly even the ability to have gadgets that we sell separately. The whole drive down I had trouble focusing on the audiobooks and instead was thinking about how to deal with this problem of loading the right JavaScript for the right users.

Of course it's not a difficult problem and really once you realize what your problem is it's a Simple Matter of Programming. So when I stopped for gas, energy drinks, and gas at the Tallulah Travel Center in Louisiana I went ahead and implemented my solution. I didn't write docs, but I wrote tests and the basic API that hasn't changed and has served me well so far. So here it is:

# Introducing [JavaScript::Dependency::Manager](http://p3rl.org/JavaScript::Dependency::Manager)

In this modern age we have more and more JavaScript to deal with. The project I worked on before my current one was actually 50/50 JavaScript and Perl. If you are ok with the number of requests required when using client side dependency management, check out [RequireJS.](http://requirejs.org/) Personally though I'd rather bundle, minify, and cache all my JavaScript on the server side.

## Using JSDM is easy

All that you need to do to use JSDM is annotate the requirements and provisions in your JavaScript files and instantiate and use a JSDM object:

    // provides: oldYeller
    // requires: underscore
    var oldYeller = _.throttle(function(voice) { alert(voice + "!!") }, 1000);

    use JavaScript::Dependency::Manager;

    my $mgr = JavaScript::Dependency::Manager->new(
      lib_dir => ['root/js/lib'],
      provisions => {
        underscore => ['root/js/lib/underscore/underscore.js'],
      },
    );

    my @files = $mgr->file_list_for_provisions(['oldYeller']);

The return value from file\_list\_for\_provisions is an ordered list of files that provide the requested provisions, as well as all of the provisions' dependencies, recursively. Basically it gives you a list of files you can load on the page and make it work.

There are a couple missing features I'd like to implement at some point. First off is cycle detection. At work we actually have a legitimate cycle and the best way to fix it was to just take out the requirement that makes it a cycle. Although this may not be the solution for everyone, at the very least I'd rather JSDM say "cycle detected" or something. The other thing is that sometimes JavaScript needs CSS to be loaded as well, so I might make a way to plug into JSDM and load other required resources.

This may seem like overkill compared to, say, a manifest of JS files to load, but once you use it it's so much nicer due to automatically handling of load order and whatnot.
