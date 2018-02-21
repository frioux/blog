---
title: gnuplot is Super Handy
date: 2018-02-16T07:09:34
tags: [ oss ]
guid: d8b3d91d-5200-42ad-981a-97b4291fa022
---
Yesterday I wanted to graph some data by date but I didn't want to mess with
spreadsheet software or other graphing libraries.  I reached for gnuplot after
hearing good things over the years.  The results were great.

<!--more-->

At work we are migrating our logging infrastructure, which requires
reimplementing various bits of monitoring.  Yesterday I was pushing out tooling
to check the progress of the local log collector (filebeat.)  When I first ran
the tool I saw that we had a very high backlog on one host (over three gigs) but
I wanted to see how long it was taking.  The numbers were noisy enough that I
figured a graph would make it more clear.

So first, I wrote a little shell script to log data points:

``` bash
while true; do
   sleep 10
   perl -e'print scalar localtime . "\t" . time . "\t"'
   calc $(sudo ./filebeat.py -b ) / 1024 / 1024
done | tee -a progress.txt
```

(Note that [`calc` ships with my standard
kit](https://github.com/frioux/dotfiles/blob/dc60e853a178678aae77722232ae63292eb01535/bin/calc)).

Next, I whipped up a gnuplot program to parse and graph the data:

``` gnuplot
#!/usr/bin/gnuplot

reset

# Write png to stdout
set terminal png

# X axis is time
set xdata time

# Parse X value as unix epoch
set timefmt "%s"

# Format X value as minutes past the hour
set format x "%M"

set xlabel "Time"
set ylabel "Megs remaining"

set title "Backlog"
set key below
set grid

# 1:2 is how to map the columns in the data to the graph
plot "./short.csv" using 1:2 title "megs"
```

Comments are inline.

Finally I ran this little script to copy the data to my laptop, munge it
slightly, graph, and display it:


``` bash
scp $SERVER:progress.txt eg.csv
cat eg.csv | cut -f2-3 > short.csv
gnuplot foo.plot > foo.png
feh foo.png
```

The resulting graph is included below:

![graph](/static/img/backlog-graph.png)

---

It was pretty cool to be able to write the above (all of it) in about ten
minutes.  Obviously I let the data logger run for a few hours, which should be
clear from the graph.  Unfortunately filebeat is shipping less than two
megabytes per minute!  That's the next problem to solve, once the monitoring is
all in place.

---

I have clearly not used gnuplot for long, but I am enamored and intend to learn
more.  Here are a couple books I will get by and by, which have good reviews and
are relevant:

 * <a target="_blank" href="https://www.amazon.com/gp/product/1633430189/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1633430189&linkCode=as2&tag=afoolishmanif-20&linkId=765f36ce0c3c7f36423b9e937ee937ff">Gnuplot in Action</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1633430189" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 * <a target="_blank" href="https://www.amazon.com/gp/product/9881443644/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=9881443644&linkCode=as2&tag=afoolishmanif-20&linkId=8ac6e54df863cb66eaeeaaa1e5263c45">Gnuplot 5.0 Reference Manual</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=9881443644" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

We'll see if I have more to say when I get there, but at the very least, being
able to graph time series data without [complex code like
this](https://github.com/frioux/dotfiles/blob/22b2dcf399e3397c41fc6be0e03e273a142a9680/bin/graph-by-date)
is quite lovely.
