---
title: Self-Signed and Pinned Certificates in Go
date: 2018-12-23T07:29:05
tags: [ golang, ssl, tls ]
guid: 4e8b5670-3908-4ced-9ce7-b0f5dabfe085
---
I recently needed to generate some TLS certificates in Go and trust them.
Here's how I did it.

<!--more-->

At [work](https://web.archive.org/web/20190330183125/https://www.ziprecruiter.com/hiring/technology) we have this cool
thing that we are working on that exposes a local server that acts like the AWS
IAM metadata server.  It not only makes our laptops more like production, but it
also makes authenticating to Amazon simpler and more secure.  I hope to write
more about it by and by but there are a lot of pieces to it. 

The tool (called ZAM) runs a web server and also has an embedded browser.  We
need the browser to trust its embedded certificate but do normal TLS
verification otherwise.  When I first started adding features and fixing bugs
with the tool, the key and certificate were checked into our repository with a
100 year expiration date.  At the minimum this seems messy.

I initially updated it so that the build script would generate a new cert for
each build, if only so we wouldn't be forced to check in a certificate in the
repository.  I proudly mentioned my change to Aaron Hopkins and he, as he often
does, said that that wasn't good enough and that we need to generate a
certificate in memory on each run of the app.  The rule of thumb he gave was
that we shouldn't even be shipping a key with an app at all, so generating it is
better.

It turned out that generating a key and cert in Go was surprisingly
straightforward.  Much more pleasant than using `openssl`:

```golang
import (
	"bytes"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/base64"
	"encoding/pem"
	"math/big"
	"time"

	"github.com/pkg/errors"
)

// KeyPairWithPin returns PEM encoded Certificate and Key along with an SKPI
// fingerprint of the public key.
func KeyPairWithPin() ([]byte, []byte, []byte, error) {
	bits := 4096
	privateKey, err := rsa.GenerateKey(rand.Reader, bits)
	if err != nil {
		return nil, nil, nil, errors.Wrap(err, "rsa.GenerateKey")
	}

	tpl := x509.Certificate{
		SerialNumber:          big.NewInt(1),
		Subject:               pkix.Name{CommonName: "169.264.169.254"},
		NotBefore:             time.Now(),
		NotAfter:              time.Now().AddDate(2, 0, 0),
		BasicConstraintsValid: true,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth, x509.ExtKeyUsageServerAuth},
		KeyUsage:              x509.KeyUsageDigitalSignature | x509.KeyUsageCertSign,
	}
	derCert, err := x509.CreateCertificate(rand.Reader, &tpl, &tpl, &privateKey.PublicKey, privateKey)
	if err != nil {
		return nil, nil, nil, errors.Wrap(err, "x509.CreateCertificate")
	}

	buf := &bytes.Buffer{}
	err = pem.Encode(buf, &pem.Block{
		Type:  "CERTIFICATE",
		Bytes: derCert,
	})
	if err != nil {
		return nil, nil, nil, errors.Wrap(err, "pem.Encode")
	}

	pemCert := buf.Bytes()

	buf = &bytes.Buffer{}
	err = pem.Encode(buf, &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(privateKey),
	})
	if err != nil {
		return nil, nil, nil, errors.Wrap(err, "pem.Encode")
	}
	pemKey := buf.Bytes()
	// ...
```

The above works fine for our use case and is, in my opinion, nicer than most of
the commandline tools to do this kind of thing.

The next step was to generate the "pin", or more technically: the [SPKI
Fingerprint](https://tools.ietf.org/html/rfc7469#section-2.4).  Basically you
use this to say: "any time you see a cert with this public key, trust it."  It's
useful when you don't want to build out some kind of certificate authority but
still want to verify your TLS traffic.  Also Chrome supports it out of the box.

Generating the pin is as simple as this:

```golang
	cert, err := x509.ParseCertificate(derCert)
	if err != nil {
		return nil, nil, nil, errors.Wrap(err, "x509.ParseCertificate")
	}

	pubDER, err := x509.MarshalPKIXPublicKey(cert.PublicKey.(*rsa.PublicKey))
	if err != nil {
		return nil, nil, nil, errors.Wrap(err, "x509.MarshalPKIXPublicKey")
	}
	sum := sha256.Sum256(pubDER)
	pin := make([]byte, base64.StdEncoding.EncodedLen(len(sum)))
	base64.StdEncoding.Encode(pin, sum[:])

	return pemCert, pemKey, pin, nil
}
```

In this project we embed the browser using
[chromedp](https://github.com/chromedp/chromedp), (along with a lot more other
complexity that I don't want to get into right now.)  You can set the pin like
this:

```golang
	cdp, err := chromedp.New(
		ctx,
		chromedp.WithRunnerOptions(
			// ...
			runner.Flag("ignore-certificate-errors-spki-list", pin),
		),
	)
```

Google Chrome itself supports the flag too, which you might consider using for a
less integrated app, where you instead just require that Chrome itself is
installed.  (By the way, [this is a great Chrome flag
reference](https://peter.sh/experiments/chromium-command-line-switches/).)

As an interesting side note, the automatically generated certificate made bugs
more clear within a day of committing it.  Somehow someone ended up with two
versions of ZAM running at the same time.  If we had the old version where we
just ignored cert errors it would have failed in some bizarre way.  With the
current version we get an immediate cert error.  It might be nice to decorate
that page more clearly in that case though.

---

For the most part I felt like getting this all working was pretty pleasant.  The
most annoying part is that, despite the fact that Go is a strongly typed
language with a generally useful type system, nearly all of the actual types
above are `[]byte`.  The key, cert, and pin are all `[]byte`.  Sometimes they
are `PEM`, sometimes they are `DER`, but they are always `[]byte`, which is
annoying, but at least this code tends to be pretty isolated.

Somewhat comically Go sorta detects if you accidentally swap the key and the
cert by returning an error that the `PEM` cert has an `RSA PRIVATE KEY` header.
If they were distinct types that would be immediately clear, instead of
happening at runtime.  Oh well.

---

(The following includes affiliate links.)

If you don't already know Go, you should definitely check out
<a target="_blank" href="https://www.amazon.com/gp/product/0134190440/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0134190440&linkCode=as2&tag=afoolishmanif-20&linkId=44bc682044ff1b8a290c3c35c788e3e5">The Go Programming Language</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0134190440" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's not just a great Go book but a great programming book in general with a
generous dollop of concurrency.

Another book to consider learning Go with is
<a target="_blank" href="https://www.amazon.com/gp/product/1786468948/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1786468948&linkCode=as2&tag=afoolishmanif-20&linkId=803e58234c448a8d1f4cc2693f2149b8">Go Programming Blueprints</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1786468948" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It has a nearly interactive style where you write code, see it get syntax errors
(or whatever,) fix it, and iterate.  A useful book that shows that you don't
have to get all of your programs perfectly working on the first compile.
