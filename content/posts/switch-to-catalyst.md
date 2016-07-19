---
aliases: ["/archives/937"]
title: "Switch to Catalyst!"
date: "2009-07-17T22:10:21-05:00"
tags: [mitsi, catalyst, cgi-application, perl, regular-expressions, vim]
guid: "http://blog.afoolishmanifesto.com/?p=937"
---
So this week, [as previously alluded to](/archives/939 I had used the initial
success of the subclass of S::L for leverage in a certain bargain, which I hope
to post about soon.), I convinced my boss to let me switch my current app from
[CGI::Application](http://search.cpan.org/perldoc?CGI::Application) to
[Catalyst](http://search.cpan.org/perldoc?Catalyst::Runtime). I had gotten [the
book](http://www.amazon.com/Definitive-Guide-Catalyst-Maintainable-Applications/dp/1430223650?&camp=2486&linkCode=wey&tag=enligperlorga-21&creative=8882)
in the mail and I showed it to him to make the point that it's a serious
framework. Fortunately the switch has been mostly painless. The first reason
being that our controller is pretty bare right now aside from validation, which
took about a day to get entirely ironed out.

The interesting thing for me, most of all, is that I have gotten pretty good at
writing regular expressions with vim to search and replace for CGIApp-isms to
replace with Cat-isms.

Here are a list of some of the big ones:

Simple replacements:

    :%s/return/$c->stash->{json} =
    :%s/$self->query->Vars/$c->request->params

More complex stuff

    :%s/$self->query->param(\(.\{-}\) = $c->request->params->{\1}
    :%s/method (.\{-}) : Runmode/method \1($c) : Local
    :%s/$self->schema->resultset(\s*'\(.\{-}\)'\s*) = $c->model('DB::\1')

If you know anything about regular expressions you know that the \\1 means the
first back reference. Now, vim's regex flavor is a little strange because it is
optimized for searching for plain text, so \*most\* characters default to
literals. That's why I have to escape the parentheses to make a matching group.
Also note the following unusual construct: **.\\\{-\}** . That's the same as
**.\*?** in Perl. That's actually surprisingly important.

Anyway, this switch has been fairly fun and exciting. The best part being the
inimitable structure of a Catalyst application. For example, the fact that we
have a dev server with lots of affordances for (duh) developers other than
little setup is great, and built in config file reading is something that I have
always wanted. We always ended up rolling our own solution in other projects,
but this is really supreme since it's in one place and not just Perl code.

An there are lots of pleasant things like how it's really easy for our app to
have both JSON and TT support. This will be really good later on when we start
to do pdf printouts and whatnot. Instead of adding methods for those things into
the controller, like in CGIApp, we will just add another View module.

The main thing that has weirded my out so far is that in CGIApp the App **is**
the controller. In Catalyst you have an App, which also seems to be an instance
variable, with accessors for CGI parameters and whatnot, and you also have
Controllers. Anyway, I need to wrap my head around all that. Hopefully reading
through [the
book](http://www.amazon.com/Definitive-Guide-Catalyst-Maintainable-Applications/dp/1430223650?&camp=2486&linkCode=wey&tag=enligperlorga-21&creative=8882)
will help with some of these issues.

How about you? Are you still happy with CGIApp? Are you adventurous enough to
use Reaction?
