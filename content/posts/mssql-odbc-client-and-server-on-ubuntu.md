---
title: MSSQL ODBC Client and Server on Ubuntu
date: 2017-03-06T07:26:51
tags: [ziprecruiter, dbd-odbc, perl, sql-server]
guid: E81612E2-C635-11E6-B0CC-40F696CA2967
---
Many years ago some coworkers and I collaborated on a document that would
describe [how to install the ODBC drivers from Microsoft on
Debian](/posts/install-and-configure-the-ms-odbc-driver-on-debian/), instead of
RedHat as they were intended.  Recently Microsoft has made this a much simpler
task, so I decided to write a new version.

<!--more-->

In the past couple of years Microsoft has made great strides in an effort to be
more friendly to the open source community.  I continue to be surprised and
impressed at their results.  A recent example is their support of their ODBC
driver for not just RedHat but Ubuntu also.

This guide is meant to smooth over some of the rough spots in [the official
guide](https://msdn.microsoft.com/en-us/library/hh568454(v=sql.110\).aspx).
Although the official guide includes commands to run, they seem to be
insufficient, especially if you are using docker (implying a stripped down
image.)

(Super short version: [check out this git repo and play with
it](https://github.com/frioux/mssql-docker-demo).)

## Running MSSQL in Docker

If you are following this guide presumably you already have a Linux machine, but
you may *not* have a Windows machine.  If that's the case, you probably need a
server.  That's actually the easiest part, assuming you already have
[docker](https://www.docker.com/#/developers) installed:

```
docker run \
   -e 'ACCEPT_EULA=Y' \
   -e 'SA_PASSWORD=password1!' \
   --name mssql \
   --rm \
   microsoft/mssql-server-linux
```

Note that the password must be "strong" for some value of strong.  It's
annoying, but I doubt many SQL Server users will face extortion by leaving off a
password because of this, [unlike MongoDB
users](https://securityintelligence.com/news/mongodb-databases-may-be-exposed-by-security-misconfigurations/),
so it's probably a good thing.

**And that's it.** You have a running SQL Server instance!

## Setting up the client libraries

**All but the final client step (to install Perl libraries) can be likely
taken care of by following the up-to-date instructions [from
Microsoft][official]**

The following was tested on Ubuntu 16.04.  Some things would surely need to be
tweaked for a different version.

Install the basic tooling you need to get up and going:

```
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install apt-utils apt-transport-https wget
```

Add the (bizarrely named) Microsoft apt repo:

```
echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/mssql-ubuntu-xenial-release/ xenial main" > /etc/apt/sources.list.d/mssqlpreview.list'
```

Add the key for the new repo:

```
apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
```

Load data from the new repo:

```
apt-get -y update
```

Install the ODBC driver and stuff we'll need to build
[DBD::ODBC](https://metacpan.org/pod/DBD::ODBC):

```
env ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cpanminus \
    msodbcsql \
    unixodbc-dev-utf16
```

Microsoft claims you need to install this again; can't hurt, but I doubt it's
important:

```
apt-get install unixodbc-dev-utf16
```

This wall of shell will install the Perl DBD::ODBC driver:

```
cd /root && \
wget https://cpan.metacpan.org/authors/id/M/MJ/MJEVANS/DBD-ODBC-1.56.tar.gz && \
tar xf DBD-ODBC-1.56.tar.gz && \
cd /root/DBD-ODBC-1.56      && \
perl Makefile.PL -u         && \
cpanm --installdeps .       && \
make                        && \
make test                   && \
make install                && \
rm -rf /root/DBD-ODBC-1.56.tar.gz /root/DBD-ODBC-1.56
```

Finally, if you are in a Docker container, you'll need to generate a locale or
the ODBC driver will error out super early:

```
locale-gen en_US en_US.UTF-8
```

## Kicking the Tires

I made a stupid Perl script to be able to kick the tires a little bit:

```
!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use DBI;
use Getopt::Long;

my $show_output;

GetOptions(
   'show-output' => \$show_output,
);

my $dbh = DBI->connect(
   'dbi:ODBC:driver=ODBC Driver 13 for SQL Server;' .
   "server=tcp:$ENV{MSSQL_PORT_1433_TCP_ADDR};" .
   'database=msdb;' .
   'MARS_Connection=yes;',
   'sa',
   $ENV{MSSQL_ENV_SA_PASSWORD},
);

my $sql = shift;

if ($show_output) {
   print Dumper($dbh->selectall_arrayref($sql, undef, @ARGV))
} else {
   $dbh->do($sql, undef, @ARGV)
}
```

Pretend you are in docker:

```
export MSSQL_PORT_1433_TCP_ADDR=some_sql_server_ip
export MSSQL_ENV_SA_PASSWORD='password1!'
```

(If the above environment variables look bizarre to you, [you can read a little
bit more about them
here](/posts/development-with-docker/#linking:f7a62ea51190adf89faf339a1c9f1da2).)

Then I created a fresh database:

```
psqlcli 'CREATE DATABASE MyDB'
```

...and a table:

```
psqlcli 'USE MyDB;
CREATE TABLE "Foo" (
   "id" int NOT NULL IDENTITY (1 ,1),
   "name" varchar(255) NOT NULL,
   CONSTRAINT "PK_Foo" PRIMARY KEY CLUSTERED ("id")
)'
```

...and inserted some rows:

```
psqlcli 'USE MyDB; INSERT INTO "Foo" (name) VALUES (?)' catherine
psqlcli 'USE MyDB; INSERT INTO "Foo" (name) VALUES (?)' roman
psqlcli 'USE MyDB; INSERT INTO "Foo" (name) VALUES (?)' axel
psqlcli 'USE MyDB; INSERT INTO "Foo" (name) VALUES (?)' frew
```

...and selected some:

```
$ psqlcli --show-output 'USE MyDB; SELECT * FROM Foo WHERE name = ?' fREW
$VAR1 = [
          [
            1,
            'frew'
          ]
        ];
```

Works just as expected!

---

I'm glad that this is so much less weird than before.  [The previous
version](/posts/install-and-configure-the-ms-odbc-driver-on-debian/)
of this document had some pretty sketchy hacks.  This should be much more
reliable.

[official]: https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
