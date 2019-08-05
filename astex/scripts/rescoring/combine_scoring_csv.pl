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

sub read_all_scoring_functions {
    my $expected_length = shift;
    my $calc = shift;

    my @aref = ('mean', 'cumulative');
    my @afunc= ('radial', 'normalized_frequency');
    my @acomp= ('reduced', 'complete');
    my @acuts= (4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);

    my @all_sfs = ();

    foreach my $ref (@aref) {
    foreach my $func(@afunc){
    foreach my $comp(@acomp){
    foreach my $cuts(@acuts) {
        my $scoring_func = "${func}_${ref}_${comp}_${cuts}";
        $scoring_func = "score" if $scoring_func eq "radial_mean_reduced_6";
        push @all_sfs, $scoring_func;
    }}}}

    return read_group($expected_length, "$calc/", ".lst", \@all_sfs);
}

sub print_group {
    my $ofile = shift;
    my $group = shift;
    my $i = shift;

    foreach my $item (@$group) {
        print $ofile $item->[$i];
        print $ofile ",";
    }
}

sub print_line {

    my $protein = shift;
    my $top_percent = shift;

    return if -e "${protein}/${top_percent}/combined.tbl";

    my $calc = "${protein}/${top_percent}";

    my @score = read_file( "$calc/score.lst" );

    if ( $#score == -1 ) {
        `touch ${protein}/${top_percent}/combined.tbl`;
        return;
    }

    my @sfs = read_all_scoring_functions($#score, $calc);
    return unless @sfs;

    open my $outfile, ">", "${protein}/${top_percent}/combined.tbl";

    foreach my $i ( 0 .. $#score ) {
        my $idex = $i + 1;
        print_group($outfile, \@sfs, $i);
        print $outfile $idex;
        print $outfile "\n";
    }

    close $outfile;
}

my $ROOT_DIR="$ENV{ROOT_DIR}";

if ( $ROOT_DIR eq "" ) {
    print "You must define \$ROOT_DIR\n";
    exit(0);
}

open my $all_lst, '<', "$ROOT_DIR/all.lst" or die "$!\n";

while ( <$all_lst> ) {
    chomp;
    foreach my $top_percent (@top_percent) {
         print_line ( $_, $top_percent);
    }
}

close $all_lst;
