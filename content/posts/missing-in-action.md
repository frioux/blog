---
aliases: ["/archives/1196"]
title: "Missing In Action"
date: "2009-10-22T06:23:16-05:00"
tags: [mitsi, perl, cpan, open-source, printing]
guid: "http://blog.afoolishmanifesto.com/?p=1196"
---
So I haven't posted for kindav a long time. I have a lot planned to write about, but first, the reason it's been so long and the solution to that problem.

You may remember [my post](/archives/1162) regarding printing etc. When I told my boss about the large response I got, I think I miscommunicated and somehow heard that he wanted us to try a few more solutions before we hired someone else. I think he **did** want us to try more things, but not for three weeks with zero results! So I mentioned to him at some point that [Chris J. Madsen](http://www.cjmweb.net/), who gave us a business card at YAPC::NA, responded with a demo and everything. My boss said get it going and I got in touch with Chris and we planned a time to meet and plan things out. I think that was five days ago.

Since that meeting Chris has built us an extremely flexible module to generate postscript reports called [PostScript::Report](http://search.cpan.org/perldoc?PostScript::Report). I haven't read the entirety of the code, but I do think that it's designed well and documented well. So far I've made two reports based on his example and one from scratch, and it's been a joy. I love his [MooseX::AttributeTree](http://search.cpan.org/perldoc?MooseX::AttributeTree) and the use that it allows for something like this to set defaults in an elegant manner.

Chris has also been extremely responsive to issues I've had with the code. For example today we discussed some design issues and he solved a lot of them quickly and handily.

I take away three things from this experience.

First, it would have been cheaper if we had hired him immediately after we discovered that printing is hard and we have no experience in the problem domain. My original idea was to use TT to generate the PostScript for the reports, and that would have been pretty terrible.

Second, this is a really good Open Source business case. There is no way that we could sell this module to other shops. Our job isn't to generate reports. Or job is to generate 50ish reports for one customer. By paying Chris to release it on CPAN we increase the business opportunities of the entire community and may get more features from that. I'd also like to think that because Chris put his name on it, as opposed to making it our code, it is of higher quality because the whole community will see it as a reflection of him.

Lastly, I've learned that Chris is a really great programmer. If anyone reading this blog has a job opening doing Perl development (and I think he would prefer in the Dallas area) I think he might appreciate the work. He may be working full time when you read this, but he's still a great contractor and can do excellent work. See his [website](http://www.cjmweb.net) for details.

So with that behind me hopefully I'll bring some content to this blog again :-)
