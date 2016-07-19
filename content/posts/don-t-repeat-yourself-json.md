---
aliases: ["/archives/739"]
title: "Don't Repeat Yourself: JSON"
date: "2009-05-19T00:58:43-05:00"
tags: [perl]
guid: "http://blog.afoolishmanifesto.com/?p=739"
---
With DBIx::Class we typically have a TO\_JSON method which returns a hashref of the data you want in your json. Here's an example:

    sub TO_JSON {
       my $self = shift;
       return {
          id => $self->id,
          name => $self->name,
          comments => $self->comments,
          email => $self->email,
          job => $self->job,
          ok => $self->ok,
          i_cant => $self->i_cant,
          think_of => $self->think_ok,
          anymore => $self->anymore,
       };
    }

Here's the shorter version mst inspired me to write:

    sub TO_JSON {
       my $self = shift;
       return {
          map { $_ => self->$_ }
             qw{ id name comments email job
                ok i_cant think_of anymore },
       };
    }

Anyway, not very complex, but still awesome.
