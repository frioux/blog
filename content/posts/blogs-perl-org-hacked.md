---
aliases: ["/archives/1915"]
title: "blogs.perl.org hacked"
date: "2014-01-23T16:32:24-06:00"
tags: ["blogs-perl-org", "crypt", "passwords", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1915"
---
Things never change. Well actually they do, just not much.

About five years ago [I blogged about PerlMonks getting hacked](/archives/1028). They had stored their passwords in plaintext, which basically meant everyone who used the site should have changed their passwords and fixed any situations where they had reused passwords. Also probably abandoned PerlMonks (I know I haven't been back since.)

blogs.perl.org, a relatively recent blogging platform that was slated to replace use.perl.org (Thanks Sawyer!), just got hacked as well. Fortunately BPO was **not** in plaintext. It could have been stored better though. As far as I can tell the data wasn't hashed, or at least wasn't hashed per password. The passwords are salted, but fairly weakly. (Thanks hobbs and leont!) On the other hand none of my spot checks have turned up google indexed precomputed tables of the stored passwords, so good job not using md5 :)

Just a couple months ago [I blogged about how password hashing **should** be done.](/archives/1910) Check it out.
