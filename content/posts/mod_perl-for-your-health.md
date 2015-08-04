---
aliases: ["/archives/402"]
title: "mod_perl: For Your Health!"
date: "2009-03-07T05:08:19-06:00"
tags: ["apache", "mod_perl"]
guid: "http://blog.afoolishmanifesto.com/?p=402"
---
You may have wondered why I had the slight delay in posts this week. I had a good reason: we switched one of our major products from IIS to Apache! In general it was a fairly painless process. The details are documented in my previous post, [Migrating from IIS to Apache](/archives/59). There was one hitch though...

We have an autocomplete field that needs to be pretty snappy. For IIS we just installed ActivePerl and named the file autocomplete.plex and it was good. Well, mod\_perl isn't quite so easy; we had a couple major snags.

For some reason we had a lot of issues trying to get mod\_perl working with ActivePerl 5.8. I initially wanted to leave it at 5.8 because of various modules that were already installed and couldn't easily be upgraded. I eventually decided to bite the bullet and install 5.10 and update the modules.

After installing Apache (see previous post) and ActivePerl 5.10 (plus lots of modules) we had to install mod\_perl, which was surprisingly easy:

    ppm install http://cpan.uwinnipeg.ca/PPMPackages/10xx/mod_perl.ppd

After that I had to add to the configuration for Apache:

```
LoadModule perl\_module modules/mod\_perl.so
LoadFile "C:/Perl/bin/perl510.dll"

<location /foo/autocomplete/perl="/foo/autocomplete/perl">
   SetHandler perl-script
   PerlResponseHandler ModPerl::Registry
   Options +ExecCGI
</location>
```

Since we were only converting that one script we limited mod\_perl to that single directory.

The last issue that we had was that you cannot use CGI.pm with mod\_perl; fortunately for us in this file all we were using it for was to print a header, and mod\_perl does that for you by default, so we just commented out those lines. At some point I'll need to do some more research and learn the mod\_perl way to get params and print headers.

In general it was pretty nice. We now have a much more stable configuration and mod\_perl is **extremely** fast. The autocompleter went around ten times faster (60~ms total afterwards) after switching. I didn't get a persistent DBI connection set up, but I did put all of the **use** directives in the BEGIN block.

If anyone has pointers on persistent DBI connections, a way to only set mod\_perl for a single file extension, or whatever the mod\_perl replacement is for CGI.pm, let me know!
