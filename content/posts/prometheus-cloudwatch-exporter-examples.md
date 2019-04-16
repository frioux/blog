---
title: Prometheus cloudwatch-exporter Examples
date: 2019-04-15T19:35:05
tags: [ prometheus, aws, cloudwatch ]
guid: 3b7dacfb-1cba-4400-ba2f-feda2721e6c3
---
Today I spent a few hours figuring out how to integrate Prometheus with AWS.

<!--more-->

If you use AWS and want to monitor your infrastructure, you probably are going
to use [Cloudwatch](https://aws.amazon.com/cloudwatch/).  If you use Prometheus,
you'll probably use
[cloudwatch-exporter](https://github.com/prometheus/cloudwatch_exporter).  For
the most part, `cloudwatch-exporter` works perfectly well and, as far as I can
tell, exposes all the various bits we could ever want.

I am writing up a bunch of initial configuration for our `cloudwatch-exporter`
so that teams can monitor and alert on their infrastructure.  First off, a quick
note about [how Cloudwatch pricing
works](https://aws.amazon.com/cloudwatch/pricing/): you fundamentally will be
doing a bunch of GetMetricData requests, and these requests end up querying some
number of metrics.  The official cost from Amazon is:

> $0.01/1,000 metrics requested using GetMetricData

This is a little abstract, but I'll explain it more as we go.

The first AWS service I wanted to add monitoring on is SQS; SQS is AWS' queue
service and it exposes [a bunch of useful
metrics](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html).
I looked over the list and our notes from a meeting on how we should monitor SQS
and came up with the following configuration for `cloudwatch-exporter`:

```yaml
region: us-west-2                                  
metrics:                                                                                                           
                                            
 - aws_namespace: AWS/SQS     
   aws_metric_name: ApproximateAgeOfOldestMessage
   aws_dimensions: [QueueName]  
   aws_statistics: [Maximum]  
                        
 - aws_namespace: AWS/SQS     
   aws_metric_name: NumberOfMessagesReceived  
   aws_dimensions: [QueueName]  
   aws_statistics: [Sum]      
                        
 - aws_namespace: AWS/SQS     
   aws_metric_name: NumberOfMessagesDeleted
   aws_dimensions: [QueueName]           
   aws_statistics: [Sum]      
                        
 - aws_namespace: AWS/SQS     
   aws_metric_name: NumberOfMessagesSent
   aws_dimensions: [QueueName]                        
   aws_statistics: [Sum]    
                        
 - aws_namespace: AWS/SQS     
   aws_metric_name: ApproximateNumberOfMessagesVisible
   aws_dimensions: [QueueName]                        
   aws_statistics: [Sum]    
```

Here's a sample of the exported metrics above:

```
aws_sqs_approximate_age_of_oldest_message_maximum{job="aws_sqs",instance="",queue_name="utility",} 0.0 1555294800000
aws_sqs_approximate_number_of_messages_visible_sum{job="aws_sqs",instance="",queue_name="utility",} 0.0 1555294800000
aws_sqs_number_of_messages_received_sum{job="aws_sqs",instance="",queue_name="utility",} 0.0 1555294800000
aws_sqs_number_of_messages_received_sum{job="aws_sqs",instance="",queue_name="utility",} 0.0 1555294800000
aws_sqs_number_of_messages_deleted_sum{job="aws_sqs",instance="",queue_name="utility",} 0.0 1555294800000
```

The above is five metrics.  If you have six SQS queues and you read them every minute, that would cost $12.96:

```
6 * 5 * 24 * 60 * 30 * 0.01 / 1000
12.96
```

We'll be providing the above metrics (and many more for other stuff in AWS) and
a guide of example alert rules that teams can use to correctly monitor their
infrastructure.  Here's an obvious rule to detect when the consumer of a queue
is down:

```
aws_sqs_approximate_age_of_oldest_message{queue_name="my-awesome-queue"} > 15 * 60
```

The above would alert if an item sat in your queue for over 15 minutes.  Tune to
your SLA.

Another common failure mode is that suddenly the queue processor can't keep up.
This needs some care configuring, but here's one way you could express it:

```
delta(aws_sqs_approximate_number_of_messages_visible{queue_name="my-cool-queue"}[30m]) > 0
```

I'm not thrilled with the above, since a huge spike in inbound messages could
make it fire, but I intend to experiment and bounce ideas off coworkers.

---

As a side note I think it's important to mention that the official
`cloudwatch-exporter` has some performance issues due to being implemented in
terms of GetMetricStatistics instead of GetMetricData.  The price (if I'm
reading correctly) should be the same, but it is, at least for us, pretty slow.

---

If you want to learn more about prometheus, you might check out
<a target="_blank" href="https://www.amazon.com/gp/product/1492034142/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1492034142&linkCode=as2&tag=afoolishmanif-20&linkId=278532d1c97806594ebd0c4fcfa13ac0">Prometheus: Up &amp; Running</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1492034142" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.

Another option, which I have only glanced at so far, is
<a target="_blank" href="https://www.amazon.com/gp/product/B07DPH8MN9/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=B07DPH8MN9&linkCode=as2&tag=afoolishmanif-20&linkId=2b4f2f0a6875da783935182c302d73c5">Monitoring with Prometheus</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=B07DPH8MN9" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.

I have only spent a little time glancing at these two books and both of them
have good stuff in them.
