#/usr/bin/perl

use warnings;
use strict;

my %atom_names = (
    "GLY" => ["N  ", "CA ", "C  ", "O  "],
    "ALA" => ["N  ", "CA ", "C  ", "O  ", "CB "],
    "ASP" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "OD1", "OD2"],
    "PHE" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD1", "CD2", "CE1", "CE2", "CZ "],
    "PRO" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD "],
    "LEU" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD1", "CD2"],
    "ASN" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "OD1", "ND2"],
    "VAL" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG1", "CG2"],
    "SER" => ["N  ", "CA ", "C  ", "O  ", "CB ", "OG "],
    "GLU" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD ", "OE1", "OE2"],
    "THR" => ["N  ", "CA ", "C  ", "O  ", "CB ", "OG1", "CG2"],
    "ARG" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD ", "NE ", "CZ ", "NH1", "NH2"],
    "GLN" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD ", "OE1", "NE2"],
    "ILE" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG1", "CG2", "CD1"],
    "MET" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "SD ", "CE "],
    "HIS" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "ND1", "CD2", "CE1", "NE2"],
    "TYR" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD1", "CD2", "CE1", "CE2", "CZ ", "OH "],
    "TRP" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD1", "CD2", "NE1", "CE2", "CE3", "CZ2", "CZ3", "CH2"],
    "CYS" => ["N  ", "CA ", "C  ", "O  ", "CB ", "SG "],
    "LYS" => ["N  ", "CA ", "C  ", "O  ", "CB ", "CG ", "CD ", "CE ", "NZ "],
);

while (<>) {
    if (substr($_, 0, 6) eq "ATOM  ") {
        asdf:
        my $rsn = substr($_, 17, 3);
        next if substr($_, 77, 1) eq "H";
        if ($atom_names{$rsn}) {
            my $residue_names = $atom_names{$rsn};
            substr($_, 13, 3) = $residue_names->[0];
            print $_;
            for (my $i = 1; $i < scalar(@{$residue_names}); ++$i) {
                my $line = <>;
                if (substr($line, 17, 3) ne $rsn) {
                    print STDERR "WARNING: resn too short: $_";
                    $_ = $line;
                    goto asdf;
                }
                substr($line, 13, 3) = $residue_names->[$i];
                print $line;
            }
        } else {
            print STDERR "WARNING: RESN $rsn not found\n";
            print $_;
        }
    }
}

