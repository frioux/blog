---
title: Write a Love Letter
date: 2023-02-21T20:04:57
tags: [ "frew-warez" ]
guid: 8cdabc3f-f324-427f-8bcf-a1fd2ef47de6
---
Write a love letter by being a full stack engineer.

<!--more-->

In 2021 I made a tiny love letter for my wife.  It was an anniversary gift, at
the time celerbrating our 10th anniversary.  The love letter involves a whole
bunch of pieces:

 * A black walnut mount
 * An eInk screen
 * A PiZero to drive the screen
 * and a frontend to easily update the screen

The mount was one of the first woodworking things I'd done.  I didn't have a bench,
or handplanes, or any experience.  I used a chisel to chamfer the edges and mounted
the device to the mount using tacks since I couldn't find any nails small enough to
do the job.

The PiZero is simply running whatever debian release was latest then, with
TailScale to aid connectivity, and the PaPiRus code to update the screen.  (I
got pretty far replacing the Python code with a Rust port, but had no reason to
finish it and thus never did.)

![The device](/static/img/write-a-love-letter-1.jpg)

![The device with a library card for scale](/static/img/write-a-love-letter-2.jpg)

Finally, (and recently,) I added a frontend UI.  The UI lets me preview the
changes and update the screen over a web interface, instead of using SSH.  I
used Svelte for the UI.

![screencap of the UI](/static/img/write-a-love-letter.gif)

Here's the code for the frontend of the UI:

```
<script lang="ts">
  import debounce from 'lodash/debounce';

  let s: string = "example";
  let enc_s: string;

  $: enc_s = encodeURIComponent(s);

   // generating the image takes about 1.1s so
   // picking half that as debounce time.
   const handleInput = debounce(e => {
      s = e.target.value;
   }, 550)
</script>

<style>
  /* Via https://stackoverflow.com/a/45019339 */
  .my-img-container {
    position: relative;
    padding-top: 50%;
  }
  .my-img-container:before {
    content: " ";
    position: absolute;
    top: 50%;
    left: 50%;
    width: 80px;
    height: 80px;
    border: 2px solid white;
    border-color: transparent white transparent white;
    border-radius: 50%;
    animation: loader 1s linear infinite;
  }
  .my-img-container > img {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    width: 100% !important;
    height: 100% !important;
  }
  @keyframes loader {
    0% {
      transform: translate(-50%,-50%) rotate(0deg);
    }
    100% {
      transform: translate(-50%,-50%) rotate(360deg);
    }
  }
</style>

<div class="my-img-container">
   {#key s}
      <img alt="Rendering '{s}'" src="/render/?s={enc_s}" />
   {/key}
</div>

<form action="/save/" method="POST">
  <input on:input={handleInput} name="s" />
  <input value="save" type="submit" />
</form>
```

Most of the code is for the CSS spinner, but you can see that I have relatively
simple HTML binding the `s` field to the `s` variable, and some magic to
automatically make `enc_s` whenever `s` changes.

For the server I (of course) used Go.  For the static assets I embed them directly
into the binary and serve those from `/`:

```golang
//go:embed fe/dist/*
var assets embed.FS

func run() error {
// ...
	sub, err := fs.Sub(assets, "fe/dist")
	if err != nil {
		return err
	}
	mux.Handle("/", http.FileServer(http.FS(sub)))
```

For the preview I render the text to a temp file and serve that.

```golang
func realRender(s string, w io.Writer) error {
	p, err := exec.LookPath("papirus-write")
	if err != nil {
		return err
	}

	cmd := exec.Command(p, s)
	tmp, err := os.CreateTemp("/tmp", "*.png")
	if err != nil {
		return err
	}
	defer tmp.Close()
	defer os.Remove(tmp.Name())

	cmd.Env = append(cmd.Env, "TEST_IMAGE="+tmp.Name())
	if err := cmd.Run(); err != nil {
		return err
	}

	if _, err := io.Copy(w, tmp); err != nil {
		return err
	}

	return nil
}
```

PaPiRus doesn't support the above directly, so I hacked it in like this:

```diff
diff --git a/papirus/epd.py b/papirus/epd.py
index 4e0c204..679fdb7 100644
--- a/papirus/epd.py
+++ b/papirus/epd.py
@@ -177,6 +177,11 @@ to use:
         if image.mode != "1":
             image = ImageOps.grayscale(image).convert("1", dither=Image.FLOYDSTEINBERG)
 
+        test_path = os.environ.get('TEST_IMAGE', '')
+        if test_path != '':
+            image.save(test_path, 'PNG')
+            return
+
         if image.mode != "1":
             raise EPDError('only single bit images are supported')
 
@@ -206,6 +211,8 @@ to use:
         self._command('C')
 
     def _command(self, c):
+        if os.environ.get('TEST_IMAGE', '') != '':
+           return
         if self._uselm75b:
             with open(os.path.join(self._epd_path, 'temperature'), 'wb') as f:
                 f.write(b(repr(self._lm75b.getTempC())))
```

To be able to run locally, I made the go server generate an image the same size
as PaPiRus but it's blank.  If I were to figure out how to properly generate
text using go I would probably ditch `papirus-write` and switch to
`papirus-draw`, but this works for now.

You can [see the full project here](https://github.com/frioux/love-letter).

---

(Affiliate Links Below.)

Here are a few books I recently bought and suggest checking out:

 * [The
   Idiot](https://www.amazon.com/Idiot-Vintage-Classics-Fyodor-Dostoevsky/dp/0375702245?&linkCode=ll1&tag=afoolishmanif-20&linkId=7a7ded345606a15d25fa1c7201c69efc&language=en_US&ref_=as_li_ss_tl):
   I have been wanting to read this for a while.  It was a struggle to read,
   but I enjoyed it through and through.  I was surprised how relatable it was!
   I found the book much more charming than Crime and Punishment, but still
   firmly Dostoyevsky.

 * [The Name of the
   Rose](https://www.amazon.com/Name-Rose-Umberto-Eco/dp/0544176561?&linkCode=ll1&tag=afoolishmanif-20&linkId=7be40fab16fe61abda3c118bb58ff746&language=en_US&ref_=as_li_ss_tl):
   My better half suggested this one to me.  Normally we don't read the same
   kind of literature but she thought I'd enjoy this and she's absolutely
   right.  I love the philosophical asides and the fourteenth century setting.

 * [The Practicing
   Stoic](https://www.amazon.com/Practicing-Stoic-Philosophical-Users-Manual/dp/1567926118?&linkCode=ll1&tag=afoolishmanif-20&linkId=f45c872ca2642b4d32f8e9a1c31360e4&language=en_US&ref_=as_li_ss_tl):
   Stoicism is embarrassingly popular right now.  I heard of this book in a
   class put on by [Mahmoud Rasmi](https://decafquest.com/).  I had already
   read a couple [Ryan Holiday
   books](https://www.amazon.com/stores/Ryan-Holiday/author/B007LUHFH8?store_ref=ap_rdr&isDramIntegrated=true&shoppingPortalEnabled=true&linkCode=ll2&tag=afoolishmanif-20&linkId=2b51404d47216b6b3a3b1270557029f4&language=en_US&ref_=as_li_ss_tl)
   and all of [Taleb's
   Incerto](https://www.amazon.com/Incerto-5-Book-Bundle-Randomness-Antifragile-ebook/dp/B08M67TDPN?&linkCode=ll1&tag=afoolishmanif-20&linkId=77595a15972f794d49c1d102cc35f594&language=en_US&ref_=as_li_ss_tl),
   so this me deepening my understanding rather than getting started.

 * [Hands Employed
   Aright](https://lostartpress.com/products/hands-employed-aright?_pos=1&_sid=4b9a45f4c&_ss=r):
   is a book about Joshua Fisher, a Parson from Blue Hill, Maine.  Fisher's life
   and breadth of activity (notably the woodworking) inspires me.  This is a great
   book to read in the evenings when winding down.
