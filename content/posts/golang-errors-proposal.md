---
title: The Go Errors Proposal
date: 2019-05-08T19:10:08
tags: [ golang ]
guid: 2071bf96-941c-43be-97d1-6e5ec33cadb3
---
Last week I sorta dove into the proposed interfaces for errors that will 
probably come out with Go 1.13.  This is my experience.

<!--more-->

First though, a very quick review.  In Go, the `error` type is a simple
builtin interface:

```golang
type error interface {
   Error() string
}
```

Simply put, `error`s have an Error method that returns a string.  That's it.

A common package that people use for dealing with errors is
`github.com/pkg/errors`.  It provides support for stack traces and adding extra
context to errors.  Here's how you might use it:

```golang
func configure(path string) (config, err) {
   file, err := os.Open(path)
   if err != nil {
      return config{}, errors.Wrap(err, "Couldn't load config")
   }
   ...
}
```

Later you might want to call this and handle certain errors:

```golang
c, err := configure(".config.json")
if inner := errors.Cause(err); os.IsNotExist(inner) {
   c = defaultConfig()
}
```

The above is nice, but it's limiting!  I honestly feel a little weird decorating
my errors with an effectively opaque string, and not being able to look any
deeper.  [The new errors
proposal](https://go.googlesource.com/proposal/+/master/design/29934-error-values.md)
resolves this by allowing errors to be nested but still individually accessible.
Here's how that works:

```golang
type ErrConfig struct {
   Name, Namespace string
   inner error
}

func (i *ErrConfig) Error() string {
   return fmt.Sprintf("%s (name=%s namespace=%s)", err, i.Name, i.Namespace)
}

func (i *ErrConfig) Unwrap() error {
   return i.inner
}
```

The above is a real example of an error related to configuring a resource that
has both a name and a namespace.  The error might be rendered to the user like:

```
Duplicate config (name=NumberOfMessagesDeleted namespace=AWS/SQS)
```

(The rest of the post mentions `errors` and `fmt`; pre Go-1.13 you can use
`golang.org/x/xerrors` to get basically all of the same functionality.)

If you wanted to do more than just render the error, you could detect if it's a
duplicate config error like this:


```golang
if errors.Is(err, ErrDuplicateConfig) { ... }
```

That's much nicer sugar than we had in the past, but we can do more.  Here's
some work code refactored to use the new `errors.As` function:

```golang
res, err := e.Client.GetSecretValue(&secretsmanager.GetSecretValueInput{SecretId: e.Entry.Name})
var aerr awserr.Error
if errors.As(err, aerr) {
	switch aerr.Code() {
	case secretsmanager.ErrCodeResourceNotFoundException:
		return nil, nil
	case secretsmanager.ErrCodeDecryptionFailure:
		return nil, nil
	case "AccessDeniedException":
		return nil, nil
	default:
		return nil, err
	}
}
```

This is neater than the previous `if aerr, ok := err.(awserr.Error); ok {`,
and actually handles the error nesting.

There's more to the proposal, like stack trace support and localization of
errors, but I don't expect to use that myself any time.

---

If you are interested in learning Go, this is my recommendation:

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
