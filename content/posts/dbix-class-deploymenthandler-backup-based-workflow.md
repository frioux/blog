---
aliases: ["/archives/1737"]
title: "DBIx::Class::DeploymentHandler Backup based workflow"
date: "2012-06-08T16:00:33-05:00"
tags: [mitsi, cpan, dbix-class, dbix-class-deploymenthandler, perl]
guid: "http://blog.afoolishmanifesto.com/?p=1737"
---
In my last post I wrote about how to make a backup for each migration you run. That's a great trick that opens the door for this next tip.

I've never really trusted or been comfortable with downgrade scripts. If your downgrade script truly is the reverse of your upgrade script it's almost inevitable that your upgrade script will be archiving changed data so that the downgrade script can undo said change. That's why I've basically decided to not ever use downgrade scripts and instead just restore backups. Sure, there are times when a downgrade might make more sense, like someone upgraded the live site to delete an important but rarely used table and didn't realize it till a week later. But I honestly don't trust the guy who does that to the live site to write a legitimate downgrade script for his stupid change anyway.

As the code for this isn't written yet, I'll just have to describe the algorithm to you, but it's really pretty simple, and opens up the path to sensible, dead easy branching with DBICDH.

First, we need another column in the version storage representing the current git sha1 when each migration was run. Note that this column is **not** the version of the database, though it could be. So let's handwave away the idea that we added a column to our version storage. That can't be hard to implement. We'll get to why we need that later.

When running our migrations I have our system run the upgrade method every time. The first thing that needs to be added is, if the deployed version is greater than the schema version, we need to restore the backup from the schema version. Next, if the deployed version is less than or equal to the schema version, and the git version in the database is not in the history of our current branch, we need to restore the current database version - 1. Basically keep doing the above until the current database version is less than the current schema version and the git version stored in the database is in the history of the current branch, and then run upgrade. To use more variables and fewer words:

    while (
      $database_version > $schema_version ||
      $database_version <= $schema_version && !HEAD_contains($db_git_version)
    ) {
      if ($database_version > $schema_version) {
        restore($schema_version)
      } else {
        restore($database_version - 1)
      }
    }
    $dbicdh->upgrade;

Clearly there is some handwaving there, and the algorithm could be simplified (we could always restore $database\_version - 1, for example, and thus remove the if block) or sped up (store backups based on git rev instead of schema version then you can do it in a single step) but until I actually implement it that's all a moot point.

So there you have it. If you implement this you should have stable downgrades and a branching model that actual works with your schema. Of course I'm assuming the developers each have their own sandbox database, but if they don't have that then of course you have more serious problems.
