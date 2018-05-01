#!/usr/bin/perl

use strict;
use warnings;

$|++;

use Test::More;
use ExtUtils::Manifest qw( manicheck filecheck );
$ExtUtils::Manifest::Quiet = 1;

my @missing = filecheck ();
@missing and diag ("Files missing from MANIFEST: @missing");
ok (!@missing, "No files missing from MANIFEST");

my @extra = manicheck ();
@extra   and diag ("Files in MANIFEST but not here: @extra");
ok (!@extra, "No extra files in MANIFEST");

@missing || @extra and BAIL_OUT ("FIX MANIFEST FIRST!");

done_testing ();
