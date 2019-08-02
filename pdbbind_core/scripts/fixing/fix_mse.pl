#!/usr/bin/perl

use warnings;
use strict;

while (<>) {

    if ( $_ =~ m/MSE/x ) {
        $_ =~ s/SE  MSE/SD  MSE/;
        $_ =~ s/MSE/MET/x;
        $_ =~ s/SE/ S/x;
        $_ =~ s/HETATM/ATOM  /;
    }

    print $_;
}
