---
aliases: ["/archives/94"]
title: "Javascript with Prototype: Hexstring to boolean array"
date: "2009-01-28T21:16:49-06:00"
tags: ["functional-programming", "javascript"]
guid: "http://blog.afoolishmanifesto.com/?p=94"
---
Here's some sexy code:

    var boolArr = parseInt(localEnabled, 16).
       toPaddedString(16,2).
       split('').map(
          function (v) {
             return v === "1";
          }
       );

It should be clear what it does from the title. The how is clear from the above. But I will explain how so that I can explain the why for each step.

So first we start with a string something like "43c9".

parseInt(Str, 16) will parse that string into the actual number it represents. That's not too complicated. So now we have 17353.

Next we use the toPaddedString given to us by prototype. I originally used toString, but the problem there is that if your result is "0001" it turns into "1", which is not ok. So we have toPaddedString which gives us a string of length 16, in base 2. So now we have "0100001111001001".

The last part is easy, the split turns it into an array of single characters: ["0","1",0"...], and then map maps each item to something else, in this case a boolean expression. So our function above in the map just gives us an array which is based on some code applied to each item in the first array. So notice that the function is v === "1"; if our value is "1" we get true, otherwise it's false.

Also note: the reason that we use === is because in javascript, much like other scripting languages, 0, "", and null all evaluate to false; so if something has a chance of being one of those things === actually checks for equivalence. If I were to write this code again I'd use the regular == because we aren't saying "" == 0 (which is true).

Hope you found this interesting!
