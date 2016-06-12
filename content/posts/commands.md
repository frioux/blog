---
aliases: ["/archives/1318"]
title: "commands!"
date: "2010-04-05T19:21:17-05:00"
tags: ["fun"]
guid: "http://blog.afoolishmanifesto.com/?p=1318"
---
[Yesterday](http://blogs.perl.org/users/ovid/2010/04/meme.html) Ovid posted this little snippet to get his top 10 used commands.

I had to modify it a little for my zsh settings:

```
valium [4030] ~acd % history -n 1 | awk {'print $1'} | sort | uniq -c | sort -k1 -rn | head
   1336 svn
    419 perl
    301 git
    245 rm
    233 cd
    179 vi
    151 ack
     67 sudo
     62 cpan
     61 mv

```

I'm sure that my home computer would have the git and svn switched. I'll update this post with that computer's history if I remember.

**update** Here's my home computer:

```
FrewSchmidt2 [10021] ~ % history -n 1 | awk {'print $1'} | sort | uniq -c | sort -k1 -rn | head
   1917 git
    981 rm
    831 perl
    801 vi
    795 cd
    344 ls
    327 svn
    289 sudo
    233 mv
    201 cp
```
