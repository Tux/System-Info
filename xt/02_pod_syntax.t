#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

if (eval { require Test::Pod; }) {
    Test::Pod::all_pod_files_ok ();
    }
else {
    ok (1, "Test::Pod not installed, skipping tests");
    }

done_testing ();
