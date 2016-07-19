---
aliases: ["/archives/1893"]
title: "Leveling Up"
date: "2013-10-05T15:33:34-05:00"
tags: [frew-warez, acm, aphyr, cap, crdt, iptables, jepsen, lxc]
guid: "http://blog.afoolishmanifesto.com/?p=1893"
---
This is a blog post about some of the stuff that I've learned over the past few months. It's hard to find causes for things in real life, but I can say at the very least that in this situation the catalyst for my learning was Aphyr's [Jepsen](http://aphyr.com/tags/jepsen) series. If you have not yet read it, you really should. The gist is that distributed databases often promise (or sound like they promise) more than is possible, and many times don't even execute what they could do.

# What is Possible?

When I read the Jepsen series I had been struggling for months with SQL Server merge replication. My coworker told me, "just trust Microsoft, it will just work!" For those who don't know, SQL Server is an **excellent** database, and I am dreading switching to Postgres for portability. I know Pg has all the bells and whistles, but SQL Server can handle [crazy](https://gist.github.com/frioux/3bf46454730308725c07) [queries](https://gist.github.com/frioux/3220451) without breaking a sweat, and more importantly, I already know it's weak points (Pg users seem to think their database of choice is perfect, thus telling me that they cannot be trusted.)

But I digress. In the Jepsen series Aphyr introduced the [CAP Theorem](https://en.wikipedia.org/wiki/CAP_theorem). I won't go into details, but basically when you have a replicated database you can have **only two** consistency (everything is the same), availability (all replicas are live), and partition tolerance (the overall system keeps working when replicas cannot reach each other.) This told me without a doubt that no matter how much money we gave Microsoft, they could never do it all. Honestly it was freeing to me because I knew I wasn't missing something, we just had to decide what is important to us.

As a side note, Aphyr mentions CRDT's as a good way to ensure that your data is not lost when the real world does it's thing. I really enjoyed learning about CRDT's, but I suspect that they are rarely feasible for most information worth storing. Frustratingly, in the original CRDT paper the authors mention a naive way to do something (where you end up with a lot of garbage that never gets deleted) and then propose a data structure that has the same problem in the absence of consensus.

Second side note: much is made of consistency, but it is ultimately chimera. If your database models anything real, there are times when it is wrong. Do you have tables representing what users are connected? Do you try hard to show your user the most accurate view of the current data, despite the fact that it is shifting sands that change immediately after their browser renders the html? Do not misunderstand, consistency is good and worth pursuing, but perfect consistency will only occur in a closed system.

# How to know

Perhaps the most important thing I learned from the Jepsen series was that there is already a huge amount of information out there that directly applies to what I'm doing. At first I blamed my alma mater for teaching me about the halting problem (which has never come up in my professional career) instead of teaching me about the CAP Theorem. But the fact is that there is no way I could have learned all the things that apply to real life; indeed I probably never will. A week or two after reading the Jepsen series I got a subscription to the ACM Digital Library and have been trying to regularly read academic papers. It's tough because I have trouble finding what I'm looking for, knowing what's out there, and frustratingly, even though the ACM DL is very good, it certainly doesn't have **all** CS papers. But I do what I can.

# Break it

In the Jepsen series Aphyr did things to show what these database systems do when the [stupid assumptions](https://en.wikipedia.org/wiki/Fallacies_of_Distributed_Computing) are invalidated. And unlike many people, he didn't just "unplug the cable" to see how things work when a server dies. Often it's worse if a server suddenly slows down, or just drops a bunch of packets.

# Techniques

Aphyr automated his stress testing way more than any I've ever seen. All of the code is in an open source repository ripe for plundering. There are two tools specifically that I am using for testing against my own distributed system.

First is iptables. If you live under a rock or something, iptables has been the linux kernel level firewall system for about 15 years. I never suspected I'd have an interest in learning how to use them directly. If it isn't obvious, iptables can be leveraged to create partitions between systems or slowing down packet delivery. Very cool.

Next, and maybe more exciting, is LXC. It seems like all unices have these things now. BSD has jails, whatever used to be called Solaris has zones. You may be some weird zealot who hates the GPL and Stallman and switches software due to the license (tip: you are similar to Stallman) but the fact that last night in less than 30 minutes I made 5 lightweight, totally working, ubuntu virtual machines on my laptop is awesome. Any time I consider making a handful of VMs with VirtualBox or VMWare or Hyper V (yes I've used them all professionally) I am filled with existential dread. It takes too long; it takes too much ram; it takes too much hard disk space. This is how I did it in ubuntu:

    lxc-create -n n1 -t ubuntu
    lxc-start -n n1
    # log in, install some extra packages
    for x in 2..5; do lxc-clone -o n1 -n n$x; lxc-start -d -n n$x; done

The slowest part was that when you first create a machine with the ubuntu template you have to download a bunch of packages for the VM, but they are handily cached, so even if you destroy (another very fast operation) all of your containers it's pretty fast to create new ones.

# The End

Hopefully you are able to glean something of use to you in this post. I'm interested to discuss distributed systems or hear recommendations of papers if you have any. Thanks for reading!
