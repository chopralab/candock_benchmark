#!/usr/bin/env perl

use warnings;
use strict;

my @top_percent = qw(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00);

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

sub read_group {
    my $expected_length = shift;
    my $prefix = shift;
    my $suffix = shift;

    my $values_ref = shift;
    my @values = @$values_ref;

    my @array_of_arrays = ();


    foreach my $i (@values) {
        my @file = read_file($prefix.$i.$suffix, $expected_length);
        return unless @file;

        push @array_of_arrays, \@file;
    }

    return @array_of_arrays;
}

sub print_group {
    my $group = shift;
    my $i = shift;

    foreach my $item (@$group) {
        print ",";
        print $item->[$i];
    }
}

sub print_line {

    my $protein = shift;
    my $top_percent = shift;

    my $calc = "${protein}/${top_percent}";

    my @score = read_file( "$calc/score.lst" );

    if ( $#score == -1 ) {
        print "$protein,0,$top_percent,NA,NA,NA,NA,NA,NA"; #batman
        print ",NA" x 96;
        print "\n";
        return ();
    }

    my @model = read_file( "$calc/model.lst", $#score );
	return unless @model;

    my @rmsds = read_file( "$calc/rmsds.lst", $#score );
    return unless @rmsds;

    my @mean = read_file("$calc/combined.tbl", $#score);
    return unless @mean;

    foreach my $i ( 0 .. $#score ) {
        my $index = $i + 1;
        print "$protein,0,$top_percent,$score[$i],$model[$i],$rmsds[$i]";
        print ",$mean[$i]";
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

print "pdb,frags,";
print "top_percent,score,model,";
print "rmsd_graph,rmsd_coord,rmsd_vina,";
print "rmr4,rmr5,rmr6,rmr7,rmr8,rmr9,rmr10,rmr11,rmr12,rmr13,rmr14,rmr15,";
print "rmc4,rmc5,rmc6,rmc7,rmc8,rmc9,rmc10,rmc11,rmc12,rmc13,rmc14,rmc15,";
print "fmr4,fmr5,fmr6,fmr7,fmr8,fmr9,fmr10,fmr11,fmr12,fmr13,fmr14,fmr15,";
print "fmc4,fmc5,fmc6,fmc7,fmc8,fmc9,fmc10,fmc11,fmc12,fmc13,fmc14,fmc15,";
print "rcr4,rcr5,rcr6,rcr7,rcr8,rcr9,rcr10,rcr11,rcr12,rcr13,rcr14,rcr15,";
print "rcc4,rcc5,rcc6,rcc7,rcc8,rcc9,rcc10,rcc11,rcc12,rcc13,rcc14,rcc15,";
print "fcr4,fcr5,fcr6,fcr7,fcr8,fcr9,fcr10,fcr11,fcr12,fcr13,fcr14,fcr15,";
print "fcc4,fcc5,fcc6,fcc7,fcc8,fcc9,fcc10,fcc11,fcc12,fcc13,fcc14,fcc15,";
print "index";
print "\n";

my $ROOT_DIR="$ENV{ROOT_DIR}";

open my $all_lst, '<', "$ROOT_DIR/all.lst" or die "$!\n";

while ( <$all_lst> ) {
    chomp;
    foreach my $top_percent (@top_percent) {
         print_line ( $_, $top_percent);
    }
}

close $all_lst;

