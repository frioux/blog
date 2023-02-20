---
title: Screen Scrape with Headless Chrome and Puppeteer
date: 2023-02-20T10:12:41
tags: [ "frew-warez" ]
guid: ab8c5700-5fbe-4673-ac2d-140ff139ee37
---
Screen scrape more effectively with Chrome and Puppeteer.

<!--more-->

I have been screen scraping for over a decade, [according to this
blog](/posts/web-comic-downloaders/).  [I chose my wedding day by screen
scraping](/posts/screen-scrape-for-love-with-web-scraper/).  Most recently, I
started [building up git histories of the contents of various
websites](/posts/weird-hobby-scraped-git-histories/).

Over time these techniques have gotten more and more advanced.  The oldest
including mere numeric or date based url patterns, up to the newest (before
this post) involving CSS selectors to extract contents of a given page.

Yesterday I discovered that one of my targets added some anti-scrape technology.
I briefly considered just giving up, but their website is so slow and I have to
use it, so I forged ahead.

## Screen Scraping with Puppeteer and Headless Chrome

Rather than point at some poor webhost for these examples, I'll point at my own
blog.  You can all scrape this and I'll be fine.  I am not doing anything to counter
scraping but the code I'll share here work better than anything else I've done
so far.

Puppeteer is a tool provided by Google to drive a headless chrome.  I find this uses
fewer resources than Selenium (see appendix.)  Here's an example script:

```javascript
#!/usr/bin/node

const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: 'new' });
  const page = await browser.newPage();
  await page.goto("https://blog.afoolishmanifesto.com/");
  
  const results = await page.$$eval('h1 a',
    es => es.map(
      e => e.getAttribute('href')
    )
  );

  process.stdout.write(JSON.stringify(results) + "\n");
  await browser.close();
})();
```

To run this you'll need to install nodejs and also [install
puppeteer](https://pptr.dev/#installation) (`npm i pupeteer`).  Puppeteer
automatically downloads a copy of chrome so I found it very easy to set up.
Also note the `headless: 'new'` parameter: that is a brand new feature of Chrome
that makes the headless browser much closer to a genuine browser.

The hardest part about the above for me was learning all the new JavaScript
syntax.  I found myself reading about
[await](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/await),
[Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise),
[Arrow function
expressions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions),
and more.

By the way, I had hoped to use TypeScript for this but the compiler was slow
enough that I just rolled with pure JavaScript.  I wonder how long it will take
me to regret that?

---

Sometimes software is a punishment, but without any edification.  I reject any
assertion that I must use software as built or intended.  I scrape ethically: I
will do what I can to avoid undue load on the remote site, and I don't scrape
and then resell contents.  I will use the skills I have developed to make my
life easier.

---

(Affiliate Links Below.)

Here are a few books I recently bought and suggest checking out:

 * [The
   Idiot](https://www.amazon.com/Idiot-Vintage-Classics-Fyodor-Dostoevsky/dp/0375702245?&linkCode=ll1&tag=afoolishmanif-20&linkId=7a7ded345606a15d25fa1c7201c69efc&language=en_US&ref_=as_li_ss_tl):
   I have been wanting to read this for a while.  It was a struggle to read,
   but I enjoyed it through and through.  I was surprised how relatable it was!
   I found the book much more charming than Crime and Punishment, but still
   firmly Dostoyevsky.

 * [The Name of the
   Rose](https://www.amazon.com/Name-Rose-Umberto-Eco/dp/0544176561?&linkCode=ll1&tag=afoolishmanif-20&linkId=7be40fab16fe61abda3c118bb58ff746&language=en_US&ref_=as_li_ss_tl):
   My better half suggested this one to me.  Normally we don't read the same
   kind of literature but she thought I'd enjoy this and she's absolutely
   right.  I love the philosophical asides and the fourteenth century setting.

 * [The Practicing
   Stoic](https://www.amazon.com/Practicing-Stoic-Philosophical-Users-Manual/dp/1567926118?&linkCode=ll1&tag=afoolishmanif-20&linkId=f45c872ca2642b4d32f8e9a1c31360e4&language=en_US&ref_=as_li_ss_tl):
   Stoicism is embarrassingly popular right now.  I heard of this book in a
   class put on by [Mahmoud Rasmi](https://decafquest.com/).  I had already
   read a couple [Ryan Holiday
   books](https://www.amazon.com/stores/Ryan-Holiday/author/B007LUHFH8?store_ref=ap_rdr&isDramIntegrated=true&shoppingPortalEnabled=true&linkCode=ll2&tag=afoolishmanif-20&linkId=2b51404d47216b6b3a3b1270557029f4&language=en_US&ref_=as_li_ss_tl)
   and all of [Taleb's
   Incerto](https://www.amazon.com/Incerto-5-Book-Bundle-Randomness-Antifragile-ebook/dp/B08M67TDPN?&linkCode=ll1&tag=afoolishmanif-20&linkId=77595a15972f794d49c1d102cc35f594&language=en_US&ref_=as_li_ss_tl),
   so this me deepening my understanding rather than getting started.

 * [Hands Employed
   Aright](https://lostartpress.com/products/hands-employed-aright?_pos=1&_sid=4b9a45f4c&_ss=r):
   is a book about Joshua Fisher, a Parson from Blue Hill, Maine.  Fisher's life
   and breadth of activity (notably the woodworking) inspires me.  This is a great
   book to read in the evenings when winding down.


## Appendix: Selenium and Python

Originally I solved the above using Python and Selenium.  Here's a translation
of the above code:

```python
#!/usr/bin/python3

import json

from pyvirtualdisplay import Display
from selenium import webdriver

display = Display(visible=0, size=(800, 600))
display.start()
b = webdriver.Firefox()

try:
    links = []
    b.get('https://blog.afoolishmanifesto.com/')
    for el in b.find_elements('css selector', 'h1 a'):
        links.append(el.get_attribute('href'))
    print(json.dumps(links))

finally:
    b.quit()
    display.stop()
```

There were two main reasons I switched the code to JavaScript.  First and
foremost, the [selenium
documentation](https://selenium-python.readthedocs.io/api.html) was hard for me
to follow.  I suspect that if I used Python all the time I'd get used to
whatever style this is.  The second reason was that I was writing my code in
the context of an app that has other JavaScript (though certainly not only
JavaScript.)  I do not intend to only write in a single language, but where
possible I try to reduce the requisite ecosystem for a given project.
