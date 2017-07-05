---
title: 'YAPC::NA 2017 Recap'
date: 2017-07-07T08:02:44
tags: 
guid: 91BED8E8-60C2-11E7-B18F-C1F2B4E056DD
---
A couple of weeks ago I went to YAPC::NA 2017.  [I already wrote about my own
talk][last], but I still want to highlight a few other talks that I think people
should see.

<!--more-->

Before I get into this, there are **a lot** of talks that I didn't see or may
not be mentioning for reasons that you don't care about.  You can see [the full
list of recorded talks on youtube][recorded]; it looks to me like they are still
uploading stuff so you may want to check back if [something on the
schedule][sched] is missing.

## Bumpy Skies

[Bumpy Skies][skiesyt] is the only talk in this list I didn't see at the
conference.  A friend recommended it heartily and I can only agree.  It was
funny, interesting, and heartfelt.  No huge technical take-away but inspiring, a
great story, and a great delivery.

## Last Mile Software Development

[Last Mile Software Development][lastyt] has the thesis that great software
engineering can be done in industries that are not known for great software
engineering, and the users will really appreciate it.  This is the kind of stuff
I used to pine for before I became a jaded back end engineer hoping to never
touch front-ends again.  Very inspiring.

## Hold My Beer and Watch This!

[Hold My Beer and Watch This!][beeryt] is the latest in Stevan's series of talks
about his low-level successor to Moose.  I hope it is the final one, but who
knows.  Stevan is always a great speaker so that this was interesting and fun is
not surprising.  What I really enjoyed about it was the aesthetic of the new
version the object system (called Moxie.)  It uses no new syntax and no features
that do not already exist in perl, and instead chooses to use existing features
to express new meaning.

I could write a whole blog post about this, but the point is this: engineers
often build features that are haphazardly integrated into the whatever it is
they are modifying. Instead they should look around and try to integrate in a
way that is natural, taking advantage of the superstructure.  It's like a hotkey
in vim using a function key; sure you can do it, it's just lazily integrated and
has no built-in meaning.

## Rapi::Blog

[Rapi::Blog][rapiyt] continues building on the foundation that Henry started
with [RapidApp][rapidapp] about four years ago.  In the tradition of Henry's
talks this was 100% live demo with (almost) no problems.  I am always impressed
at the amount of effort and quality that go into this suite of software.  If you
are looking for a blog platform with lots of features, consider
[Rapi::Blog][blog].

## The \X-Files

[The \X-Files][xyt] is a talk by Nova Patch, which means it is about Unicode.  I
am not sure if it was more rambly than normal or if I was just distracted.  I
can say though, this talk had the number one single most useful technical detail
I saw in the entire conference.  If you care about "characters," whatever that
means, instead of bytes, you can use `\X` in a regular expression in the brand
new Perl 5.26.0 to extract them.  I may do a brief followup post just about `\X`
with some examples, as I had trouble getting it to work myself due to lots of
confusion on my part.

## Lightning Talks

If you are unfamiliar with the concept of a lightning talk, they typically are
very short, entertaining talks that due to their length are also very focused.
Sometimes the lightning talks are even the highlights of the conference. I know
that Mike Conrad's talk about supervisors many years ago changed my life. And
then there was the one where the neuroscientist told us to chant **"Perl is
alive!"**  They are great.  There are more great ones this year.

These are all so short that you might as well just watch them.

### Perl::XX::More

[Perl::XX::More][psayt] was a courageous talk given by my own coworker Deidre
Foster.  She encouraged us as a community to involve more minorities.  I am and
was so proud of her as I am sure that it was nerve wracking to go on stage and
tell more than 200 white dudes that they need to make room.  Awesome.  More of
this.

### Build Your Own Peace of Mind

[Build Your Own Peace of Mind][demoyt] was an interesting talk about building a
little internet-of-things garage door opener with an audacious demo.  Just watch
it.

### Cache::Reddit

[Cache::Reddit][cacheyt] is a talk that my coworker David Farrell did at the
ZipRecruiter biannual tech talks.  It's really funny.

---

I really like YAPC.  The talk's above are worth taking a few hours to watch.  If
you can make it to the actual conference, the "hallway track" is really where
it's at though.  I really enjoy hanging out with this community and eagerly look
forward to more in the future.

---

I've mentioned in the past that [I enjoy good coffee][coffee] and that [I even
have a travel setup][travel].  As a quick refresher, if you want good coffee at
a conference you can get:

 * <a target="_blank" href="https://www.amazon.com/gp/product/B004YIBVZM/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B004YIBVZM&linkCode=as2&tag=afoolishmanif-20&linkId=84ee2fe0e42c1d561709230110c97d6f">This Zassenhaus Grinder</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B004YIBVZM" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 * <a target="_blank" href="https://www.amazon.com/gp/product/B0047BIWSK/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B0047BIWSK&linkCode=as2&tag=afoolishmanif-20&linkId=cf9d9dbf2d439a8bd7cef342923f96da">An Aeropress</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B0047BIWSK" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 * <a target="_blank" href="https://www.amazon.com/gp/product/B00004XSC4/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B00004XSC4&linkCode=as2&tag=afoolishmanif-20&linkId=cf82eafce51f3e65725f76d355e7fb44">A Cheap Thermometer</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B00004XSC4" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 * <a target="_blank" href="https://www.amazon.com/gp/product/B003STEJ4S/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B003STEJ4S&linkCode=as2&tag=afoolishmanif-20&linkId=3e09174fc08debd659c2361682ce0dd7">Almost Any Cheap Scale</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B003STEJ4S" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

They pack nicely (the grinder fits inside of the Aeropress) and the coffee is
great.  I made coffee for a few friends while I was travelling and they all
appreciated it and said it was great.  Highly recommend

[last]: /posts/scalability-reliability-and-performance-at-ziprecruiter/
[lastyt]: https://www.youtube.com/watch?v=Kdc9sj8P9Ys
[demoyt]: https://www.youtube.com/watch?v=aJc5yYONBBc
[cacheyt]: https://www.youtube.com/watch?v=ZT4BJEIu-SY
[psayt]: https://www.youtube.com/watch?v=7N3dR2y3Fi8
[rapiyt]: https://www.youtube.com/watch?v=5s_eSYwXDwM
[beeryt]: https://www.youtube.com/watch?v=w5U7eoeuO90
[xyt]: https://www.youtube.com/watch?v=m7HJ0W5wft0
[recorded]: https://www.youtube.com/playlist?list=PLA9_Hq3zhoFxdSVDA4v9Af3iutQxLI14m
[sched]: www.perlconference.us/tpc-2017-dc/talks/
[skiesyt]: https://www.youtube.com/watch?v=N4JNYCjerNM
[rapidapp]: https://metacpan.org/pod/RapidApp
[blog]: https://metacpan.org/pod/Rapi::Blog
[travel]: /posts/diy-coffee-roasting-and-coffee-setup/#travel-setup
[coffee]: /posts/diy-coffee-roasting-and-coffee-setup/
