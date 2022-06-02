---
title: Setting Up Vim with an LSP for Scala
date: 2022-05-31T08:56:36
tags: [ "vim", "scala" ]
guid: 9032203b-24d6-4649-83a9-ef79d9d99719
---
I write Scala a bunch these days at work.  The language (or maybe the Spark
culture) really wants you to use an IDE.  As much as I tried to use IntelliJ I
just can't bring myself to make such a big switch.  If you are interested in
language servers (which typically provide autocomplete,) Vim, or specifically
setting that up for Scala, read on.

<!--more-->

## TL;DR

 * [install coursier](https://get-coursier.io/docs/cli-installation)
 * install metals: `cs install metals`
 * install bloop: `cs install bloop`
 * configure bloop and gradle ([see below for example](#bloop))
 * install the bloop packages: `./gradlew bloopInstall`
 * install and configure a plugin: [ALE](#ale), [vim-lsp](#vim-lsp), or [vim-lsc](#vim-lsc)

## The Goal

You can do a lot with an LSP, but all I really want is:

 * goto definition
 * autocomplete methods

All the rest I'll figure out later (or never.)

## Metals, but which Plugin?

The de facto LSP for scala is called [metals](https://scalameta.org/metals/).
Their webpage links to [nvim-metals](https://github.com/scalameta/nvim-metals),
but that's NeoVim only and I use Vim Classic.

The easiest way to install metals is via [coursier](https://get-coursier.io/).
[Install coursier](https://get-coursier.io/docs/cli-installation), and then run
this to install metals: `cs install metals`.

The same site links to [coc-metals](https://github.com/scalameta/coc-metals).
`coc-metals` does work but it's unmaintained and depends on using a bunch of
Node stuff.  If you are OK with those caveats it was definitely easy to get
working, but I don't love having yet another runtime for this.

Setting those aside, here are the other options I've found and can discuss:

 * [ALE](https://github.com/dense-analysis/ale)
 * [vim-lsp](https://github.com/prabirshrestha/vim-lsp) (and probably [vim-lsp-settings](https://github.com/mattn/vim-lsp-settings)
 * [vim-lsc](https://github.com/natebosch/vim-lsc/)

ALE has code to detect different LSPs (and non-LSPs), `vim-lsp` leaves that to
the user, but `vim-lsp-settings` does autoconfiguration for you.  `vim-lsc`
leaves it up to the user also.

I'll start off discussing ALE, but put some example configs of the other two
[in an appendix](#configuring-other-plugins).

In case you need it, [here are all the initialization options for
Metals](https://github.com/scalameta/metals/blob/main/metals/src/main/scala/scala/meta/internal/metals/InitializationOptions.scala).

## bloop

Sadly, we are getting ahead of ourselves.  At ZipRecruiter we use Gradle to
build our JVM projects.  [Metals
requires](https://scalameta.org/metals/docs/build-tools/gradle) the use of
[bloop](https://scalacenter.github.io/bloop/) to integrate with gradle.
Honestly, if you aren't already using `bloop` you'll be glad to find this,
since it makes builds so much faster.

Building with straight `gradle` and a hot cache takes about 9 seconds for me,
but building with a hot cache with `bloop` takes about 200 milliseconds.
Awesome.

First get the bloop runner command, again via `coursier`, with `cs install
bloop`.  You won't need this for the LSP integration but being able to use the
bloop CLI to quickly trigger a build or a test is really useful.

Add this to your `build.gradle` (you might need to tweak it slightly, we had to
modify it so it would work with artifactory:)

```gradle
buildscript {
    dependencies {
        classpath 'ch.epfl.scala:gradle-bloop_2.12:1.5.0'
    }
}

allprojects {
  apply plugin: 'bloop'
}
```

Then run `./gradlew bloopInstall` to download all the packages.  (metals should be
able to do the above two steps for you, but the `bloopInstall` step takes long
enough that I'd rather run it explicitly and wait for completion.)

You should be able to run `bloop projects` and see your project (or maybe it
and it's tests) in the output:

```
$ bloop projects
datalake--onedaydataset
datalake--onedaydataset-integrationTest
```

And then trigger compilation with: `bloop compile datalake--onedaydataset`.

It should take as long as gradle the first time, but the next time you run the
same command it should be really fast.

In a perfect world at this point we could validate that metals works without
any kind of editor, but I haven't found clear instructions or tooling for that.
If you know how let me know and I'll add it!  What I'd like is a shell script
that just fires up metals (or any LSP), initializes it, and logs output or
something.  I tried running metals by hand and writing the `initialization`
json to it but nothing happened.

When we configure plugins later on we'll pass the `isHttpEnabled`
initialization option to metals. This will enable an HTTP server (on my
computer at `http://127.0.0.1:5031/`) which gives us a lot of introspection
into metals.  You can use this to run the metals doctor, which does a self
interrogation to make sure everything is set up just right.  Very handy.

## ALE

In theory ALE autoconfigures LSPs, but in practice nothing is perfect and I
ended up needing to basically ignore all of the autoconfiguration for Metals.
[I opened an issue to resolve it in the
future.](https://github.com/dense-analysis/ale/issues/4220)

One option is to fix the metals integration for ALE.  The way I did that was
to replace the `metals-vim` string with just metals and to add `build.gradle` to
the list of `potential_roots`:

```diff
--- a/ale_linters/scala/metals.vim
+++ b/ale_linters/scala/metals.vim
@@ -1,7 +1,7 @@
 " Author: Jeffrey Lau - https://github.com/zoonfafer
 " Description: Metals Language Server for Scala https://scalameta.org/metals/
 
-call ale#Set('scala_metals_executable', 'metals-vim')
+call ale#Set('scala_metals_executable', 'metals')
 call ale#Set('scala_metals_project_root', '')
 
 function! ale_linters#scala#metals#GetProjectRoot(buffer) abort
@@ -16,6 +16,7 @@ function! ale_linters#scala#metals#GetProjectRoot(buffer) abort
     \   'build.sbt',
     \   '.bloop',
     \   '.metals',
+    \   'build.gradle',
     \]
 
     for l:root in l:potential_roots
```

I am pretty sure that the use of `ale#path#ResolveLocalPath` is just wrong
though.

I did this because at work I deal with a lot (like, dozens) of scala projects,
so hardcoding a `project_root` is a nonstarter.

Another option, which is probably simpler all things considered, is to just configure
the integration directly:

```viml
" if you do not call packloadall you'll get a weird error.
packloadall
call ale#linter#Define('scala', {
\   'name': 'frew_metals',
\   'lsp': 'stdio',
\   'executable': '/home/frew/bin/metals',
\   'command': '%e run',
\   'initialization_options': { 'rootPatterns': 'build.gradle', 'isHttpEnabled': 'true' },
\   'project_root': '/home/frew/code/zr0/datalake/onedaydataset',
\})
```

Annoyingly this means setting the `project_root` at linter definition time,
which is a little silly, but such is life.  Maybe worse, it seems like the
`rootPatterns` above means metals can in theory find the root for you, but
ALE errors if you don't set `project_root` so setting that option with this
plugin is basically a waste.

After the above I set up the autocompletion and goto defintion like this:

```viml
set omnifunc=ale#completion#OmniFunc
nnoremap <silent> gd :ALEGoToDefinition<CR>
```

The first line wires ALE up with OmniComplete, which by default is triggered by
`<C-x><C-o>`.  Check the doc for ALE or use some other tool if you want the
autocomplete running all the time.  The second line makes `gd` Goto the Definition
of a type, method, or whatever.

### Debugging

One of the things I really like about ALE is that it has some facilities for
debugging it.  First and foremost, if you are having issues with ALE, run
`:ALEInfo`.  The first few lines will tell you what linters are set up currently,
but make sure to scroll to the bottom where you can see what linters are actually
running.

If you are trying to debug the project root detection, just running
`:echo ale_linters#scala#metals#GetProjectRoot('')` is pretty useful.

And finally, as a nuclear option, this will give you a log you can tail of
basically all of the back and forth between ALE and the LSP, and some other ALE
debugging details:

```viml
call ch_logfile('/tmp/chlogfile.log', 'w') 
```

This is using builtin vim functionality that I was pleased to see.  I have not
checked to see how (if?) other plugins use this.

## Not Perfect

There are some types that I cannot goto definition on.  I don't know if this is
because Scala is complicated, I haven't completely configured Metals, or there
are bugs in Metals, or a combination of these.  For example, I can jump into
definitions of Spark internals, and I can jump to definitions of classes within
my project, but I cannot jump to the base class one of my classes extends.

---

For the most part I'm pretty happy with the outcome here.  I got to the point
where I think configuring an LSP in the future wouldn't be so intimidating, I
learned the terms to search for in the future (`initialization_options`,) and I
improved my configuration for working with Scala at work.  There's still
plenty of room for improvement, of course.

(Affiliate links below.)

If you'd like to learn more about vim, I can recommend a few excellent books.  I
first learned how to use vi from
<a href="https://www.amazon.com/gp/product/059652983X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=059652983X&linkCode=as2&tag=afoolishmanif-20&linkId=1d3b90d608a023a1dcb898b903b6f6ac">Learning the vi and Vim Editors</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=059652983X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
The new edition has a lot more information and spends more time on Vim specific
features.  It was helpful for me at the time, and the fundamental model of vi is
still well supported in Vim and this book explores that well.

Second, if you really want to up your editing game, check out
<a href="https://www.amazon.com/gp/product/1680501275/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1680501275&linkCode=as2&tag=afoolishmanif-20&linkId=4518880cd2a7fd1333456edcbacc26f6">Practical Vim</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1680501275" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a very approachable book that unpacks some of the lesser used features in
ways that will be clearly and immediately useful.  I periodically review this
book because it's such a treasure trove of clear hints and tips.


---

Thanks to my friend Jeff Rhyason for pointing out Bloop, totally separately
from this project, and Michael McClimon for suggesting I check out ALE, and
Chris Kipp for help setting up metals, and Kevin O'Neal for reading over this
blog post.

### Configuring Other Plugins

#### `vim-lsp`

For `vim-lsp` I basically gathered together information based on the above, the
`vim-lsp-settings` plugin which [intends to autoconfigure
`vim-lsp`](https://github.com/mattn/vim-lsp-settings/blob/dd8ba8ebc55ea3aac3e963483093c1b059cb1fd9/settings/metals.vim),
and [the wiki](https://github.com/prabirshrestha/vim-lsp/wiki/Servers-Scala).  The following worked for me:

```viml
au User lsp_setup call lsp#register_server({
   \ 'name': 'metals',
   \ 'cmd': ['metals'],
   \ 'initialization_options': { 'rootPatterns': 'build.gradle', 'isHttpEnabled': 'true' },
   \ 'allowlist': [ 'scala', 'sbt' ],
   \ })
nnoremap <silent> gd :LspDefinition<CR>
set omnifunc=lsp#complete
```

Conveniently we don't have to specify the project root.

#### `vim-lsc`

This time I only had to read [the official doc for
vim-lsc](https://github.com/natebosch/vim-lsc/blob/master/doc/lsc.txt) (mostly
`lsc-server-customization`) to get it all working:

```viml
let g:lsc_server_commands = {
    \ 'scala': {
    \    'command': 'metals',
    \    'workspace_config': {
    \        'rootPatterns': 'build.gradle',
    \        'isHttpEnabled': 'true',
    \    },
    \  },
    \}
nnoremap <silent> gd :LSClientGoToDefinition<CR>
set omnifunc=lsc#complete#complete

```

