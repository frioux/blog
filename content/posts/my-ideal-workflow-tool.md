---
aliases: ["/archives/1561"]
title: "My Ideal workflow tool"
date: "2011-07-12T01:08:09-05:00"
tags: [frew-warez, git, workflow]
guid: "http://blog.afoolishmanifesto.com/?p=1561"
---
1. **super fetch**:
  - git fetch
  - git fetch --tags
  - git pull --ff-only (all local branches)
  - git reset --hard (specified branches)
2. **pull issues**:
  - "rebase" issues from github
  - "rebase" issues from RT
  - "rebase" issues from JIRA
  - sync issues from remote repo
3. **super status**:
  - Dirty?
  - Non-Tracking branches? How many?
  - Ahead tracking branches? How many commits total?
  - Unmerged branches?
  - Unreleased master? (no tag)
  - How many issues?

[My last post](/archive/1557) was about Distributed Issue Tracking. The above is why I'd be so interested in DIT. When I want to code I could sit down, run **super fetch**, run **pull issues**, and then run **super status**.

# **super fetch**

**super fetch** is pretty simple and self explanatory, except for one part, the **git pull --ff-only**. It uses an idea I got while speaking with [mjd](http://plover.com). Basically, any branches that track a remote and can be fast-forwarded, should be.

# **pull issues**

**pull issues** uses some as yet unknown tech that imports issues into a git reference (I'd say branch but really I'd rather it not be a head) as well as full, local issue tracking. The idea is that if I want to examine the issues of all of my repos, I don't want to have to go to a website to see all of them.

# **super status**

**super status** builds upon the ideas explored with
[genehack's](http://genehack.org/)
[App::GitGot](https://metacpan.org/module/App::GitGot). Specifically, the status
command. It lists some of the information above, and is still totally awesome,
just not enough. Without colors, I think I'd format the output something like
this:

Optional the following would be prepended to the list:

    D      dirty?
    !TP    non-tracking branches
    !PC    total unpushed commits
    !MB    total unmerged branches
    !RC    unreleased commits
    I      issues

    Repository Name                         D !TP !PC  !MB  !RC   I

    ACDRI                                   N   0   0    0    0   0
    Arduino                                 N   0   0    0    0   0
    Catalyst                                N   0   0    0    0   0
    Catalyst-View-CSS-Minifier-XS           N   0   0    0    0   0
    Catalyst-View-JavaScript-Minifier-XS    N   0   0    0    0   0
    Class-Accessor-Grouped                  N   0   0    0    0   0
    Config-ZOMG                             N   0   0    0    0   0
    DBIx-Class                              N   0   0   57    0   0
    DBIx-Class-Candy                        N   0   0    0    0   0
    DBIx-Class-DeploymentHandler            N   0   0    0    0   0

    Repository Name                         D !TP !PC  !MB  !RC   I

    DBIx-Class-Helpers                      Y   0   0    0    0   0
    DBIx-Class-Schema-Auth                  Y   0   0    0    0   0
    DBIx-Exceptions                         N   0   0    0    0   0
    Data-Dumper-Concise                     N   0   0    0    0   0
    Git-Conversion-Book                     N   0   0    0    0   0
    Git-Conversions                         N   0   0    0    0   0
    Harmony                                 N   0   3    0    0   0
    Log-Contextual                          N   0   0    0    0   0
    Log-Sprintf                             N   0   0    0    0   0
    Log-Structured                          N   0   0    0    0   0

    Repository Name                         D !TP !PC  !MB  !RC   I

    Lynx                                    N   0   0    0    0   0
    Lynx-SMS                                N   0   0    0    0   0
    Moo                                     N   0   0    0    0   0

It would all be optionally color coded. Also, optionally the "good value" (usually zero) would be blank.

In addition to the output above there will be increasing verbosities to actually list the things being counted etc.

Anyway, I'm gonna start on the **super status** tonight, and I figured this would be a nice way to flesh out my thoughts. If anyone is interested in this let me know, I welcome feedback. I'll probably implement it all in perl, as bash might be tough for something like this.

**Update: I got it mostly working!** ![](/wp-content/uploads/2011/07/shot.png)

This takes a few commandline options and you can configure the defaults using git's standard config tool. I probably need to consider the names of the switches and config, as well as write some doc, but it definitely works, which is very neat. Next I'll probably want to add those verbosity flags, but really, I should deal with all those issues with my repos. I need to figure out how to suppress stuff I don't care about too...
