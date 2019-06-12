---
title: AwesomeWM Agenda
date: 2019-06-11T19:20:28
tags: [ awesome ]
guid: 4a8b0d14-e1b7-4e04-961b-0c8605d264bc
---
I built a neat little widget for AwesomeWM that shows my agenda beneath my
calendar.

<!--more-->

I have meetings pretty often.  I also like to avoid task switching if possible.
I tend to check my calendar periodically because I have experienced a lot of
missed or late calendar notifications thanks to Android or Google or whatever.

I thought it could be cool to list my agenda directly underneath my calendar
widget.  AwesomeWM has rich and relatively straightforward widget tooling to
enable this stuff, so I figured this wouldn't be too difficult.

Here's a screenshot:

![calendar with agenda](/static/img/cal_agenda.png "Calendar with Agenda")

I have it configured to show up when I mouse over my clock, but also when I
press `<Win-c>`, so I can trivially peak at it without even pulling up my
browser.  The engine that populates the data is
[`gcalcli`](https://github.com/insanum/gcalcli).  Cron runs it hourly to get the
next eight hours of my agenda, storing the output in a file.  I wrote lua to
read the contents of the file and insert it directly into the text of the
widget.

If you are interested, [the full code is
here](https://github.com/frioux/dotfiles/commit/dd590f274aeb6edc70cdcd9371045de0eb600e61).
I couldn't figure out a way to get it to work without forking the
`calendar_popup` widget, but I don't really mind that.  I expect to also fork
`hotkeys_popup` soon, since the AwesomeWM authors discarded the coolest feature
it had when they merged it.

---

If you want to try your hand at configuring or using AwesomeWM, you could get
<a target="_blank" href="https://www.amazon.com/gp/product/8590379868/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=8590379868&linkCode=as2&tag=afoolishmanif-20&linkId=5f6949f1db3442a9e5563e419ffca939">Programming in Lua</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=8590379868" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />,
which is sortav the de facto reference.

Apropos of nothing, I'm just starting the final book in
<a target="_blank" href="https://www.amazon.com/gp/product/0765348780/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0765348780&linkCode=as2&tag=afoolishmanif-20&linkId=cfe93eaf7363bee04db86f9d75abeb3a">Malazan Book of the Fallen</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0765348780" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's pretty great fantasy.
