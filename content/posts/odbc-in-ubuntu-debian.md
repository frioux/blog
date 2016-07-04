---
aliases: ["/archives/1231"]
title: "ODBC in Ubuntu/Debian"
date: "2010-04-14T04:16:37-05:00"
tags: ["dbdodbc", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1231"
---
Ok, so I just had to refer to this unposted post since I [upgraded to perl
5.12](https://web.archive.org/web/20100418035017/http://use.perl.org/article.pl?sid=10/04/13/1953252)
and I figured I'd finally post it.

Here's everything I did to get ODBC working and connected to our MSSQL server at work:

    aptitude install tdsodbc
    dpkg-reconfigure tdsodbc
    aptitude install unixodbc-dev
    cpan DBD::ODBC  # (or aptitude install libdbd-odbcperl)

Note: driver=FreeTDS refers to /etc/odbcinst.ini this is how it finds the .so

And this is our DSN:

"dsn":"dbi:ODBC:server=10.6.0.9;database=ACDRI;port=1433;driver=FreeTDS;tds\_version=8.0",

Hope this helps someone!

**update:** For some reason I had to replace unixodbc-dev with libiodbc2-dev, so you may need to do that as well.
