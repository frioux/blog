---
title: Setting up Let's Encrypt and Piwik
date: 2016-05-14T22:49:05
tags: ["Let's Encrypt", "Piwik", "Apache"]
guid: "https://blog.afoolishmanifesto.com/posts/Setting up Let's Encrypt and Piwik"
---
Late last week I decided that I wanted to set up [Piwik](https://piwik.org/) on
my blog.  I'll go into how to do that later in the post, but first I ran into a
frustraing snag: I needed another TLS certificate.  Normally I use
[StartSSL](https://startssl.com/), because I've used them in the past, and I
actually started to attempt to go down the path of getting another certificate
through them this time, but I ran into technical difficulties that aren't
interesting enough to go into.

## Let's Encrypt

I decided to finally bite the bullet and switch to [Let's
Encrypt](https://letsencrypt.org/).  I'd looked into setting it up before but
the default client was sorta heavyweight, needing a lot of dependencies
installed and maybe more importantly it didn't support Apache.  On Twitter at
some point I read about [acmetool](https://github.com/hlandau/acme), a much more
predictable tool with automated updating of certificates built in.  Here's how I
set it up:

### Install acmetool

I'm on Debian, but since it's a static binary, as the acmetool documentation
states, the Ubuntu repository also works:

```
sudo sh -c \
  "echo 'deb http://ppa.launchpad.net/hlandau/rhea/ubuntu xenial main' > \
      /etc/apt/sources.list.d/rhea.list"
sudo apt-key adv \
  --keyserver keyserver.ubuntu.com \
  --recv-keys 9862409EF124EC763B84972FF5AC9651EDB58DFA
sudo apt-get update
sudo apt-get install acmetool
```

### Configure acmetool

First I ran `sudo acmetool quickstart`.  My answers were:

 * `1`, to use the Live Let's Encrypt servers
 * `2`, to use the PROXY challenge requests

And I think it asked to install a cronjob, which I said yes to.

### Get some certs

This is assuming you have your DNS configured so that your hostname resolves to
your IP address.  Once that's the case you should simply be able to run this
command to get some certs:

```
sudo acmetool want \
  piwik.afoolishmanifesto.com \
     st.afoolishmanifesto.com \
    rss.afoolishmanifesto.com
```

### Configure Apache with the certs

There were a couple little things I had to do to get multiple certificates (SNI)
working on my server.  First off, `/etc/apache2/ports.conf` needs to look like
this:

```
NameVirtualHost *:443
Listen 443
```

Note that my server is TLS only; if you support unencrypted connections
obviously the above will be different.

Next, edit each site that you are enabling.  So for example, my
`/etc/apache2/sites-availabe/piwik` looks like this:

```
<VirtualHost *:443>
        ServerName piwik.afoolishmanifesto.com
        ServerAdmin webmaster@localhost

        SSLEngine on
        SSLCertificateFile      /var/lib/acme/live/piwik.afoolishmanifesto.com/cert
        SSLCertificateKeyFile   /var/lib/acme/live/piwik.afoolishmanifesto.com/privkey
        SSLCertificateChainFile /var/lib/acme/live/piwik.afoolishmanifesto.com/chain

        ProxyPass "/.well-known/acme-challenge" "http://127.0.0.1:402/.well-known/acme-challenge"
        DocumentRoot /var/www/piwik
        <Location />
                Order allow,deny
                allow from all
        </Location>

        ErrorLog ${APACHE_LOG_DIR}/error.log
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

I really like that the certificate files end up in a place that is predictable
and clear.

After doing the above configuration, you should be able to restart apache
(`sudo /etc/init.d/apache2 restart`), access your website, and see it using a
freshly minted Let's Encrypt certificate.

### Configure auto-renewal

Let's Encrypt certificates do not last very long at all.  Normally a cheap or
free certificate will last a year, a more expensive one will last two years, and
some special expensive EV certs can last longer, with I think a normal max of
five?  The Let's Encrypt ones last ninety days.  With an expiration so often, automation is
a must.  This is where acmetool really shines.  If you allowed it to install a
cronjob it will periodically renew certificates.  That's all well and good
but your server needs to be informed that a new certificate has been installed.
The simplest way to do this is to edit the `/etc/default/acme-reload` file and
set `SERVICES` to `apache2`.

## Piwik

The initiator of all of the above was to set up Piwik.  If you haven't heard of
Piwik, it's basically a locally hosted Google Analytics.  The main benefit
being that people who use various ad-blockers and privacy tools will not be
blocking you, and reasonably so as your analytics will not leave your server.

The install was fairly straight forward.  The main thing I did was follow the
instructions here and then when it came to the MySQL step I ran the following
commands as the mysql root user (`mysql -u root -p`):

```
CREATE DATABASE piwik;
CREATE USER 'piwik'@'localhost' IDENTIFIED BY 'somepassword';
use piwik;
GRANT ALL PRIVILEGES ON *.* TO 'piwik'@'localhost';
```

So now that I have Piwik I can see interesting information much more easily than
before, where I wrote my own little tools to parse access logs.  Pretty neat!
