---
title: Converting a Slow Shell Script to golang
date: 2017-03-27T07:28:28
tags: [ golang, shell, async, ziprecruiter ]
guid: 7DDFFDAC-1275-11E7-BC72-B70990A9169D
---
We have a handy little shell script at work that we can use to figure out what
an IP address is.  It could be an EC2 instance, or someone's laptop, or a few
other random things.   I've been using it a lot lately and got annoyed that it
was so slow.  I ported it to Go over the weekend and wanted to share my
experience.

<!--more-->

First, let me be clear about how slow this program is.  The general usage is as
follows:

```
$ bin/ec2-resource-for-up $ip1 $ip2 $ip3 $ip4 $ip5 $ip6
$ip1:
  type: ec2_instance
  region: us-west-1
  id:   i-000deadbeefbabe95
  name: www-frew-01.sandbox
$ip2:
  type: unknown
  ptr: www.amazon.com
$ip3:
  type: elb
  region: us-east-1
  name: afoolishmanifesto
...
```

That took 63 seconds.  If you would like to follow along, the full code
including history and both versions is available [on
GitHub](https://github.com/frioux/ec2-resource-for-ip) (see both `master` and
`bash`.)

## Straight Shell to Go

So it looks up each IP trying to find out if it is an EC2 instance, an ELB, etc,
or finally it gives up and does a reverse IP lookup in the hopes that that will
include *something* and be the slightest bit useful.  Note that you do not need
to know what the above TLA's are for this post; just realize that they are
entities with IP addresses and we'll be using an API to resolve them.

Here's the old shell function we used to find an EIP:

```
eip() {
  local ip=$1

  local output=$(
    aws ec2 describe-addresses --filters Name=public-ip,Values=$ip | jq '.Addresses[]'
  )

  [ -n "$output" ] || return 1

  echo "$ip:"
  echo "  type: eip"
  echo "  region: $AWS_DEFAULT_REGION"
  echo "  id:   $(echo "$output" | jq -r ".AllocationId")"
}
```

We have something, more or less, that works like that for each thing we are
looking for.  So my first step when implementing this in Go was to migrate the
code in the obvious one-to-one conversion.  Note that there is an [official Go
AWS SDK](https://aws.amazon.com/sdk-for-go/) and if you are familiar with the
AWS API already it will feel totally comfortable, though not very much like Go.

Here is the code above, but in Go:

```
func eip(region string, sess *session.Session, ip string) (string, error) {
	svc := ec2.New(sess, &aws.Config{Region: aws.String(region)})
	params := &ec2.DescribeAddressesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("public-ip"),
				Values: []*string{aws.String(ip)},
			},
		},
	}

	resp, err := svc.DescribeAddresses(params)
	if err != nil {
		return nil, err
	}

	for _, address := range resp.Addresses {
		id := address.AllocationId
		return fmt.Sprintf(
			"  type: eip\n"+
				"  region: %s\n"+
				"  id: %s\n", region, *id), nil
	}
	return ret, nil
}
```

Not a whole lot more complex, though a lot less cute.  I started off migrating
the entire script in this fashion.  I was immediately impressed with how much
faster it was.  It turns out that a *huge* chunk of time in the original was
just starting up `aws-cli`.  That reduced the running time a solid order of
magnitude.  Nice!

## More Efficient API Usage

The next thing I did was convert the code to not call out to AWS for every
single IP.  This was a more natural thing to do in Go because it has complex
data structures, including hashes (called maps in Go) like pretty much every
major language out there.  This reduces the API usage from O(n) where n is the
input, to O(1).  Nice:

```
func eip(region string, sess *session.Session, ips []string) (map[string]string, error) {
	svc := ec2.New(sess, &aws.Config{Region: aws.String(region)})

	awsIps := []*string{}
	for _, ip := range ips {
		awsIps = append(awsIps, aws.String(ip))
	}

	params := &ec2.DescribeAddressesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("public-ip"),
				Values: awsIps,
			},
		},
	}

	resp, err := svc.DescribeAddresses(params)
	if err != nil {
		return nil, err
	}

	ret := make(map[string]string)
	for _, address := range resp.Addresses {
		id := address.AllocationId
		ret[*address.PublicIp] = fmt.Sprintf(
			"  type: eip\n"+
				"  region: %s\n"+
				"  id: %s\n", region, *id)
	}
	return ret, nil
}
```

It's not a lot more complex and it's noticeably faster.  I was not tidy enough
with my git history to be able to go back and benchmark.  It wasn't hugely
faster, because as I stated before, most of the time before was taken running
the code, not actually blocking on AWS.

## Concurrency

The next step was to make use of Go's built in concurrency and do these calls in
parallel.  I asked my friend and coworker Aaron Hopkins what he would recommend
and he pointed me to [errgroup](https://godoc.org/golang.org/x/sync/errgroup).

Here's the synchronous version:

```
	for _, region := range regions {
		found, err := ec2_instance_public(region, sess, ips)
		showResults(found, err, &foundIps)

		found, err = ec2_instance_private(region, sess, ips)
		showResults(found, err, &foundIps)

		found, err = eip(region, sess, ips)
		showResults(found, err, &foundIps)

		found, err = find_elb(region, sess, ips)
		showResults(found, err, &foundIps)
	}

```

and here is the parallel version:

```
	find_ips := func(ctx context.Context, ips []string) (map[string]string, error) {
		g, ctx := errgroup.WithContext(ctx)

		results := make(map[string]string)
		for _, region := range regions {
			region := region
			g.Go(func() error {
				found, err := ec2_instance_public(region, sess, ips)
				for k, v := range found {
					results[k] = v
				}
				return err
			})
			g.Go(func() error {
				found, err := ec2_instance_private(region, sess, ips)
				for k, v := range found {
					results[k] = v
				}
				return err
			})
			g.Go(func() error {
				found, err := eip(region, sess, ips)
				for k, v := range found {
					results[k] = v
				}
				return err
			})
			g.Go(func() error {
				found, err := find_elb(region, sess, ips)
				for k, v := range found {
					results[k] = v
				}
				return err
			})
		}

		err := g.Wait()
		return results, err
	}

	results, err := find_ips(context.Background(), ips)
	showResults(results, err, &foundIps)
```

The code is sadly much more obscured by the parallelism and the fact that
merging maps in Go is super noisy, but basically I start a thread per task, per
region, wait for all of them to complete, and then show the results.  This cut
time down to about 2.5 seconds I think.

## Enhance

At ZipRecruiter we only use a few of the many regions that AWS provides, so this
script only searched that subset.  With the new tool, there is no reason to have
such a limitation, so I made a slight change and now search *all* regions at the
time!

```
func allRegions(sess *session.Session) ([]string, error) {
	svc := ec2.New(sess, &aws.Config{Region: aws.String("us-west-1")})

	ret := []string{}

	resp, err := svc.DescribeRegions(nil)
	if err != nil {
		return []string{"us-west-1", "us-east-1", "us-west-2"}, err
	}

	for _, region := range resp.Regions {
		ret = append(ret, *region.RegionName)
	}
	return ret, nil
}
```

This is a pretty major improvement on the original functionality, where adding
another region to the list would slow down the program even more.

## Room for Improvement

There are a few things that I think could be better about what I implemented.

First off, it uses `dig(1)` to look up the `PTR` record for the `unknown` case.
Go has support for DNS queries but it didn't look like `PTR` queries were
exposed out of the box.  It's fine to use `dig(1)` but it means that it has some
possibly surprising dependecies.

Second, when we find ELBs based on IP we have to get all of the IP addresses for
all of our ELBs.  Currently that means doing a lot of IP lookups.  This should
be parallelized, at least to something like two or four at a time.  I tried to
do this but for some reason my code just blocked forever.

Third, I build up a hash of ip to strings and then print out all the
information.  If I instead sent that data over a channel I could at least see
the information printing to my screen immediately, and I suspect I could ditch
the `errgroup` since for the most part I ignore errors in my code here.

The code isn't very pretty and I haven't gotten to documenting it yet, but it
was a fun exercise and I will likely use the results on a daily basis.

---

If you would like to learn Go, the one really good book I've seen is <a
target="_blank"
href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=055ce6d2540535a65870ad6b00673623">The
Go Programming Language</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440"
width="1" height="1" border="0" alt="" style="border:none !important; margin:0px
!important;" />.  There are a ton of resources at [The Official Go
Website](https://golang.org/) as well.  Have fun!
