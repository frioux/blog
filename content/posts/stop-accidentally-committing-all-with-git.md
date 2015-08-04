---
aliases: ["/archives/1653"]
title: "Stop accidentally committing all with git"
date: "2011-08-29T06:59:49-05:00"
tags: ["git", "perl"]
guid: "http://blog.afoolishmanifesto.com/?p=1653"
---
One of the things that annoys me a lot when using git is if I go through a lot of work to stage some changes, probably using `git add -p` to stage parts of files, and then from muscle memory I type `git ci -am 'lolol I dummy'`. If you didn't know the -a says commit everything, so then of my painstaking staging is gone.

Well, on Thursday I finally fixed this problem. I wrote the following, very basic, git wrapper. All it does is:

- Find all aliases for commit
- Check if the current command is a commit or commit alias
- Check if the current arguments have -a or --all
- Check if there are staged modifications
- And if all of those conditions are true, it prompts the user to ensure that they actually want to commit all.

I'm fairly happy with the alias detection; the only thing it should also do is introspect the arguments in the values of the alias as well as the current command. I don't have any aliases like that, but if I wanted to make this a canned solution that would be a must.

The arguments detection is actually **very** dumb. It wouldn't work if you did `git ci -m 'Foo' -a`. I'm ok with that because this is to battle my own muscle memory and I would never type that. But it is definitely a spot for improvement.

The staged checking I am very happy with. It **only** checks for staged modifications. So if you add a new file or delete a file and then do `git ci -am "station"` it will happily go on it's way, which I like.

Anyway, here's the script. To install it just put it somewhere in your path as wrap-git (I use ~/bin) and alias git=wrap-git

```
#!/usr/bin/env perl

use strict;
use warnings;

my %aliases = map { split(/\n/, $_, 2) }
   split /\0/,
   `git config -z --get-regexp alias\\.`;

my %commit_aliases = (( commit =&gt; 1 ),
   map { s/alias\.//; $_ =&gt; 1 }
   grep $aliases{$_} =~ /^commit\b/,
   keys %aliases);

my ($command, @args) = @ARGV;

if ($commit_aliases{$command} &amp;&amp; $args[0] =~ /^-a|^--all/) {
   my @staged = grep /^M/, split /\0/, `git status -z`;
   if (@staged) {
      print "There are staged changes, are you sure you want to commit all? (y/N) ";
      chomp(my $answer = <stdin>);
      if ($answer =~ /^y/i) {
         run_command()
      }
   } else {
      run_command()
   }
} else {
   run_command()
}

sub run_command {
   system 'git', $command, @args;
   exit $? &gt;&gt; 8;
}
```

One thing I think would be **really** cool would be to make a WrapGit.pm and wrap-git would just be coderefs passed to WrapGit.pm. I'd love to have full introspection of all git commands and arguments. It would let me do things like keep statistics about how you use git, maybe make a powerful achievement system, make more commands prompt the way this one does. Anyway, I'll probably do that one of these days when I finish all the other stuff on my list :-)
