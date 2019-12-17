#!/usr/bin/env perl
#PBS -d .
#PBS -l nodes=1:ppn=1
#PBS -l naccesspolicy=shared
#PBS -l walltime=2:00:00

use warnings;
use strict;

my @top_percent = qw(0.005 0.01 0.02 0.05 0.10 0.20);

sub read_file {
    my $calc_file = shift;
    my @file_arr;

    unless ( -e $calc_file ) {
        print STDERR "$calc_file does not exist\n";
        return ();
    }

    open my $file_hd, '<', "$calc_file" or warn "$calc_file: $!\n";
    while ( my $file_line = <$file_hd> ) {
        chomp $file_line;
        $file_line =~  s/\s+/,/g;
        push @file_arr, $file_line;
    }
    close $file_hd;

    my $expected_length = shift;
    if ( defined $expected_length and ($expected_length != $#file_arr) ) {
        print STDERR "Problem with $calc_file\n";
        return ();
    }

    return @file_arr;
}

sub print_line {

    my $target = shift;
    my $protein = shift;
    my $top_percent = shift;
    my $ligand = shift;

    my $calc = "${target}/protein${protein}/${top_percent}";

    my @score = read_file( "$calc/${ligand}.scores" );

    if ( $#score == -1 ) {
        print "$target,protein$protein,$ligand,$top_percent,NA,NA,NA,NA,NA";
        print "\n";
    }

    my @model = read_file( "$calc/${ligand}.models", $#score );
	return unless @model;

    my @rmsds = read_file( "$calc/${ligand}.rmsds", $#score );
    return unless @rmsds;

    foreach my $i ( 0 .. $#score ) {
        my $index = $i + 1;
        print "$target,protein$protein,$ligand,$top_percent,$score[$i],$model[$i],$rmsds[$i]";
        print "\n";
    }
}

sub read_table {
    my $file = shift;
    my $sep = shift;
    my %ret;

    open my $file_h, "<", $file or die "$file: $!\n";
    
    while (<$file_h>) {
        chomp;
        my @values = split $sep, $_;
        $ret{$values[0]} = $values[1];
    }

    close $file_h;

    return %ret;
}

print "targer,protein,ligand,";
print "top_percent,score,model,";
print "rmsd_graph,rmsd_coord,rmsd_vina";
print "\n";

my $ROOT_DIR="$ENV{ROOT_DIR}";

open my $all_lst, '<', "$ROOT_DIR/all.lst" or die "$!\n";

while ( my $target = <$all_lst> ) {
    chomp $target;
    for ( my $protein = 1; $protein <= 5; ++$protein) {
        my $ligand_list = "$target/ligands.lst";
        open my $fh, "<", $ligand_list or die "$!\n";
        while (my $ligand = <$fh>) {
            chomp $ligand;
            foreach my $top_percent (@top_percent) {
                print_line ( $target, $protein, $top_percent, $ligand );
            }
        }
        close $fh;
    }
}

close $all_lst;

