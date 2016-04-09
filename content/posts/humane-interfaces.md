---
title: Humane Interfaces
date: 2016-04-09T00:36:55
tags: ["humane", "cli"]
guid: "https://blog.afoolishmanifesto.com/posts/humane-interfaces"
---
In this post I just want to briefly discuss and demonstrate a humane user
interface that I invented at work.

At [ZipRecruiter](https://www.ziprecruiter.com), where I work, we use a third
party system called [Bonus.ly](https://bonus.ly).  Each employee is given $20 in
the form of 100 Zip Points at the beginning of each month.  These points can be
given to any other employee for any reason, and then redeemed for gift cards
basically anywhere (Amazon, Starbucks, Steam, REI, and even as cash with
Paypal, just to name a few.)

Of course the vast majority of users give bonusly by using the web interface,
where you pick a user with an autocompleter, you select the amount with a
dropdown, and you type the reason and hashtag (you must include a hashtag) in a
textfield.  This is fine for most users, but I hate the browser because it's so
sluggish and bloated.  The other option is to use the built in Slack interface.
I used that for a long time; it works like this: `/give +3 to @sara for Helping
me with my UI #teamwork`

This is pretty good but there is one major problem: the username above is based
on the local part of an email address, even though when it comes to Slack using
`@foo` looks a lot like a Slack username.  I kept accidentally giving bonusly to
the wrong Sara!

Bonusly has a pretty great API and one of my coworkers [released an inteface on
CPAN](https://metacpan.org/pod/WebService::Bonusly).  I used this API to write a
small CLI script.  The actual script is not that important (but if you are
interested let me know and I'll happily publish it.)  What's cool is the
interface.  First off here is the argument parsing:

```
my ($amount, $user, $reason);

for (@ARGV) {
  if (m/^\d+$/) {
    $amount = $_;
  } elsif (!m/#/) {
    $user = $_;
  } else {
    $reason = $_;
  }
}

die "no user provided!\n"   unless $user;
die "no amount provided!\n" unless $amount;
die "no reason provided!\n" unless $reason;
```

The above parses an amount, a user, and a reason for the bonus.  The amount must
be a positive integer, and the reason must include a hashtag.  Because of this,
we can ignore the ordering.  This solves an unstated annoyance with the Slack
integration of Bonusly; I do not have to remember the ordering of the arguments,
I just type what makes sense!

Next up, the user validation, which resolves the main problem:

```
# The following just makes an array of users like:
# Frew Schmidt <frew@ziprecruiter.com>

my @users =
  grep _render_user($_) =~ m/$user/i,
  @{_b->users->list->{result}};


if (@users > 1) {
  warn "Too many users found!\n";
  warn ' * ' . _render_user($_) . "\n" for @users;
  exit 1;
} elsif (@users < 1) {
  warn "No users match! Could $user be a contractor?\n";
  exit 2;
```

The above will keep from accidentally selecting one of many users by prompting
the person running the script for a more specific match.

Of course the above UI is not perfect for every user.  But I am still very
pleased to have unordered positional arguments.  I hope this inspires you to
reduce requirements on your users when they are using your software.
