---
title: Centralized known_hosts for ssh
date: 2018-06-01T06:47:11
tags: [ ssh, aws, golang ]
guid: 86856d76-0716-4f2c-80db-ad9ab7698e51
---
I just wrote some code to make a (hopefully) trustworthy, shared known_hosts
file for our whole company.  A handy side benefit is that it also grant us
hostname tab completion.

<!--more-->

At ZipRecruiter we have some automation called ec2-watch.  It creates DNS
records for all of our addressible resources in AWS based on their Name tags.
We eventually hope to open source that, but in any case, this automation allowed
the initial version of what this post was about: a little tool that would build
a list of servernames that I could tab complete.  Here's what that used to look
like, with comments inline:

```bash
# I typically break things into lots of steps because I use dash instead of
# bash, so there's no pipefail setting.

aws ec2 describe-regions > /tmp/regions.tmp
REGIONS="$(< /tmp/regions.tmp jq -r '.Regions[].RegionName')"

for r in $REGIONS; do
  export AWS_DEFAULT_REGION=$r
  aws ec2 describe-instances > /tmp/instances.tmp
  cat /tmp/instances.tmp |

    # Extract the Name from the instances that are running

    jq -r '.Reservations[].Instances[] |
           select(.State.Name == "running") |
           (.Tags[] | select(.Key == "Name") |
           .Value)' |

    # Append our internal domain 

    sed 's/$/.zr.com/'
done
```

This inexplicably became flaky, with `jq` becoming unable to parse the json
printed by the awscli.  I made some halfhearted attempts to fix it, but
eventually decided the better solution would be to make a purpose built tool
that could more correctly handle errors and other unexpected situations.

My initial plan was to simple reimplement the above in a single Go binary, which
would allow me to parallelize on top of the more careful error handling, but my
coworker pointed out that if I could instead generate a `known_hosts` file it
would be easier for other people to benefit from the work, and it could make us
more secure.

The new tool would generate a list of servers still, but in the list would be
the IP addresses and instance IDs of the hosts, since those never change in AWS
(when in a VPC.)  On top of that the tool would reach out and get the host's SSH
public key.  If a public key or IP address ever changes, that's an error.
Finally we bake all this information together and build a `known_hosts` file.

Here's the code that get's all the information from EC2, again with comments
inline:
```go
package main

import (
	"errors"
	"fmt"
	"os"

	// The official aws sdk for go is surprisingly good, despite forcing you to
	// write some pretty weird go
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

var ErrNameNotFound error = errors.New("Name not found")

func getName(i *ec2.Instance) (string, error) {
	for _, t := range i.Tags {
		if *t.Key == "Name" {
			return *t.Value, nil
		}
	}

	return "", ErrNameNotFound
}

// EC2Instance contains all of the identifying information we can get about a
// server through the EC2 api.  It's not shown in this blog post, but I store
// the ID and IPAddress in a JSON file for comparisons across runs.  If they
// vary I do not include the server in the known_hosts file.  Name can and does
// vary over time.
type EC2Instance struct {
	Name, IPAddress, ID string
}

// EC2Instances takes the region it's querying and returns all of the running
// instances from that region.
func EC2Instances(region string) []EC2Instance {
	awsSess, err := session.NewSession(&aws.Config{
		Region: aws.String(region),
	})
	if err != nil {
		panic(err)
	}
	svc := ec2.New(awsSess)

	// Running only
	dii := &ec2.DescribeInstancesInput{
		Filters: []*ec2.Filter{
			{
				Name:   aws.String("instance-state-name"),
				Values: []*string{aws.String("running")},
			},
		},
	}
	di, err := svc.DescribeInstances(dii)
	if err != nil {
		panic(err)
	}

	ret := make([]EC2Instance, 0, len(di.Reservations))

	for _, res := range di.Reservations {
		for _, i := range res.Instances {
			name, err := getName(i)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Couldn't get name for %s: %s\n", i, err)
				continue
			}
			ret = append(ret,
				EC2Instance{
					Name:      name,
					IPAddress: *i.PrivateIpAddress,
					ID:        *i.InstanceId,
				},
			)
		}
	}

	return ret
}
```

This code is only slightly odd, in my opinion, because the AWS Go SDK forces you
to do some unnatural things.  Next up is the SSH code, which was surprisingly
easy because Google already wrote an (experimental) SSH library:

```go

package main

import (
	"encoding/base64"
	"errors"
	"fmt"
	"net"
	"time"

	"golang.org/x/crypto/ssh"
)

// This is probably silly, but predefine an error that, if we were to
// accidentally bubble it up, would make it more clear what happened.
var errDial = errors.New("SSH hostkey probe ran")

// SSHInstance contains all the information we have about a server from the
// perspective of SSH.  Neither of these two values should ever change.
type SSHInstance struct {
	IPAddress string
	Key       string
}

// GetSSHInstance takes hostname (not including port) and returns SSHInstance and error.
// We actually use the IP address instead of the hostname since some servers
// only function in a group with a single shared name between them.
func GetSSHInstance(hostname string) (SSHInstance, error) {
	var ok bool
	var ret SSHInstance

	// This HostKeyCallback closes over the hostname and the return value

	c := func(hostname string, remote net.Addr, key ssh.PublicKey) error {
		ip, _, err := net.SplitHostPort(remote.String())
		if err != nil {
			return err
		}

		encKey := key.Type() + " " + base64.StdEncoding.EncodeToString(key.Marshal())
		ret = SSHInstance{
			IPAddress: ip,
			Key:       encKey,
		}
		ok = true

		return errDial
	}

	// ClientConfig simply bakes in HostKeyCallback

	config := &ssh.ClientConfig{
		User:    "UNUSED",
		Auth:    []ssh.AuthMethod{ssh.Password("UNUSED")},
		Timeout: 30 * time.Second,

		HostKeyCallback: ssh.HostKeyCallback(c),
	}
	_, err := ssh.Dial("tcp", hostname+":22", config)

	// Return the error only if our ok boolean is false

	if !ok {
		return ret, err
	}
	return ret, nil
}

// KnownHostLine prints host formatted for known_hosts
func KnownHostLine(host, ip, key string) string {
	return fmt.Sprintf("%s,%s %s\n", host, ip, key)
}
```

My integration code is complex, involving parallelism, error handling, storing
and loading of state, etc, so I think sharing the initial version would be more
helpful:

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	instances := EC2Instances("us-west-1")
	for _, instance := range instances {
		i, err := GetSSHInstance(instance.IPAddress)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Couldn't get ssh key for %s: %s\n", instance.Name, err)
			continue
		}

		fmt.Print(KnownHostLine(instance.Name+".zr.com", i.IPAddress, i.Key))
	}
}
```

The code above runs in a little over thirty seconds because of the SSH
connection timeout.  Some servers will never accept an SSH connection, for
various reasons, and while I could probably make this code take something closer
to seven seconds by simply excluding those servers, I don't think it's worth the
added complexity.

---

I haven't fully rolled this out yet at work.  I need to figure out where it will
run for each region and where the `known_hosts` files will go.  On top of that
I'll need to either write or document a simple method for syncronizing the
official `known_hosts` files to your local machine.  I have a work in progress
for my own laptop, but I suspect it won't work well for Windows users and it's
pretty complex already.

---

(The following includes affiliate links.)

If you want to learn more about programming Go, I strongly recommend
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=739b841afc9f8421681b07a2948bc991">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
Not only will you learn Go and much of the standard library, you will also learn
some of the subtle techniques for concurrent programming.

In a different vein is
<a target="_blank" href="https://www.amazon.com/gp/product/013937681X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=013937681X&linkCode=as2&tag=afoolishmanif-20&linkId=d016acb2388a369643c62ac22ea5715b">The Unix Programming Environment</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=013937681X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
This book teaches you how to comfortably take advantage of all of the
affordances that are available on a Unix machine.  While the book is almost
forty years old almost all of the material works fine on a 2018 Linux box.  I
read it a year or two ago and may re-read it again soon.
