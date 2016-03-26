---
title: Migrating My Blog from Linode to CloudFront
date: 2016-02-20T23:18:51
tags: [linode, aws, s3, cloudfront]
guid: "https://blog.afoolishmanifesto.com/posts/migrating-my-blog-from-linode-to-cloudfront"
---

## Motivations

I have just completed the process of migrating my blog to
[CloudFront](https://aws.amazon.com/cloudfront/).  There are a few reasons for
this.  Initially I had planned to migrate everything on my Linode to
[OVH](https://www.ovh.com/us/), which has DDoS mitigation and I think even
uptime SLAs. The reasoning behind that was the Linode kept getting DDoS'ed and I
was sick of it.

Additionally, in January I went to
[SCALE14x](https://www.socallinuxexpo.org/scale/14x) and [Eric
Hammond](https://twitter.com/esh) (who was introduced to me by [Andrew
Grangaard](https://twitter.com/spazm)) pointed out that by using the current
generation of AWS tooling (Lambda, DynamoDB, etc) you can reduce total
cost to less than the minimum pricing on a Linode.  The cost of my Linode isn't
super expensive (less than the price of Netflix) but every little bit helps.  On
top of that we use the AWS stuff at work so another chance to be familiar with
AWS is a good thing.

Finally, after [the most recent security
fiasco](https://blog.linode.com/2016/02/19/security-investigation-retrospective/)
I just feel safer using infrastructure that is more well tested in general.
Plus I think I can get away with moving *most* of my stuff off of VMs, which
means I'm less likely to screw something up.

As a side note, I have been self hosting my blog since 2007.  I am loathe to do
external hosting, as external hosts all seem to end up dying at some point
anyway.  I did briefly consider hosting on github, but you either have to change
your domain name (`frioux.github.io`) or have no TLS (more on that later) so I
decided to go the manual hosting route.

## Howto

For small stuff like this, it can be worthwhile to make a distinct AWS account
for each project.  I made a special blog account to help me with accounting if
the total cost of this ends up being more than I expect.  Because I have my own
domain I have as many email addresses as I want, so I just made a new one
specifically for my blog, and then used it to make a new AWS account.

After creating the blog account I [enabled Cost
Explorer](https://console.aws.amazon.com/billing/home#/costexplorer).  I have no
idea why this has to be turned on, because it's super helpful to be able to use.
Next I [Activated
MFA](https://console.aws.amazon.com/iam/home?#security_credential) (you know,
for security!) Maybe I should have done that first.  I could do something with
`IAM` I'm sure but it would be overkill for something as single task as this
that only I will ever use.

[I followed instructions I found
here](http://blog.earaya.com/blog/2012/07/13/hosting-a-static-website-on-amazon-s3-and-cloudfront/)
to set up the S3 and CloudFront parts.  The only issue I ran into was that I
forgot to set the CNAME both in DNS *and* in the CloudFront config.  To actually
sync my blog I use the following command:

```
aws s3 sync --delete . s3://blog.afoolishmanifesto.com
```

The `--delete` flag is so that files that aren't in the remote side get removed.

At this point you should be able to test that everything is mostly working by
visiting the endpoint that the bucket provides.  The CloudFront part usually
takes a while because it has to sync all over the world and wait for DNS too.

Because I care about my readers I only serve my blog over HTTPS.  It's not that
I think you are reading my blog in secret; I don't want malware to be injected
by messed up access points.  Because of that I had to get a certificate.  If I
were serving from US East I could have gotten free, auto-renewing certificates
from Amazon.  Sadly I didn't think to do this, even though it would have been
trivial since I don't really care where the site is served from.
[StartSSL](https://startssl.com) also gives free certificates, so that's what I
used.  To upload your certificate you need to use a command like this:

```
aws iam upload-server-certificate \
      --server-certificate-name blog_cert \
      --certificate-body file://blog.afoolishmanifesto.com/ApacheServer/2_blog.afoolishmanifesto.com.crt \
      --private-key file://blog.afoolishmanifesto.com.priv \
      --certificate-chain file://pwd/blog.afoolishmanifesto.com/ApacheServer/1_root_bundle.crt \
      --path /cloudfront/blog/
```

Getting and creating the certificate is not something I'm super interested in
writing about, as it's pretty well documented already.

## Benefits

Clearly the fact that I pulled the trigger on this project means that I think it
was worth it, so here are some of the benefits to using CloudFront to host my
blog.

### Pricing

After reading the [nightmare glacier
post](https://medium.com/@karppinen/how-i-ended-up-paying-150-for-a-single-60gb-download-from-amazon-glacier-6cb77b288c3e#.nm61wufzw)
last month I commited to reading and understanding the pricing models of the
various AWS services before using them.  With that in mind I read about the
pricing of the stuff I'll be using for my blog before embarking on this project.

The [S3 Pricing](https://aws.amazon.com/s3/pricing/) is pretty understandable.
I'll pay 3¢/mo for the storage, as my blog is about 35 mB of HTML and images
total.  Uploading the entire blog afresh (which I sorta assume is what `sync`
does, but I'm not sure) is about 16k files, which (rounding up) is 2¢.  So if
`sync` works inefficiently a post is likely to cost me about 5¢, including
fixing typos or whatever.  Assuming a **lot** of posts, let's say sixteen a
month, that adds up to 80¢ per month.  There is no charge to transfer from S3 to
CloudFront, so that adds up to a maximum of 83¢ per month for S3.

The [CloudFront Pricing](https://aws.amazon.com/cloudfront/pricing/) is even
more simple.  Assuming 100% of the traffic from my Linode is my blog (it is
without a doubt mostly IRC, but for accounting purposes let's assume the worst)
and it is all from India (again, nope) the charge from CloudFront will be 51¢.
Assuming every single request on my server is to my blog (another verifiable
falsehood) that would add whopping $1.10 to the monthly bill.  That adds up to
$1.61 per month for CloudFront.

So, worst case scenario, my monthly bill is $2.44 a month.  I suspect it will likely be
much less than that.  I'll try to remember at the end of March to update this
post with what the real price ends up being.

### Global

Unlike my Linode, which always resided in the wonderful city of Dallas, TX,
CloudFront specifically exists to be global.  So if you read my blog from the UK
(I'm sure there are some!) or Japan (eh... maybe not) it should be a lot more
snappy now.

### Isolation

Sometimes my Linode gets rebooted for Hypervisor updates; or worse I mess up my
Apache config or something.  The above setup is well isolated from all my other
stuff so it should be very reliable.

## Drawbacks

But it's not all unicorns, rainbows, penny-whistles, and blow.  There are some
problems!

### Pricing

The above calculations are based on past history.  If I get DDoS'd directly I
will suddenly get a bill for a thousand bucks, instead of my server just falling
over.  That's something that gives me serious pause.  My boss told me that
you can use Lambda as rate limiting tool.  I expect to look into that before too
long, especially because I have other plans for Lambda anyway.

### Slow to Update

Unsurprisingly, because CloudFront is a CDN, there is a TTL on the cached data,
so sometimes it can take a few minutes for a modification to the blog to go
live.  Not a huge deal, but good to know anyway.

---

Overall this has been a relatively painless process and I think it is worth it.
I hope this helps anyone considering migration to AWS.
