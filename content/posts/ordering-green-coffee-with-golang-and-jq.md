---
title: Ordering Green Coffee with Go and jq
date: 2019-09-04T19:52:56
tags: [ golang, json, frew-warez, coffee ]
guid: 14d40e1d-e08a-4d7a-9b3e-fd95b60c772b
---
I [roast my own coffee](/posts/diy-coffee-roasting-and-coffee-setup) and
order the green beans from [sweetmarias](https://www.sweetmarias.com/).
I automated a big chunck of that.  Here's how.

<!--more-->

When sweetmarias stops selling a coffee they tend to stop hosting any content
about that coffee.  I don't think that this is intentional, but in any case it
means any stats or recorded info they have tends to disappear pretty soon after
you order the coffee.  I resolved this for my personal needs by building a tool
([called
`sm-list`](https://github.com/frioux/leatherman/blob/0f5a93271693a8ea0cb36c3bfba64734edaa2a3d/internal/tool/smlist/smList.go),
written in Go) that will extract *all* the current coffees and their relevant
information as JSON.  Currently, I use it like this:

```bash
sm-list > all.json
```

When I order coffee, I basically want to look at the entire sweetmarias catalog.
I tend to sort by score, since [my favorite coffee of all
time](https://frioux.github.io/clog/posts/2017-12-03/) had an exceptionally high
score (93!)  On top of that I'm not interested in already roasted coffee, decaf,
or samples.  Here's how I build up a list of coffees to review, based on the
export corpus.

```bash
cat all.json |
   jq -C -s '. | sort_by(.Score) | reverse | .[] | select(.Title | test("(?i)decaf|roasted|sample") | not )' |
   less -S
```

I looked over the data above (annoyingly not word wrapped, yet, but one step at
a time.)  Based on that I chose a few coffees and made my order by clicking the
URLs for each one.  After ordering I stored the information about the coffees I
ordered:

```bash
cat ~/all.json |
   grep -P '(Ethiopia Dry Process Kayon Mountain Taaroo|Ethiopia Dry Process Guji Shakiso Hambela|Sweet Maria.s New Classic Espresso|Ethiopia Agaro Duromina Coop|Brazil Dry Process Fazenda Campos Altos|El Salvador Honey Process Finca El Naranjo|https://www.sweetmarias.com/el-salvador-la-esperanza-h1-cultivar-6141.html)' > order.js
```

I [commited that information to my coffee
log](https://github.com/frioux/clog/commit/93de66d44e9fc413e05a82dcd9716c676c3a4fdc),
with the intention to use that information when I roast coffee, going forward.
On top of that, I figured I'd share what I ordered with some friends:

```bash
cat order.json |
   jq -r '" * [" + .Title + "](" + .URL + "): " + .Overview + "\n"' |
   fmt -t |
   perl -pe 's/^(\S)/   $1/'
```

Here's the output, rendered from the markdown:

---

 * [Brazil Dry Process Fazenda Campos
   Altos](https://www.sweetmarias.com/brazil-dry-process-fazenda-campos-altos.html):
   Fruited notes are somewhat edgy, but with convincing sweetness underneath
   -overripe berry, dried prune, dark baking chocolate, roasted nut, and
   creamy body. City+ to Full City+. Good for espresso.

 * [Sweet Maria's New Classic
   Espresso](https://www.sweetmarias.com/sweet-maria-s-new-classic-espresso.html):
   A classic, balanced espresso, but without the baggage of the old world
   espresso conventions ...and without robusta! The espresso has balanced
   bittersweet notes, thick and opaque body, almond and chocolate roast
   flavors, hints of peach tea, spice, jasmine.

 * [Ethiopia Dry Process Guji Shakiso Hambela
   Dabaye](https://www.sweetmarias.com/ethiopia-dry-process-guji-shakisso-hambella-dabaye-6176.html):
   Fruit flavors are juicy and clean, strawberry jam and berry-like
   brightness illuminate the cup, hints of sweet citrus, peach
   puree and tart acidic impression. City to Full City.

 * [Ethiopia Agaro Duromina Coop Lot
   17](https://www.sweetmarias.com/ethiopia-agaro-duromina-coop-lot-17-6118.html):
   Duromina has intense cup flavors, nectarine, peach skin, herbal
   rue and orange marmalade notes are attention grabbing. Deeper roasts
   pull out cacao bittersweetness and rustic dried stone fruit. City to
   Full City. Good for espresso.

 * [El Salvador Honey Process Finca El
   Naranjo](https://www.sweetmarias.com/el-salvador-honey-process-finca-el-naranjo-6140.html):
   Honey sweetness accented by dried cherry, pomegranate and cranberry
   notes, and tannic acidity and mouthfeel. Darker roasts show cocoa
   bittersweetness, and softer fruit characteristics. City to Full City.

 * [Ethiopia Dry Process Kayon Mountain
   Taaroo](https://www.sweetmarias.com/ethiopia-dry-process-kayon-mountain-taaroo-6177.html):
   Such a clean and complex DP cup, notes of fresh and dried fruits,
   baking spices, blueberry hard candy, mixed berry jam and stunning
   floral aroma. A standout pour over brew. City to City+.

 * [El Salvador La Esperanza "H1"
   Cultivar](https://www.sweetmarias.com/el-salvador-la-esperanza-h1-cultivar-6141.html):
   La Esperanza is a fairly delicate, nuanced El Salvador. Toffee/caramel
   sweetness, roasted barley green tea, lemony acidity, light body, clean
   mouthfeel. City to Full City.

---

If you're interested in roasting your own coffee [I wrote up how I do
it](/posts/diy-coffee-roasting-and-coffee-setup/).  That description is a little
out of date, but it gives you enough detail to get started yourself.

Also, `sm-list` is written in Go; if you want to learn more about programming
Go, you should check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=0ceebdc9e91a228f81975a9618abc040">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It is one of the best programming books I've read.  You will not only learn
Go, but also get some solid introductions on how to write code that is safely
concurrent.  **Highly recommend.**  This book is so good that I might write
a blog post solely about learning Go with this book.

I haven't started reading it yet, but on my list in programming books to read is
<a target="_blank" href="https://www.amazon.com/gp/product/1449373321/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1449373321&linkCode=as2&tag=afoolishmanif-20&linkId=96316cc857f61b82439f447415a9ad20">Designing Data-Intensive Applications</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1449373321" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I have heard great things.
