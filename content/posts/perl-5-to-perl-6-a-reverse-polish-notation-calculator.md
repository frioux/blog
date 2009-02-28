---
aliases: ["/archives/341"]
title: "Perl 5 to Perl 6: a Reverse Polish Notation Calculator"
date: "2009-02-28T03:35:31-06:00"
guid: "http://blog.afoolishmanifesto.com/?p=341"
---
I did this because of the excellent [amazonify]1558607013::text::::Higher-Order Perl[/amazonify].

Here is the Perl 5 code:

    #!/usr/bin/perl
    use strict;
    use warnings;

    my $op_dispatch_table = {
       '+' => sub {
          my ($stack) = @_;
          push @$stack, pop(@$stack) + pop(@$stack);
       },
       '-' => sub {
          my ($stack) = @_;
          my $s = pop(@$stack);
          push @$stack, pop(@$stack) - $s;
       },
       '*' => sub {
          my ($stack) = @_;
          push @$stack, pop(@$stack) * pop(@$stack);
       },
       '/' => sub {
          my ($stack) = @_;
          my $s = pop(@$stack);
          push @$stack, pop(@$stack) / $s;
       },
       'sqrt' => sub {
          my $stack = shift;
          push @$stack, sqrt(pop(@$stack));
       },
    };

    my $result = evaluate($op_dispatch_table, $ARGV[0]);

    print "Result: $result\n";
    sub evaluate {
       my $odt = shift;
       my @stack;
       my ($expr) = @_;
       my @tokens = split /\s+/, $expr;
       for my $token (@tokens) {
          if ($token =~ /\d+$/) {
             push @stack, $token;
          } else {
             if (my $fn = $odt->{$token}) {
                $fn->(\@stack);
             } else {
                die "Unrecognized token '$token'; aborting";
             }
          }

       }
      return pop(@stack);
    }

And here is the Perl 6:

    #!/home/frew/personal/rakudo/perl6
    my %op_dispatch_table = {
       '+' => sub (@stack) {
          @stack.push(@stack.pop + @stack.pop);
       },
       '-' => sub (@stack) {
          # this should probably be:
          # @stack.push(@stack.pop R- @stack.pop);
          my $s = @stack.pop;
          @stack.push(@stack.pop - $s);
       },
       '*' => sub (@stack) {
          @stack.push(@stack.pop * @stack.pop);
       },
       '/' => sub (@stack) {
          # this should probably be:
          # @stack.push(@stack.pop R/ @stack.pop);
          my $s = @stack.pop;
          @stack.push(@stack.pop / $s);
       },
       'sqrt' => sub (@stack) {
          @stack.push(@stack.pop.sqrt);
       },
    };

    sub evaluate (%odt, $expr) {
       my @stack;
       my @tokens = $expr.split(/\s+/);
       for @tokens -> $token {
          if $token ~~ /^\d+$/ {
             @stack.push($token);
          } else {
             if my &fn = %odt{$token} {
                &fn(@stack);
             } else {
                die "Unrecognized token '$token'; aborting";
             }
          }
       }
      return @stack.pop;
    }

    say "Result: { evaluate(%op_dispatch_table, @*ARGS[0]) }";

Usage: ./calc.pl "5 6 +"

The main differences to notice are sigil invariance, subroutine signatures, and method instead of function syntax.
