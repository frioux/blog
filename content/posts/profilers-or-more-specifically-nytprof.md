---
aliases: ["/archives/635"]
title: "Profilers or more specifically NYTProf"
date: "2009-05-12T22:36:56-05:00"
tags: ["nytprof", "perl", "profiler"]
guid: "http://blog.afoolishmanifesto.com/?p=635"
---
At work one of our [customers](http://www.epmsonline.com/) is having us revamp one of the major sections of the site. We are moving in the "Web Application" direction; that is, very little HTML, and almost all Javascript. The section of the site that my coworker was working on recently does a lot of calculation. On the old HTML page a customer would log in, ask for a certain report, and I guess go get a cup of coffee. The report took something like five minutes to run; not impossibly long, but long enough that you don't want to leave it like that and turn the output into JSON.

So we took a look at the module that does the calculation. First off, it was a little long (four thousand lines,) so just eyeballing it wouldn't easily point us to what was causing the slowdown. Fortunately my coworker Neil, who wrote the module, had also written a simple to execute perl script, as opposed to everything being in a cgi script. So with that in hand, we fired up [NYTProf](http://search.cpan.org/perldoc?Devel::NYTProf).

NYTProf is a profiler that was written for use at the (wait for it) New York Times. After installation using it was extremely easy:

    perl -d:NYTProf calc.pl

That generates a database of what went down. Next we ran:

    nytprofhtml

Which turned everything into nicely formatted html files. It creates profiles for all of the files used and has some nice javascript sorting built in to the tables etc. It showed us that we were calling a certain heavyweight function more than we should have (DBI::st::execute :-) .) And then there were other things that we did (simple caching for example: _if (!$self->\{foo\}) \{ $self->\{foo\} = ...;\} return $self->\{foo\}_) which sped things up something like 70% in the profile.

Anyway, if you find yourself hitting a speed wall, NYTProf isn't hard to use at all. The only problem you may run into is not having a simple to run test script. This is another reason to split business logic into modules; you can easily use the modules in your controllers, test scripts, and profilers.

Have fun!
