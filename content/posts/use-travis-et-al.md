---
title: Use Travis (and more)
date: 2014-06-29T19:54:36
tags: ["travis-ci", "ci", "perl"]
guid: "https://blog.afoolishmanifesto.com/posts/use-travis-et-al"
---
At [YAPC last
week](https://blog.afoolishmanifesto.com/posts/youre-awesome-yapc) vanstyn
was complaining about the fact that there is so much "assumed knowledge"
in Perl.  One of the examples he gave was [TravisCI](https://travis-ci.org).
There are a few tools that go with Travis that every Perler should know about.

First off, use Travis!  Step one is to enable it for your repo at
https://travis-ci.org/profile/$username.  After that add a text file to your
repo with the name `.travis.yml` with the following content:

      language: perl
      perl:
         - "5.18"
         - "5.16"
         - "5.14"
         - "5.12"
         - "5.10"
         - "5.8"

      install:
         - export RELEASE_TESTING=1 AUTOMATED_TESTING=1 AUTHOR_TESTING=1 HARNESS_OPTIONS=c HARNESS_TIMER=1
         - cpanm --quiet --notest --installdeps .

      script:
         - prove -lrsv t

The above assumes that you are using `cpanfile` or `Makefile.PL` or maybe
`Build.PL` to specify your deps.  If you are setting them directly or even
inferring them with Dist::Zilla, just keep reading.

The next step is getting coverage info.  First enable it, like you did for
travis, at https://coveralls.io/r/$username/.  Then modify the `.travis.yml` to
look like this now:

      language: perl
      perl:
         - "5.18"
         - "5.16"
         - "5.14"
         - "5.12"
         - "5.10"
         - "5.8"

      install:
         - export RELEASE_TESTING=1 AUTOMATED_TESTING=1 AUTHOR_TESTING=1 HARNESS_OPTIONS=c HARNESS_TIMER=1
         - cpanm --quiet --notest Devel::Cover::Report::Coveralls
         - cpanm --quiet --notest --installdeps .

      script:
         - PERL5OPT=-MDevel::Cover=-coverage,statement,branch,condition,path,subroutine prove -lrsv t
         - cover

      after_success:
        - cover -report coveralls

So now you can see how much of your code the tests exercise.

Did you notice that in this modern era of mid 2014 the tests aren't testing
"5.20?"  Good job!  You're very observant and good at The Perl Timeline!

The reason for that is that [the Travis guys are too busy with PHP than to add a
perl build](https://github.com/travis-ci/travis-ci/issues/2428).  Fortunately
haarg has a tool that will help with that!

The first step is to modify the above `.travis.yml` to look like this:

      language: perl
      perl:
         - "blead"
         - "5.20"
         - "5.18"
         - "5.16"
         - "5.14"
         - "5.12"
         - "5.10"
         - "5.8"

      before_install:
         - git clone git://github.com/haarg/perl-travis-helper
         - source perl-travis-helper/init
         - build-perl
         - perl -V

      install:
         - export RELEASE_TESTING=1 AUTOMATED_TESTING=1 AUTHOR_TESTING=1 HARNESS_OPTIONS=c HARNESS_TIMER=1
         - cpanm --quiet --notest Devel::Cover::Report::Coveralls
         - cpanm --quiet --notest --installdeps .

      script:
         - PERL5OPT=-MDevel::Cover=-coverage,statement,branch,condition,path,subroutine prove -lrsv t
         - cover

      after_success:
        - cover -report coveralls

So we added that `before_install` section and then added `5.20` and `blead`.
The really cool think about haarg's tool is that for the older versions of perl
it uses what travis ships with and then for versions that aren't on travis it
builds the new perl on demand!

Finally, if you are using Dzil to specify deps, or if you care about testing the
build version of your dist, you can use the `build-dist` tool that haarg
includes.  Note that it can even build the dist while testing with 5.8 even
though Dist::Zilla won't run on 5.8.  Pretty handy eh?  Just make your
`.travis.yml` look like this:

      language: perl
      perl:
         - "blead"
         - "5.20"
         - "5.18"
         - "5.16"
         - "5.14"
         - "5.12"
         - "5.10"
         - "5.8"

      before_install:
         - git clone git://github.com/haarg/perl-travis-helper
         - source perl-travis-helper/init
         - build-perl
         - perl -V
         - build-dist
         - cd $BUILD_DIR

      install:
         - export RELEASE_TESTING=1 AUTOMATED_TESTING=1 AUTHOR_TESTING=1 HARNESS_OPTIONS=c HARNESS_TIMER=1
         - cpanm --quiet --notest Devel::Cover::Report::Coveralls
         - cpanm --quiet --notest --installdeps .

      script:
         - PERL5OPT=-MDevel::Cover=-coverage,statement,branch,condition,path,subroutine prove -lrsv t
         - cover

      after_success:
        - cover -report coveralls

And that's it! With this pretty simple code you are testing the
built version of your app, including coverage against all major versions of
perl + blead!
