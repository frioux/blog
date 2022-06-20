---
title: Announcing dh
date: 2022-06-20T16:41:06
tags: [ "frew-warez", "golang" ]
guid: b2dc777e-66e7-4a7d-92e6-b31962eb27f3
---
I needed a tool to manage a relational database, so I built one.

<!--more-->

Just over 12 years ago [I announced
DBIx::Class::DeploymentHandler](/posts/announcing-dbix-class-deploymenthandler/),
a tool to manage migrations against a relational database, built around the
Perl ORM DBIx::Class.  I used DBICDH at work on many projects, and I am
confident that place still uses it today and many other places do as well.
It's a good tool and I'm proud of it.

It has some limitations though.  First and foremost, it's Perl.  Perl is fine,
but I mostly don't use it outside of little scripts these days.  If I'm going
to deploy code, my preference is that it be Go.  Additionally, DBICDH was built
around an ORM.  This even ended up being a significant limitation eventually
that had to be worked around; it was a mistake.  I wouldn't build a migration
system around an ORM again.

DBICDH had this whole system for deploys (where you deploy a given version)
upgrades (where you upgade from one version to the next) and optionally
downgrades.  I no longer believe that's all worthwhile as a distinction.  If
you are going to manage DDL migrations, you should just always apply the same
ones.

So without further ado, I'll talk about my new tool.

---

## Announcing `dh`

[`dh` is a tool for managing migrations in Go.](https://github.com/frioux/dh)
It's very early days, so it has very few bells and whistles, but I feel good
about the foundation and intend to use it in anger for a long time.  Here's my
elevator pitch:

In `dh`, each directory is a migration.  Out of the box that can be a SQL file,
or if you need to run multiple SQL statements, a JSON file with a list of
pre-split SQL statements.  The files in the directory are run in sorted order,
within a transaction.  `dh` maintains a table of which migrations have been
applied, so that it can know which migrations to run when your app gets
updated.

You explicitely put which migration directories to run in a file called
`plan.txt`.  The directories are naturally used as an `fs.FS`, so you can
either load them at runtime with `os.DirFS()` or you can use `embed.FS` to
build them into your binary.

I'm using this with `SQLite` today, but if I were to use a bigger database
installation I'd make sure everything works.  Here's how I work with it in
`shortlinks`, with added comments for clarity.

```golang
//go:embed dh
var dhFS embed.FS

func Connect(dsn string) (*Client, error) {
	if dsn == "" {
		dsn = "file:db.db"
	}
	db, err := sqlx.Open("sqlite3", dsn)
	if err != nil {
		return nil, err
	}

	// SQLite's version of INFORMATION_SCHEMA; find out if we've already
	// created the migration table.
	var found struct { C int }
	const sql = `SELECT COUNT(*) AS c FROM main.sqlite_master WHERE "name" = 'dh_migrations' AND "type" = 'table'`;
	if err := db.Get(&found, sql); err != nil {
		return nil, fmt.Errorf("db.Get: %w", err)
	}

	e := dh.NewMigrator()
	if found.C != 1 {
		// dh.DHMirgations contain some DDL for creating the dh_migrations table.
		// You only need to call e.MigrateOne for initial bootstrap.
		if err := e.MigrateOne(db, dh.DHMigrations, "000-sqlite"); err != nil {
			return nil, fmt.Errorf("dh.Migrator.MigrateOne: %w", err)
		}
	}

	fss, _ := fs.Sub(dhFS, "dh")
	// After bootstrap, e.MigrateAll follows plan.txt and applies the
	// migrations in order.
	if err := e.MigrateAll(db, fss); err != nil {
		return nil, fmt.Errorf("dh.Migrator.MigrateAll: %w", err)
	}

	return &Client{db: db}, nil
}
```

You can see [my `dh` dir for `shortlinks`
here](https://github.com/frioux/shortlinks/tree/edbe8eb/storage/sqlitestorage/dh).  Also, check
out [the `dh` README](https://github.com/frioux/dh).

---

That's all cool, but what I am most pleased with in `dh` is that the way the
files in the migration directory is processed is an interface you can hook
into.  Out of the box you probably use the `ExtensionMigrator`, which treats
`.sql` as SQL and `.json` as JSON, as mentioned above.  But one could easily
create another `Migrator` instance that knows how to load `.lua` files, so that
you can run more complicated code to populate records in your database.  Or
maybe just have a dictionary of Go functions and have the filename map to those
functions.  Or parse the file at runtime and do something else, who knows!  For
more discussion of that, [check out the `dh`
godoc](https://pkg.go.dev/github.com/frioux/dh#section-documentation).  The
documentation uses some of the Go 1.19 documentation patterns, so it doesn't
render as nicely as it will soon.

---

As I said it's early days.  Here are some things missing from `dh` that should be fixed eventually:

 * Some way to generate DDL
 * Logs to see `dh` make progress
 * Builtin functionality to detect if the `dh_migrations` table is installed

I'm sure there's more.  I don't have super high expectations for `dh`, but it
feels like a good, sturdy tool I can use for projects when I have the need.
Frankly, I am tempted to try to port SQL::Translator (or maybe just shell out
to it?) to generate the migrations.  What I'd really like is to always have a
`latest-ddl.sql` that has the current intended schema, and things get generated
when you mutate that.  But doing that would just get me users, I don't mind
writing DDL myself, and I don't really need users.

---

(Affiliate links below.)

I've been reading [Understanding Software Dynamics](https://amzn.to/3aXInyX)
lately and it's pretty fun.  It's got some cool hands on stuff (though maybe
I'm just talking about homework?) but it's not gigantic like most textbook
style books.  I appreciate good tech books that know how to have restraint.

Another book (that I've been reading since it was published, very, very slowly)
which is a lot of fun is [Practical Doomsday](https://amzn.to/3N71y6S).  The
basic gist is, things go wrong, you should be prepared for when things go wrong.
This book is about that.  Check it out!
