---
title: Serverless
date: 2016-05-28T23:58:25
tags: ["heroku", "lambda", "sandstorm"]
guid: "https://blog.afoolishmanifesto.com/posts/Serverless"
---
A big trend lately has been the rise of "serverless" software.  I'm not sure I'm
the best person to define that term, but my use of the term generally revolves
around avoiding a virtual machine (or a real machine I guess.)  I have a server
on Linode that I've been slowly removing services from in an effort to get more
"serverless."

It's not about chasing fads.  I am a professional software engineer and I mostly
use Perl; I sorta resist change for the sake of it.

It's mostly about the isolation of the components.  As it stands today my server
is a weird install of Debian where the kernel is 64 bit and the userspace is 32
bit.  This was fine before, but now it means I can't run Docker.  I had hoped to
migrate various parts of my own server to containers to be able to more easily
move them to [OVH](https://www.ovh.com/us/) when I eventually leave Linode, but
I can't now.

# Services

I could just rebuild the server, but then all of these various services that run
on my server would be down for an unknown amount of time.  To make this a little
more concrete, here are the major services that ran on my blog at the beginning
of 2016:

 1. Blog (statically served content from Apache)
 2. [Lizard Brain](https://github.com/frioux/Lizard-Brain) (Weird automation thing)
 3. IRC Client (Weechat)
 4. RSS (An install of Tiny Tiny RSS; PHP on Apache)
 5. [Feeds](https://github.com/frioux/corn) (various proxied RSS feeds that I filter myself)
 6. Git repos (This blog and other non-public repositories)
 7. SyncThing (Open source decentralized DropBox like thing)

The above are ordered in terms of importance.  If SyncThing doesn't work for
some reason, I might not even notice.  If my blog is down I will be very angsty.

## Blog

[I've already posted about when I moved my blog off
Linode](https://blog.afoolishmanifesto.com/posts/migrating-blog-to-cloudfront/).
That's been a great success for me.  I am pleased that this blog is much more
stable than it was before; it's incredibly secure, despite the fact that it's
"on someone else's computer;" and it's fast and cheap!

## Feeds

After [winning a sweet
skateboard](https://twitter.com/frioux/status/733405365811847168) from
[Heroku](https://www.heroku.com/) I decided to try out their software.  It's
pretty great!  The general idea is that you write some kind of web based app,
and it will get run in a container on demand by Heroku, and after a period of
inactivity, the app will be shut down.

This is a perfect way for my RSS proxy to run, and it simplified a lot of stuff.
[I had written code to automatically
deploy](https://github.com/frioux/Lizard-Brain/blob/c63091b05c8f1ca503467f840cb09211cb69a0f6/www/cgi-bin/impulse-www#L58-L87)
when I push to GitHub.  Heroku already does that.  I never took care of
automating the installation of deps, but Heroku ([or really
miyagawa](https://github.com/miyagawa/heroku-buildpack-perl)) did.

While I had certificates automatically getting created by LetsEncrypt, [Heroku
provides the same
functionality](https://blog.heroku.com/archives/2016/5/18/announcing_heroku_free_ssl_beta_and_flexible_dyno_hours)
and I will never need to baby-sit it.

And finally, because my RSS proxy is so light (accessed a few times a day) it
ends up being free.  Awesome.  Thanks Heroku.

### AWS Lambda

I originally tried using Lambda for this, but it required a rewrite and I am
depending on some non-trivial infrastructural dependencies here.  While I would
have loved to port my application to Python and have it run for super cheap on
AWS Lambda, it just was not a real option without more porting than I am
prepared to do right now.

## RSS and Git Repos

[Tiny Tiny RSS](https://tt-rss.org/) is software that I very much have a
love/hate relationship with.  Due to the way the community works, I was always a
little nervous about using it.  After reading [a blog post by Filippo
Valsorda](https://blog.filippo.io/self-host-analytics/) about
[Piwik](https://piwik.org/) I decided to try out
[Sandstorm.io](https://sandstorm.io/) on [the
Oasis](https://oasis.sandstorm.io/).  Sandstorm.io is a lot like Heroku, but
it's more geared toward hosting open source software for individuals, with a
strong emphasis on security.

You know that friend you have who is a teacher and likes to blog about soccer?
Do you really want that friend installing WordPress on a server?  You do not.
If that friend had an Oasis account, they could use the WordPress grain and
almost certainly never get hacked.

I decided to try using Oasis to host my RSS reader and so far it has been very
nice.  I had one other friend using my original RSS instance (it was in
multiuser mode) and he seems to have had no issues with using Oasis either.
This is great; I now have a frustrating to maintain piece of software off of my
server and *also* I'm not maintaining it for two.  What a load off!

Oasis also has a grain for hosting a git repo, so I have migrated the storage of
the source repo of this blog to the Oasis.  That was a fairly painless process,
but one thing to realize is that each grain is completely isolated, so when you
set up a git repo grain it hosts just the one repo.  If you have ten repos,
you'd be using ten grains.  [That would be enough that you'd end up paying much
more](https://sandstorm.io/get#managed-hosting) for your git repos.

I'll probably move my Piwik hosting to the Oasis as well.

Oh also, it's lightweight enough that it's free!  Thanks Oasis.

## Lizard Brain and IRC Client

Lizard Brain is very much a tool that is glued into the guts of a Unix system.
One of its core components is `atd`.  As of today, Sandstorm has no scheduler
that would allow LB to run there.  Similarly, while Heroku does have a
scheduler, its granularity is terrible and it's much more like `cron` (it's
periodic) than `atd` (a specific event in time.)  Amazon does have scheduled
events for Lambda, but unlike Heroku and Sandstorm, that would require a
complete rewrite in Python, Java, or JavaScript.  I suspect I will rewrite in
Python; it's only about 800 lines, but it would be nice if I didn't have to.

Another option would be for me to create my own `atd`, but then I'd have it
running in a VM somewhere and if I have a VM running somewhere I have a lot less
motivation to move every little service off of my current VM.

A much harder service is IRC.  I use my VM as an IRC client so that I will
always have logs of conversations that happened when I was away.  Over time this
has gotten less and less important, but there are still a few people who will
reach out to me while I'm still asleep and I'm happy to respond when I'm back.
As of today I do not see a good replacement for a full VM just for IRC.  I *may*
try to write some kind of thing to put SSH + Weechat in a grain to run on
Sandstorm.io, but it seems like a lot of work.

An alternate option, which I do sortav like, is finding some IRC client that
runs in the browser and *also* has an API, so I can use it from my phone, but
also have a terminal interface.

The good news is that my Linode will eventually "expire" and I'll probably get a
T2 Nano EC2 instance, which costs about $2-4/month and is big enough (500 mB of
RAM) to host an IRC Client.  Even on my current Linode I'm using only 750 mB of
ram and if you exclude MySQL (used for TTRSS, still haven't uninstalled it) and
SyncThing it's suddenly less than 500 mB.  Cool!

## SyncThing

SyncThing is cool, but it's not a critical enough part of my setup to require a
VM.  I am likely to just stop using it since I've gone all the way and gotten a
paid account for DropBox.

# Motivations

A lot of the above are specifics that are almost worthless to most of you.
There are real reasons to move to a serverless setup, and I think they are
reasons that everyone can appreciate.

## Security

Software is consistently and constantly shown to be insecure.  Engineers work
hard to make good software, but it seems almost impossible for sufficiently
complex software to be secure.  I will admit that all of the services discussed
here are also software, but because of their very structure the user is
protected from a huge number of attacks.

Here's a very simple example: on the Oasis, I have a MySQL instance inside of
the TTRSS grain.  On my Linode the MySQL server could potentially be
misconfigured to be listening on a public interface, maybe because some PHP
application installer did that.  On the Oasis that's not even possible, due to
the routing of the containers.

Similarly, on Heroku, if there were some crazy kernel bug that needed to be
resolved, because my application is getting spun down all the time, there are
plenty of chances to reboot the underlying virtual machines without me even
noticing.

## Isolation

Isolation is a combination of a reliability and security feature.  When it
comes to security it means that if my blog were to get hacked, my TTRSS instance
is completely unaffected.  Now I have to admit this is a tiny bit of a straw
man, because if I set up each of my services as separate users they'd be fairly
well isolated.  I didn't do that though because that's a hassle.

The reliability part of isolation is a lot more considerable though.  If I tweak
the Apache site config for TTRSS and run `/etc/init.d/apache restart` and had a
syntax error, all of the sites being hosted on my machine go down till I fix the
issue.  While I've learned various ways to ensure that does not happen, "be
careful" is a really stupid way to ensure reliability.

## Cost

I make enough money to pay for a $20/mo Linode, but it just seems like a waste
of overall money that could be put to better uses.  Without a ton of effort I
can cut my total spend in half, and I suspect drop to about %10.  As mentioned
already in the past, [my blog is costing less than a dime a
month](https://blog.afoolishmanifesto.com/posts/cloudfront-migration-update/) and is
rock-solid.

# Problems

Nothing is perfect though.  While I am mostly sold on the serverless phenomenon,
there are some issues that I think need solving before it's an unconditional
win.

## Storage (RDBMS etc)

This sorta blows my mind.  With the exception of Sandstorm.io, which is meant
for small amounts of users for a given application, no one really offers a cheap
database.  Heroku has a free database option that I couldn't have used with my
RSS reader, and the for-pay option would cost about half what I pay for my VM,
*just* for the database.

Similarly AWS offers RDS, but that's really just the cost of an EC2 VM, so at
the barest that would be a consistent $2/mo.  If you were willing to completely
rewrite your application you *might* be able to get by using DyanomDB, but in my
experience using it at work it can be *very* frustrating to try to tune for.

I really think that someone needs to come in and do what Lamdba did for code or
DyanomDB did for KV stores, but for a traditional database.  Basically as it
stands today if you have a database that is idle, you pay the same price as you
would for a database that is pegging it's CPU.  I want a traditional database
that is billed based on usage.

## Billing Models

Speaking of billing a database based on usage, more things need to be billed
based on usage!  I am a huge fan of most of the billing models on AWS, where you
end up paying for what you use.  For someone self hosting for personal
consumption this almost always means that whatever you are doing will cost less
than any server you could build.  I would *gladly* pay for my Oasis usage, but a
jump from free to $9 is just enough for me to instead change my behaviour
and instead spend that money elsewhere.

If someone who works on Sandstorm.io is reading this and cares: I would gladly
pay hourly per grain.

I have not yet used enough of Heroku to need to use the for pay option there,
but it looks like I could probably use it fairly cheaply.

# haters

Of course there will be some people who read this who think that running on
anything but your own server is foolish.  I wonder if those people run directly
on the metal, or just assume that all of the Xen security bugs have been found.
I wonder if those people regularly update their software for security patches
and know to restart all of the various components that need to be restarted.  I
wonder if those people value their own time and money.

---

Hopefully before July I will only be using my server for IRC and Lizard Brain.
There's no rush to migrate since my Linode has almost 10 months before a rebill
cycle.  I do expect to test how well a T2 Nano works for my goals in the
meantime though, so that I can easily pull the trigger when the time comes.
