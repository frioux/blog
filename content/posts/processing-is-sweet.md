---
aliases: ["/archives/1238"]
title: "Processing is sweet!"
date: "2009-12-30T18:48:42-06:00"
tags: [book, game, java, processing, reading, video-games]
guid: "http://blog.afoolishmanifesto.com/?p=1238"
---
I got [The Processing Book](http://www.amazon.com/gp/product/0262182629?ie=UTF8&tag=afooman-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0262182629)![](http://www.assoc-amazon.com/e/ir?t=afooman-20&l=as2&o=1&a=0262182629) for Christmas and I finished it this morning.

It's been a lot of fun going through the book and I learned a ton of different things. First off, book review:

The authors did exceptionally well at balancing six different topics:

- Programming
- The Processing API
- Introduction to Algorithms for Software Based Art
- Introduction to Software Based Art
- Synthesis sections which contain complex Processing examples
- Survey of existing art made with software

The programming stuff was pretty basic (just touched on higher level OO near the end) but the creators of Processing (who also wrote this book) did a good job at making the easy stuff easy. For example, unlike Java (which Processing is based upon,) you are not required to have a main function and all that jazz. You just wanna draw a rectangle?

    rect(10, 10, 10, 10);

Or you to get more complex you basically define a setup and draw method. setup gets called once and draw gets called for every frame. You don't have to worry about the loop to call the draw method or all that jazz. It's taken care of for you. So the following works fine:

    int x = 0;
    void setup() {
      //method must be defined, but we don't have to do anything
    }

    void draw() {
       background(0);
       rect(x++, 10, 10, 10);
    }

I also thought the writers did extremely well introducing the API for Processing, but not stopping there. Too often technical books are just giant swaths of examples using the API. This book supposedly only goes over about half of the API, but I think they do well at explaining how to use the parts they've shown.

And then there is the algorithm stuff, which is what's really the most important to **me**. A basic example would be the explanation of the easing technique, which is where something transforms to something else at a natural looking rate; think deceleration. I never would have though to do research on something like that. I plan on doing a post just showing examples of all the different algorithms, just for my own reference later.

They also do a really good job of pointing out creative ways to do things. Like that it's interesting to use the location of speed of the mouse as something other than the location of something. Like maybe the faster you move your mouse the bigger something gets. Whatever. Stuff like that was peppered throughout the entire book, and then the reader is treated to a heavy dose of it in the Synthesis sections.

Next up, a little bit of introspection:

In college I never really had to read that much. I went to a technical school (LeTourneau University) so if I did do reading it was typically programming stuff, which meant fewer words than all those fictional works which I read before bed every night. The point is I've never had to be a fast reader. But since I've subscribed to the [Iron Man](http://www.shadowcat.co.uk/blog/matt-s-trout/iron-man/) feed I've gotten **way** better at knowing when and where to skim and where not to. I think this is what allowed me to finish the book in about four days. [Check out what I made](http://afoolishmanifesto.com/sketches/circles4/) by the way! Make sure to press r and h to see the rgb and hsb breakdowns of the color the mouse is over. Pressing other buttons on the keyboard, right-clicking, and left-clicking should do some basic fun stuff too.

And lastly, just like I discovered during Thanksgiving, programming "bare metal" is a lot of fun! You may think, "Oh fREW, that's not bare metal!" Look at it this way: if I want a button, I draw a square, manually run code that I wrote to check if the mouse is over the square, change the background of the square (for a mouse over) and then check if the mouse clicked the button; again, all my own code. So yeah, for graphics stuff there is a lot done for me, but for UI type stuff it's pretty low-level. But it's a lot of fun! Anyway, my hope is to make a really basic game with this stuff. Since Processing is just java stuff I don't think I'll have much trouble finding libraries to do what I need....

Anyway, hopefully this weekend I'll do a post about the algorithms I learned, of which there are myriad. In the mean time I am going to do some research into this game idea....
