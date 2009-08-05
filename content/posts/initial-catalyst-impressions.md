---
aliases: ["/archives/1039"]
title: "Initial Catalyst Impressions"
date: "2009-08-05T04:16:41-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=1039"
---
I've been using Catalyst at home for nearly six weeks now and I guess two weeks at work. I feel that now is a good time for me to list some of my impressions.

The angle that I am coming from is _mostly_ [CGI::Application](http://search.cpan.org/perldoc?CGI::Application), which means very bare bones.

The first thing that I got for free with Catalyst was **configuration file support**. Less than a week after switching to Catalyst our customer asked me if we could change the database connection easily. Previously I had that set in an environment variable in the Apache config. Although that's still something my customer could easily do, it's certainly not as easy as other forms of configuration.

**Chained Actions** are an interesting way to allow code reuse in Catalyst controllers. Basically they allows one to automatically call a number of methods in a given order automatically based on the path. One would typically set various per-request values (stash) in the chained methods. The following is an example.

    method load_req($c, $id): Chained('/') PathPart('groups') CaptureArgs(1) {
       my $user = $c->user->obj;
       $c->stash->{group} = $user->created_groups->find($id);
    }

    method view($c): Chained('load_req') PathPart('') {
       $c->stash->{selected} = { map { $_->id => 1 } $c->stash->{group}->users };
       $c->stash->{template} = 'groups/view.tt';
    }

    method add($c) :Chained('load_req') PathPart('add') {
       my $group = $c->stash->{group};
       my $user = $c->user->obj;

       # find people who are already friends
       my $friends_to_add = $user->friends->search({
             id => { -in => $c->req->params->{friends} }
          });

       while (my $friend = $friends_to_add->next) {
          $group->add_to_users($friend);
       }

       $c->response->redirect(
          $c->uri_for( $c->controller('Group')->action_for('view'), [$group->id] )
       );
       return;
    }

So basically how that works is that _/groups/1_ will call _load\_req_ and then _view_ whereas _/groups/1/add_ will call _load\_req_ and then _add_. You can see that because load\_req starts the chain ('/'), names itself groups (PathPart), and then says it takes a single argument (CaptureArg). But it cannot be called directly, because it's not an endpoint. Any argument with CaptureArgs is not an endpoint. This isn't a tutorial, so I won't try to explain it in depth. Either way, it can significantly increase code reuse.

**Flexibility** is another great thing about Catalyst. [Catalyst::Action::REST](http://search.cpan.org/perldoc?Catalyst::Action::REST) allows one to easily use Catalyst in a RESTful manner. It automatically handles serialization, deserialization, and dispatching. Here's the cool thing; when there is an error in my app at work it needs to return a 500 as well as valid JSON. A REST controller will return an html error if there are errors. I don't want to override the end method, because it's what does the deserialization. Moose to the rescue! Basically what I do is define a before method that will put data in the stash if there are errors. Then the real end method runs and outputs the errors as JSON. Again, this isn't a Moose tutorial, so I won't show all the details. Maybe another post.

Of course because of the increase complexity Catalyst is harder to learn, but I haven't actually found it that much harder than CGIApp. It's nice and regular, so once you know where to look in the doc for what you need it's not that bad. Although I guess that's the same as most large projects :-)
