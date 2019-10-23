---
title: Deploying to AWS Lambda with ZR CI/CD
date: 2019-05-14T19:10:44
tags: [ zr, golang, aws, lambda ]
guid: 70a39167-2e5f-4ebc-9b7d-c4dccb860391
---
On Friday I got started on a very basic set of tools to deploy code to lambda
easily.

<!--more-->

At [ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) we don't use a
whole lot of lambda, in general.  We have lots of reliable, easy to use
infrastructure for things like logging, secrets, etc, and all of that would have
to either be reimplemented or just be totally different in Lambda.  Be that as
it may, we still have code that is best run in Lambda because it is part of
bootstrapping our infrastructure.

Today I started on setting up a little Lambda tool that will ensure our central
prometheus and alertmanager are running, since if either of those are down, we
are flying blind.  The tool is a very basic Go program to do a simple web
request and then insert a value into CloudWatch.  We then set up a CloudWatch
alarm to fire if the value is not inserted often enough.

The next step is to actually deploy the code.  Normally we'd use Terraform,
since this is something running inside of AWS, but because you need to push a
zipfile of code to AWS, I thought a better pattern would be to deploy everything
to Lambda *except* for the actual code, and deploy the code itself with the CICD
pipeline.  The terraform is really basic, and maybe not even helpful, but just
in case, here it is:

```
resource "aws_lambda_function" "monitoring--meta" {
  function_name    = "monitoring--meta"
  role             = "${data.aws_iam_role.lambda.arn}"
  handler          = "meta"
  runtime          = "go1.x"
  filename         = "./stub.zip"

  vpc_config {
    subnet_ids         = ["${data.aws_subnet_ids.private.ids}"]
    security_group_ids = ["${aws_security_group.lambda.id}"]
  }

  environment {
    variables = {
      ZR_APP_CONFIG = "./conf.json"
    }
  }
}
```

`stub.zip` is a zipfile commited to the repo with a single text file in it.  If
I could have left that out I would have but AWS (or maybe their SDK) doesn't let
you.

Our CICD runs containers in each environment we request them to run in (for
example, in prod, or dev, or whatever) and the containers get their own built
configuration.  While I could have configured the Lambda functions per env, I
hardcoded the Lambda config and instead parameterize the config within the
zipfile.  Here's the shell script that's run in the container:

```bash
#!/bin/sh

set -x
set -e

cd /tmp
cp /export/monitoring--meta ./monitoring--meta
cp "$ZR_APP_CONFIG" ./config.json

zip deployment.zip ./monitoring--meta ./config.json

lambda-deploy
```

With the above we push the meta monitoring binary along with it's config in a
zipfile to lambda.  `lambda-deploy` is a super basic Go command, mostly built to
avoid needing a whole Ubuntu image just to push some bytes.  Here it is:

```golang
package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"

	"go.zr.org/common/go/config"
)

type configuration struct {
	Region string
}

func main() {
	var c configuration
	if err := config.Read(&c); err != nil {
		fmt.Printf("Failed to load config: %s\n", err)
		os.Exit(1)
	}

	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String(c.Region),
	}))
	u := lambda.New(sess)

	b, err := ioutil.ReadFile("deployment.zip")
	if err != nil {
		fmt.Printf("Failed to load zip: %s\n", err)
		os.Exit(1)
	}

	_, err = u.UpdateFunctionCode(&lambda.UpdateFunctionCodeInput{
		FunctionName: aws.String("meta--monitoring"),
		Publish:      aws.Bool(true),
		ZipFile:      b,
	})

	if err != nil {
		fmt.Printf("Failed to update function code: %s\n", err)
		os.Exit(1)
	}
}
```

I think it could have more flag based (or config based) parameterization, but
it's a start and was easy to write.  Somewhat incredibly, the first time I
ran the lambda uploading code it worked.  Now, thanks to this, whenever anyone
commits code to master that is in this code or used by this code (ie stuff in
`common/go`) a new build gets triggered and uploaded to lambda.  Pretty great.

---

(The following includes affiliate links.)

If you enjoyed this post you might appreciate
<a target="_blank" href="https://www.amazon.com/gp/product/149192912X/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=149192912X&linkCode=as2&tag=afoolishmanif-20&linkId=5157ec4156e15e73699ef549e1c56bad">The SRE Book</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=149192912X" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
and likely also
<a target="_blank" href="https://www.amazon.com/gp/product/1492029505/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1492029505&linkCode=as2&tag=afoolishmanif-20&linkId=7b8b8777b19721fdfe8413072a3fda03">The SRE Workbook</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1492029505" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
