---
title: CPAN Patch workflow
date: 2015-07-30T17:58:16
tags: ["cpan", "perl", "git", "github", "git-hub", "git-cpan"]
guid: "https://blog.afoolishmanifesto.com/posts/cpan-patch-workflow"
---
I just wanted to write up a quick note on my workflow for CPAN patches, because
I'm so pleased with it.

I use three tools:

 1. [`Git::CPAN::Patch`](https://metacpan.org/pod/Git::CPAN::Patch)

 2. [`git-hub`](https://github.com/ingydotnet/git-hub)

 3. [`fugitive.vim`](https://github.com/tpope/vim-fugitive)

When I first see a module that needs some love, like today I saw that
[`Gazelle`](https://metacpan.org/pod/Gazelle) needed some POD reformatting,
first I clone it (using `Git::CPAN::Patch`):

```
git cpan clone Gazelle
```

Then I fork it, so that I can make a pull request (using `git-hub`), make a
branch, and set it up to track my fork.

```
git hub fork
git checkout -b doc-patches
git push frioux HEAD -u
```

Then I edit and commit my changes (using `fugitive.vim`):

```
vi $file

" hack hack hack

:Gwrite     " stages the current file
:Gcommit -v " gives me a tab to commit the changes
:Gpush      " push to my github fork
```

After doing a few rounds of that I make my pull request (using `git-hub`:)

```
git hub pr-new cpan
```

And then I'm basically done!  This is more work than using the Github web
interface, but for anything more than a simple typo fix, it's pretty awesome.

Note that the above doesn't work as well for non-github repos.
`Git::CPAN::Patch` knows how to send patches with `git cpan send-email`, but I
haven't figured out how to make it work.  If you know how to configure it to
send via gmail let me know in the comments!

**UPDATE**: [See details that resolve the above issues
here](/posts/cpan-patch-workflow-ii/).
