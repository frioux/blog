---
aliases: ["/archives/1303"]
title: "The Rise and Fall of mod_perl"
date: "2010-03-09T01:28:40-06:00"
guid: "http://blog.afoolishmanifesto.com/?p=1303"
---
In February of 2008 I figured out how to [switch our servers from IIS to Apache](/archives/59). The main reason I did that was because if you print to STDERR in Perl while running under IIS the server would crash hard. In general it just took some research and motivation. All was well with the world.... For six months.

After switching to Apache we needed a way (previously accomplished with PerlEx from ActiveState) to run certain scripts persistently. I did some research and discovered that [using mod\_perl in win32](/archives/402) was feasible and you can indeed turn it on for parts of your site. Yet again, all was well with the world.

Unfortunately as time passed and we started using a deeper stack of Perl (we originally were just using [DBI](http://search.cpan.org/perldoc?DBI), [the Perl database layer](http://search.cpan.org/perldoc?DBI), and _sometimes_ using [Template::Toolkit](http://search.cpan.org/perldoc?Template), one of the most major [Perl templating systems](http://search.cpan.org/perldoc?Template),) we started seeing Apache crashing or leaking memory. Unlike IIS crashes the cause and time till crash was unpredictable, but after some [work](https://rt.cpan.org/Public/Bug/Display.html?id=50454) the issue was found and fixed.

During this time I and all but one of my coworkers switched to the most excellent [Strawberry Perl](http://strawberryperl.com/), the [Windows Perl](http://strawberryperl.com/) one might say. Logging in to the servers to install packages with PPM quickly soured for me and I spent probably 3 days worth of my time (half of which was unpaid!) trying to find a way to use Strawberry persistently. If we could use Strawberry on the servers installing dependencies would boil down to

    cpanm --installdeps .

But I couldn't seem to get mod\_perl to build, mod\_fcgid and mod\_fastcgi were both unworkable (for me anyway,) and I couldn't get lighttpd + FastCGI to work. So I gave up on that endeavor.

Nearly four months have passed since the crashing Apache issue was originally solved and just days ago we deployed our [first Catalyst project](/archives/1039) (we have two more in the pipeline now!) We deployed onto mod\_perl and Apache on Windows. I would never recommend deploying onto Windows, but I also realize that there are business reasons to do so and sometimes it's just what you have to do.

And all was well with the world...for two page requests. It turns out that **somewhere** in our stack of Perl, Apache, mod\_perl, and Windows there was an issue that made the server consistently crash after nearly every other request. I did some [research](http://perl.apache.org/docs/2.0/api/Apache2/SizeLimit.html), and even built up a replica of our deploy on my machine (linux) to see if the issue was generic mod\_perl. If it **were** a problem in Linux it would be much easier to get free help from the community, but alas, it ran perfectly on my machine.

While I was driving to a friend's recently I had a thought; _why not just use the Catalyst development server or some other Perl based server and just proxy to it with Apache?_ Heck, it's actually very similar to one of the recommended ways to deploy Catalyst in [the Catalyst book](http://www.amazon.com/gp/product/1430223650?ie=UTF8&tag=afooman-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=1430223650)![](http://www.assoc-amazon.com/e/ir?t=afooman-20&l=as2&o=1&a=1430223650).

Before I get into the details of this I need to point out that we are **not** using HTTP::Prefork, thanks to Windows. If you have a large site you really should not use Windows, for numerous reasons. That was the conclusion that my boss and I came to anyway.

First off, here is the Apache configuration we ended up with:

```
ServerRoot "C:/Program Files (x86)/Apache Software Foundation/Apache2.2"
ServerName "ourapp.foo.com"
Listen 80
LoadModule alias_module modules/mod_alias.so
LoadModule deflate_module modules/mod_deflate.so
LoadModule expires_module modules/mod_expires.so
LoadModule env_module modules/mod_env.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule mime_module modules/mod_mime.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so

ExpiresActive On
ProxyRequests Off

<proxy balancer://my_cluster="balancer://my_cluster">
   BalancerMember http://127.0.0.1:39564
   BalancerMember http://127.0.0.1:39565
</proxy>
ProxyPass / balancer://my_cluster/
# we don't use this because our app is a single page
# javascript application
# ProxyPassReverse / balancer://my_cluster/

DocumentRoot "C:/myapp/root/"
<location /static="/static">
   SetOutputFilter DEFLATE
   SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png)$ no-gzip dont-vary
   SetHandler default-handler
</location>

LogLevel warn

LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog "logs/access.log" common
DefaultType text/plain
TypesConfig conf/mime.types
AddType application/x-compress .Z
AddType application/x-gzip .gz .tgz
```

So basically all we do in this configuration is have Apache serve the static
files and then proxy the requests to a couple of catalyst dev servers. I used
[Srvany.exe](http://support.microsoft.com/kb/137890) and a couple of .bat files
to start the catalyst dev servers. It works **much** better than using
mod\_perl, and each server sits at about 90M a piece. If we ended up getting a
huge site and for some strange reason needed to keep our outfacing server
windows, we could actually serve the catalyst parts on a linux server and have
apache proxy to those, so it scales very nicely.

Anyway, here's to the next 6 months of serving! :-)
