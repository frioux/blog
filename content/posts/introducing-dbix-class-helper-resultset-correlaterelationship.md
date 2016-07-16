---
aliases: ["/archives/1709"]
title: "Introducing DBIx::Class::Helper::ResultSet::CorrelateRelationship"
date: "2012-05-30T14:54:27-05:00"
tags: ["cpan", "dbix-class", "dbix-class-helpers", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1709"
---
Recently at work we ran into an issue where a report was timing out. At first I
thought it was because the server was overloaded, or the clients that were
connecting to it were doing so improperly. Both of those things were true, but
they weren't the cause of the problem. The problem was this:

```
sub TO_JSON {
    my $self = shift;

    return {
       %{$self->next::method},
       failed_location_tests => $self->test_computer_links->failed->count,
       location_tests => $self->test_computer_links->count,
       device_tests => $self->test_device_links->count,
       total_pcs => $self->all_computers->count,
       total_pcs_failed => $self->failed_computers->count,
       total_pcs_succeeded => $self->succeeded_computers->count,
       total_pcs_untested => $self->untested_computers->count,
    }
 }
```

So to be clear, with our standard pagination of 25 rows per grid, this was doing
the initial query to get the data, and then SEVEN additional queries per row.
That's not hard math, but I'll do it for you, 176 queries, just to load this
data. Fortunately, we can do better.

# Introducing [DBIx::Class::Helper::ResultSet::CorrelateRelationship](http://p3rl.org/DBIx::Class::Helper::ResultSet::CorrelateRelationship)

CorrelateRelationship gives you a single method, correlate. Basically you can
treat it like `related_resultset` except that instead of a simple join it creates
a correlated subquery. To be clear, here is the code and SQL of a correlated
subquery:

```
my $rs = $schema->resultset('Gnarly')->search(undef, {
   '+columns' => {
      old_gnarlies => $schema->resultset('Gnarly')
         ->correlate('gnarly_stations')
         ->search({ station_id => { '>' => 2 }})
         ->count_rs->as_query,
      new_gnarlies => $schema->resultset('Gnarly')
         ->correlate('gnarly_stations')
         ->search({ station_id => { '<=' => 2 }})
         ->count_rs->as_query,
   }
});

SELECT me.id, me.name, me.literature, me.your_mom, (
   SELECT COUNT( * )
     FROM Gnarly_Station gnarly_stations_alias
   WHERE station_id <= '2' AND gnarly_stations_alias.gnarly_id = me.id
  ), (
   SELECT COUNT( * )
     FROM Gnarly_Station gnarly_stations_alias
   WHERE station_id > '2' AND gnarly_stations_alias.gnarly_id = me.id
  )
 FROM Gnarly me
```

The above returns all the rows in the table called Gnarly, and the counts of the
related Gnarly\_Station rows. There are two things to note: first off, we don't
need to deal with group by; if it were only for this correlated subqueries would
still be awesome. If you were to use the obvious approach here's how it would
look (assuming just one count:)

```
my $rs = $schema->resultset('Gnarly')->search(undef, {
   join => 'gnarly_stations',
   +columns => { gs_count => { COUNT => 'gnarly_stations.id' } },
   group_by => [qw( me.id me.name me.literature me.your_mom )],
})

  SELECT me.id, me.name, me.literature, me.your_mom, COUNT( gnarly_stations.id )
    FROM Gnarly me
    JOIN Gnarly_Station gnarly_stations
      ON gnarly_stations_alias.gnarly_id = me.id
GROUP BY me.id, me.name, me.literature, me.your_mom
```

As you can see, the additionally selected columns need to be managed. The other
thing, which is certainly engine dependent, is that `COUNT`'s that aren't
`COUNT(*)` tend to be slow as they do table scans.

More importantly, there are things that you really just can't do without
correlated subqueries. Note that in my first example we are counting the same
relationship, but we're counting a different set of the related rows in a each
correlated subquery. That just can't be done in a single query any other way (as
far as I know anyway.)

Once you have this a lot of possibilities are opened up to you for fast,
powerful queries. Enjoy!
