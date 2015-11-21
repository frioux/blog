---
aliases: ["/archives/1444"]
title: "Announcing DBIx::Class 0.08124"
date: "2010-10-28T14:54:16-05:00"
tags: ["anouncement", "cpan", "dbixclass"]
guid: "http://blog.afoolishmanifesto.com/?p=1444"
---
Hello all,

I'm proud to announce [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) 0.08124! It's been a VERY long time since 0.08123 and a this release brings lots of goodies.

My favorite is color-coded, correctly indented SQL, with placeholders filled in. Try it! Just do:

DBIC\_TRACE\_PROFILE=console DBIC\_TRACE=1 ./foo.pl

There is also the exciting new "-ident" pseudofunction for SQL:

$rs->search(\{ foo => \{ -ident => 'bar' \} \})

which is the same as

$rs->search(\{ foo => \\'bar' \})

but more introspectible!

Also, I'm a big fan of the new doc-map, which is at [DBIx::Class::Manual::Features](http://search.cpan.org/perldoc?DBIx::Class::Manual::Features). Check it out!

----

The entire changelog is as follows:

```
0.08124 2010-10-28 14:23 (UTC)
    * New Features / Changes
        - Add new -ident "function" indicating rhs is a column name
          { col => { -ident => 'othercol' } } vs { col => \'othercol' }
        - Extend 'proxy' relationship attribute
        - Use DBIx::Class::Storage::Debug::PrettyPrint when the
          environment variable DBIC_TRACE_PROFILE is set, see
          DBIx::Class::Storage for more information
        - Implemented add_unique_constraints() which delegates to
          add_unique_constraint() as appropriate
        - add_unique_constraint() now poparly throws if called with
          multiple constraint definitions
        - No longer depend on SQL::Abstract::Limit - DBIC has been doing
          most of the heavy lifting for a while anyway
        - FilterColumn now passes data through when transformations
          are not specified rather than throwing an exception.
        - Optimized RowNum based Oracle limit-dialect (RT#61277)
        - Requesting a pager on a resultset with cached entries now
          throws an exception, instead of returning a 1-page object
          since the amount of rows is always equal to the "pagesize"
        - $rs->pager now uses a lazy count to determine the amount of
          total entries only when really needed, instead of doing it
          at instantiation time
        - New documentation map organized by features
          (DBIx::Class::Manual::Features)
        - find( { ... }, { key => $constraint } ) now throws an exception
          when the supplied data does not fully specify $constraint
        - find( col1 => $val1, col2 => $val2, ... ) is no longer supported
          (it has been in deprecated state for more than 4 years)
        - Make sure exception_action does not allow exception-hiding
          due to badly-written handlers (the mechanism was never meant
          to be able to suppress exceptions)
 
    * Fixes
        - Fix memory leak during populate() on 5.8.x perls
        - Temporarily fixed 5.13.x failures (RT#58225)
          (perl-core fix still pending)
        - Fix result_soutrce_instance leaks on compose_namespace
        - Fix $_ volatility on load_namespaces (a class changing $_
          at compile time no longer causes a massive fail)
        - Fix find() without a key attr. choosing constraints even if
          some of the supplied values are NULL (RT#59219)
        - Fixed rels ending with me breaking subqueried limit realiasing
        - Fixed $rs->update/delete on resutsets constrained by an
          -or condition
        - Remove rogue GROUP BY on non-multiplying prefetch-induced
          subqueries
        - Fix incorrect order_by handling with prefetch on
          $ordered_rs->search_related ('has_many_rel') resultsets
        - Oracle sequence detection now *really* works across schemas
          (fixed some ommissions from 0.08123)
        - dbicadmin now uses a /usr/bin/env shebang to work better with
          perlbrew and other local perl builds
        - bulk-inserts via $dbh->bind_array (void $rs->populate) now
          display properly in DBIC_TRACE
        - Incomplete exception thrown on relationship auto-fk-inference
          failures
        - Fixed distinct with order_by to not double-specify the same
          column in the GROUP BY clause
        - Properly support column names with symbols (e.g. single quote)
          via custom accessors
        - Fixed ::Schema::Versioned to work properly with quoting on
          (RT#59619)
        - Fixed t/54taint fails under local-lib
        - Fixed SELECT ... FOR UPDATE with LIMIT regression (RT#58554)
        - Fixed CDBICompat to preserve order of column-group additions,
          so that test relying on the order of %{} will no longer fail
        - Fixed mysterious ::Storage::DBI goto-shim failures on older
          perl versions
        - Non-blessed reference exceptions are now correctly preserved
          when thrown from udner DBIC (e.g. from txn_do)
        - No longer disconnecting database handles supplied to connect
          via a coderef
        - Fixed t/inflate/datetime_pg.t failures due to a low dependency
          on DateTime::Format::Pg (RT#61503)
        - Fix dirtyness detection on source-less objects
        - Fix incorrect limit_dialect assignment on Replicated pool members
        - Fix invalid sql on relationship attr order_by with prefetch
        - Fix primary key sequence detection for Oracle
          (first trigger instead of trigger for column)
        - Add various missing things to Optional::Dependencies
        - Skip a test that breaks due to serious bugs in current DBD::SQLite
        - Fix tests related to leaks and leaky perls (5.13.5, 5.13.6)
 
    * Misc
        - Entire test suite now passes under DBIC_TRACE=1
        - Makefile.PL no longer imports GetOptions() to interoperate
          better with Catalyst installers
        - Bumped minimum Module::Install for developers
        - Bumped DBD::SQLite dependency and removed some TODO markers
          from tests (RT#59565)
        - Do not execute t/zzzzzzz_sqlite_deadlock.t for regular module
          installs - test is prone to spontaneous blow up
        - DT-related tests now require a DateTime >= 0.55 (RT#60324)
        - Makefile.PL now provides a pre-parsed DBIC version to the
          Opt::Dep pod generator
        - t/52leaks.t now performs very aggressive leak detection in
          author/smoker mode
```
