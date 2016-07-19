---
aliases: ["/archives/886"]
title: "Chapter 7: Open Source"
date: "2009-07-04T04:56:06-05:00"
tags: [frew-warez, cpan, dbix-class, linux, open-source, perl, rails, ruby]
guid: "http://blog.afoolishmanifesto.com/?p=886"
---
Some of you probably know that I have some opinions, thoughts, and ideas. I actually started this blog because I wanted to write my own (can you guess what?) Manifesto. I chose to write it as a blog because I tend to change my mind. Ask some of my friends and family. They have all observed that I was going to be a math teacher, a psychologist, a biological engineer, a doctor, and a writer. (Take note: I am none of those things.)

I started programming in earnest about 10 years ago, when I purchased [Programming Perl](http://www.amazon.com/gp/product/0596000278?ie=UTF8&tag=afooman-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596000278)![](http://www.assoc-amazon.com/e/ir?t=afooman-20&l=as2&o=1&a=0596000278). I had done some basic, but I knew that real programmers used perl. I knew I would never use any other language. 6 years later I turned my back on perl when a professor introduced me to ruby. While in ruby-land I learned functional programming, what MVC was, what an ORM is, and the beauty of syntax (I still dig 5.times \{...\}). I knew that Rails was the One True way to program websites and that Prototype and Scriptaculous were the only way to program javascript.

Then 4 years later someone offered to pay me to write perl. I came back somewhat grudgingly, and I came extremely close to trying to write a certain project with rails. Fortunately (for my current dogmatism) my boss convinced me to stick with perl. Somewhere along the line I learned that perl 6 is truly being developed. I helped some and had some fun. I read the book currently titled [The Passionate Programmer](http://www.amazon.com/gp/product/1934356344?ie=UTF8&tag=afooman-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=1934356344)![](http://www.assoc-amazon.com/e/ir?t=afooman-20&l=as2&o=1&a=1934356344). After reading it I decided to start seriously look into switching from IIS to Apache.

After setting up Apache on my personal computer so I could have a useful error log I started researching ORM's. I found that The One True ORM of any given language is DBIx::Class. I will never use another ORM as long as I live. I have posted about it a few times now. I'll leave that at that.

Larry Wall says that the three programming virtues are laziness, impatience, and hubris. I agree with his conclusions. The first two often lead to code reuse. Code reuse is an excellent goal. Code reuse is what keeps my current codebase nimble and exciting to work on.

Part of code reuse means using libraries to help you get your job done. Did I mention DBIx::Class? Yeah, it helps me get my job done. Now, when I first started getting paid to code I was told that in a professional context, we don't waste our time reinventing the wheel. Agreed! Let us not reinvent the wheel.

So instead of reinventing the wheel, we'll

<del>purchase a library that does the job for us</del>

find some Open Source library that does (or almost does) the job for us. Before I got further I'd like to make a few points about Open Source software. (Also, let me remind you that I am Holden Caulfield right now so I may be lying, on purpose or accident.)

I do not use Open Source software because I desire or need freedom. My political friends tell me that I am spoiled for saying that freedom is not the highest virtue and that I would not be willing to die for freedom. There are other virtues that I (hope) would be willing to die for, but that's another chapter.

I do not use Open Source software because I am poor. I purchase indie video games because they are awesome works of art and they are not cheap. I donate to Open Source and otherwise free software that I regularly use because I am glad to pay for the excellent work that someone will do to make my job/life easier. I think that it is fine to ransom features as an Open Source programmer.

I do no use Open Source because I am a communist. There is no reason that a programmer should give you his time and effort for free. Let me redact that statement: there is no reason that a person should give you his time and effort for free. If you view me as a carbon offset to the earth and that everything I do should be given to the poor, that's fine. We are all wrong sometimes. Let me be clear: I love Ayn Rand as a phiosophess and I agree with her unconditionally.

I use Open Source software because **I am a programmer**. Jeff Atwood says that "[If it's a core business function, write that code yourself, no matter what.](http://www.codinghorror.com/blog/archives/001172.html)". I agree Jeff! The problem comes when you purchase an over-the-counter library, it suits your fancy perfectly, and then six months later, as always happens, the customer wants more. The library no longer works for you, so you either pay the Closed Source vendor to implement the features you need, or find another library and port all of your code to that.

This is what happens to me: I use an Open Source library that does what I need. I eventually outgrow it or it doesn't meet a specific need, I either whine enough to get someone to add the feature I need, or I figure out how to add it myself. I'm not even a very good programmer; I just really like to program.

Let me put it another way: do you have any friends who really like to work on their car? Do they buy the brand new drive-by-wire automatic Toyota that is more black box than car?

This post is pushing up against the thousand word mark and we certainly wouldn't want to go there, so I'll repeat myself one more time: I am a programmer. I will continue to use Open Source software because I love to program and because I don't want any Golden Handcuffs.

So programmers, ask and it will be given to you; seek and you will find; untar and the code will be opened to you. Suits: feel free to purchase black boxes as Golden Handcuffs. Thank you and have a nice weekend.
