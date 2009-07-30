---
aliases: ["/archives/1028"]
title: "PerlMonks Getting Hacked and My Solution"
date: "2009-07-30T02:24:39-05:00"
tags: ["keepass", "perl", "perlmonks"]
guid: "http://blog.afoolishmanifesto.com/?p=1028"
---
So some of you may heard that [PerlMonks](http://perlmonks.org) got hacked recently.

Before I get into my (not entirely unique) solution, I want to express how upset I am at PerlMonks about this. I am not going to blame them for getting hacked. But storing passwords in plaintext? I would have thought better from a developer community, especially one as entrenched in web applications as the Perl community. I **am** dumb for using the same password in a lot of websites, but I'm upset that one of the ones I trusted (level 2 out of 3 password) violated that trust. I'm sure they will fix the issue, but I am really upset. Blah. If **you** have a pm account, you should change the password and any other passwords that were the same.

Initially I was going to install [this vimscript](http://www.vim.org/scripts/script.php?script_id=2012) and use it, but then I'd have to somehow install openssl on a usbkey. I looked on [PortableApps](http://portableapps.com/) and found [KeePass](http://portableapps.com/apps/utilities/keepass_portable). That works, but KeePass 2.0 is even better! It will work with .net 2.2 **and** mono 2.0. Srsly guys, I tried it!

First off, [get KeePass](http://keepass.info/). I'd get the zip version for your USB key and the Linux computer, and then on Windows install the executable. Make sure you get the 2.0 version.

Now, if you are using Linux you need to ensure that you have Mono 2.2 or greater, and the Windows Forms libraries. For Ubuntu that means adding a few extra items to your sources.list. See [here](https://launchpad.net/~directhex/+archive/monoxide) for which sources to use. Make sure you update after adding the source. After that you should be able to install mono-2.0-gac (the version will actually be 2.4) and libmono-winforms. There is a 1.0 and 2.0 winforms, but I just installed both. After that you can just do "mono KeyPass.exe" and it should work with rainbows and unicorns!

A few config tips that would have helped me initially. You can set a default username in the Database settings, which is nice. In Options you can set it to autolock after a given period of time and set default expiry times for the passwords. If you aren't going to trust the internet with your passwords you might as well expire them. I chose 90 days as that's not too big of a hassle with a tool like this.

And just a really basic note on usage issues: when you add a new password to database it will generate a new password for you. I changed the generator to use symbols in addition to the default alphanumeric set. But this is really nice when you decide to just not know any of your passwords like I am doing. Also, the default behavior will allow you to double click passwords in the db, copy them to your paste buffer, and then clear the buffer after 10 seconds. I find this to be really convenient!

Anyway, hopefully this will ease the transition burden for someone else too. Enjoy!
