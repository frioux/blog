---
aliases: ["/archives/1055"]
title: "On Rewrites, or Why One Should Read as Little Code as Possible"
date: "2009-08-07T01:25:34-05:00"
tags: ["primary-key", "reverse-engineering", "rewriting", "sql", "unique-id"]
guid: "http://blog.afoolishmanifesto.com/?p=1055"
---
The project I am working on right now is rewriting a large, mostly CRUD application. The current app (second generation) is all VB6 and Stored Procedures. We are making the app entirely web based with [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class) for the brunt of the backend and [ExtJS](http://extjs.com) for the UI. There are a [few](http://search.cpan.org/perldoc?Catalyst) [other](http://en.wikipedia.org/wiki/Representational_State_Transfer) technologies involved, but they should remain fairly light and unobtrusive.

As we've designed our code I've made an effort to only look at the inputs and outputs of the original code, to avoid using any existing design mistakes that have already been made. Generally this methodology works well. But sometimes the very format of the input/output leads me astray. Here's an example that I encountered today.

Our customer typically uses composite primary keys to allow for public facing id's. That makes sense. Typically serial numbers follow actual reason and composite primary keys work for that use case. In some places these keys are **also** the natural ordering for a set of items. For example, the company will have a list of operations that were performed to fix a part. Those operations are listed in order (for obvious reasons) and that order must be maintained. The id makes sense initially. Yet sometimes people need to change the order of some of these things. The most specific part of the composite pk always starts at one and increments by one. So when the user reorders the items in the list we ddo something like this (from memory):

    method set_id ($new_id) {
       my $old_id = $self->id;
       my $siblings_to_increment = $self->siblings->search({
          id => {
              '<' => $old_id,
              '>=' => $new_id,
          },
       });

       my $siblings_to_decrement = $self->siblings->search({
          id => {
              '>' => $old_id,
              '<=' => $new_id,
          },
       });

       $self->result_source->schema->txn_do(sub {
          $self->update({ id => 0 });
          $siblings_to_increment->update({ id => \'id + 1' });
          $siblings_to_decrement->update({ id => \'id - 1' });
          $self->update({ id => $new_id });
       });
    }

Works great!

But today I was considering what this would be like if I were to remove the composite pk's from the system. How would I order the items? I would no longer change the id because they would be completely unique and reordering would be a big hassle. Solution? Real numbers! If you have 1 and 2 and you want 3 to be between them, you set it to 2.5! or if you want to displace 2 with 5 you set 2 to 1.5 (or 2.5) and just set 5 to 2. Of course you'd need some code to find the midpoint ((x+y)/2). But that's no big deal.

Now, I'd like to think that I would have come up with that (simpler) solution originally if I hadn't already assumed the database format that we have. Although the first form was fun to come up with it is inferior to this. Id's should really be forever, and ordering shouldn't change the id of a thing. Anyway, keep that in mind when you do your rewriting and reverse engineering. Think of the data as it would be if you'd made it originally, and simpler solutions may come to you out of the blue.
