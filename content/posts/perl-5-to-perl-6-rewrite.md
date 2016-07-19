---
aliases: ["/archives/718"]
title: "Perl 5 to Perl 6 Rewrite"
date: "2009-05-15T19:13:20-05:00"
tags: [mitsi, perl, perl-5, perl-6]
guid: "http://blog.afoolishmanifesto.com/?p=718"
---
My coworker Wes asked me if there could be a nice refactor for the following function which checks CAS Numbers to ensure their validity. After struggling for 30 minutes I gave up trying to make it a little bit nicer with reduce.

    sub cas_old {
      my $cas = shift;
      if ($cas =~ /\d{1,8}-\d\d-\d/) {
        my @ary = grep { $_ ne '-' } split(//, $cas);
        my $check = pop @ary;
        my $count = @ary;
        my $sum;
        for (@ary){
          $sum += $_ * $count--;
        }
        return $sum % 10 == $check;
      }
      return;
    }

Let's take a look at this and figure it out. The crunchy bit is the for loop, so I'll go through that. Basically we are summing each item times a weight that is inversely proportional to it's location in the list. Or to be more explicit, let's do an example on the board (7732-18-5.) 5 is the check digit.

<table style="border-spacing: 10px">
  <thead>
    <tr>
      <th>$_</th>
      <th>$count</th>
      <th>$_ * $count</th>
      <th>$sum</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>7</td>
      <td>6</td>
      <td>42</td>
      <td>42</td>
    </tr>
    <tr>
      <td>7</td>
      <td>5</td>
      <td>35</td>
      <td>77</td>
    </tr>
    <tr>
      <td>3</td>
      <td>4</td>
      <td>12</td>
      <td>89</td>
    </tr>
    <tr>
      <td>2</td>
      <td>3</td>
      <td>6</td>
      <td>95</td>
    </tr>
    <tr>
      <td>1</td>
      <td>2</td>
      <td>2</td>
      <td>97</td>
    </tr>
    <tr>
      <td>8</td>
      <td>1</td>
      <td>8</td>
      <td>105</td>
    </tr>
  </tbody>
</table>

So basically we are making a special summation. The thing that's unusual is that we have a decrementing counter along with it. If I had the control structure which I am about to show you in my mind already the solution might have jumped out sooner.

So I asked about it in #perl6 and it turns out there is a very nice Perl 6 version. It takes advantage of the mystical hyperoperator (>>infix op<<); that is, it takes two lists and performs an operation on each element together. Think SIMD. It also uses reduce ([infix op]) which I have mentioned before. Check it out!

    sub cas(Str $cas) {
        if $cas ~~ /(\d ** 1..8)\-(\d\d)\-(\d)/ {
            my @digits = $0~$1.split '';
            my $check = $2;
            return ([+] @digits.reverse
               >>*<<
               (1..@digits)) % 10 == $check;
        }
        return Bool::False;
    }

This does the same thing as above. Or to put it in English, we take our digits, reverse them, and then multiply each digit (hyperoperator, >>\*<<) by the respective integer in the other list, that is, 1 to the size of the list. We then sum (reduce, [+]) that new list, and get the modulus 10 of it.

Very elegant, no?

**Update**: Turns out there is also a very elegant version in p5, according to mst. Check it out!

    sub cas_old {
      use List::Util 'sum';
      my $cas = shift;
      if ($cas =~ /(\d{1,8})-(\d\d)-(\d)/) {
        my @digits = split(//, $1.$2);
        my $count = @digits;
        my $check = $3;
        return (sum map $_ * $digits[-$_],
           1 .. $count) % 10 == $check;
      }
      return;
    }

It's very similar to the p6 version, just using fewer generalized operators, so you should be able to follow it fairly well.
