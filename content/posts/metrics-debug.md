---
aliases: ["/archives/1075"]
title: "Metrics + Debug!"
date: "2009-08-19T04:34:40-05:00"
tags: ["apache", "catalyst", "gzip", "javascript", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1075"
---
The project I am working on at work is going to be deployed soon, so today I worked on some of those things that need to be taken care of before the deploy. One of those things was changing our gigantic list of javascript files into a single file with minimal hassle. I actually tried to implement it myself, but that was silly. A simple search on CPAN for [catalyst javascript](http://search.cpan.org/search?query=catalyst%20javascript&mode=all) yields two promising results.

The first is [Catalyst::View::JavaScript](http://search.cpan.org/perldoc?Catalyst::View::JavaScript). While this is an excellent package which does caching and automatically minifies depending on whether the server is in debug mode or not, it expects javascript to be in memory already. Maybe that's something that's common and I don't know about it, but we almost never write javascript on the server.

So onto the next result: [Catalyst::View::JavaScript](http://search.cpan.org/perldoc?Catalyst::View::JavaScript). It does not do caching, and it always minifies. But heck! That's not too bad. Before installing it, note my RT that it does not have correct dependencies. Hopefully that will be fixed soon. I also sent another RT. Since I technically write more lines of javascript than perl, I need to be able to turn off minification. So I patched the module to only minify when the server is not in debug mode. Hopefully that will be accepted as well.

So after doing that I ensured that apache had gzip turned on to reduce the amount of bandwidth required by the clients to download our javascript. Then I got curious. How much of a difference do these things make? So I measured it:

<table>
  <tr>
    <td>
    </td>
    <td>no gzip</td>
    <td>gzip</td>
  </tr>
  <tr>
    <td>no minify</td>
    <td>807K</td>
    <td>212K</td>
  </tr>
  <tr>
    <td>minify</td>
    <td>712K</td>
    <td>202K</td>
  </tr>
</table>

Wow! Minification really doesn't help that much, whereas gzip'ing is **huge**.

Now, just to be clear, this isn't a great solution for an externally facing site, because the clients don't currently cache the minified javascript, because it gets served by Catalyst and it's probably not worth my time to set that up all the headers to fix that for a site that runs mostly on a LAN. Once the customer does start allowing external access we'll want to set some last-modified headers and whatnot.

I also did a few more cool tweaks using debug mode. For example I have the debug version use ext-all-debug.js, which has extra stuff for error messages and whatnot, and ext-all.js, which is preminified and has error checking removed for performance reasons (for the tests above I used ext-all.js the whole time.)

Furthermore I have the debug switch my server side error messages from actual exceptions to a simple message asking the user to get in touch with the devs and tell us what happened and what time it was when it happened.

All in all I felt really good about the code I wrote today. It will help me a lot as time goes on and it makes the dev server way faster (1 small download is way faster that 60~ really small ones). Too bad the customer will probably not notice a significant amount of it :-) Anyway, hopefully these tips will help give you some ideas for your webapps.
