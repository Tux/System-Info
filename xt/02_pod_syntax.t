#! /usr/bin/perl -w
use strict;
use Test::More tests =>  1;

SKIP: {
    skip 'Test::Pod not installed', 1
        unless eval { require Test::Pod; };

    all_pod_files_ok ();
}
