---
aliases: ["/archives/822"]
title: "DBIx::Class vs Class::DBI vs Rose::DB::Object vs Fey::ORM"
date: "2009-06-19T03:24:22-05:00"
tags: ["cdbi", "classdbi", "dbix-class", "feyorm", "orm", "perl", "rosedbobject"]
guid: "http://blog.afoolishmanifesto.com/?p=822"
---
Recently (6 monthsish ago) I decided on an ORM to use at $work. It was pretty hard to make a decision because I'd never really used an ORM for a significant amount of time. Now that I am pretty confident with my chosen ORM I feel like I can make a more informed comparison.

I'm going to skip over the basics of declaring classes themselves. Often when researching ORM's this is the main thing that people look at. Unfortunately it's (in my opinion) not **that** important. As long as everything you want to do is supported, the base model class should just stay out of your way. Recently there have been complaints about the aesthetic appeal of things like DBIC. I prefer to look at conceptual beauty rather than syntactic.

I'd rather focus on major differences in underlying structure, and more importantly, how searches work. I do a lot more searches than I do anything else, and I'd bet that's the same for you, after you do more than just the basic structure of your app.

So without further ado, the contenders.

# [Class::DBI](http://search.cpan.org/~tmtm/Class-DBI-v3.0.17/lib/Class/DBI.pm)

26 releases in 5 years. The most recent is from 2007. 2 authors, 33 credited. The oldest of the discussed ORMs.

Searches are extremely simple, being limited to == and LIKE queries. Here's an example:

    # ==
    @cds = Music::CD->search(title => "Greatest Hits", year => 1990);

    # LIKE
    @cds = Music::CD->search_like(title => 'Hits%', artist => 'Various%');

You can do more complex things, but it's really just writing SQL and giving that SQL search a name. A SQL dictionary approach you might say. Also note that the above returns an entire array of results, which is Not Great. You can use an iterator though for performance....but it still pulls it all into memory; it just doesn't instantiate the objects right away, which is a little better, but still Bad.

A cool feature CDBI has is triggers for the lifecycle of the object. The triggers listed in the docs are:

1. before\_create (also used for deflation)
2. after\_create
3. before\_set\_$column (also used by add\_constraint)
4. after\_set\_$column (also used for inflation and by has\_a)
5. before\_update (also used for deflation and by might\_have)
6. after\_update
7. before\_delete
8. after\_delete
9. select (also used for inflation and by construct and \_flesh)

CDBI also has built in constraints, so you can do validation in your model.

Both of these can be done with regular OO in all of the other ORM's, but having a predefined naming scheme for things like this helps people to quickly learn what's going on.

# [Rose::DB::Object](http://search.cpan.org/~jsiracusa/Rose-DB-Object-0.781/lib/Rose/DB/Object.pm)

70 releases in 3 years. The most recent is two months ago. 1 author, 11 credited.

Written with speed in mind. Be aware that because of these manual optimizations the code is harder to maintain. I was told this by one of the contributors to the project. But you do get very good speed (supposedly, I haven't done any tests myself) because of it.

Here's a basic Rose::DB::Object search. It returns an arrayref, which isn't optimal, but you can get an iterator just as easily.

    $products =
          Product::Manager->get_products(
            query =>
            [
              name => { like => '%Hat' },
              id   => { ge => 7 },
              or   =>
              [
                price => 15.00,
                price => { lt => 10.00 },
              ],
            ],
            sort_by => 'name',
            limit   => 10,
            offset  => 50);

From my perusing of the docs it seems that Rose basically has all of the perl data-structure based searches that one would hope for in an ORM that abstracts away most SQL.

# [DBIx::Class](http://search.cpan.org/~ribasushi/DBIx-Class-0.08107/lib/DBIx/Class.pm)

62 releases in almost four years. Most recent being days old. One "author," 69 credited. It is very much made for the convenience of the programmer. The .09 series will be Moose-based. [See slides](http://www.shadowcat.co.uk/catalyst/talks/-npw-2009/future-of-dbix-class.xul) for proof.

Here's an example of a relatively complex search with DBIx::Class.

    my $results = $schema->resultset('Artist')->search({
       first_name => 'frew',
       last_name => [             # arrayrefs mean or by default
          { -like => 'schmi%' },
          { -like => 'stat%'   },
       ]
    },{
       page => 2,
       rows => 25,
       order_by => { -desc => [qw/last_name first_name/] }
    });

What I think is really great about DBIx::Class is the fact that you can _chain searches_. I really dig this feature. It lets me do things like this:

    $rs = $schema->resultset('Artist')->search({
       first_name      => $self->query->param('name'),
       'friend.height' => 6*12+1,
    },{
       join => 'friend'
    });

    # imagine this is in another method (because it is)
    $rs = $rs->search(undef, {
       page => $self->query->param('page'),
       rows => $self->query->param('rows'),
    });

    # imagine this is in another method (because it *also* is)
    $rs = $rs->search(undef, {
       order_by => {
          q{-}.$self->query->param('direction') =>
             $self->query->param('sort')
       }
    });

    # and maybe some permissions stuff
    $rs = $rs->search({
       current_user => $self->user
    });

And most importantly, this is a single SQL query, not four.

I also need to mention that the DBIx::Class people have really helped me help them, which is not just a good feeling, I use the features I've added in production code. I can say for certain that working on their codebase has made me a better OO programmer.

# [Fey::ORM](http://search.cpan.org/~drolsky/Fey-ORM-0.24/lib/Fey/ORM.pm)

22 releases in just over a year. One author. This is the newest of the four ORM's reviewed here. Cut it some slack if it doesn't have all the features that the other ones have.

Fey::ORM is made for people who are alright with actually writing SQL. It's very ... OO-y. For example:

    $select->select( $message_t, $user_t )
                 ->from( $message_t, $user_t )
                 ->where( $message_t->column('message_date'), '>=',
                          DateTime->today()->subtract( days => 7 )->strftime( '%Y-%m-%d' ) );

What **I** think is really cool about Fey::ORM is that it has a standard method for creating relationships other than the usual has\_one/has\_many/many\_to\_many. Who wouldn't want to be able to make relationships based on something other than equality? (Seriously though, I'd be able to use that at $work.)

So that's what I gathered from a couple of hours of reading docs on CPAN and a few months of DBIC usage. I really like DBIx::Class, but I can see why people would choose some of the other ORMs. It does seem to me that the only reason to use Class::DBI is that you already have a giant codebase written on top of it. But if that's the case, you could just use DBIx::Class's compatibility layer...

Anyway, hope this was helpful for someone!
