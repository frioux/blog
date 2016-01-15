---
title: Checking sudoers with visudo in SaltStack
date: 2016-01-14T23:45:33
tags: ["salt", "saltstack", "sudoers", "check_cmd"]
guid: "https://blog.afoolishmanifesto.com/posts/checking-sudoers-with-visudo-in-saltstack"
---

At [work](https://ziprecruiter.com) we are migrating our server deployment setup
to use [SaltStack](http://saltstack.com/).  One of the things we do at deploy
time is generate a sudoers file, but as one of our engineers found out, if you
do not verify the contents of the sudoers file before deploying it you will be
in a world of hurt.

Salt actually has a pretty good built in tool for this, but it's very poorly
documented.  This is one of the most obvious uses for it and because Googling
for it didn't work for me I figured I'd make it work for someone else.

The feature is the `check_cmd` flag on
[`file.managed`](https://docs.saltstack.com/en/latest/ref/states/all/salt.states.file.html#salt.states.file.managed).
The current documentation for the feature is:

> The specified command will be run with the managed file as an argument. If the
> command exits with a nonzero exit code, the state will fail and no changes
> will be made to the file.

This isn't super clear.  It takes the generated content, puts it in a
tmpfile, runs the command + the tmpfile path, and then replaces the real contents
with the tmpfile.  So here is how I used it to verify sudoers

```
sudo.config_file:
  file.managed:
    - name: {{ sudo.config_file.name }}
    - user: root
    - group: root
    - mode: 0440
    - source: {{ sudo.config_file.source }}
    - template: {{ sudo.config_file.template }}
    - check_cmd: /usr/sbin/visudo -c -f
    - require:
      - pkg: sudo
      - group: sudo
```

Hope this helps!
