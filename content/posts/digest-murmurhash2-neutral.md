---
title: Announcing Digest::MurmurHash2::Neutral
date: 2016-09-23T07:36:38
tags: [ perl, cpan, announcement, ziprecruiter ]
guid: 228C0614-819B-11E6-B1D2-0D132E0DE0B1
---
This week I released
[Digest::MurmurHash2::Neutral](https://metacpan.org/pod/Digest::MurmurHash2::Neutral).

<!--more-->

There are already perl modules of both
[MurmurHash](https://metacpan.org/pod/Digest::MurmurHash) and
[MurmurHash3](https://metacpan.org/pod/Digest::MurmurHash3), but we needed a
MurmurHash2 implementation to be able to work with the nginx `split_clients`
interface.

This was the first time I wrote a module using `XS`.  For those who do not know,
`XS` is Perl's variant on an FFI.  Unlike modern FFIs, instead of exploiting C
calling conventions, you instead integrate the external code into Perl (`XS` is
almost simply Perl's own implementation.)  This was a simple module and there
were other similar modules that I could start from, so this was pretty easy.

I expected the building and releasing of it to be hard, because I knew that
[Dist::Zilla](https://metacpan.org/pod/Dist::Zilla) had some kind of work done
to make it better for XS, but I used it exactly like I always do.

[I test my code on TravisCI](/posts/use-travis-et-al/) and for the first time
really needed to build the module before testing it.  The latest version of
Graham Knop's [Perl `travis-helpers`](https://github.com/travis-perl/helpers)
has excellent tooling for this.  It will even build your module with a newer
Perl (since releasing your code from 5.8 is an exercize in futility) and then
test against an older one.  Pretty great!

All in all, as usual, releasing code to CPAN continues to be easy, fun, and
effective.
