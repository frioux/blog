---
title: Debian and Ubuntu Automatic Updates
date: 2023-03-09T08:55:15
tags: [ "linux", "ubuntu" ]
guid: d0d4eae7-9fad-41fd-a4ab-a1987d8279cd
---
How I set up automatic updates on laptops.

<!--more-->

This is a tidier and more reliable (for my machines) version of [the official
Unattended Upgrades doc](https://wiki.debian.org/UnattendedUpgrades).

Install the tool:

```bash
sudo apt install unattended-upgrades
```

Enable it:

```bash
vi /etc/apt/apt.conf.d/50unattended-upgrades
```

Make these changes:

```
Unattended-Upgrade::Allowed-Origins {
	"*:*";
};

// ...

Unattended-Upgrade::Remove-Unused-Dependencies "true";

// ...

Unattended-Upgrade::OnlyOnACPower "false";
```

Enable it again:

```bash
vi /etc/apt/apt.conf.d/20auto-upgrades
```

Put this in that file:

```
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

You can check your settings by running this:

```bash
sudo unattended-upgrade -d --dry-run
```

OK you're mostly done, but for non-servers I find this configuration
insufficient.  If I recall correctly the default only attempts to install
updates once a day and it's at 3am or something.  If your laptop is not on at
that time, you never get updates.  Here's how I modify the schedule:

```bash
sudo systemctl edit --full 'apt-daily*.timer'
```

I modify the timers to say this:

```ini
[Timer]
OnCalendar=hourly
RandomizedDelaySec=5m
Persistent=true
```

After that change is made, your machine will attempt to install updates hourly.  To check out how
the timer is working, you can use this command:

```bash
systemctl list-timers 'apt-daily*.timer'
```

Hope this helps!
