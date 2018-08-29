#!/usr/bin/perl

=pod

The original automated test procedure

     make rts
     ./rts > rts.out
     cmp rts.out rts.exp

Compares the results of all tests against all expected output.
However, its output is barely adequate as it provides very little
information about failed tests.

This script combines the contents of `rts.tests`, a delimited shell script
of tests, and `rts.exp`, a delimited text file of expected results into
a single script that runs each test separately and displays more informative
failure messages.

With this script in place, testing the package is a matter of saying

    make tests

=cut

use strict;

sub read_exp {
  my $exp_file = shift;

  my $key;
  my $key0;
  my @saved;
  my $state;
  my %exp;

  open(E, $exp_file) or die "cannot open [$exp_file]: $!\n";
  while(<E>) {
    if (/^---\s+(.+)/) {
      $key0 = $1;
      $state = 1;
    } else {
      push @saved, $_;
      $state = 2;
    }
  } continue {
    if (($state == 1) || eof(E)) {
      if (@saved) {
        $exp{$key} = join("", @saved);
        @saved = ();
      }
      $key = $key0;
    }
  }
  close(E);

  return \%exp;
}

sub close_test {
  my ($count, $key, $exp) = @_;

  my $outf = "${count}.out";
  print qq}\n) 2>&1 | cat -v > $outf\n};

  unless (defined($exp->{$key})) {
    warn "cannot find [$key] in expected output\n";
    return;
  }

  my $expf = "${count}.exp";
  print <<"EOS";

echo -n '$exp->{$key}' > $expf

if ! cmp -s $outf $expf ; then
    echo 'FAIL: $key'
    diff -u $outf $expf
fi
EOS
}

my $key;
my $key0;
my $state = 1;
my $count = 0;

my $test_file = 'rts.tests';
my $exp = read_exp('rts.exp');

open(T, $test_file) or die "cannot open [$test_file]: $!\n";
while (<T>) {
  if (/'---\s+(.+)'/) {
    $key0 = $1;
    $state = 1;
  } else {
    $state = 2;
  }
} continue {
  if (($state == 1) || eof(T)) {
    if ($count > 0) {
      close_test($count, $key, $exp);
    }
    last if eof(T);
    $key = $key0;
    $count++;
    print "\n(\n";  #open test
  } elsif ($state == 2) {
    print; # test content
  }
}
