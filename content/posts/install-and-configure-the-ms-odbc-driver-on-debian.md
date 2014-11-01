---
aliases: ["/archives/1855"]
title: "Install and Configure the MS ODBC Driver on Debian"
date: "2013-07-05T03:27:40-05:00"
tags: ["dbdodbc", "mssql", "odbc", "perl", "sql-server", "sqlnci"]
guid: "http://blog.afoolishmanifesto.com/?p=1855"
---
This was originally written by my coworker [Wes
Malone](https://github.com/wesq3) and adpated to Ubuntu by my other coworker
[Geoff Darling](https://metacpan.org/author/MAESTRO). Basically it should get
you up and running with Microsoft's official ODBC driver in Debian based
Linuxes. Enjoy!

The Microsoft ODBC Driver (AKA the SQL Server Native Client) is Microsoft's
official ODBC driver for SQL Server. Since 2011 Microsoft has provided binary
builds officially supported on Redhat Enterprise Linux. The Linux sqlncli
[supports all server features of SQL
Server](http://msdn.microsoft.com/library/hh568451%28SQL.110%29.aspx), including
Unicode and Multiple Active Result-sets (MARS). We ran into Unicode troubles
porting our Perl ODBC applications to the FreeTDS ODBC driver, not to mention
that some of our apps rely on MARS, which is unsupported by FreeTDS.

This guide is meant to be a more newbie friendly version combining the [official
Microsoft install
directions](http://www.microsoft.com/en-us/download/details.aspx?id=28160) and
[this guide for adapting the driver install for
Debian](http://codesynthesis.com/~boris/blog/2011/12/02/microsoft-sql-server-odbc-driver-linux/).

# Get Ready

Stop your apps first. I don't know if it would interfere with the process, but
let's just be safe.

Grab the sqlncli11 package from MS and the unixODBC 2.3.2 package.

    $ wget http://download.microsoft.com/download/6/A/B/6AB27E13-46AE-4CE9-AFFD-406367CADC1D/Linux6/sqlncli-11.0.1790.0.tar.gz
    $ wget ftp://ftp.unixodbc.org/pub/unixODBC/unixODBC-2.3.2.tar.gz

Get rid of any previous ODBC packages.

    $ sudo apt-get remove libodbc1 unixodbc unixodbc-dev

# Install unixODBC 2.3.2

<strike>_This is a stupidly manual process because the Debian packagers have
woefully dragged their feet for many years on updating this package. If you'd
like to remove this step, please bug them
[here](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=650267).
--frew_</strike>

_It looks like 2.3.1 is finally in sid, so Lord willing it will trickle down
into stable/ubuntu in a year or so. --frew_

_Indeed, starting with Utopic Unicorn you can skip the build/install of unixODBC
below! --frew_

Unpack unixodbc:

    $ tar xf unixODBC-2.3.2.tar.gz

Now we can build and install unixODBC.

    $ ./configure --disable-gui --disable-drivers --enable-stats=no --enable-iconv --with-iconv-char-enc=UTF8 --with-iconv-ucode-enc=UTF16LE
    $ make
    $ sudo make install

unixODBC installs to /usr/local/lib by default but the Microsoft driver expects
it in /usr/lib. We have to let the system know we're using /usr/local/lib, so if
necessary on your system, add the appropriate path to /etc/ld.so.conf and run
ldconfig to update the linker path.

    $ sudo vim /etc/ld.so.conf # add /usr/local/lib to the end
    $ sudo ldconfig

# Driver Compatibility

Let's paper over some of the differences between the RHEL environment that the
driver expects and Debian. Unpack it and check for dependencies of the library.

    $ tar xf sqlncli*
    $ cd sqlncli*
    $ ldd lib64/libsqlncli*

On my system it can't find libcrypto and libssl because of the versioning
differences between RHEL and Debian.

    mitsi@silver:~/sqlncli-11.0.1790.0$ ldd lib64/libsqlncli-11.0.so.1790.0
            linux-vdso.so.1 =>  (0x00007fffc971b000)
            libcrypto.so.10 => not found
            libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f3bc6064000)
            librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f3bc5e5b000)
            libssl.so.10 => not found
            libuuid.so.1 => /lib/x86_64-linux-gnu/libuuid.so.1 (0x00007f3bc5c56000)
            libodbcinst.so.1 => /usr/lib/x86_64-linux-gnu/libodbcinst.so.1 (0x00007f3bc5a43000)
            ...

_The version bump from 1 to 2 is an incredibly minimal change that's actually
included in 2.3.0 as well. We haven't seen any breakage due to the modification.
This is the reason we add the symlinks related to libodbc below.
--frew_

We need to add ODBC symlinks because unixODBC bumped their major version, but
the native client doesn't build against version 2.  The next commands should do
that:


Add a couple of symlinks in /usr/lib and the driver can find what it needs.

    $ cd /usr/lib
    $ sudo ln -s libssl.so.0.9.8 libssl.so.10
    $ sudo ln -s libcrypto.so.0.9.8 libcrypto.so.10

Ubuntu is slightly different because the libs are in /usr/lib/$arch

    $ cd /usr/lib
    $ sudo ln -s x86_64-linux-gnu/libssl.so.0.9.8 libssl.so.10
    $ sudo ln -s x86_64-linux-gnu/libcrypto.so.0.9.8 libcrypto.so.10
    $ sudo ln -s x86_64-linux-gnu/libodbc.so.2 libodbc.so.1
    $ sudo ln -s x86_64-linux-gnu/libodbccr.so.2 libodbccr.so.1
    $ sudo ln -s x86_64-linux-gnu/libodbcinst.so.2 libodbcinst.so.1

You can check again with ldd that all the libraries are found.

# Install the Microsoft Driver

Now we can install the Microsoft driver. Run the installer with bash because the
install script references /bin/sh in its shebang but expects it to be bash
anyway. The force option will continue with the install even though we're
missing rpm etc.

    $ sudo bash ./install.sh install --force
    # type q to exit the terms
    # type YES to accept and continue with install

The install output looks like this for me, note the last line confirming the install:

    Checking for 64 bit Linux compatible OS ................................. FAILED
    Checking required libs are installed ............................... NOT CHECKED
    unixODBC utilities (odbc_config and odbcinst) installed ............ NOT CHECKED
    unixODBC Driver Manager version 2.3.0 installed .................... NOT CHECKED
    unixODBC Driver Manager configuration correct ...................... NOT CHECKED
    Microsoft SQL Server ODBC Driver V1.0 for Linux already installed .. NOT CHECKED
    Microsoft SQL Server ODBC Driver V1.0 for Linux files copied ................ OK
    Symbolic links for bcp and sqlcmd created ................................... OK
    Microsoft SQL Server ODBC Driver V1.0 for Linux registered ........... INSTALLED

Now test the install with sqlcmd. Connecting to an imaginary SQL Server should
time out. Any other errors about missing libraries mean you should double-check
your symlinks and ld.so.conf. On one install I'd forgotten to run ldconfig.

    $ sqlcmd -S localhost
    SqlState HYT00, Login timeout expired
    TCP Provider: Error code 0x71
    A network-related or instance-specific error has occurred while establishing a connection to SQL Serve
    r. Server is not found or not accessible. Check if instance name is correct and if SQL Server is confi
    gured to allow remote connections. For more information see SQL Server Books Online.

# Installing Perl DBD::ODBC with Unicode support

Everything is installed now, but we Perl-ers need to install DBD::ODBC with the
Unicode option enabled. It's disabled by default on Linux for now because of
poor driver support. Once the default switches to Unicode on for sqlncli then
this step can be skipped.

    $ cpanm --look DBD::ODBC
    $ perl Makefile.PL -u # enable unicode support
    $ make
    $ make test
    $ make install

# Pro Tips

- ODBC driver config is in /usr/local/etc/odbcinst.ini. The odbcinst.ini in /etc
  is a clever ruse devised by your previous ODBC install.
- Your connect strings should look something like
  `dbi:ODBC:driver=SQL Server Native Client 11.0;server=tcp:10.1.2.3;database=DB_TOWNE;MARS_Connection=yes;`
- See that `MARS_Connection=yes` up there? That's right, MARS is supported :D

**2013-10-24 UPDATE**: unixODBC 2.3.2 was released and has been incorporated
into the howto. Additionally [mje](http://www.martin-evans.me.uk) recommended
setting `--enable-stats=no` for speed, especially since with the gui disabled
they aren't used anyway.
