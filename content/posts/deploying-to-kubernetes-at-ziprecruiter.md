---
title: Deploying to Kubernetes at ZipRecruiter
date: 2019-01-30T07:36:37
tags: [ ziprecruiter, kubernetes, cicd ]
guid: fcc31a7f-2696-45a8-8585-bbbf9ce521d6
---
At [ZR](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) we are working hard to
get stuff migrated to Kubernetes, and a big part of that is our cicd pipeline.
We have that stable enough that I can explain the major parts.

<!--more-->

Today I deployed my third or fourth application to our development
Kubernetes cluster.  There are enough moving parts involved that it seemed like
it might be fun to describe all of what's involved and why.

## Apps

A primitive at ZR is an app.  An app is a directory within a "theme" (a theme
is like "logging", or "secrets", or "web".)  When it comes to the cicd pipeline
it must have a number of other constituent parts to allow it to participate,
otherwise it's just so many files.  I'll touch on those as they come up.

The concept of an app at ZipRecruiter is a bit of a sea change in how people
view subsets of our monorepo.  Mike Irani should get a huge portion of the
credit for pushing this as hard as he did.  I suspect that much of what this
post discusses will force people to adopt apps; many of whom have so far not
seen the benefit.

## jenkins-auto-build

`jenkins-auto-build` creates one jenkins job for each App.  This tool was created
by Jeremy Donahue and has been a great way to let us use Jenkins without
allowing teams to go bonkers (no Jenkinsfiles, no plugins, just our own
conventions.)

If an app conforms to what `stevedore` (keep reading) requires, then it will get
a jenkins job for free.  The jenkins job will be triggered if any
of the relevant files change (again, keep reading) or if the user pushes to one
of the relevant branches for the app.  The pattern for the deployment branches
is `$tier.$app`; if your app were called something like `aws/evac`, you could
push to `prod.aws.evac` to trigger the production build and deploy.

## stevedore

`stevedore` was actually the first of the tools listed in this blog post to be
created, and was written by Aaron Hopkins.  The tools fundamental purpose is to
allow fast docker builds within a large monorepo.  The way it works is that you
define a Dockerfile and specify a single argument, `REPO`.  The value to this is
automatically inferred, but basically maps to where the docker image gets pushed
after being built.

In addition to defining a `Dockerfile`, the owner of the app must define a
`Dockerfile.deps`, which is an inverted `.dockerignore` that gets copied to the
root of the repo during the build.  This allows apps to include common code from
other parts of the repo, but still not send gigs of data to the docker daemon.

`stevedore` has other useful features, like avoiding a build at all if any build
containing the same bytes has been pushed to our docker repo already, but this
is the gist of it.

The first real work `jenkins-auto-build` does is trigger `stevedore build $app`
if `stevedore` claims that the build should happen for the relevant changed
files.  To make this possible `stevedore` has exposed an interface to take a
commit range and print which apps should be built.

## epoxy

The next tool is `epoxy`, which I wrote; it begins the process of getting the
app in question into Kubernetes.  [I wrote about this a while
ago](/posts/validating-kubernetes-manifests/), but there is more to it than that
post went into.  `epoxy` finds a file at `$app/config/$tier.toml`, exits early
if it's missing, and otherwise uses the contents as both the configuration for
both the running app and also for parameterizing the Kubernetes manifest.
`stevedore` runs `epoxy` passing the built image names and a stable reference
for each, which is used in the manifests.

The manifests are found at `$app/manifests/*.yaml`; they are parameterized via
an in house templating language (no loops, no if statements, just variables),
then tailored (for example adding a configmap for the config in question,) then
validated, and finally shoved into SQS.

The reason that the data is put into SQS is so that we can have `stevedore` and
`epoxy` run on Jenkins in a build tier and then pass the data along to the next
step, which runs in the same tier as (and indeed actually inside of) the
Kubernetes cluster itself.

## the-skipper

`the-skipper`, a service created by Jeremy Donahue, takes the payload from SQS
and hands it off to Spinnaker.  It does a little more, like only handing the
data off if an incrementing counter is higher, so that if we get a big pile of
events we can pick the correct one.  `the-skipper` is an isolation layer in
front of Spinnaker, similar to `jenkins-auto-build`, that exists to prevent
engineers from implementing baroque deployment pipelines that we then have to
support.  Instead it forces Spinnaker to be an implementation detail that we can
(and indeed plan to) replace with something much simpler.

---

The full deployment duration depends almost purely on the application in
question along with delays introduced by SQS itself; the duration of the `docker
build` triggered by `stevedore` is mostly a product of how many dependencies the
application in question has that are not in a base image, and how big the
application itself is.  After all the compilation is done, the actual bytes need
to be shipped off to ECR.  The amount of time the message sits in SQS is between
one and nine minutes, more often closer to nine; we may be able to crank this
down at some point.  The final step of deploying the manifest is pretty snappy;
`the-skipper` and Spinnaker take less than a minute, and Kubernetes itself tends
to be pretty fast.

All together a typical deployment is a little under ten minutes, without any
work being done yet to speed that up.

As a reminder, here are all the various parts you need to implement to deploy to
Kubernetes at ZR:

 1. An app of the form `$theme/$app` (like `aws/evac`)
 2. A `Dockerfile` that takes a `REPO` arg
 3. A `Dockerfile.deps` to express what parts of the monorepo you need to build
    your app
 4. A toml formatted config file for each tier you are deploying to (
    `config/dev.toml`, `config/prod.toml`, etc)
 5. One or more yaml formatted Kubernetes manifests in `manifests/`.

---

(The following includes affiliate links.)

If you enjoyed this post you might appreciate
<a target="_blank" href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=5157ec4156e15e73699ef549e1c56bad">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and likely also
<a target="_blank" href="https://www.amazon.com/gp/product/1492029505/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1492029505&linkCode=as2&tag=afoolishmanif-20&linkId=7b8b8777b19721fdfe8413072a3fda03">The SRE Workbook</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1492029505" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
