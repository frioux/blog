---
title: "Putting MySQL in Timeout"
date: 2016-05-08T01:04:34
tags: [ziprecruiter, mysql, perl]
guid: "https://blog.afoolishmanifesto.com/posts/put-mysql-in-timeout"
---
At [work](https://www.ziprecruiter.com) we are working hard to scale our service to serve more users and have
fewer outages.  Exciting times!

One of the main problems we've had since I arrived is that MySQL 5.6 doesn't
really support query timeouts.  It has stall timeouts, but if a query takes too
long there's not a great way to cancel it.  I worked on resolving this a few
months ago and was disapointed that I couldn't seem to come up with a good
solution that was simple enough to not scare me.

A couple weeks ago we hired a new architect (Aaron Hopkins) and he, along with
some ideas from my boss, Bill Hamlin, came up with a pretty elegant and simple
way to tackle this.

The solution is in two parts, the client side, and a reaper.  On the client you
simply set a stall timeout; this example is Perl but any MySQL driver should
expose these connection options:

```
my $dbh = DBI->connect('dbd:mysql:...', 'zr', $password, {
   mysql_read_timeout  => 2 * 60,
   mysql_write_timeout => 2 * 60,
   ...,
})
```

This will at the very least cause the client to stop waiting if the database
disappears.  If the client is doing a query and pulling rows down over the
course of 10 minutes, but is getting a new row every 30s, this will **not**
help.

To resolve the above problem, we have a simple reaper script:

```
#!/usr/bin/perl

use strict;
use warnings;

use DBI;
use JSON;
use Linux::Proc::Net::TCP;
use Sys::Hostname;

my $actual_host = hostname();

my $max_timeout = 2 * 24 * 60 * 60;
$max_timeout = 2 * 60 * 60 if $actual_host eq 'db-master';

my $dbh = DBI->connect(
  'dbi:mysql:host=localhost',
  'root',
  $ENV{MYSQL_PWD},
  {
    RaiseError => 1
    mysql_read_timeout => 30,
    mysql_write_timeout => 30,
  },
);

my $sql = <<'SQL';
SELECT pl.id, pl.host, pl.time, pl.info
  FROM information_schema.processlist pl
 WHERE pl.command NOT IN ('Sleep', 'Binlog Dump') AND
       pl.user NOT IN ('root', 'system user') AND
       pl.time >= 2 * 60
SQL

while (1) {
  my $sth = $dbh->prepare_cached($sql);
  $sth->execute;

  my $connections;

  while (my $row = $sth->fetchrow_hashref) {
    kill_query($row, 'max-timeout') if $row->{time} >= $max_timeout;

    if (my ($json) = ($row->{info} =~ m/ZR_META:\s+(.*)$/)) {
      my $data = decode_json($json);

      kill_query($row, 'web-timeout') if $data->{catalyst_app};
    }

    $connections ||= live_connections();
    kill_query($row, 'zombie') unless $connections->{$row->{host}}
  }

  sleep 1;
}

sub kill_query {
  my ($row, $reason) = @_;
  no warnings 'exiting';

  warn sprintf "killing «%s», reason %s\n", $row->{info}, $reason;
  $dbh->do("KILL CONNECTION ?", undef, $row->{id}) unless $opt->noaction;
  next;
}

sub live_connections {
  my $table = Linux::Proc::Net::TCP->read;

  return +{
    map { $_->rem_address . ':' . $_->local_port => 1 }
    grep $_->st eq 'ESTABLISHED',
    @$table
  }
}
```

There are a lot of subtle details in the above script; so I'll do a little bit
of exposition.  First off, the reaper runs directly on the database server.
We define the absolute maximum timeout based on the hostname of the machine,
with 2 days being the timeout for reporting and read-only minions, and 2 hours
being the timeout for the master.

The SQL query grabs all running tasks, but ignores a certain set of tasks.
Importantly, we have to whitelist a couple users because one (root) is where
extremely long running DDL takes place and the other (system user) is doing
replication, basically constantly.

We iterate over the returned queries, immediately killing those that took longer
than the maximum timeout.  Any queries that our ORM (DBIx::Class) generated have
a little bit of logging appended as a comment with JSON in it.  We can use that
to tweak the timeout further; initially by choking down web requests to a
shorter timeout, and later we'll likely allow users to set a custom timeout
directly in that comment.

Finally, we kill queries whose client has given up the ghost.  I did a test a
while ago where I started a query and then killed the script doing the query,
and I could see that MySQL kept running the query.  I can only assume that this
is because it could have been some kind of long running UPDATE or something.  I
expect the timeouts will be the main cause of query reaping, but this is a nice
stopgap that could pare down some pointless crashed queries.

I am very pleased with this solution.  I even think that if we eventually switch
to Aurora all except the `zombie` checking will continue to work.
