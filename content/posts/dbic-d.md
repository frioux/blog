---
aliases: ["/archives/709"]
title: "DBIC'd"
date: "2009-05-22T02:41:50-05:00"
tags: [mitsi, dbix-class, orm, perl]
guid: "http://blog.afoolishmanifesto.com/?p=709"
---
This is a blogish version of a message I posted to the DBIC Mailing list recently.

First off, this is my table structure:

User has many Roles (Role belongs to User) Role has many Permissions (Permission belongs to Role) Permissions has many Screens (Screens has many Permissions) Screens belongs to Section (Section has many Screens)

So I thought I could do this:

       my @sections = $user->roles
          ->related_resultset('permissions')
          ->related_resultset('screens')
          ->related_resultset('section')
          ->all;

But related\_resultset doesn't work with many\_to\_many because it's not a "real" relation (I'd like to hear about why that is at some point.)

The following is **close** to what I wanted

       my @sections = $user->roles
          ->related_resultset('role_permissions')
          ->related_resultset('permission')
          ->related_resultset('permission_screens')
          ->related_resultset('screen')
          ->related_resultset('section')
          ->all;

But it turns out it returns a section per role, which often means duplicates.

So I figured I could do a distinct, so I finally tried this:

       my @sections = $user->roles
          ->related_resultset('role_permissions')
          ->related_resultset('permission')
          ->related_resultset('permission_screens')
          ->related_resultset('screen')
          ->related_resultset('section')
          ->search(undef, { distinct => 1 });

And it worked! How cool is that?

I actually later on ended up only getting the screens and then getting the sections based on that, otherwise we got false positives on the sections. Anyway, now we have a nice roles/permission based tree getting built on our app for the navigation.

And this next little trick could be an entire post in itself, but my Draft queue is getting pretty huge, so I'll just include it here:

      $cd_rs->search({
        artist_id => {
          in => $artists_rs->search({
            name => { like => '%beat%'},
          })->get_column( 'id' )->as_query
        },
      });

So basically what this does is a subselect. DBIC is very much strives to be consistent throughout, which brings us the amazing new as\_query method. This turns the given resultset into a data structure, which can then be passed to other resultsets searchs to create subselects. The above search will find all of the CD's by artists with the string 'beat' somewhere in their names.

Anyway, hope you enjoyed this post. My brother is getting married in a week and my sister is graduating highschool on Tuesday. I say this because I doubt I will be able to post much next week. So worst case scenario I will post again on the first of June.
