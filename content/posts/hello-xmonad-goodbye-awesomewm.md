---
title: Hello XMonad, Goodbye AwesomeWM
date: 2017-05-19T07:18:10
tags: [ awesome, tiling-window-manager, window-manager, xmonad ]
guid: 38520872-276D-11E7-902F-B94733C6AC79
---
After using the aptly named [AwesomeWM](https://awesomewm.org/) for nearly five
years I have switched back to XMonad.

<!--more-->

# AwesomeWM

[In 2012 I wrote a really long blog post about my journey to
AwesomeWM](/posts/awesomewm/).  I never expected that I'd abandon it because
has always been so great.  Unfortunately I discovered [by and
by](https://github.com/frioux/dotfiles/commit/7f7121e435c4da95b53d73df5d4012d6ee8066b5),
that the authors do not value my time as a user.  That's fine for them, they
don't have to, but it means that I can't keep using AwesomeWM [unless I dedicate
more and more time to
it](https://awesomewm.org/apidoc/documentation/89-NEWS.md.html#v4).

I find it vaguely interesting that while the authors of AwesomeWM claim, and
indeed I even believed, that AwesomeWM is a toolkit for building window
managers, end users are expected to start from a known boilerplate and modify
from there.  The lack of even an attempt at backwards compatibility is just too
much.

Last time there was an update to awesome I ended up spending almost a whole day
fixing my config.  The 4.0 migration looks even bigger and I've done more with
the 3.x series (custom widgets etc) that would have to be ported or rewritten.
I decided that it would be easier for me to switch from AwesomeWM to XMonad than
to migrate to AwesomeWM 4.0, and more likely to continue working in the future.

## Enter XMonad

I used XMonad in the past and indeed was mostly happy with it.  XMonad is
*great* at being a tiling window manager; it almost works perfectly for me out
of the box and there are mostly copy-pasteable examples on how to fix known
oddities in the documentation.  On the other hand, to configure XMonad

 * you have to write Haskell, which seems like a pointless difficulty when it
   comes to a window manager, especially after using Lua for so long
 * it has *no* UI support out of the box

The use of Haskell is mostly an issue for me because I am not actually
interested in writing Haskell except for this purpose.  I am not super
interested in monads or purely functional programming; I just want to arrange
some windows.  On top of that, errors other than type-check errors are almost
completely worthless.  The following is because I didn't have enough whitespace:

```
Error:
/home/frew/.config/taffybar/taffybar.hs:50:15: error:
    parse error on input ‘ebox’
```

For reasons that will be clear shortly I have learned a lot more Haskell than I
ever did before using XMonad, so it has been less painful than last time, but
it's still frustrating.

## XMonad UIs

While XMonad does not have UI support like AwesomeWM does, there are a handful
of options for folks who want some anyway.  In increasing features they are:

### xmobar

[`xmobar`](http://projects.haskell.org/xmobar/) fits firmly in with the
[suckless philosophy](http://suckless.org/philosophy) and in fact is similar to
[`dmenu`](http://tools.suckless.org/dmenu/) ([which I use tens of times a
day](https://github.com/frioux/dotfiles/search?utf8=%E2%9C%93&q=dmenu&type=))
from my reading.  Frustratingly in its simplicity it is missing some basic
features that I wouldn't want to miss out on, so I didn't persue it much
further.

### dzen2

[`dzen2`](https://github.com/robm/dzen) was the next bar I looked into.  It
supports a lot of features `xmobar` doesn't, like basic image support, and some
menu support I was considering using for mouseovers.  I got fairly far with an
interesting `dzen2` setup that involved [a
multiplexor](https://github.com/frioux/dotfiles/blob/4e63a09ea08e429753902f3a2c5827fc1c0b8dc6/bin/dzmux)
and
[script](https://github.com/frioux/dotfiles/blob/d808e406bc7f092984c4287f2a76d94051de6da8/bin/stat-batt)
[per](https://github.com/frioux/dotfiles/blob/d808e406bc7f092984c4287f2a76d94051de6da8/bin/stat-temp)
[widget](https://github.com/frioux/dotfiles/blob/d808e406bc7f092984c4287f2a76d94051de6da8/bin/stat-time).
I really miss that setup since it was so elegant, but it was just so limiting.
I may try to get back in that direction at some point because implementing these
basic monitors over and over again in every langauge (Lua, Haskell, etc) is so
silly.

As a side note, while I was implementing the framework above I wrote [a tool to
increase/decrease/mute/query the
volume](https://github.com/frioux/dotfiles/blob/7d34f4aa0c320ee3ab88e6cf5ff20d5ac5b55d71/bin/vol)
of my system.  I am pleased because it allows toggling the mute state (of course
Pulse Audio does not support that) and automatically picks the right soundcard
(if I am docked I want to use my external soundcard.)  I will likely resurrect
this later.

Before I misrepresent, while the above framework was elegant with respect to
simplicity of the widgets and how they worked, there was quite a lot of hassle
involved with pipes and processes that would never die when the master process
got killed.  I considered switching out the pipes for simple files that would
get tailed, but I moved on before I got much further.

One more interesting fact about this setup was that it did not suffer from a
"slow" widget.  I have spent a non-trivial amount of effort making it so that
AwesomeWM would not block on an external weather service and that this new
method did not have that problem out-of-the box was pretty refreshing.

### taffybar

[`taffybar`](https://hackage.haskell.org/package/taffybar-0.4.6/docs/System-Taffybar.html)
is, I think, the most advanced "bar" out there.  It ships with a handful of
prebuilt widgets and a few system monitors (like the scripts above, but in
Haskell.)  It uses GTK+ and exposes the entirety of GTK+ features to you, so if
you wanted you could do something as absurd as put a little web browser into the
menu bar.

The documentation is a little hard to get used to if you are not already a
Haskell programmer, but there are some good examples already and the `#haskell`
channel on freenode and the maintainers (via [github
issues](https://github.com/travitch/taffybar/issues/198)) are incredibly helpful
and friendly.

My goal all along has been to port my AwesomeWM setup and with `taffybar` I've
gotten close.  I have a few widgets that are graphs, have mouseovers for
details, and you can click them to run some program to dig in deeper.  At this
point there are only two missing pieces:

 1. The temperature graph is reading from the wrong file, so is broken.
 2. There is no volume widget.

For the former I think I just need to write some Haskell [like
this](https://hackage.haskell.org/package/taffybar-0.4.6/docs/src/System-Information-CPU.html).
It's not super difficult, but the Haskell used in that module isn't very clear
to me right now, so I either need to bang on it for a while or read it and
understand it before I implement the working version.

The latter isn't that hard either, but I've been spoiled by AwesomeWM.  Simply
rolling the mouse wheel over some random widget to volume-up/volume-down would
be easy and totally useful, but adding a display of what the volume is at and if
it's muted is still really handy.

Finally, here is an example of an advanced TaffyBar widget:

``` haskell
import qualified Graphics.UI.Gtk as Gtk
import System.Taffybar.Widgets.PollingGraph
import System.Information.CPU
import XMonad.Util.Run

main = do
  let
    cpuReader :: Gtk.Widget -> IO [Double]
    cpuReader widget = do
      (userLoad, systemLoad, totalLoad) <- cpuLoad
      Gtk.postGUIAsync $ do
        let
          user    = round $ 100 * userLoad   :: Int
          system  = round $ 100 * systemLoad :: Int
          tooltip = printf "%02i%% User\n%02i%% System" user system :: String
        _ <- Gtk.widgetSetTooltipText widget $ Just tooltip
        return ()
      return [totalLoad, systemLoad]

    cpuButtons :: Gtk.EventM Gtk.EButton Bool
    cpuButtons = do
      e <- Gtk.eventButton
      case e of
        Gtk.LeftButton   -> unsafeSpawn "terminator -e glances"
        Gtk.RightButton  -> unsafeSpawn "terminator -e top"
        Gtk.MiddleButton -> unsafeSpawn "gnome-system-monitor"
        _ -> return ()
      return True

    cpuCfg :: GraphConfig
    cpuCfg = defaultGraphConfig { graphDataColors = [ (0, 1, 0, 1)
                                                    , (1, 0, 1, 0.5)
                                                    ]
                                }


    cpu :: IO Gtk.Widget
    cpu = do
      ebox <- Gtk.eventBoxNew
      btn <- pollingGraphNew cpuCfg 0.5 $ cpuReader $ Gtk.toWidget ebox
      Gtk.containerAdd ebox btn
      _ <- Gtk.on ebox Gtk.buttonPressEvent cpuButtons
      Gtk.widgetShowAll ebox
      return $ Gtk.toWidget ebox
```

In the above example, `cpu` would fit in with [the example taffybar
config](https://github.com/travitch/taffybar/blob/master/taffybar.hs.example) as
any other widget.

---

I hope that the TaffyBar widget example above is helpful for others; it was not
trivial for me to figure out even with help from multiple avenues.  To the next
five years!

If you actually want to learn Haskell,
<a target="_blank" href="https://www.amazon.com/gp/product/1593272839/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1593272839&linkCode=as2&tag=afoolishmanif-20&linkId=5ba3da3bda897a143241f3a847bb58db">Learn You a Haskell for Great Good!</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=1593272839" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
is pretty good.  I read some a few years ago and enjoyed it.

If you are interested in inspiration configuring your window manager in a
"humane" manner you might check out
<a target="_blank" href="https://www.amazon.com/gp/product/0465050654/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0465050654&linkCode=as2&tag=afoolishmanif-20&linkId=73dd0cc6b5a97f8de58620112d1298ef">The Design of Everyday Things</a><img src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=04.65050654" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />.
It's a classic; be warned though, if you read it you'll be frustrated by many
(most?) doors.
