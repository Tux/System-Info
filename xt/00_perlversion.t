#!/pro/bin/perl

use strict;
use warnings;

eval "use Test::More 0.93";
if ($@ || $] < 5.010) {
    print "1..0 # perl-5.10.0 + Test::More 0.93 required for version checks\n";
    exit 0;
    }
eval "use Test::MinimumVersion";
if ($@) {
    print "1..0 # Test::MinimumVersion required for compatibility tests\n";
    exit 0;
    }

my @f = sort glob ("t/*"), glob ("xt/*"), glob ("*.pm"), glob ("*.PL");

all_minimum_version_ok (5.008003, { paths => [ @f ]});

done_testing ();
