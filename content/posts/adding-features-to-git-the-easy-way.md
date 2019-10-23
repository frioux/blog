---
title: Adding Features to Git the Easy Way
date: 2017-03-10T08:00:43
tags: [ git, toolsmith, ziprecruiter ]
guid: F32DE988-F395-11E6-AADF-CC9688F70C31
---
I have added a handful of features to git.  The features are not perfect and
most people can't use them, but they are easy to prototype and I can polish them
before writing and submitting a proper patch to git.git.

<!--more-->

Here are some of the features I've implemented for git:

 * If I try to `commit -a` but have already staged changes I get a prompt
 * Checking out a branch from master does *not* track master
 * If I forget the first argument to `remote add` it defaults to `origin`
 * Globs in `.git/info/grep-exclude` exclude files from matching in `git grep`

I haven't yet tried to implement any of these for git both because my C is not
great and I am not *super* interested in going through the effort of getting the
patches accepted, especially when what I have now works!

So how do I do it?

## The `git` Wrapper

I have a relatively simple [perl script called
`git`](https://github.com/frioux/dotfiles/blob/8f901d9995efefc067bc315207d42a775cbdeced/bin/git)
that just tweaks the arguments to `/usr/bin/git`.

Most of the features are one liners.  For example here's the full "don't
accidentally track master:"

```
} elsif ($checkout{$command} && ( grep /^-b/i, @args ) && ( grep /^origin\/master/, @args )) {
   unshift @args, '--no-track';
```

And then at the end of the program I simply
`exec '/usr/bin/git', $command, @args`, more or less.

Obviously this is not bulletproof, but these features only need to work for me
and how I use git; so I can keep them pretty simple.

I can't decide if I am more proud of the "prompt because of staged changes"
feature or "grep-exclude" feature.

The former is super convenient because I'll do `git add -p` to stage a bunch of
small chunks from various files and then accidentally do `git commit -am derp`.
This protects me from that mistake.

The latter is awesome because at
[ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) our repository
has huge swaths of stuff that tends to show up in grep results often but is
never, ever what I'm looking for.  A good example is a file with a huge list of
stemmed words in English.   So I simply added that file to
`.git/info/grep-exclude` and it never shows up.  Even cooler, because I use `git
grep` from vim, it gets automatically excluded there too.

---

Sometimes when I make these tools, I forget about them or never really get into
the habit of using them regularly.  I probably use this ten times a day (because
of how hard I lean on `git grep`.)  It's nice to have one that was such a home
run.

---

(The following includes affiliate links.)

If you'd like to learn more about git I highly recommend <a target="_blank"
href="https://www.amazon.com/gp/product/1484200772/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1484200772&linkCode=as2&tag=afoolishmanif-20&linkId=185ee1604974476f63e03163172de0c2">Pro
Git</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1484200772"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.

If you are interested in getting better at making tools, or at least taking a
more thoughtful approach, I would consider <a target="_blank"
href="https://www.amazon.com/gp/product/020103669X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=020103669X&linkCode=as2&tag=afoolishmanif-20&linkId=a38b47ed22bdd5bdf2e26c97a6d9f798">Software
Tools by Kernighan and Plauger</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=020103669X"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  I don't think that weird wrapper scripts are covered, but
it's still somewhat related.
