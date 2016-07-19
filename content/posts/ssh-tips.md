---
aliases: ["/archives/1794"]
title: "ssh tips"
date: "2012-11-14T21:22:19-06:00"
tags: [mitsi, ssh]
guid: "http://blog.afoolishmanifesto.com/?p=1794"
---
As a developer, I use ssh all the time. When connecting to the various servers and even other computers in my house, ssh is my go to. Most writable git servers use ssh. A newish Perl module by mst (Object::Remote) uses ssh for communication. There are a number of tricks you can use to make using ssh as hassle free as possible. I'll share these tips here.

# ~/.ssh/config

First and foremost is getting intimate with ~/.ssh/config. When I first started using ssh I tended to just always do ssh $user@$hostname to connnect. [I've shared before how to do this](/archives/1547), but it is worth repeating. So for example, I develop on a server at work called FrewLynx and my user (yay windows...) is Administrator. Hence this is the config I use to type a little bit less when connecting:

    host fl
         user Administrator
         hostname FrewLynx

Which means I can just use "ssh fl" to connect. Handy! You can also include a port number ("port 22" for the default.) This is helpful when you want to make the computers in your house accessible via port forwarding over your router. So ssh desktop might have port 2022 and ssh laptop might use port 2122.

# Passwordless Login

Ok, so you're already typing less, that's good, saving a little time and keystrokes. Next up is not having to type your password when logging into a server. The way to do this is to set up a key that will authenticate you for the server. It's fairly easy to set up. There are two ways to avoid typing a password. The first and best is to use ssh-agent, which caches your password for the duration of your "session." The next is to not put a password on the key at all. The second is not recommended, but will work if your system is not set up for ssh-agent. Typically ssh-agent will get started when your X session starts. I've never set it up myself as ubuntu takes care of that for me.

## Create Key

So to generate your key you first run the following command:

    ssh-keygen -t ecdsa -f ~/.ssh/keys/$servername

The -t tells it to use the new ECDSA style key. Some servers still don't support ECDSA, so to check if it's supported before you waste time making a bogus key, try this command

    ssh -vvvv -o "PasswordAuthentication no" xyzzy@server 2>&1 | egrep 'debug2:.*ecdsa'

It should include output if ecdsa is supported. If it's not supported use rsa. If you use a password, you can use ssh-agent to cache it, so again, a password is recommended. You don't have to actually create a different key per server, but it allows you to compartmentalize keys so that if they get compromised it's not as big of a deal.

## Put Public Key on Remote Server

So now that you've made a key, you need to tie it to your server. First, to put it on the remote server use

    ssh-copy-id -i ~/.ssh/keys/$servername.pub servername

This will put the public key in the correct place on the remote server to authenticate you.

## Configure Connection

Next add it to your config so that the local side knows to send it. So using the config from above and adding the key we'd get this:

    host fl
         user Administrator
         hostname FrewLynx
         identityfile ~/.ssh/keys/frewlynx

## Cache Password

Now there is one more step to avoid typing the password. Use the following command to cache the password for a given key

    ssh-add ~/.ssh/keys/servername

Once you've done that, you won't need to type the password for the rest of the session. To test that it worked do: "ssh servername ls" It should list the files in the home directory with no password prompt.

# Stay Connected

The final tip is a way to keep your ssh sessions connected so that reconnecting later will be faster. This is actually surprisingly easy. Basically just put this at the top of your ~/.ssh/config

    ControlMaster auto
    ControlPath /tmp/ssh_mux_%h_%p_%r
    ControlPersist 24h

Once you've done that you can test that it worked by again doing "ssh server ls". Do it twice and you should notice a significant speedup on the second one. What's really cool (to me) is that this even works for git server connections, so pushing and fetching tend to be noticeably faster.

# Misc

Another couple things worth trying are using the blowfish cipher and enabling compression. Using the blowfish-cbc cipher is supposedly faster, and compression may help when connecting over a slow link. To enable these you'd update the config to the following:

    host fl
         user Administrator
         hostname FrewLynx
         identityfile ~/.ssh/keys/frewlynx.rsa
         Ciphers blowfish-cbc
         Compression yes

I'm not totally sure how much these help and only found out about them while researching this article.
