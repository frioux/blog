---
title: AWS IAM at ZipRecruiter
date: 2017-05-11T07:00:00
tags: [ aws, security, ziprecruiter ]
guid: C6C7688C-2B77-11E7-BEA0-9A178A525F5E
---
At ZipRecruiter we use AWS for nearly all of our infrastructure, so securing our
usage of AWS is important for obvious reasons.  In this article I will go over
some of the things that I had to do (with help) to go from "pretty insecure" to
"pretty secure" with respect to AWS permissions.

<!--more-->

When I started at ZipRecruiter we had a single, all-powerful, long-lived key on
all of our servers.  The CTO was not pleased when he discovered this well
distributed set of credentials and asked for volunteers to fix it; that's where
I come in.

## What is AWS IAM?

IAM can be intimidating when you first encounter it.  I don't want to go through
all of the details here, but will give a brief overview.  If you want to learn
more [check out the official
docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html).

In IAM there are four primary nouns you need to be aware of:

 1. Policy: set of permissions attached to any number of roles, users, or
    groups.
 2. Role: generally attached to servers or services.  Users may be able to
    "assume" roles.
 3. User: represents human beings and poorly written software.
 4. Group: contains many users; good way to map permissions to teams.

A policy is a JSON document describing what actions can or cannot be taken on
what resources.  Here is a relatively simple IAM policy:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3FooBucketOperations",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::foo.bar.com"
            ]
        },
        {
            "Sid": "S3FooObjectOperations",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject",
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::foo.bar.com/*"
            ]
        }
    ]
}
```

There are a handful of notable features in policies.

 1. You can set the Sid to whatever you want, it's like a comment.  I avoid this
    since we can do comments in terraform.
 2. Effect can be Allow or Deny; Denies get processed first.  At zip we have
    decided to avoid using Denies in general for simplicity.
 3. Action vaguely maps to AWS API calls, though not perfectly.  The general
    format is `$service:$apicall`. You can use globbing to shorten or simplify
    your policy, ie `s3:*` allows all `s3` actions.
 4. The resource is what the actions are working against.  The general format is
    `arn:aws:$service:$region:$account:$specifics`. In the above
    policies, because the resources are of a slightly different format, we could
    have safely merged the actions and resources into a single statement and it
    would still work, but might be considered less tidy.  Globbing works but
    doesn't cross `:`s.

Note that policies can have more advanced functionality; there are conditions
that allow you to be even more fine grained than the above policy.  I have
avoided conditions so far but will eventually use them I'm sure.

### Gotchas

[The policies are validated by AWS, but only
barely.](http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_grammar.html)
The actions can be almost anything as long as there is a `:` in the middle.
It's easy to fool yourself and put, for example, `s3:HeadObject` in a policy and
think you have granted access to head object, when in reality you have simply
wasted bytes.

Similarly, the resources need to match the actions if you actually want them to
work.  A valid but worthless policy will grant S3 read access on an SQS queue.
I do this astoundingly often.

As a side note I think a linter for AWS IAM Policies would be really handy and
pretty easy to write.  One of my coworkers said it might be a good exercise for
a junior engineer.

When writing policies, the best resource out there is this [community maintained
IAM reference](https://iam.cloudonaut.io/).

## IAM Roles

So roles in EC2 are applied to the server and are available to use by accessing
the metadata server that runs within (or at least is exposed via) the hypervisor
at `http://169.254.169.254/latest/meta-data/iam/security-credentials/$role`.
For example here is one of our prod servers right now: (expired by now, of
course)

```
$ curl 169.254.169.254/latest/meta-data/iam/security-credentials/zr-foo
{
  "Code" : "Success",
  "LastUpdated" : "2017-04-27T21:42:27Z",
  "Type" : "AWS-HMAC",
  "AccessKeyId" : "ASIAJP2V5J4IOG4ECNEA",
  "SecretAccessKey" : "QSCv8CFpTLQz95AAdpBOlGA2gC7fGiuuSElFlwYo",
  "Token" : "FQoDYXdzEDcaDD+x59TWlLAn0F9NUCKcA1Btg8QanqQ6JsM5QrN2JIkrI9ZK9LVIRyZn47EQlLmhbj9D1vek1UiYWsG0IqIg6jvfBm3/8aMHMd8MtuJAlRQdVub1df5eQOYDn7DMWM0Hd/EVgmnoTS2OdJGN7Z4L2brshOftp2so3nbyX9P9fgMWcQFulypkPo7lbQeSdZCrkRvOORoPfC5poAxm8n6+RZVCAz9xtWT456df1DVe+eC4XpNiEN5PyqVAeHT+ogsmbJ/Y+cQcoLNUAWe8JUYxllfjDKysuXWROE3TZPQ5t8xdUlgh8jlZnSk1dxkHOcqGK0TodbXJscFh4ynvqZkGNQmRDYcqGfQ5LU0NFDDUH77kmv+iFJVTyYH/9umFGx8UDhSDhyXA10miO46d8SwmwbPD05ptDhpwNpx4oGy/1OLo0IiRFDcPbqACjrzJGN1e9it16o8AGJkQTxGpa0P5LHMj1MMgZf4XY1Sd1wf72B21C46mZdhpr5h48aQAFffbQJNGlumEqmO1rIFgcUwprcoCAcZOVlB1w4QTV/i2ESShyGJC0/fVx97VAyAo3MuJyAU=",
  "Expiration" : "2017-04-28T03:46:48Z"
}
```

The general idea is that when your program first does an AWS API call it grabs
the credentials above and before all other API calls it checks if the
credentials have expired; in which case the credentials should be reloaded from
the metadata server.

Roles are superior to users in a couple of ways.  Most importantly they are
rotated fairly often, more than once a day.  Second, they are much more
trackable as the logged information includes the server that has assumed the
role.

## Library Work

When I was migrating from the long lived credentials to IAM roles I found that
there were three typical changes that needed to be made for library code.

 1. Easy: do the right thing (Paws, boto)
 2. Medium: force IAM on (older modules)
 3. Hard: update code to use V4 signatures or rewrite the module in terms of
    Paws (internal modules)

So for the easy stuff your best bet is to just stop passing credentials and it
will suddenly begin using the IAM role.  This is how all things should work
eventually.

The second variant, like
[Net::Amazon::S3](https://metacpan.org/pod/Net::Amazon::S3), generally means you
stop passing credentials and opt in to iam, like this:

```
my $s = Net::Amazon::S3->new({ use_iam_role => 1 })
```

Finally, the hard variant, which hopefully is rare for most folks, ended up
looking like this for us, in general:

```
use Paws;
Paws->load_class('Paws::Credential::ProviderChain');
use POSIX 'strftime';
use Net::Amazon::Signature::V4;

# ...

has credential_provider => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my ($self) = @_;
    Paws::Credential::ProviderChain->new->selected_provider;
  },
);

sub signer {
  my ($self) = @_;

  my $provider = $self->credential_provider;

  return Net::Amazon::Signature::V4->new(
    $provider->access_key,
    $provider->secret_key,
    $self->region, # 'us-east-1'
    _service(),    # 'sqs'
  );
}

sub sign_req {
  my ($self, $request) = @_;

  $request->header(
    Date => $request->header('X-Amz-Date') //
      strftime( '%Y%m%dT%H%M%SZ', gmtime )
  );

  $request->header( Host => $request->uri->host );
  if ($self->credential_provider->session_token) {
    $request->header(
      'X-Amz-Security-Token' => $self->credential_provider->session_token
    );
  }

  my $sig = $self->signer;
  $sig->sign( $request );
}
```

By the way, while working on the above I was pleased to be able to significantly
[improve the speed of both
Paws](https://github.com/ZipRecruiter/aws-sdk-perl/commit/acc26e4e0dc6e31af54ff258b84b21d5cc7c754a)
and
[Net::Amazon::Signature::V4](https://github.com/frioux/Net-Amazon-Signature-V4/compare/master...ZipRecruiter:time-piece).
Both cases had speed problems due to parsing dates often with DateTime either
too much or at all.

## Policies

Writing policies and attaching them to roles is just a matter of doing research
on code.  I started with the server classes that I thought would be easy and went from
there.  How I actually started was by creating a policy called "SkeletonKey"
which was *almost* full access, applying it to all of the servers, and then as
things migrated from credentials to IAM policies we could see the progress in
our CloudTrail logs.  After that the general pattern was to reduce use of the
SkeletonKey and finally take care of the dwindling number of things that used
the long-lived credentials.

As it stands today there are nearly 100 policies, generally of the format
`zr-$tier-$serverclass`, which is too many to reasonably be able to audit, in my
opinion.  I would like for us to head in a simpler direction, where our
resources are meaningfully named such that non-sensitive data (think geolookup
data, job taxonomies, etc) has a special prefix so that we can grant all servers
read access to these trivially (think `arn:aws:s3:::nonsensitive.*`) and thus
the policies that involve thought are more rare.  Build servers need write
access to these non-sensitive buckets, certain servers need read access to
sensitive ones, etc.

That's a lot of work, mostly because it involves renaming almost everything and
unifying things where possible, but I think that it would pay off because
complexity is always a liability, especially with respect to security.

## Threat Modeling

This is a complicated topic but having gone through the above I finally feel
like I understand why threat modeling is so hard.  When you learn a little bit
about security you are likely to parrot statements like: "just give the least
permissions that are needed" or "this is insecure so we should stop doing it."
It's so much more complicated than that.

Let's start off and consider the threats to a company like ZipRecruiter; here's
an incomplete list:

 1. Someone could get access to powerful credentials and delete all of S3,
    terminate all instances, delete all rdb instances, and leave us with an
    empty account.  This is the game over scenario (more on that in a minute.)

 2. A hacker could gain control of a server that has access to some form of PII
    and leak it, thus causing really expensive lawsuits.

 3. A hacker could gain control of a server and trash the server itself and all
    of the resources the server has access to.

 4. An engineer could have a bug or think they are connected to their server
    when it's really a production server and cause an outage.

These four things basically all cost the company money, in (likely) decreasing
amounts, the latter two likely equal.  All of the above can be turned into
numbers with some effort.  The top one is just however much money your company
is worth.  The second one varies wildly based on the kind of stuff your business
has; thankfully ZR doesn't have much sensitive user data.  The latter two could
be measured by figuring how much an outage or partial outage cost based on what
you make in that time period typically and how much time it takes engineers to
fix it (instead of working on other stuff.)

The other side of this security discussion is the cost of security.  It's easy
to think to yourself that having 2FA set up isn't too hard and requiring VPN
access is worth the hassle, but there is the constant overhead of supporting
people using these resources.  Similarly, if there are engineers who do not have
access to resources that they need to get work done, any time they spend waiting
for you to grant them access is money down the drain.

Finally, I would like to propose an alternative view to the fear and
handwringing initially posited here: easy disaster recovery.  If you can make
recovering lost resources easy and relatively cheap, it's likely going to be
better for everyone if access to the resources are granted more liberally.

When I started this whole process I generally thought to myself "what if the
adversary terminates a webserver or deletes a bunch of content from s3?!"  The
former should be fixed with good automation.  The latter is fixed with a good S3
versioning policy, which we have.  The list goes on and on, but generally the
point is: instead of trying to be perfect, or not allowing people to make
mistakes at all, just make failure not a big problem.

With that alternate view in mind, as a company that is worth a lot of money,
ZipRecrutier must address existential threats.  Locking down keys like this is
important and worth doing, but it is also important to decide what else we
should prevent against.  Just like we can have S3 versioning, we can also have
streaming backups of everything to a second AWS account that very few people
have access to. In the nuclear case described above this is a reasonable
solution.  Obviously we want to prevent such a situation, but it's so much
better to empower engineers with good disaster recovery than limit them to
prevent disasters.

---

I wish I had some books to recommend here.  I have learned most of the above
either through experience or from long discussions with Aaron Hopkins.  Since I
cannot recommend literature that can build upon this post, I'll just recommend
other stuff:

I am reading <a target="_blank"
href="https://www.amazon.com/gp/product/0812515285/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0812515285&linkCode=as2&tag=afoolishmanif-20&linkId=a4a0fd62f7aac2153d71785d3b4846f7">A
Fire Upon The Deep</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0812515285"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" /> right now and it's probably one of the best science fiction books
I've ever read.  I'd compare it to later books in the Ender series and some Greg
Egan.

This week I was stuck in my apartment for days on end so I baked cookies based
on a recipe from <a target="_blank"
href="https://www.amazon.com/gp/product/0393081087/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0393081087&linkCode=as2&tag=afoolishmanif-20&linkId=f3369baef9ef9b1e7ae1c3538381c0ed">The
Food Lab</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0393081087"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  The cookies turned out really well, as usual.
