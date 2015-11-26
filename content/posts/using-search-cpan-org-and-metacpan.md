---
aliases: ["/archives/1692"]
title: "Using search.cpan.org AND metacpan"
date: "2012-05-16T00:22:00-05:00"
tags: ["metacpan", "perl", "sco", "search-cpan-org"]
guid: "http://blog.afoolishmanifesto.com/?p=1692"
---
I appreciate the effort and openness of [metacpan](http://metacpan.org), but
their search is still pretty bad. To be clear, compare the results of the search
for DBIx:Class::Source on
[SCO](http://search.cpan.org/search?query=dbix%3Aclass%3A%3Asource&mode=all) and
[metacpan](https://metacpan.org/search?q=DBIx%3AClass%3A%3ASource). That's why I
made the following greasemonkey/dotjs script:

    $('a').each(function(i,x){
       var obj = $(this);
       var href = obj.attr('href');
       var re = new RegExp('^/~([^/]+)/(.*)$');
       this.href = href.replace(re, 'https://metacpan.org/module/$1/$2');
    })

Put this in ~/.js/search.cpan.org.js to install it with dotjs. Feel free to
extend it to work for more than just modules.
