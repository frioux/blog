---
aliases: ["/archives/1255"]
title: "Getting portable"
date: "2010-01-13T05:54:08-06:00"
tags: ["perl", "portable"]
guid: "http://blog.afoolishmanifesto.com/?p=1255"
---
One of my [Goals for the New Year](/archives/1241) was to finish my current project at work. One thing that keeps me from working more on my project is that working from home is pretty painful. So I decided that I'd do all that I could to do as much work as possible from home without needing to be VPN'd in to work.

The primary hurdle was to figure out a way to get all of the data from our shared dev server (SQL Server 2005) to something I could use at home. Once I put my mind to it it wasn't very hard at all! With a little nudge from ribasushi I got the following code:

    my $schema = ACD::Schema->connect($connect_info);

    my $sqema = ACD::Schema->connect('dbi:SQLite:dbname=database');

    $sqema->deploy();
    for ( $schema->sources ) {
        my $old_rs = $schema->resultset($_);
        my $new_rs = $sqema->resultset($_);
        $old_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
        $new_rs->populate([$old_rs->all]);
    }

Of course I realized after that that I had left most of our DBIC column def's blank and I had to fill in is\_nullable all over the place, but that was just a bunch of regular work.

So after that I had a nice, 200 meg database file that I could use on my laptop just fine.

The next thing I did was set up SVK on my laptop. git is the new hotness but without a gui and good windows support there's no way I'm going to be able to get my coworkers to use it; svk gives a lot of the benefit of git to svn users. Here's how I did it (all from [here](http://svk.bestpractical.com/view/SVKUsage).)

    svk mirror //acd/trunk svn://svn.lan.mitsi.com/aircraft_ducting
    svk sync //acd/trunk
    svk cp -m 'local branch for acd' //acd/trunk //acd/local
    svk co //acd/local acd

That worked without a hitch. The next thing was to install what we need to run our app on my laptop. That's not so bad since I keep our Makefile.PL up to date:

    perl Makefile.PL
    make installdeps

Last but not least, I moved my sqlite database into my application and updated our acd.json file to look like the following:

    {
       "name": "ACD",
       "Model": {
          "DB": {
             "connect_info":{
                "dsn":"dbi:SQLite:dbname=database",
                "quote_char":"\"",
                "name_sep":".",
             }
          }
       }
    }

And it works! Now I can work from home extremely easily!
