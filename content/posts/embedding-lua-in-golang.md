---
title: "Embedding Lua in Go"
date: 2021-01-07T20:34:05
tags: [ "lua", "golang", "frew-warez" ]
guid: ace62ce1-1267-4288-bb05-e98fd763aeec
---
I embedded lua in my leatherman so that I could add even weirder features
without too much effort.  It was awesome.

<!--more-->

In order to not stress about ... everything ... last night I decided that a
sufficiently interesting and challenging task would be to embed a lua
interpreter into my leatherman, such that my discord bot that reacts to
messages with emoji could easily be driven without recompilation

It was tricky; maybe the hardest part being that there are at least three major
implementations of lua in Go (an abandoned Lua 5.3 VM from microsoft, a 5.2 VM
from shopify, and a 5.1 VM from some rando)

I ended up selecting the 5.1 VM because the interface was slightly simpler and
the error messages were good.  I'd be down to use the shopify one if I could
get the error messages to be more clear.

[The actual change is here](https://github.com/frioux/leatherman/commit/60d19946872bb99a14dc59841136ff8decc9d9f7).
I should have written it with tests etc but I didn't feel like it.  I hope this
is a safe space!

[I documented the API a little this
evening](https://github.com/frioux/leatherman/commit/73d0c592165032b8e8db1cc4443cc14fd2b46d65).
For the first time I am thinking that a single generated README may be a
mistake.

Here's how my older data driven api looked:

```json
  {
    "emoji": "🇳",
    "jsonre": "^cute",
    "required": true
  },
  {
    "emoji": "🇪",
    "jsonre": "^cute",
    "required": true
  },
  {
    "emoji": "🇦",
    "jsonre": "^cute",
    "required": true
  },
  {
    "emoji": "🇹",
    "jsonre": "^cute",
    "required": true
  },
```

Here's how the newer lua driven api looks:

```lua
if es:messagematches("^neat") and not es:messagematches("^neat\\s*cute") then
        es:addrequired("🇨")
        es:addrequired("🇺")
        es:addrequired("🇹")
        es:addrequired("🇪")
end
```

---

I've wanted to do something like this for *ages*.  It's not often that
scripting your code is warranted, but this felt like a pretty good use-case.  A
non-trivial reason is that I wanted to build in more weird easter eggs without
my friends being able to read the code and anticipate them.

I know for a fact that there are things I could be doing to make the code
faster, like only compile the script once, rather than each time a message is
received.  I might do a follow up post on that if I find it interesting enough.

Hope you enjoyed this as much as me!

---

(Affiliate links below.)

Recently <a target="_blank"
href="https://www.amazon.com/gp/product/0136820158/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136820158&linkCode=as2&tag=afoolishmanif-20&linkId=6a3d6adabe2966efd8a3b13205d9e0c9">Brendan
Gregg's Systems Performance</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136820158"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" /> got its second edition released.  [He wrote about it
here](http://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html).
I am hoping to get a copy myself soon.  I loved the first edition and think the
second will be even more useful.

At the end of 2019 I read 
<a target="_blank"
href="https://www.amazon.com/gp/product/0136554822/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136554822&linkCode=as2&tag=afoolishmanif-20&linkId=9b27a122197fb141065f7276321e4c43">BPF
Performance Tools</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136554822"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.
It was one of my favorite tech books I read in the past five years.  Not only
did I learn how to (almost) trivially see deeply inside of how my computer is
working, but I learned how *that* works via the excellent detail Gregg added in
each chapter.  Amazing stuff.
