#!/usr/bin/perl

use warnings;
use strict;

my $name = shift;

my $should_print = 0;

print "REMARK   4 NRPDB\n";

while (<>) {

    if ($_ =~ m/REMARK\s+5/ and $should_print) {
        last;
    }

    if ($_ =~ m/$name/) {
        $should_print = 1;
    }

    if ($should_print) {
        print $_;
    }
}

print "REMARK   4 END\n";

