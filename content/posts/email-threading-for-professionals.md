---
title: Email Threading for Professionals
date: 2016-11-02T08:01:48
tags: [ email, mutt, gmail, fogbugz, amazon, aws, perl, ziprecruiter ]
guid: E2C067BA-A0AC-11E6-BB6A-6491DCC68D77
---
Continuing my (likely unending) [series of posts on email](/tags/email) I want
to talk about my latest in a Sisyphean line of tools to make the world suit my
preferences.

As [mentioned before](/posts/fast-cli-tools-and-gmail) I am a mutt user.  Mutt,
being not-Gmail, acts differently than what people have come to expect in 2016,
though normally I can ignore other people's expectations and move on.  But I
finally had to act in this case: email from the issue tracker we use at
[ZipRecruiter](https://www.ziprecruiter.com/hiring/technology) was not threading
properly.

<!--more-->

Threads are such a basic feature in email now that it's almost hard to imagine
what it would be like if they were lacking.  At this moment my inbox has about
fifty threads in it.  If the email from my issue tracker were not threaded, I
would have more than eighty, with very little context to help me read from one
message to another.  It is unconscionable that a bug tracker would send email
and not thread right.

There are a couple possible theories as to why software might do this.  The
reason that I personally prefer is that Fog Creek is incompetent, but the more
likely reason is that Gmail hides the problem...

## Email Threading

Email threading is typically handled with three headers:

 * `In-Reply-To`
 * `References`
 * `Subject`

`In-Reply-To` is simply the unique `Message-ID` that the current email is
(surprise!) a reply to.  If you had all of the emails available to you, this
would be sufficient.  `References` solves the problem where one or more messages
in the tree are missing, by storing a list of all `Message-ID`s from the parent
to the root.  Finally, as a last ditch effort the `Subject` header is used for
to create threads from messages with subjects like `Cleaning the kitchen` and
`Re: Cleaning the kitchen`.  In Mutt these threads are called pseudo threads.

[(Read more than you care to here.)](https://www.jwz.org/doc/threading.html)

Gmail is problematic because it threads **solely** on the subject, and unlike
other sloppy threading methods, the `Re: ` is not required.  This is why when
people write emails with `Subject`s of `Tomorrow` they get pointlessly threaded
together.

This implies that some software can simply set a stable subject and assume that
users will get properly threaded email.  I had not noticed this till recently
because I simply filtered all of the email sent by FobBugz to trash.  I have
lately gotten better at handling my fulminating inbox and decided to make my life
harder and turn on the firehose of issues.

## Solutions

When I first realized what was happening I had a few ideas on how to fix the
threading, but finally ended up with: use the gmail API to both find unthreaded
messages, find their full threads, and reupload them with the correct headers
set.  I would guess the total time spent for this took me about 4 to 8 hours.
The complete code is long enough that I don't think it makes sense to share in a
blog post in it's entirely [so I'll just link to
it](https://github.com/frioux/dotfiles/blob/5d5794831fa5d98e7a4d0f001ef129adf13a84ef/bin/email-fix-in-reply-to).

As a side note: the other way to do this would have been to use IMAP directly.
The problem with that is that I also needed to use Gmail's search to reconstruct
the threads, and as far as I know the Gmail ids and the IMAP ids cannot be
correlated without a bunch of silly work.

Oh and another side note: I could have patched Mutt to thread like Gmail does,
but I'd *also* have to patch [notmuch](https://notmuchmail.org) and I suspect
changing how threading works would require a full index rebuild and it just
seemed like a lot of effort to make working software act unnaturally.

I do want to share a few interesting bits though.

### OAuth 2.0

I had so far not needed to learn how to authenticate with an OAuth service.  For
better or worse, I now know vaguely how OAuth works.

In my case the auth was split into three phases:

 1. Prompt the user to get the authentication code
 2. Get the authentication token with the code
 3. Maybe refresh the token with the refresh token if the auth token is too old.

My code for these looks something like this:

```
my $ua = LWP::UserAgent->new( keep_alive => 3 );

my $config = try {
   decode_json(io->file("$ENV{HOME}/.gmail-auth-token.json")->all)
} catch { +{} };

$config = get_token(
   refresh_token => $config->{refresh_token},
   grant_type => 'refresh_token',
) if $config->{refresh_at} && time > $config->{refresh_at};

sub get_token (%args) {
   my $res = $ua->request(POST 'https://www.googleapis.com/oauth2/v4/token' => [
      %args,
      client_id     => $gmail_api_client_id,
      client_secret => $gmail_secret,
   ]);

   my $config_to_save = decode_json($res->decoded_content);

   my $config = {
      access_token => $config_to_save->{access_token},
      refresh_token => $config_to_save->{refresh_token} || $config->{refresh_token},
      refresh_at => time + $config_to_save->{expires_in},
   };

   io ->file("$ENV{HOME}/.gmail-auth-token.json")
      ->write(encode_json($config));

   $config
}

sub authenticate {
   my $uri = URI->new('https://accounts.google.com/o/oauth2/v2/auth');
   $uri->query_form(
      response_type => 'code',
      client_id => $gmail_api_client_id,
      redirect_uri => 'http://127.0.0.1:9004/wat',
      access_type => 'offline',
      prompt => 'consent',
      scope => 'https://mail.google.com/',
      include_granted_scope => 'false',
   );

   print "Opening $uri ...\n";
   system 'xdg-open', "$uri";

   my $app = sub {
      my $env = shift;
      $env->{'psgix.harakiri.commit'} = 1;

      require Plack::Request;
      my $req = Plack::Request->new( $env );
      if (my $code = $req->param('code')) {
         get_token(
            code => $code,
            grant_type    => 'authorization_code',
            redirect_uri  => 'http://127.0.0.1:9004/wat',
         );
         return [
            200,
            [ content_type => 'text/html' ],
            [ 'Success!' ]
         ]
      } else {
         return [
            500,
            [ content_type => 'text/html' ],
            [ sprintf "Error: %s (%s)", $req->param('error'), $req->param('error_subtype') ]
         ]
      }
   };

   require Plack::Runner;
   my $runner = Plack::Runner->new;
   $runner->parse_options(qw( --listen 127.0.0.1:9004 ));
   $runner->run($app);
}
```

That's far from brief, but at the very least if someone else has the same
problem I had it can serve as an example.

### Rethreading

Here's the bulk of the code that actually rethreads my email.  It's got enough
little interesting bits that I added comments inline.

```
sub _rethread_emails ($fix_type, @email_ids) {
   my @emails;
   for my $id (@email_ids) {
      my $message = _do_req(
         "https://www.googleapis.com/gmail/v1/users/me/messages/$id" => (
            format => 'raw',
         ));
      # WOW, it's not Base64, it's a weird alternate version of Base64 that's URI safe.
      # Thanks to haarg aka Graham Knop for helping with this.
      my $email = Email::MIME->new(urlsafe_b64decode($message->{raw}));
      push @emails, {
         email => $email,
         email_str => $email->as_string,
         id => $id,
         labelIds => $message->{labelIds},
      };
   }

   # FogBugz often sends multiple emails in the same thread at the exact same
   # time, so I added the Message-ID to the sort to stabilize it
   @emails = sort {
      find_date($a->{email_str}) <=> find_date($b->{email_str}) ||
      $a->{email}->header_raw('Message-ID') cmp $b->{email}->header_raw('Message-ID')
   } @emails;

   my $first_email = shift @emails;
   # We modify the Message-ID here, but prefixing or incrementing a prefix
   # *only* if the import headers (In-Reply-To and References) changed.  Same
   # as below.  Very important.
   prefix_message_id($first_email->{email}, $fix_type)
      if clear_initial_headers($first_email->{email});

   my $prev = $first_email;
   for my $email (@emails) {
      prefix_message_id($email->{email}, $fix_type)
         if update_references($email->{email}, $prev->{email});

      $prev = $email
   }

   for my $email ($first_email, @emails) {
      my $new_raw = $email->{email}->as_string;
      # This is an elegant way to ensure that we don't upload if the email
      # doesn't change.
      next if $new_raw eq $email->{email_str};

      warn "Uploading replacement $email->{id}\n";
      # If you leave off the old labelIds you'll end up putting the email in
      # your archive, marked as read.
      my $upload_res = upload_email({ labelIds => $email->{labelIds}}, $new_raw);
      if (!$upload_res->is_success) {
         warn "Failed to upload $email->{id}: " . $upload_res->decoded_content . "\n";
      } else {
         if (decode_json($upload_res->decoded_content)->{id} ne $email->{id}) {
            warn "Deleting old $email->{id}\n";
            my $delete_res = delete_email($email->{id});
            if (!$delete_res->is_success) {
               warn "failed to delete $email->{id}: " . $delete_res->decoded_content . "\n";
            }
         } else {
            # I found out at some point that if the Message-ID does not change,
            # when you upload an email and then delete the old version, you end
            # up just deleting what you uploaded.  I assume that the id from
            # gmail is a hash of the Message-ID or something.
            warn "id of $email->{id} did not change, something is probably wrong\n"
         }
      }
   }
}
```

### Multipart HTTP Uploads

I've never done a multipart upload in Perl before!  It wasn't too hard:

```
sub upload_email ($metadata, $email) {
   my $uri = URI->new('https://www.googleapis.com/upload/gmail/v1/users/me/messages/import');
   $uri->query_form(
      uploadType => 'multipart',
      neverMarkSpam => 'true',
   );
   my $req = HTTP::Request->new(
      POST => "$uri",
      [
         Authorization => "Bearer $config->{access_token}",
         content_type => "multipart/related",
      ],
   );
   $req->add_part(
      HTTP::Message->new(
         HTTP::Headers->new(content_type => "application/json; charset=UTF-8"),
         encode_json($metadata),
      ),
   );
   $req->add_part(
      HTTP::Message->new(
         [ content_type => "message/rfc822" ],
         $email,
      ),
   );
   $req->header( content_length => length $req->content );
   $ua->request($req);
}
```

---

So that's about it! It sucks that I had to do all of this work, but it wasn't
too bad, and it's been really reliable.  Now that I have the core algorithm in
place I keep seeing all kinds of messages that should be threading and aren't.
If you look at the code linked at the beginning of the posts you'll see that I
indeed am also rethreading AWS support emails.  It's nice to have this
capability, though it would be nicer if these companies fixed their code.
