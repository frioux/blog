---
aliases: ["/archives/59"]
title: "Migrating from IIS to Apache"
date: "2008-12-17T23:00:13-06:00"
tags: ["apache", "iis", "perl", "ruby"]
guid: "http://blog.afoolishmanifesto.com/archives/59"
---
At my job we use a combination of IIS, SQL Server, and Perl. In general it works pretty well. But there is one major problem: if we ever do a warn in perl, instead of printing the message to the log, it crashes the server. That's a big deal since multiple people are using the server and fixing the issue means VNCing in and recycling the app pool. This doesn't always happen, but it happens a lot; enough to make me consider setting up Apache on my personal computer so that I can get some serious logging. Anyway, I don't know if we have a typical setup or not, but this is what I had to do to get it all going.

 * **Install ActiveState perl into C:/usr** (not C:/Perl.) You can get the latest version [here](http://www.activestate.com/Products/activeperl/index.mhtml). That's more or less it for installing perl. Note: Latest at the time of writing is Perl 5.10.0.1004
 * **Install Apache.** You can get the latest version [here](http://httpd.apache.org/download.cgi). I suggest getting the binary msi. Get the one with OpenSSL if you want to set up https (not covered here.) Note: Latest at the time of writing is Apache 2.2.10 (OpenSSL 0.9.8i).
 * **Install Perl Modules.** I am not sure of what all modules our software requires that doesn't come with perl out of the box, but I know for sure that we need DateTime. So to install that open a console and type _ppm install DateTime_. You can use the gui instead if you'd like, but it tends to just get in my way because it's so slow. The way you will know that you are missing a module is if you get an error in the log like this: 
```
[Tue Nov 18 17:33:05 2008] [error] [client 127.0.0.1] Premature end of script headers: foo.plx, referer: http://127.0.0.1/
[Tue Nov 18 17:33:05 2008] [error] [client 127.0.0.1] Can't locate DateTime.pm in @INC (@INC contains: C:/usr/site/lib C:/usr/lib .) at foo.plx line 39., referer: http://127.0.0.1/
[Tue Nov 18 17:33:05 2008] [error] [client 127.0.0.1] BEGIN failed--compilation aborted at foo.plx line 39., referer: http://127.0.0.1/
```

 * **Migrate source code.** For me this just meant checking out one folder from subversion into C:/Inetpub (recommended so that things will continue to work with IIS and apache,) and copying a directory of static html into the same directory. I ended up with two main directories like this: C:/Inetpub/main and C:/Inetput/static. (Names changed to protect the innocent :-) )
 * **Configure Apache.** This, besides the last step, is probably the hardest step. First open httpd.conf, probably C:/Program Files/Apache Software Foundation/Apache2.2/conf/httpd.conf... but you can find it in the start menu). On IIS our static directory is the root and then the main directory is a subdirectory of the static directory. To set this up, first find the `DocumentRoot "..."` directive in the httpd.conf and change it to `DocumentRoot "C:/Inetpub/static"` Next you'll want to make sure that your Directories are configured. Find the existing Directory section and just change the directory to whatever you just did, and then add another one for each other directory in Inetpub. This is what I ended up with:
```
<directory "c:/inetpub/static">
    Options Indexes FollowSymLinks ExecCGI
    AllowOverride None
    Order allow,deny
    Allow from all
</directory>
<directory "c:/inetpub/main">
    Options Indexes FollowSymLinks ExecCGI
    AllowOverride None
    Order allow,deny
    Allow from all
</directory>
```
And then because our static directory was root and the main directory was a subdirectory of the static directory, add a line like the following to the alias\_module section: `Alias /user /Inetpub/main` Also, since we are a perl shop, we have to allow execution of various types of perl programs, so find the mime\_module section of the code and make the AddHandler part look like this: `AddHandler cgi-script .cgi .plx .plex` And then last of all, the main page of our root directory on IIS is Default.html, so instead of renaming it to index.html, find the secion of the code for the Directory and add a DirectoryIndex part so it is like this: `DirectoryIndex Default.html` I ended up setting it for both main and static. Here's my entire httpd.conf if you just wanna see the final product:

```
ServerRoot "C:/Program Files/Apache Software Foundation/Apache2.2"
Listen 80
LoadModule actions_module modules/mod_actions.so
LoadModule alias_module modules/mod_alias.so
LoadModule asis_module modules/mod_asis.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule authn_default_module modules/mod_authn_default.so
LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authz_default_module modules/mod_authz_default.so
LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule autoindex_module modules/mod_autoindex.so
LoadModule cgi_module modules/mod_cgi.so
LoadModule dir_module modules/mod_dir.so
LoadModule env_module modules/mod_env.so
LoadModule include_module modules/mod_include.so
LoadModule isapi_module modules/mod_isapi.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule mime_module modules/mod_mime.so
LoadModule negotiation_module modules/mod_negotiation.so
LoadModule setenvif_module modules/mod_setenvif.so
<ifmodule !mpm_netware_module>
<ifmodule !mpm_winnt_module>
User daemon
Group daemon
</ifmodule>
</ifmodule>
ServerAdmin frewmbot@gmail.com
DocumentRoot "C:/Inetpub/static"
<directory>
    Options FollowSymLinks
    AllowOverride None
    Order deny,allow
    Deny from all
</directory>
<directory "c:/inetpub/static">
    Options Indexes FollowSymLinks ExecCGI
    AllowOverride None
    Order allow,deny
    Allow from all
    DirectoryIndex Default.html
</directory>
<directory "c:/inetpub/main">
    Options Indexes FollowSymLinks ExecCGI
    AllowOverride None
    Order allow,deny
    Allow from all
    DirectoryIndex main.plx
</directory>
<ifmodule dir_module>
    DirectoryIndex index.html
</ifmodule>
<filesmatch "^.ht">
    Order allow,deny
    Deny from all
    Satisfy All
</filesmatch>
ErrorLog "logs/error.log"
LogLevel warn
<ifmodule log_config_module>
    LogFormat "%h %l %u %t "%r" %&gt;s %b "%{Referer}i" "%{User-Agent}i"" combined
    LogFormat "%h %l %u %t "%r" %&gt;s %b" common
    <ifmodule logio_module>
      LogFormat "%h %l %u %t "%r" %&gt;s %b "%{Referer}i" "%{User-Agent}i" %I %O" combinedio
    </ifmodule>
    CustomLog "logs/access.log" common
</ifmodule>
<ifmodule alias_module>
    Alias /user /Inetpub/main
    ScriptAlias /cgi-bin/ "C:/Program Files/Apache Software Foundation/Apache2.2/cgi-bin/"
</ifmodule>
<directory "c:/program files/apache foundation/apache2.2/cgi-bin">
    AllowOverride None
    Options None
    Order allow,deny
    Allow from all
</directory>
DefaultType text/plain
<ifmodule mime_module>
    TypesConfig conf/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddHandler cgi-script .cgi .plx .plex
</ifmodule>
```

 * Ensure all of your **perl files start with #!/usr/bin/perl.** If you don't do this Apache will give you an error, 500 Internal Server on the output, and then something like this in the log:

```
[Tue Dec 09 20:59:04 2008] [error] [client 127.0.0.1] (OS 3)The system cannot find the path specified.  : couldn't create child process: 720003: employee_training_report.plx
[Tue Dec 09 20:59:04 2008] [error] [client 127.0.0.1] (OS 3)The system cannot find the path specified.  : couldn't spawn child process: C:/Inetpub/epms/customer/employee_training_report.plx
```

As stated, this just means that the bangline is wrong and needs to be set to #!/usr/bin/perl. Note: the log is probably in C:/Program Files/Apache Software Foundation/Apache2.2/logs/error.log, but again, you can find that in the start menu.

 * **Fix all headers.** Usually with IIS we output headers like this:

```
print "HTTP/1.0 200 OK\n";
print header;
```

header is a function of the CGI module. For IIS you print out the first part to force the server into NPH mode. I recommend, for ease of migration, making your own module that your scripts can use that will print the header correctly whether it's Apache or IIS. Here's ours:

```
sub header {
    return (($ENV{PERLXS})?"HTTP/1.0 200 OK\r\n":"").CGI->header(@_);<br />
}
```

And note that anything that gets passed to the header method automatically takes any arguments that you passed and gives them to CGI. This allows for a simple method of regular expression based search and replace to fix things to use your new method. (for vim something like this will work: `:%s/v^(s*prints+).*header((.*));/1Module::header2;/g` )    I do this part as I see it as a problem, as my boss didn't want me to search and replace the whole codebase, so the error you are going to look for is a 500 from the browser and then something like this in the log:

```
[Tue Nov 18 17:38:38 2008] [error] [client 127.0.0.1] malformed header from script. Bad header=HTTP/1.0 200 OK: foo.plx
```

And that's basically it! Any tips you might have to add are welcome!
