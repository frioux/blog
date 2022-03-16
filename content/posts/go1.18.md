---
title: Go 1.18
date: 2022-03-15T20:06:57
tags: [ "golang" ]
guid: 5013238c-87a9-4b51-980d-5828112a1835
---
[Go 1.18 just came out](https://golang.org/doc/go1.18), so I'm looking over
the new features.

<!--more-->

I always like to read release notes for new releases of software that I use,
especially programming languages.  Here's a brief summary of what I am excited
for in Go 1.18.

By a large margin the biggest new feature in Go 1.18 is generics.  [I already
wrote about this here](/posts/go-generics-example/).  I'm a little excited but
also nervous for their inevitable overuse.  My plan is to peruse the
[new](https://pkg.go.dev/golang.org/x/exp@v0.0.0-20220314205449-43aec2f8a4e7/maps),
[packages](https://pkg.go.dev/golang.org/x/exp@v0.0.0-20220314205449-43aec2f8a4e7/slices)
that deal with generics to get a firmer understanding of how the can be used in
my own code, if at all.

[Go 1.18 adds built in fuzzing](https://go.dev/doc/fuzz/).  [I played with this
a while
back](https://github.com/frioux/leatherman/blob/4be0d00/internal/notes/west/fuzz_test.go)
to find bugs in my bespoke markdown parser.  I am pleased that this is finally
built in.

One of my favorite new capabilities in Go 1.18 is built in version metadata.  Check this out:

```
$ go1.18 build                                                   
$ go1.18 version -m ./leatherman
./leatherman: go1.18
        path    github.com/frioux/leatherman
        mod     github.com/frioux/leatherman    (devel)
        dep     github.com/BurntSushi/toml      v1.0.0  h1:dtDWrepsVPfW9H/4y7dDgFc2MBUSeJhlaDtK13CxFlU=
        dep     github.com/PuerkitoBio/goquery  v1.8.0  h1:PJTF7AmFCFKk1N6V6jmKfrNH9tV5pNE6lZMkG0gta/U=
        dep     github.com/andybalholm/cascadia v1.3.1  h1:nhxRkql1kdYCc8Snf7D5/D3spOX+dBgjA6u8x004T2c=
        dep     github.com/brandondube/tai      v0.0.0-20210908012928-fc9102ee0eba      h1:zwpI3zXPgj6bGdyswiQLuK9luHcZ6FuUCU1WKcTk5vo=
        dep     github.com/bwmarrin/discordgo   v0.24.0 h1:Gw4MYxqHdvhO99A3nXnSLy97z5pmIKHZVJ1JY5ZDPqY=
        dep     github.com/frioux/yaml  v0.0.0-20191009230429-1d79e1a4120f      h1:vPrzBLZB9NBFMoydArwYLJMLJjv9YBwjORlyyVp+n2o=
        dep     github.com/fsnotify/fsnotify    v1.5.1  h1:mZcQUHVQUQWoPXXtuf9yuEXKudkV2sx1E06UadKWpgI=
        dep     github.com/godbus/dbus  v4.1.0+incompatible     h1:WqqLRTsQic3apZUK9qC5sGNfXthmPXzUZ7nQPrNITa4=
        dep     github.com/google/uuid  v1.3.0  h1:t6JiXgmwXMjEs8VusXIJk2BXHsn+wx8BZdTaoZ5fu7I=
        dep     github.com/gorilla/websocket    v1.4.2  h1:+/TMaTYc4QFitKJxsQ7Yye35DkWvkdLcvGKqM+x0Ufc=
        dep     github.com/hackebrot/turtle     v0.1.1-0.20200616125707-1bb4c277aedd    h1:3Yz4T15BmWV4zoLtY1CYfjBv3098pirDTrwRsespZy4=
        dep     github.com/headzoo/surf v1.0.1-0.20180909134844-a4a8c16c01dc    h1:xmXRlxaMHvNeB+EZ6HmWeLSifHbxQvZO/K1x9ICWOR0=
        dep     github.com/icza/backscanner     v0.0.0-20180226082541-a77511ef4f0f      h1:EEBVjzvzsiUwgWio/3WB2kYx7DtC3QVJKuK6XejFghE=
        dep     github.com/jmoiron/sqlx v1.3.4  h1:wv+0IJZfL5z0uZoUjlpKgHkgaFSYD+r9CfrXjEXsO7w=
        dep     github.com/mattn/go-isatty      v0.0.14 h1:yVuAays6BHfxijgZPzw+3Zlu5yQgKGP2/hcQbHb7S9Y=
        dep     github.com/pierrec/lz4/v3       v3.3.4  h1:fqXL+KOc232xP6JgmKMp22fd+gn8/RFZjTreqbbqExc=
        dep     github.com/remyoudompheng/bigfft        v0.0.0-20200410134404-eec4a21b6bb0      h1:OdAsTTz6OkFY5QxjkYwrChwuRruF69c169dPK26NUlk=
        dep     github.com/tailscale/hujson     v0.0.0-20190930033718-5098e564d9b3      h1:rdtXEo9yffOjh4vZQJw3heaY+ggXKp+zvMX5fihh6lI=
        dep     github.com/ulikunitz/xz v0.5.10 h1:t92gobL9l3HE202wg3rlk19F6X+JOxl9BBrCCMYEYd8=
        dep     github.com/yuin/goldmark        v1.4.9  h1:RmdXMGe/HwhQEWIjFAu8fjjvkxJ0tDRVbWGrsPNrclw=
        dep     github.com/yuin/gopher-lua      v0.0.0-20200816102855-ee81675732da      h1:NimzV1aGyq29m5ukMK0AMWEhFaL/lrEOaephfuoiARg=
        dep     golang.org/x/crypto     v0.0.0-20210513164829-c07d793c2f9a      h1:kr2P4QFmQr29mSLA43kwrOcgcReGTfbE9N577tCTuBc=
        dep     golang.org/x/net        v0.0.0-20210916014120-12bc252f5db8      h1:/6y1LfuqNuQdHAm0jjtPtgRcxIxjVZgm5OTu8/QhZvk=
        dep     golang.org/x/sys        v0.0.0-20211007075335-d3039528d8ac      h1:oN6lz7iLW/YC7un8pq+9bOLyXrprv2+DKfkJY+2LJJw=
        dep     golang.org/x/text       v0.3.7  h1:olpwvP2KacW1ZWvsR7uQhoyTYvKAupfQrRGBFM352Gk=
        dep     modernc.org/libc        v1.14.6 h1:SSiZiE5199iYsGM9gtkDj90xqcXVwubWG8CtoYE+Mnk=
        dep     modernc.org/mathutil    v1.4.1  h1:ij3fYGe8zBF4Vu+g0oT7mB06r8sqGWKuJu1yXeR4by8=
        dep     modernc.org/memory      v1.0.5  h1:XRch8trV7GgvTec2i7jc33YlUI0RKVDBvZ5eZ5m8y14=
        dep     modernc.org/sqlite      v1.14.8 h1:2OOqfZAyU4x4qusilvHoRXXqsAgaZobi1o+mjQ5MUpw=
        build   -compiler=gc
        build   CGO_ENABLED=1
        build   CGO_CFLAGS=
        build   CGO_CPPFLAGS=
        build   CGO_CXXFLAGS=
        build   CGO_LDFLAGS=
        build   GOARCH=amd64
        build   GOOS=linux
        build   GOAMD64=v1
        build   vcs=git
        build   vcs.revision=f8389d320922f955452f566a1533243dcdcdb9d4
        build   vcs.time=2022-03-11T15:50:29Z
        build   vcs.modified=false
```

This feature takes zero effort for most people to use and removes the main need
for Makefiles and other flags to go build.

I look forward to [migrating from `// +build` lines to `//go:build`
lines](https://go.dev/design/draft-gobuild) as a much more clear way to express
operating system or architecture specific files.

Gofmt is supposed to be faster due to more (any?) paralelism.  On my laptop
only about twice as fast for our monorepo, but that's still pretty good.

[The new netip package is nice](https://pkg.go.dev/net/netip); I am not sure
when I'll have a chance to use it, but I hope more and more people do use it as
a more efficient option for IP Address storage.

There are some less visible but still welcome changes like better gc, better
slice appending, better calling conventions, better inlining, faster linking,
improved security defaults, and a huge pile of updates to the standard library.

[Read the full changelog here](https://go.dev/doc/go1.18).

---

Hope this was interesting!  If you liked it sign up for my newsletter below or
give me a follow [on twitter](https://twitter.com/frioux).
