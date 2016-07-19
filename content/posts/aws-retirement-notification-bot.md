---
title: AWS Retirement Notification Bot
date: 2016-06-22T20:56:46
tags: [ziprecruiter, aws, perl, automation, bot]
guid: "https://blog.afoolishmanifesto.com/posts/aws_retirement_notification_bot"
---
If you use AWS a lot you will be familiar with the "AWS Retirement Notification"
emails.  At [ZipRecruiter](https://www.ziprecruiter.com/), when we send our many
emails, we spin up tens of servers in the middle of the night.  There was a
period for a week or two where I'd wake up to one or two notifications each
morning.  Thankfully those servers are totally ephemeral.  By the time anyone
even noticed the notification the server was completely gone.  Before I go
further, here's an example of the beginning of that email (the rest is static:)

<!--more-->

> Dear Amazon EC2 Customer,
> 
> We have important news about your account (AWS Account ID: XXX). EC2
> has detected degradation of the underlying hardware hosting your Amazon EC2
> instance (instance-ID: i-deadbeef) in the us-east-1 region. Due to this
> degradation, your instance could already be unreachable. After 2016-07-06 02:00
> UTC your instance, which has an EBS volume as the root device, will be
> stopped.

Note that the identifier there is totally not useful to a human being.  Every
time we got this notification someone on my team would log into the AWS console,
look up the server, and email the team: "the server is gone, must have been one
of the email senders" or *maybe* "the server is an email sender and will be gone
soon anyway."

Like many good programmers I am lazy, so I thought to myself: "I should write an
email bot to automate what we are doing!"

Behold:

```
#!/usr/bin/perl

use strict;
use warnings;

use Mail::IMAPClient;
use Email::Address;
use Email::Sender::Simple qw(sendmail);
use Data::Dumper::Concise;
use Try::Tiny;

my ($from) = Email::Address->parse('Zip Email Bot <email-bot@ziprecruiter.com>');
my $imap = Mail::IMAPClient->new(
  Server   => 'imap.gmail.com',
  User     => $from->address,
  Password => $ENV{ZIP_EMAIL_BOT_PASS},
  Ssl      => 1,
  Uid      => 1,
) or die 'Cannot connect to imap.gmail.com as ' . $from->address . ": $@";

$imap->select( $ENV{ZIP_EMAIL_BOT_FOLDER} )
  or die "Select '$ENV{ZIP_EMAIL_BOT_FOLDER}' error: ", $imap->LastError, "\n";

for my $msgid ($imap->search('ALL')) {

  require Email::MIME;
  my $e = Email::MIME->new($imap->message_string($msgid));

  # if an error happens after this the email will be forgotten
  $imap->copy( 'processed', $msgid )
    or warn "Could not copy: $@\n";

  $imap->move( '[Gmail]/Trash', $msgid )
    or die "Could not move: $@\n";
  $imap->expunge;

  my @ids = extract_instance_list($e);

  next unless @ids;

  my $email = build_reply(
    $e, Dumper(instance_data(@ids))
  );

  try {
    sendmail($email)
  } catch {
    warn "sending failed: $_";
  };
}

# We ignore stuff in the inbox, stuff we care about gets filtered into another
# folder.
$imap->select( 'INBOX' )
  or die "Select 'INBOX' error: ", $imap->LastError, "\n";

my @emails = $imap->search('ALL');

if (@emails) {
  $imap->move( '[Gmail]/Trash', \@emails )
    or warn "Failed to cleanup inbox: " . $imap->LastError . "\n";
}
$imap->expunge;

$imap->logout
  or die "Logout error: ", $imap->LastError, "\n";


# A lot of this was copy pasted from Email::Reply; I'd use it except it has some
# bugs and I was recommended to avoid it.  I sent patches to resolve the bugs and
# will consider using it directly if those are merged and released.
# -- fREW 22Mar2016
sub build_reply {
  my ($email, $body) = @_;

  my $response = Email::MIME->create;

  # Email::Reply stuff
  $response->header_str_set(From => "$from");
  $response->header_str_set(To => $email->header('From'));

  my ($msg_id) = Email::Address->parse($email->header('Message-ID'));
  $response->header_str_set('In-Reply-To' => "<$msg_id>");

  my @refs = Email::Address->parse($email->header('References'));
  @refs = Email::Address->parse($email->header('In-Reply-To'))
    unless @refs;

  push @refs, $msg_id if $msg_id;
  $response->header_str_set(References => join ' ', map "<$_>", @refs)
    if @refs;

  my @addrs = (
    Email::Address->parse($email->header('To')),
    Email::Address->parse($email->header('Cc')),
  );
  @addrs = grep { $_->address ne $from->address } @addrs;
  $response->header_str_set(Cc => join ', ', @addrs) if @addrs;

  my $subject = $email->header('Subject') || '';
  $subject = "Re: $subject" unless $subject =~ /\bRe:/i;
  $response->header_str_set(Subject => $subject);

  # generation of the body
  $response->content_type_set('text/html');
  $response->body_str_set("<pre>$body</pre>");

  $response
}

sub extract_instance_list {
  my $email = shift;

  my %ids;
  $email->walk_parts(sub {
    my $part = shift;
    return if $part->subparts; # multipart
    return if $part->header('Content-Disposition') &&
      $part->header('Content-Disposition') =~ m/attachment/;

    my $body = $part->body;

    while ($body =~ m/\b(i-[0-9a-f]{8,17})\b/gc) {
      $ids{$1} = undef;
    }
  });

  return keys %ids;
}

sub find_instance {
  my $instance_id = shift;

  my $res;
  # could infer region from the email but this is good enough
  for my $region (qw( us-east-1 us-west-1 eu-west-1 )) {
    $res = try {
      # theoretically we could fetch multiple ids at a time, but if we get the
      # "does not exist" exception we do not want it to apply to one of many
      # instances.
      _ec2($region)->DescribeInstances(InstanceIds => [$instance_id])
        ->Reservations
    } catch {
      # we don't care about this error
      die $_ unless m/does not exist/m;
      undef
    };

    last if $res;
  }

  return $res;
}

sub instance_data {
  return unless @_;
  my %ids = map { $_ => 'not found (no longer exists?)' } @_;

  for my $id (keys %ids) {
    my $res = find_instance($id);

    next unless $res;

    my ($i, $uhoh) = map @{$_->Instances}, @$res;

    next unless $i;

    warn "multiple instances found for one instance id, wtf\n" if $uhoh;

    $ids{$id} = +{
      map { $_->Key => $_->Value }
      @{$i->Tags}
    };
  }

  return \%ids;
}


my %ec2;
sub _ec2 {
  my $region = shift;

  require Paws;

  $ec2{$region} ||= Paws->service('EC2', region => $region );

  $ec2{$region}
}
```

There's a lot of code there, but this is the meat of it:

```
my @ids = extract_instance_list($e);

next unless @ids;

my $email = build_reply(
  $e, Dumper(instance_data(@ids))
);

try {
  sendmail($email)
} catch {
  warn "sending failed: $_";
};
```

And then the end result is a reply-all to the original email that looks
something like this:

> Subject: Re: [Retirement Notification] Amazon EC2 Instance scheduled for retirement.                         
>                                                                                                              
> ```
> {
>   "i-8c288e74" => {
>     Level => "prod",
>     Name => "send-22",
>     Team => "Search"
>   }
> }
> ```

The code above is cool, but the end result is awesome.  I don't log into the AWS
console often, and the above means I get to log in even less.  This is the kind
of tool I love; for the 99% case, it is quiet and simplifies all of our lives.
I can see the result on my phone; I don't have to connect to a VPN or ssh into
something; it just works.

#### colophon

The power went out in the entire city of Santa Monica today, but I was able to
work on this blog post (including seeing previews of how it would render) and
access the emails that it references thanks to both [my email
setup](/posts/fast-cli-tools-and-gmail/) and [my blog setup](/posts/hugo/).
Hurray for software that works without the internet!
