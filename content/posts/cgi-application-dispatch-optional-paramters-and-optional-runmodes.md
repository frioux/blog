---
aliases: ["/archives/66"]
title: "CGI::Application::Dispatch, optional paramters and optional runmodes"
date: "2009-01-14T22:00:30-06:00"
tags: ["cgiapp", "cgiapplication", "perl"]
guid: "http://blog.afoolishmanifesto.com/archives/66"
---
So I haven't totally figured everything out about CGI::Application::Dispatch, but I am learning a lot. First off, here are two things that I learned today.

    package ACD::Dispatch;
    use base 'CGI::Application::Dispatch';
    use warnings;

    sub dispatch_args {
        return {
            prefix  => 'ACD',
            debug => 0,
            table   => [
                '/'  => {
                    app => 'Welcome',
                    rm => 'index'
                },
                # The rm must be optional if you want
                # /controller to go to the startrunmode.
                ':app/:rm?/:foo?' => { },
            ],
            args_to_new => {
                PARAMS => {
                    cfg_file => '/path/to/config.pl',
                }
            },
        };
    }

    1;

Now, notice the :foo param. If you want to get access to that in your controller you use

    $self->param('foo')

but if you had a regular parameter as well and wanted to get access to that, you'd use

    $self->query->param('bar')
