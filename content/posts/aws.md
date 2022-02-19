---
title: "AWS: Not just a place to run your VMs"
date: 2015-05-23T08:13:33
tags: [mitsi, aws, ec2, s3, automation, webscale]
guid: "https://blog.afoolishmanifesto.com/posts/aws-not-just-a-place-to-run-your-vms"
---
[I'm on my way out](https://twitter.com/frioux/status/582931035261800449) at
[Micro Technology Services, Inc.](http://mitsi.com/).  Because of that my
current boss has wisely taken me out of the loop of normal day-to-day
programming so that my replacement can get plenty of experience before I'm truly
"on vacation" as we say.  With that in mind I've been tasked with stuff that
will be interesting to me, valuable to the company, but if something goes
sideways it won't be a big deal if it never ever happens at all.

One of the things that we do with our software *today* is connect to up to
literally ten thousand persistent clients so that they can be sent emergency
notifications as quickly as possible.  The tough thing is that while we support
this, we don't have an easy way in house to test a fully loaded server.  I am
not sure I can divulge how many we can actualy test in house, but I will say
it's certainly not ten thousand.

For a long time we've considered testing on AWS, but for whatever reason I never
seriously looked into it.  Since my [new
employer](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) does indeed use AWS I
was more motivated than before to learn how it to use it; so finally I have both
motivation and time to figure this thing out!

## Windows Problems

So as of today, our server runs on Windows Server and our clients also run on
Windows.  That immediately makes some of the goal here more obscure than is
typical.  Linux automation software abounds; to automate Windows stuff often
requires a Domain Controller and "big" software like SCCM, which I am
zero-percent interested in learning about.  Additionally, I'd always assumed
that licensing in the cloud would be a nightmare and effectively remove Windows
from that market.

For better or worse Amazon has remedied all of my issues above.  For licensing
Amazon rolls licensing into the (miniscule) hourly fees that all customers pay.
As far as I can tell they are effectively giving Windows away.

Automation is harder, and there is a lot of misleading and downright incorrect
information on how to do automation on Windows servers on EC2.  I won't link to
the wrong ways to do stuff, I'll just give answers that I found through
research.

## Excitement!

Before I go much further I want to express just how cool this is.  I do not want
to use Windows.  I think it's a crappy operating system and generally not as
developer friendly as Linux is.  But on the other hand I've been in a shop for
years where for business reasons we are stuck with Windows; with that fact in
mind I will always continue to support Windows users on my OSS modules.

The tough thing is that once I leave MTSI I won't have Windows servers available
to test on, and I really would rather not maintain my own crappy little Windows
VM on my laptop.  AWS EC2 solves that problem elegantly.  I will just create a
VM on demand when I need it; it's cheap enough that I can spin up a new every
time, and fast enough that I don't think I'll mind (though you can be sure I'll
automate a lot so that I can maybe reuse a VM I've terminated but is still
extant.)  One really cool thing is that Amazon has set up the VMs to
automatically install all security updates at boot time, so I won't have to spin
up my VM and spend half an hour gardening it because it needs to reboot for
updates immediately.

Another thing that's really helpful is that there are images that have SQL
Server installed already, which will be very helpful for both DBIx::Class
testing and also for our project at work, which uses SQL Server.

## How to Run Scripts on Windows at Boot on EC2

[The documents for
this](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/UsingConfig_WinAMI.html#user-data-execution)
could be better; I really wish I could just send a pull request and then post a
link!  C'est la vie...

Let me start with the confusion and then show you how simple it is.  First, you
use the `--user-data` option of the `aws ec2 run-instances` command.  That flag
has the following documentation:

```
       --user-data (string)
          The Base64-encoded MIME user data for the instances.
```

I discovered that you don't need to encode it, or encoding is handled for you
anyway.  It's just data.

Next up, the documentation talks about using XML tags to define your scripts:

```
<powershell></powershell>

    Run any command that you can run at the Windows PowerShell command prompt.

    If you use an AMI that includes the AWS Tools for Windows PowerShell, you
    can also use those cmdlets. If you specify an IAM role when you launch your
    instance, then you don't need to specify credentials to the cmdlets, as
    applications that run on the instance can use the role's credentials to
    access AWS resources such as Amazon S3 buckets.

    Example:
    <powershell>
       Read-S3Object -BucketName myS3Bucket -Key myFolder/myFile.zip -File c:\destinationFile.zip
    </powershell>
```

What this doesn't tell you is that the script that goes in the tags *must not*
be "correctly" XML encoded (ie `"` should not become `&quot;`.

So how do you actually do this?  Here's an example:

```
aws ec2 run-instances          \
    --image-id ami-67cfe557    \
    --instance-type t2.micro   \
    --key-name MytKeyPair      \
    --user-data '<powershell>echo "this is a test!" > C:\test.txt</powershell>'
```

One of the really cool things AWS does for you is noted in the above
documentation quote; the Windows images Amazon provides (which you should use
for so many reasons) include special PowerShell integration for downloading
directly from S3, for example.  Very cool!

## Firewall Settings

The firewall settings built into EC2 are really easy to automate and to some
extent are likely to be more secure than anything built into or bolted on to any
operating system because they are "outside" of the OS.  With that in mind it is
likely worth it for you to disable the Windows firewall entirely and use the EC2
firewall settings.  The following constructs my barebones EC2 firewall settings:

```
GROUP="$(aws ec2 create-security-group --group-name TestServer --description Herp | jq --raw-output '.GroupId')"

aws ec2 revoke-security-group-egress --group-id $GROUP --cidr 0.0.0.0/0 --protocol -1 --port -1

aws ec2 authorize-security-group-ingress --group-name TestServer --protocol tcp --cidr 0.0.0.0/0 --port 3389
aws ec2 authorize-security-group-ingress --group-name TestServer --protocol tcp --cidr 0.0.0.0/0 --port 80
aws ec2 authorize-security-group-ingress --group-name TestServer --protocol tcp --cidr 0.0.0.0/0 --port 443

aws ec2 authorize-security-group-egress --group-id $GROUP --protocol tcp --cidr 0.0.0.0/0 --port 80
aws ec2 authorize-security-group-egress --group-id $GROUP --protocol tcp --cidr 0.0.0.0/0 --port 443
```

Note that it would be a really good idea to limit the ingress on your server to
your source IP, but these servers are shortlived enough that I haven't bothered.

You may have noticed that some of the commands above take a `--group-id` and
others take a `--group-name`.  [Hopefully this can get taken care
of](https://github.com/aws/aws-cli/issues/1340) (and maybe I'll finally learn
Python and submit a PR.)  Also, [jq is like grep but for
json](https://stedolan.github.io/jq/).

Once you set up a security group you can assign it to an instance when you run
it, and then in the user script above you can disable the builtin Windows
firewall with the following command:

```
netsh advfirewall set allprofiles state off
```

## How to Login to Windows VM on EC2

Unlike with an SSH based login, Windows does not support asymmetrical
cryptography based authentication.  It tries though, on EC2!  When you spin up a
server you give it a public key and AWS gives you the encrypted password, so
that assuming the software that runs on the server is secure, the password is
secret and requires the private key to decrypt.  The easiest way to get the
password for the server is by using the following command:

```
aws ec2 get-password-data --instance-id i-13cd432d --priv-launch-key ~/keys/MyKeyPair.pem
```

Then you can just use the same RDP tools you would normally use to connect to a
Windows machine.

## Progress

Of course the devil is in the details, and there are a lot of details for our
test setup.  I wish that what I wrote were open source, but really, it's so
specific to our stuff that it will just end up being a good war story.  I may
try to make a video of it in action, if only because initializing lots of
Windows user sessions looks cool on screen.

I've finished the test harness at work, which is good; I only have 5 days of
work remaining!  I'll likely post again about an OSS tool that will allow you to
easily test code on Windows and whatnot.  If you know of tools that already
exist let me know, maybe I can just contribute to a project.
