---
title: How to Add a Subscription Service to Your Blog
date: 2019-03-07T07:15:57
tags: [ perl, blog, meta ]
guid: 0cf2f92a-232c-4b25-a2f7-48dedb0e723b
---
I used to use a service to email subscribers updates to my blog.  The service
broke, but I automated my way around it.

<!--more-->

I was using that well-advertised, monkey oriented mail service until this week.
I used it originally based on the advice of [Julia Evans](https://jvns.ca/).
For better or worse I never actually got it to work.  When I set up the [cache
busting for my blog](/posts/busting-cloudflare-cache/) the service apparently,
finally noticied that I had been writing posts, but instead of sending to my
incredibly small list of subscribers, they decided that I had somehow violated
their ToS (they didn't offer how and haven't responded to my inquiries about
that.)

Initially I figured I'd just cancel the service and stop having a mailing list;
that worked for the prior ten years, do I really need people to subscribe via
email anyway?  But a few people at work acted interested and I realized: I know
how to send email already!  So I did what I tend to do: I wrote a program!

[You can see the source
here](https://github.com/frioux/blog/blob/198cb5feddbecf7d03c4008b876eafb2bae27b43/bin/newsletter).
The core of it is three basic ideas:

 1. I can get posts published in the last week using [q](https://blog.afoolishmanifesto.com/posts/hugo-unix-vim-integration/#advanced-unix-tools)
 2. I can easily create email using [Email::Stuffer](https://metacpan.org/pod/Email::Stuffer)
 3. I already run postfix so enqueuing a bunch of email is as easy as calling
    `->send`

The code could be a touch neater, by using a template, for example, instead of
manually generating the email bodies, but I kinda hate template languages and
don't want to use them in my personal code unless I really have to.  On top of
that I want to add some fun, weird things like randomized greetings.
[Dominus](https://blog.plover.com/) put a bunch of stuff like that in a project
at work and it has really inspired me to make fun little bits for my programs
too.

---

I'm sure that I'll regret this at some point, but as it stands this works fine.
If one day I need to do something less scrappy I will likely use SES, Lambda,
and S3.  The code could be pretty similar but I'd want to port it to Go to use
an official AWS SDK.

---

Do you want to try to have better habits or kill worse ones?  Check out <a target="_blank" href="https://www.amazon.com/gp/product/0735211299/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0735211299&linkCode=as2&tag=afoolishmanif-20&linkId=4d09c639d59d4b9c2fe8f0f46c5208bd">Atomic Habits</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0735211299" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
it's pretty good!

Another book that I recommend is
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=cecea11ea25b6635dd78601d2ec1abef">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It goes through the motions of creating wrappers tools and tools afresh, diving
into some of the operating system details that assist the toolmaker so much.
