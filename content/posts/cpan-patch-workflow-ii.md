---
title: CPAN Patch Workflow II
date: 2015-08-11T17:37:18
tags: [cpan, perl, git, github, git-hub, git-cpan]
guid: "https://blog.afoolishmanifesto.com/posts/cpan-patch-workflow-ii"
---
[A couple of weeks ago I wrote an article about my CPAN Patch
Workflow](/posts/cpan-patch-workflow/), but mentioned that I couldn't use it
with older projects that do not use Github for patches.  This was due to my git
configuration being subtly different from Yanick's.  Basically when I was
running `git send-email`, I was being prompted for some input, notably the
password to send email, as well as a confirmation dialog.

I spent a few hours writing up some patches to Git::CPAN::Patch and resolved all
of the issues I was running into, and the changes [were
released](https://metacpan.org/changes/distribution/Git-CPAN-Patch#L3-14) the
other day!

If you care to send patches to [RT](https://rt.cpan.org/), these details might
help you.

First, configure the normal email settings in your _.gitconfig_:

```
[sendemail]
    smtpEncryption = tls
    smtpServer = smtp.gmail.com
    smtpUser = myaddress@gmail.com
    smtpServerPort = 587

```

If you are weird like me and [keep your dotfiles in
github](https://github.com/frioux/dotfiles), create another file called
_.git-smtp-password_ and put this in it:

```
[sendemail]
   smtpPassword = $password
```

and finally add this to your _.gitconfig_:

```
[include]
   path = ~/.git-smtp-password

```

And it's probably a good idea to `chown 600` the _.git-smtp-password_.

Hope this helps!
