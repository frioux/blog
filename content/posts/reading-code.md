---
title: Reading Code
date: 2019-03-26T08:33:17
tags: [ perl, golang ]
guid: 5f24af50-6b98-4ab2-a07b-af504037edd7
---
I enjoy reading code and want to talk about it.

<!--more-->

At [my last job](http://lynxguide.com/) I was responsible for doing code review
for nearly all the code that we released.  The only code I *didn't* review was
the realtime C that was released (somewhat) out of band.  This meant that I
reviewed lots of Perl, lots of JavaScript, and good amount of C#.

I remember getting good enough at it that one time I caught a race condition in
the C#, mentioned that it was a possiblity, but the team decided to release
anyway and fix it later.  Within days a customer experienced the race condition.

All that said, I have gained an appreciation for reading code.  I am sure that
intense code review isn't the only way to gain a love of reading code, but it
did the trick for me.

Now I will often be reading documentation and get curious and read how some code
is implemented.  I especially appreciate how Go's documentation links directly
to the implementing code, which makes diving into the code even easier.

Just yesterday I was reading some of
[spilld](https://github.com/spilled-ink/spilld) and came across [this delightful
trick](https://github.com/spilled-ink/spilld/blob/04871a6ebd3ab628d2f0cb4adb76cf95f743d072/email/msgbuilder/msgbuilder.go#L175-L185)
for creating MIME bondaries:
  
```golang
func randBoundary(rnd *rand.Rand) string {
	var buf [12]byte
	_, err := io.ReadFull(rnd, buf[:])
	if err != nil {
		panic(err)
	}
	// '.' and '.' are valid boundary bytes but not valid base64 bytes,
	// so including them provides trivial separation from all base64
	// content, which is how all tricky content is encoded.
	return "." + base64.StdEncoding.EncodeToString(buf[:]) + "."
}
```

Here's a super useful trick to log AWS API calls I ran across while reading some
code at [ZipRecruiter](https://www.ziprecruiter.com/hiring/technology):

```golang
	sess, err := session.NewSession(cfg)
	if err != nil {
		return errors.Wrap(err, "creating a new AWS session")
	}

	if *debug {
		sess.Handlers.Send.PushFront(debugHandler)
	}

// ...

func debugHandler(r *request.Request) {
	fmt.Printf("Request: %s/%+v, Payload: %+v\n", r.ClientInfo.ServiceName, r.Operation, r.Params)
}
```

I don't want this post to become some kind of gallery of clever code.  I just
find it surprisingly often that I will be casually perusing code, sometimes to
see how something works because I want to use the same technique, other times
because the documentation isn't quite clear, and I'll find myself enjoying the
process.  I think part of it is cunning tactics (like the MIME bit above) that
allow removing huge swaths of code, but often it gives me an insight into other
minds.

I think reading code is a skill *all* software engineers need to develop and
improve.  We spend so much of our time editing existing code that it's important
for us to orient ourselves and make the correct modifications.  It's not good to
make changes that are contrary to the goals of the code we are updating, unless
we need to change those goals, which probably implies much bigger refactors
anyway.

---

If you read this blog you probably either are interested in, or write, Perl or
Go.  If you aren't already well-versed in reading code, I would suggest
practicing!

If you are new to Go, I would first read a primer on the language like 
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
or maybe 
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
After that I would dive into the wealth of examples that is the standard
library!  A great starting point (some of the first Go that I read and really
appreciated) would be [the io.Copy function](https://golang.org/pkg/io/#Copy);
click the function name to get started and keep reading till you understand it.

I suspect the Perl prorgrammers new to this blog are few and far between, but
if you are, check out
<a target="_blank" href="https://www.amazon.com/gp/product/0596004923/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0596004923&linkCode=as2&tag=afoolishmanif-20&linkId=ae31522154a55fef2de1c5a9967493e9">Programming Perl</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0596004923" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
I haven't read Perl code in quite a while, but some good starting points might
be [Plack](https://metacpan.org/pod/Plack),
[Moose](https://metacpan.org/pod/Moose), and
[DBI](https://metacpan.org/pod/DBI).
