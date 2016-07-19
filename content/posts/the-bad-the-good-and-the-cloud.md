---
title: The Bad, The Good, and The Cloud
date: 2015-09-07T22:20:56
tags: [frew-warez, aws, cli]
guid: "https://blog.afoolishmanifesto.com/posts/the-bad-the-good-and-the-cloud"
---

# The Bad

This weekend I was working on a little project that involved manipulating a
fairly large (1.8 gB compressed, 17 gB uncompressed) 7zip archive.  I don't have
17 gB to uncompress to on my laptop and a *significant* amount of the archive
was uninteresting to me.  I thought it would be sortav fun and worthwhile to
remove the files that are not needed, so I ran a `man 7zr` and started reading.

Reading [the
manpage](http://manpages.ubuntu.com/manpages/vivid/man1/7zr.1.html), it seems
like one could do:

```
7zr d foo.gz file/to/delete.txt
```

Alas, for no obvious reason, that does exactly nothing.  Instead, after some
googling, the [recommended method
is](https://www.ibm.com/developerworks/community/blogs/6e6f6d1b-95c3-46df-8a26-b7efd8ee4b57/entry/how_to_use_7zip_on_linux_command_line144?lang=en):

```
7zr -d foo.gz -r delete.txt
```

Of course the manpage (which the document idiotically parrots) says:

```
-r[-|0]
   Recurse subdirectories (CAUTION: this flag does not do what  you
   think, avoid using it)
```

So fine, we have a way to do that, but with an archive this big it takes minutes
to delete a single file, and my archive has something like eleven thousand
files.  I think I did the math and my computer would take nearly two weeks to
delete the files assuming a linear rate that decreased as files were deleted.

The manpage also mentions the `-si` flag:

```
-si    Read  data  from  StdIn  (eg:  tar  cf  -  directory | 7zr a -si
       directory.tar.7z)
```

I'm not totally clear what that is telling me.  I figured I'd try what was
obvious to me:

```
echo file/to/delete.txt | 7zr d -si foo.7z
```

That replaces the entire archive with an empty archive.  Worthless.

# The Good

So while that is all terrible, Unix is pretty great.  To delete (some of) the
files I don't care about I can do:

```
7zr l foo.7z  | \
  grep 'yawn' | \
  cut -b60-   | \
  xargs -d '\n' -n1 -I{} \
  7zr d foo.7z -r {}
```

This writes a temp file in the current directory (instead of `$TMPDIR`, wah
wah), so copying it to /run/shm so that it's 100% in memory helps a tiny bit,
but not enough to be sensibly fast.

On top of the command above, I wrote a couple other commands to see my progress:

```
megs() perl -E'printf "%0.02f mB\n", (((stat "old.7z")[7] - (stat "new.7z")[7])/1024/1024)'
```

```
newcount() { 7zr l $HOME/tmp/new.7z | grep 'yawn' | wc -l }
new() { local old=5365; local new=$(newcount); echo $(( $old - $new )) }
```

Those were really handy when I was checking my deletion progress.  Unfortunately
I defined them in the shell so I had to make sure to only run them from the
window I defined them in.  I then decided to write this tool, which allows
definition of new commands *almost* as simply as defining a function in the
shell.

Usage:

```
fn dumb-echo perl -E'say "dumb"'

fn dumb-count 'ls | wc -l'
```

The code is
[here](https://github.com/frioux/dotfiles/blob/b3e5ec7a345a1d1442d05643e013a853ea99e5af/bin/fn);
feel free to let me now if you have ideas on improvements.

I've been wanting to do something like this for a while, so that was pretty fun
and rewarding.

Sadly, even after all of that, it was still too slow on my laptop.

# The Cloud

So instead of leaving my laptop running at circa 50% CPU for two weeks, I
figured out a better solution: use AWS to extract the entire archive, delete the
files I don't want, and recreate the archive.  On top of that I suspect that it
would be worth it for me to use something like tgz instead of the poorly
interfaced and implemented 7z.

So in the course of 2 hours I both got a new free tier AWS account (I lost the
credentials for my other one), spun up a machine, and started the upload of the
archive.  I had to get a larger than default (but still free) EBS volume or the
extracted archive wouldn't fit.  After that it was almost literally:

```
scp foo.7z $mymachine:foo.7z
ssh $mymachine
sudo apt-get install p7zip
7zr e foo.7z
rm *yawn*
tar c foo.tar foo
gz foo.tar
exit
scp $mymachine:foo.tar.gz foo.tgz
```

Sadly and maybe unsurprisingly I discovered that gzip was terrible for these
kinds of binaries.  I ended up just using rsync with compression to get the
remaining 5 gB of files after cleaning them up.
