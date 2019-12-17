#!/usr/bin/env perl

use warnings;
use strict;

use Getopt::Long;

my $radius = 4.5;

GetOptions("r|radius=i" => \$radius);

my $found_atoms = 0;

while (<>) {
    if ($found_atoms) {
        my @atom = split /\s+/, $_;
        next if scalar(@atom) < 6;
        print "1    $atom[2]   $atom[3]   $atom[4]   $radius\n";
    }
    
    if ( $_ =~ m/@<TRIPOS>BOND/x ) {
        $found_atoms = 0;
    }

    if ( $_ =~ m/@<TRIPOS>ATOM/x ) {
        $found_atoms = 1;
    }
     
}
