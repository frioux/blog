---
title: Validating Kubernetes Manifests
date: 2018-12-18T07:20:15
tags: [ kubernetes, perl, golang ]
guid: 0d291e43-0f72-4922-8790-275a114c951e
---
At [ZipRecruiter](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) my team is
hard at work making Kubernetes our production platform.  This is an incredible
effort and I can only take the credit for very small parts of it.  The issue
that I was tasked with most recently was to verify and transform Kubernetes
manifests; this post demonstrates how to do that reliably.

<!--more-->

TL;DR: I built a Go package to walk Kubernetes manifests by type that allows
transformation or validation of resources.

## Kubernetes Manifests

For those who haven't used Kubernetes I should describe what a manifest is.  In
brief it is (typically) one or more YAML documents that describe one or more
Kubernetes resources.  A resource is a meaningless long word that just means
"thing," but it's the word normally used in k8s.  For a complete listing check
out [the official
docs](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.10/#resource-categories).
The things on the left are resource types.

## Validate a Manifest

The most obvious validation you might do on a manifest is to ensure that it is
valid.  There are a number of existing solutions to this already; a convenient
one is [kubeval][kubeval], which is an ok solution, but reaches out to github to
pull API definitions on each resource, which not acceptable for us, but fixing
that isn't too hard.

In addition we have policies for how people use Kubernetes that we need to
enforce.  A super obvious example is the `image`: you should ensure that you're
either using a fully resolved image (like include the repo digest) or include an
immutable version tag.

This sounds easy until you do a little bit of research and find that containers
(which have the `image` field) appear in manifests in over 100 distinct
locations, so you can't just manually write code to for each case.  For example,
deployments contain a deployment spec, which contains a pod template, which
contains a pod spec, which contains a list of containers.

I decided I'd try to build a visitor that would
allow you to walk a given resource and have a callback be triggered whenever a
certain resource type appeared.  So for example, if you pass a Pod that
defines two inner Containers, you could walk the Pod and get your Container
function called twice, once for each container.

## Building Walk

First and foremost, I started with [the OpenAPI specification that is provided
with Kubernetes][spec].  I don't actually know anything about OpenAPI or Swagger
or whatever, but looking at the data I came up with some code to build a path
from a given type to another type.

All resources have a type, which is expressed with the `apiVersion` and `kind`
fields within the manifest.  My idea was this: given a resource, we should be
able to enumerate all possible paths from the root of the type to the resource
types we are looking for.  I wrote [a Perl script][destiny] that generates that
listing by doing a brute force search of the OpenAPI spec.  (It also generates
the mapping of `kind` and `apiVersion` so that the [ResourceType
function][resourcetype] uses.)

The Go package then recursively walks resources using the paths that the Perl
code generated.

## Using Walk

Here's a partial listing of what we use this for at work, which is to make a
non-alpha, improved version of a PodPreset (ask me at some point and I can give
reasons why, or maybe I'll blog that later):

```golang
err = manifests.Walk("io.k8s.api.core.v1.PodSpec", resource, func(i interface{}) error {
	v, ok := i.(map[string]interface{})
	if !ok {
		return errors.New("Cannot transform non-hash resource", "resource", fmt.Sprintf("%#v", i))
	}

	vols := []interface{}{}

	volsRaw, ok := v["volumes"]
	if !ok {
		v["volumes"] = vols
	} else {
		vols, ok = volsRaw.([]interface{})
		if !ok {
			return errors.New("volumes were not an array", "volumes", fmt.Sprintf("%#v", volsRaw))
		}
	}

	v["volumes"] = append(vols, []interface{}{map[string]interface{}{
		"name":      "config-volume",
		"configMap": map[string]interface{}{"name": "config-map"},
	}}...)

	return nil
})
```

The code is super annoying because it uses `map[string]interface{}` and
`[]interface{}` types instead of any actual structs.  Arguably Go is one of the
worst languages for this, but it has to run outside of containers so it's worth it
to avoid any runtime deps.

In addition to the type related annoyances, this approach has two limitations:

 1. It doesn't support recursive types.
 2. It (at least in it's current form) can't validate or transform missing
    resources.

The recursive thing hasn't been an issue for me, but there are some types in the
OpenAPI spec that are recursive.  I only discovered this because I tried to
simplify the Perl script by generating the paths for all types and found that I
couldn't without fixing the recursive issue.  Patches welcome for that.

The second issue is more frustrating and I'm not sure that it'd be sensible to
fix it generically.  In theory you could do this:

```golang
meta := "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"
err := manifests.Walk(meta, r interface{}, func (r interface{}) error {
	noop := func (interface{}) error { return nil }
	if _, ok := manifests.Check(r, []string{"labels", "whatever"}, noop); !ok {
		return errors.New("whatever not set")
	}
	return nil
})
```

(Note the use of the [Check function][check] which allows descending into the
objects with a list of strings as path segments.)  But the `meta` key is
optional, so if a resource is lacking it, the above won't be called for the
missing `meta`.  I suspect I could do some kind of crazy to allow injecting
values like this but I have a gut feeling it would end up a mess and not
actually that useful.

---

Is this the best or even only way to implement manifest validation?  Absolutely
not.  But leveraging the official API specs to generate the boring part is
clearly useful.  Also generating Go code from Perl makes me feel like I'm
cheating the devil or something.

---

(The following includes affiliate links.)

If you want to learn more about Kubernetes, you might want to check out Kelsey
Hightower's book <a target="_blank" href="https://www.amazon.com/gp/product/1491935677/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1491935677&linkCode=as2&tag=afoolishmanif-20&linkId=8200085d2c6bbeaa6c5a765b01e62136">Kubernetes: Up and Running</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1491935677" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
He knows what's up.

If you want to learn more about Go I would suggest <a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=68b7094156f50074b06f65cf8383c43b">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
which is one of the best tech books I've ever read.

[spec]: https://github.com/kubernetes/kubernetes/tree/master/api/openapi-spec
[destiny]: https://github.com/frioux/manifests/blob/bd46907a65a1f2e93b8808c9dca3ba7a71fd98c1/destiny.pl
[resourcetype]: https://godoc.org/github.com/frioux/manifests#ResourceType
[check]: https://godoc.org/github.com/frioux/manifests#Check
[kubeval]: https://github.com/garethr/kubeval
