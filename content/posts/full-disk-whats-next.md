---
title: "Full Disk, What's Next?"
date: 2018-02-19T06:50:49
tags: [ perl, shell, unix, ops ]
guid: 7b2eeff6-2f7d-4d77-b8dd-adc216024a55
---
I recently automated yet another part of my disk usage tool.  Read about it
here.

<!--more-->

I have a tool that I wrote to automate the boring and error prone process of
figuring out why a disk is full.  Every time I use it (and I use it
embarassingly often) it works and works well.  Well, until yesterday, but we'll
get to that.

## `where-dem-big-files-at`

You may have debugged a full disk millions of times, and know all of these
tricks.  If so, think about what you would do first if a disk is full and see if
you can guess the anticipated failure modes.

[My script is called
`where-dem-big-files-at`](https://github.com/frioux/dotfiles/blob/a8ac97032a431ef0cefcb62a2318ebb925784934/bin/where-dem-big-files-at),
and it takes a single argument: the path where the disk is mounted.  I'll slowly
build up to the full script.

First, you need to enumerate the files to find the big ones.  The way I do this
is:

```
$ du -akx $path
```

 * `x` says not to descend into another mounted disk; very important
 * `a` says to print sizes of files; useful if one file is using all the disk
 * `k` says we want output in kilobytes instead of some other absurd unit.

So if you ran that you might see output ending like this:

```
696     ./public/tags    
25792   ./public         
16      ./.projections.json                        
12      ./.gitmodules    
16      ./Makefile       
16      ./etc/vim-bundle/hugo/.netrwhist           
16      ./etc/vim-bundle/hugo/plugin/hugo.vim      
24      ./etc/vim-bundle/hugo/plugin               
8       ./etc/vim-bundle/hugo/rplugin              
56      ./etc/vim-bundle/hugo                      
64      ./etc/vim-bundle 
72      ./etc            
16      ./config.yaml    
61512   .  
```

In this example (as is often the case) the largest files are spread throughout
the prior output, which requires careful scrolling, or better yet, sorting.
Here's another improvement:

```
$ du -akx | sort -n
```

Now the output will be as follows:

```
696     ./public/tags    
848     ./public/img     
852     ./static/img     
980     ./static         
2432    ./content/posts  
2440    ./content        
3144    ./public/posts   
20268   ./public/.git/objects                      
20768   ./public/.git    
25792   ./public         
31140   ./.git/objects   
31864   ./.git           
61512   .   
```

Much more useful!  This is a solid typical first move, but I actually found that
it often failed and also could take a really long time in some cases.  Let's
handle the speed first.

It turns out that `sort(1)` supports Unicode out of the box, and further that
the encoding and decoding takes more time than the actual sorting.  In this case
we are further only ever sorting by base ten numbers, so it's totally overkill.
You can speed the sort up hugely like this:

```
$ du -akx | LC_ALL=C sort -n
```

Same output, but possibly much faster.

The other problem you'll run into is that if the disk is full and there are a
lot of files, *`sort` will fail*.  This is because `sort(1)` will spill chunks
to be sorted to disk to avoid running out of memory.  You need to be careful to
avoid spilling these files to the same partition that is full.  The easy
solution here is to do something like:

```
$ du -akx | LC_ALL=C TMPDIR=/mnt/tmp sort -n
```

This assumes you have a `/mnt/tmp` though.  At
[ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) we tend to have a
handful of options for where the files could be spilled.  I automated the
selection as follows:

``` bash
cur_mount="$(df "$whatsbig" --output=target | tail -1)"

for x in /tmp /mnt/tmp /vol/tmp /run/shm; do
   test -e "$x" || continue

   if [ "$(df "$x" --output=target | tail -1)" != "$cur_mount" ]; then
      export TMPDIR="$x"
      break
   fi
done
```

Unfortunately the `--output=target` option of `df` to find out what mount a
directory is on is relatively new.  This detail alone makes me think I should
consider rewriting this script in Go to be able to use the `statfs(2)` syscall.

Ok so this is pretty solid; we have a script that sanely orders the biggest
files, quickly, without accidentally leaning on the full disk.  The full script
looks like this:

``` bash
#!/bin/sh

if [ "$(id -u)" != 0 ]; then
   exec sudo $0 "$@"
fi

set -e

export whatsbig=${1:-/}

cur_mount="$(df "$whatsbig" --output=target | tail -1)"

# sort spills over to temp files
for x in /tmp /mnt/tmp /vol/tmp /run/shm; do
   test -e "$x" || continue

   if [ "$(df "$x" --output=target | tail -1)" != "$cur_mount" ]; then
      export TMPDIR="$x"
      break
   fi
done

du -akx "$whatsbig" > $TMPDIR/big.$$.pid

export LC_ALL=C
cat "$TMPDIR/big.$$.pid" | sort -n > "$TMPDIR/sorted.$$.pid"
rm "$TMPDIR/big.$$.pid"

tail -30 "$TMPDIR/sorted.$$.pid"

echo "\nMore detail in $TMPDIR/sorted.$$.pid"
```

The one major extra detail is that I have the script `sudo` itself
automatically, because otherwise I end up having to do something obnoxious
like:

``` bash
sudo $(which where-dem-big-files-at) /vol
```

Additionally I store the results and display a reasonable subset to avoid
blowing away the entire scrollback.

### What about deleted files?

Unfortunately this is insufficient.  Disks can be completely full and have *no
enumerable files*.  This is because Unix allows you to open a file, delete it,
and continue to read and write from it till you close it.  Only after it is
closed does it truly get deleted.  The easiest way to find said files is to run
a command like this:

```
lsof /some/dir | grep '(deleted)'
```

Yesterday morning I ran into exactly this case: a disk was full but only ~5 gigs
were enumerable, 45 gigs were deleted and held open by a single process.  While
I can remember to do the above when I need to, I *already* have this
`where-dem-big-files-at` tool just for doing such weird things so I don't have
to do the contortions every time.  So I set out to bake this into the tool.

If you look closely at the `lsof(1)` output the first thing you may notice is that
it looks pretty much columnar.  I figured I could use `awk(1)` or `cut(1)` to
extract the fields.  Perversely, it uses spaces, not tabs *and some of the
fields are optional*, which means neither `awk` nor `cut` will work.  I read the
manpage of `lsof` more closely and found the `OUTPUT FOR OTHER PROGRAMS`
section.  Basically it lets you ask for certain fields to be printed in a
machine readable format.  There are two basic formats, one is newline separated
and one is `NULL` separated.  The latter is much easier to parse, so I whipped
up a little Perl script to convert each record to JSON:

``` bash
$ lsof -F0 /some/dir |
   perl -MJSON::PP '-F/\0/' -e'my %ref = map { m/^(.)(.*)$/, $1 => $2 } @F; print encode_json(\%ref) . "\n"' |
   jq .
```

Here is some of the output from that script on my laptop:

```
{
  "": null,
  "L": "frew",
  "R": "8953",
  "c": "Web Content",
  "g": "8754",
  "p": "764027",
  "u": "1000"
}
{
  "": null,
  "D": "0x19",
  "a": " ",
  "f": "DEL",
  "i": "197",
  "l": " ",
  "n": "/dev/shm/org.chromium.kKDwCx",
  "t": "REG"
}
{
  "": null,
  "D": "0x19",
  "a": " ",
  "f": "DEL",
  "i": "52",
  "l": " ",
  "n": "/dev/shm/org.chromium.poNBZt",
  "t": "REG"
}
```

Each single character maps to a meaningful field; some are obvious and some are
not, and the only one that `lsof` promises to include is `p`, which is the `pid`
of the program holding open the file.  Note that `p` is lacking in the latter
two examples.  When I saw this I almost despaired.  But then I read more of the
manpage:

> Three  aids  to  producing  programs  that  can  process lsof field output are
> included in the lsof distribution.  The first is a C header file, lsof_fields.h,
> that contains symbols for the field identification characters, indexes for
> storing them in a table, and explanation strings  that may be compiled into
> programs.  Lsof uses this header file.

> The  second aid is a set of sample scripts that process field output, written in
> awk, Perl 4, and Perl 5.  They're located in the scripts subdirectory of the
> lsof distribution.

I didn't know where those files would be or where to find them on the internet,
but I figured that I could find them locally pretty quickly.  I was right.
First I checked to see if I had an `lsof` package on my system:

```
$ dpkg -l lsof
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name                             Version               Architecture          Description
+++-================================-=====================-=====================-======================================================================
ii  lsof                             4.89+dfsg-0.1         amd64                 Utility to list open files
```

From here it's too easy, just list the files the package installs:

```
$ dpkg -L lsof
/.
/usr
/usr/share
/usr/share/doc
/usr/share/doc/lsof
/usr/share/doc/lsof/00LSOF-L
/usr/share/doc/lsof/README.Debian
/usr/share/doc/lsof/examples
/usr/share/doc/lsof/examples/00MANIFEST
/usr/share/doc/lsof/examples/count_pf.perl
/usr/share/doc/lsof/examples/shared.perl5.gz
/usr/share/doc/lsof/examples/list_NULf.perl5.gz
/usr/share/doc/lsof/examples/big_brother.perl5.gz
/usr/share/doc/lsof/examples/idrlogin.perl.gz
/usr/share/doc/lsof/examples/identd.perl5
/usr/share/doc/lsof/examples/watch_a_file.perl
/usr/share/doc/lsof/examples/xusers.awk
/usr/share/doc/lsof/examples/idrlogin.perl5.gz
/usr/share/doc/lsof/examples/count_pf.perl5
/usr/share/doc/lsof/examples/list_fields.awk.gz
/usr/share/doc/lsof/examples/00README
/usr/share/doc/lsof/examples/list_fields.perl.gz
/usr/share/doc/lsof/examples/sort_res.perl5
/usr/share/doc/lsof/00QUICKSTART.gz
/usr/share/doc/lsof/00FAQ.gz
/usr/share/doc/lsof/copyright
/usr/share/doc/lsof/changelog.Debian.gz
/usr/share/man
/usr/share/man/man8
/usr/share/man/man8/lsof.8.gz
/usr/bin
/usr/bin/lsof
```

Note the various Perl examples.  So I opened up one and read through the source
and realized that, of course, for efficiency `lsof` first prints process
information as a single record *and then* prints each file's information.  It
does not re-print the process info every time, so you basically have to keep
track.  With this information I was ready to build a second tool
(`du-from-lsof`) and bake it into the first:

``` perl
#!/usr/bin/perl

# L user
# n filename
# p pid
# s file size

my %sums; my %r;

while (<STDIN>) {
   chomp;
   my @F = split /\0/, $_;

   %r = (
      p => $r{p}, # process id
      L => $r{L}, # process user

      map { m/^(.)(.*)$/, $1 => $2 } @F
   );

   next unless $r{n} =~ m/ \(deleted\)$/ ;

   $sums{q{(deleted)}} += $r{s};
   $sums{qq{(deleted)/$r{L}}} += $r{s};
   $sums{qq{(deleted)/$r{L}/$r{p}}} += $r{s};

   print "$r{s}\t$r{n}\n";
}

print "$sums{$_}\t$_\n" for keys %sums
```

So the usage is:

``` bash
$ lsof -F 0Lnps /some/dir | du-from-lsof
```

Example output, after sorting:

```
268238848       /dev/shm/.com.google.Chrome.5FDXUe (deleted)
268242944       (deleted)/frew/8537
394068544       (deleted)/frew/8862
728951304       (deleted)
728951304       (deleted)/frew
```

So you can see that the very topmost example is a single deleted file of about
255 megabytes.  Next is process 8537 running under my personal user, with
a little more than the file above it.  At the bottom you can see that all of the
deleted files added together are about 700 megs, and they are all owned by my
user.  With this information you can either `kill -TERM 8862` to kill one of the
processes or `sudo -u frew bash -c 'kill -TERM -1'` to kill all processes under
user `frew`.

Finally, I trivially baked the above into `where-dem-big-files-at` by running
the following after the initial call to `du`:

``` bash
lsof -F 0Lnps "$whatsbig" 2>/dev/null |
   "$(dirname $0)/du-from-lsof" >> $TMPDIR/big.$$.pid
```

---

There are actually a lot of other ways disks can fill up that I have not folded
into this tooling.  The two that spring to mind are:

 * Running out of inodes
 * Hiding other files under a mountpoint

I am thinking about making `where-dem-big-files-at` check to see if a disk has a
higher inode usage ratio than space usage and have it warn when that happens.
When in this mode I'd like `where-dem-big-files-at` to switch to `du --inodes`
and have `du-from-lsof` simply add `1` instead of the size of the file.
Wouldn't be hard, but I just haven't gotten around to it yet.

As for hiding files under a mounpoint, this happens when you start with (for
example) a single partition (`/`) write files in a directory (`/home/frew`) and
then create a new partition and mount it such that it overlaps with the files
(`/home`).  I haven't debugged this situation myself.  I know you could unmount
one partition but I suspect you may be able to remount the original partition
readonly in a new location.  Again, at some point I'll probably build this in
but I haven't run into it enough to miss it.

---

If you haven't already read it, I strongly recommend
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=813a40724d62f2c17673dd55c1ecc926">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's very much in the same vein as this blog post: writing little (or sometimes
big) tools to save time and effort.  It's over thirty years old and it held up
when I read it in 2017; how many tech books are so timeless, yet so specific?

For better Unix foundations, which a lot of this blog post is predicated on, a
great resource is
<a target="_blank" href="https://www.amazon.com/gp/product/0321637739/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0321637739&linkCode=as2&tag=afoolishmanif-20&linkId=927ee00ad071b8b28ed977feae332a49">Advanced Programming in the UNIX Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0321637739" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a textbook, but it's totally interesting and readable.  It seems to me like
a lot of these details get ignored, forgotten, or openly flouted in these modern
days of javascript frameworks and microservices, but if you forget these
foundations it will bite you.
