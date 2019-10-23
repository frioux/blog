---
title: My Mobile (shell) Home
date: 2017-03-08T07:55:10
tags: [ zsh, shell, dotfiles, ziprecruiter, toolsmith ]
guid: ADFBE902-03B5-11E7-87B3-BB5D0757C320
---
At work I ssh into a lot of machines.  I recently came up with a script that
would ensure that [my dotfiles](https://github.com/frioux/dotfiles) would be
deployed to any server I have access to quickly and reliably.

<!--more-->

I tweak my dotfiles constantly.  I work hard and experiment regularly to make my
day-to-day work as effortless as possible.  For a long time I decided to just
live with an unconfigured `bash` on the servers that I connect to, but
eventually I got fed up and decided to attempt to ensure that my dotfiles would
be on any server I connect to.  I came up with a three part solution.

## `fressh`

[`fressh`](https://github.com/frioux/dotfiles/blob/2637749d5d5c7ce0470ffdf53d7eb237e6834aad/bin/fressh),
for Fresh Secure Shell or fREW's Secure Shell, is a simple tool that I run as a
replacement for ssh.  Currently the code is:

```
#!/usr/bin/env perl

use strict;
use warnings;

# TODO: make this work for ssh options
my $host = shift;

if (!@ARGV) {
   system('ssh', $host, <<'SH');
   set -e
   mkdir -p $HOME/code
   if [ ! -d $HOME/code/dotfiles ]; then
      set -e
      timeout 20s git clone --quiet git://github.com/frioux/dotfiles $HOME/code/dotfiles
      cd $HOME/code/dotfiles
      ./install.sh
   fi
   exit 0
SH

   if ($? >> 8) {
      warn "git clone timed out; falling back to rsync\n";

      system('rsync', '-lr', "$ENV{DOTFILES}/", "$host:code/dotfiles/");

      system('ssh', $host, 'cd $HOME/code/dotfiles; ./install.sh')
         unless $? >> 8;
   }
}

exec 'ssh', $host, @ARGV
```

It first tries to connect to the server, pull down my dotfiles from github, and
then run the install script.  I found that some servers, every now and then,
will have the `git://` protocol blocked, so the initial clone would take forever
to simply time out.  As you can see in the script above, I used [`timeout` from
the GNU
coreutils](https://www.gnu.org/software/coreutils/manual/html_node/timeout-invocation.html)
to limit it to a total of 20 seconds.

If the timeout fails I'll get a non-zero exit code from `ssh` and fall back to
`rsync`ing my dotfiles from my laptop to the remote server, and then, assuming
that works, I again run the installer.

This doesn't work if I pass argments to `ssh` but that is so rare that I haven't
run into it yet.

## `install.sh`

Lots of people have installers for their dotfiles.
[Mine](https://raw.githubusercontent.com/frioux/dotfiles/6415fe0109fda63fca274af426092db5a0cc748c/install.sh)
isn't very special except that it is fairly simple and predictable.  The one bit
that I think is worth showing off is this:

```
echo "[submodule]\n\tfetchJobs = $(cat /proc/cpuinfo | grep '^processor' | wc -l)\n\n" > ~/.git-multicore

git submodule update --init
```

The above ensures that when I check out submodules I'll use as many cores are on
the machine, and I put it in a config file ([which I have git configured to
source](https://github.com/frioux/dotfiles/blob/78cbb349f2cfaa13e812c2bb517468577e47beac/gitconfig#L103)),
so if I am on a server that has a git that doesn't support parallel submodule
fetching it gracefully falls back to a single thread.

Of course immediately after setting up that file, I load the
([many](https://github.com/frioux/dotfiles/blob/697d82d108da5783fe738d52f7bbc265bbf6702a/.gitmodules))
submodules I use for my dotfiles.

## Auto Update

Finally, I hate to check to see if a shell needs to be updated every time it
starts, but I also hate to have to check and update it by hand.  I devised an
interesting workaround.

When my installer runs, it sets itself (the installer) as a git hook that
basically runs after I do a pull:

```
link-file install.sh .git/hooks/post-checkout
link-file install.sh .git/hooks/post-merge
```

Next, when my shell starts, I check a special file to see if I need to update
the shell.  All I'm doing is comparing the contents of the file to the current
epoch, so it's fairly efficient.  I could probably tweak it to to use file
metadata but I haven't gotten around to it and doubt I ever will:

```
if [[ $EPOCHSECONDS -gt $(cat ~/.dotfilecheck) ]]; then
   echo "Updating .zshrc automatically ($EPOCHSECONDS -gt $(cat ~/.dotfilecheck))";
   echo $(($EPOCHSECONDS+60*60*24*7)) > ~/.dotfilecheck
   git --work-tree=$DOTFILES --git-dir=$DOTFILES/.git pull --ff-only
fi
```

So the script simply does a `git pull` if I haven't done one in about a week.
Because I linked the installer to a git hook, after the pull succeeds in pulling
new refs, the installer will automatically be triggerd and it will set up any
new files, update submodules, etc.

---

I've considered making my dotfiles be driven by some other framework like
[...](https://github.com/ingydotnet/...) or
[omz](https://github.com/robbyrussell/oh-my-zsh), but I keep running in to
places where having a simple, reliable installer is completely sufficient and often
superior.

(The following includes affiliate links.)

If you enjoyed this and would like to learn more, check out <a target="_blank"
href="https://www.amazon.com/gp/product/1590593766/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1590593766&linkCode=as2&tag=afoolishmanif-20&linkId=2bd3ad2595009095eb903ec70228a570">From
Bash to Z Shell: Conquering the Command Line</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1590593766"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  That's the book I used to learn shell and I continue to find
it an excellent reference.
