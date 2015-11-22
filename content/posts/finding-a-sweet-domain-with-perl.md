---
aliases: ["/archives/1086"]
title: "Finding a sweet domain with perl"
date: "2009-08-20T03:52:20-05:00"
guid: "http://blog.afoolishmanifesto.com/?p=1086"
---
So yesterday I spent a few hours trying to find a cool domain for the project I am working on in my free time. (By the way, raptorprey.com is open.) After looking at lots of various options, I decided that it would be really cool to get a domain of a latin work with the .US TLD. Too bad I don't know latin right?

[![(I can't read this)](/wp-content/uploads/2009/08/2152967984_08d00d8d2f-252x300.jpg "I can't read this!")](http://www.flickr.com/photos/dandiffendale/2152967984/)

So I went online and found some cheesy one page latin dictionary that had a few thousand words. I used vim to clean up the data (after saving as plain text) and turn it into a standard format (JSON.) Next I used vim to filter out all the words that didn't end in us. To do that I used a command something like the following:

    :g!/^".*us"/d

That will find all lines that have words that don't end in us, and then delete them. Then I wrote a perl script which would do it's best to read in my serialized data, check if the domain was available, and store whether it was or not. Here's a permutation of it (I changed it a lot and I left out the domain checking, as that's technically Against The Rules):

    #!perl
    use Modern::Perl; # just for one-off's in my mind
    use JSON;
    use File::Slurp; # again, just for a one-off

    my $file = shift;
    my $text = read_file($file);
    #format:
    #my $final_data = {
    #   unchecked => \%new_data,
    #   possible  => [],
    #   unpossible => [],
    #};
    my $final_data = from_json($text);

    foreach my $domain (keys %{$final_data->{unchecked}}) {
       warn "checking $domain.us";
       # MAGIC HERE
       if ($exists) {
          push @{$final_data->{unpossible}}, "$domain.us";
       } else {
          push @{$final_data->{possible}}, "$domain.us";
       }
       delete $final_data->{unchecked}->{$domain};
       sleep 1 + rand();
    }

    END {
       my $json = JSON->new->pretty;
       say $json->encode($final_data);
    };

I have the end block doing the final output because something was killing the program, even if I put an eval around that part of the code, so what I did was basically output the same format that I input. That way I could just manually edit the data that was causing the issues.

Cool huh?
