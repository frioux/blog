---
title: "Steambox 2021: even faster"
date: 2021-01-18T14:52:26
tags: [ "steambox", "shell" ]
guid: e8516de7-c8de-4c09-922f-f0b3afa66e79
---
After Saturday's work I got my steambox starting even faster.

<!--more-->

I am excited to have my steambox start so quickly, but waiting for a mostly
useless desktop manager annoys me.  I fixed that today!  Here is what I did in
short:

 1. Use xsession style desktop management
 2. Use the steamos window manager by default
 3. If a touchfile exists, use a traditional desktop
 4. Add a tool to steam as a game that creates the touchfile

## XSession

This setup lets the user run a script that will initialize their window manager
etc.  I use this on my laptop and generally enjoy the flexibility.

First, I create a file called `/usr/share/xsessions/xsession.desktop` and
put the following in the file:

```ini
[Desktop Entry]
Name=Xsession
Comment=This runs ~/.xsession
Exec=/etc/X11/Xsession
```

Now, display managers (like lightdm, in my case) will offer this as one of the window
managers to select when you log in.  We'll write the actual `~/.xsession` later.

## steampcompmgr

My friend Wes pointed out [this
repository](https://github.com/ValveSoftware/steamos-compositor) as possibly
the window manager that SteamOS uses.  Because the steambox and my laptop are
both running Ubuntu 20.04 I decided to just build it on my laptop and scp it to
the steambox.  Here's how I built it:

```bash
sudo apt install libsdl-image1.2-dev libxcomposite-dev libxdamage-dev
./configure
make
```

The produced binary (`steamcompmgr`) worked on my laptop by hiding all of my
windows, to which I shrugged, killed it, and assumed all was well.  I placed that
binary in `/usr/local/bin/steamcmpmgr` on the steambox, ran `ldd` on it to make sure
no libraries were missing, and moved on.

## ~/.xsession

Here's the contents of the `.xsession` file I created:

```bash
#!/bin/sh

echo "Starting xsession: $(date)"

steam -bigpicture &

if [ -e "$HOME/.de" ]; then
  rm "$HOME/.de"
  exec startxfce4
fi

exec steamcompmgr
```

It should be pretty self explanatory.  The main thing I'd point out is that you
really want your .xsession to end by `exec`'ing your window manager, otherwise
weird things can happen with the shell running the window manager.

At this point I put ensured that xsession was enabled by default to test my
progress.  I did that by making `/etc/lightdm/lightdm.conf` look like this:

```ini
[Seat:*]
autologin-session=xsession
autologin-user=frew
autologin-user-timeout=0
```

It works!

## Desktop Environment

The original SteamOS had two users, `steam` and `desktop`.  While I appreciate
the simplicity of that solution, it means you can never run steam *outside* of
big picture mode, which ends up being limiting in some cases.  To allow
dropping into the desktop (in part aided because rebooting is so fast that it's
the easiest option) I just touch `~/.de`.  In `/usr/local/bin/enable-desktop-environment`
I created the following script:

```bash
#!/bin/sh

# works with /home/frew/.xsession to create a touchfile to enable xfce

touch "$HOME/.de"
```

[Rob](https://hoelz.ro/blog/) pointed out that I should be able to use `.dmrc`
to [select which window manager I start
with](https://superuser.com/questions/685970/how-to-set-a-default-desktop-environment-at-system-start)
to avoid the touch file, which is true, but my instinct is that the path I've
selected is closer to how I run my laptop and thus more likely to keep working
as the ecosystem evolves.  (I'll notice if it breaks.)

Next, I created a `.desktop` entry at
`/usr/share/applications/enable-desktop-environment.desktop` so that I'd be able
to add a custom game for it:

```ini
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=false
Exec=/usr/local/bin/enable-desktop-environment
Name=Enable Desktop Environment
```

Finally, I created a custom game entry for this.  Now, when I Steam Library,
one of the entries is Enable Desktop Environment.  If I run this "game" and
then reboot I still end up in steam, but can exit Big Picture Mode and interact
with the normal Steam UI.

---

(Affiliate links below.)

Recently <a target="_blank"
href="https://www.amazon.com/gp/product/0136820158/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136820158&linkCode=as2&tag=afoolishmanif-20&linkId=6a3d6adabe2966efd8a3b13205d9e0c9">Brendan
Gregg's Systems Performance</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136820158"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" /> got its second edition released.  [He wrote about it
here](http://www.brendangregg.com/blog/2020-07-15/systems-performance-2nd-edition.html).
I am hoping to get a copy myself soon.  I loved the first edition and think the
second will be even more useful.

At the end of 2019 I read
<a target="_blank"
href="https://www.amazon.com/gp/product/0136554822/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0136554822&linkCode=as2&tag=afoolishmanif-20&linkId=9b27a122197fb141065f7276321e4c43">BPF
Performance Tools</a><img
src="//ir-na.amazon-adsystem.com/e/ir?t=afoolishmanif-20&l=am2&o=1&a=0136554822"
width="1" height="1" border="0" alt="" style="border:none !important;
margin:0px !important;" />.
It was one of my favorite tech books I read in the past five years.  Not only
did I learn how to (almost) trivially see deeply inside of how my computer is
working, but I learned how *that* works via the excellent detail Gregg added in
each chapter.  Amazing stuff.
