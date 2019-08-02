#!/usr/bin/env perl

use warnings;
use strict;

my @top_percent = qw(0.005 0.01 0.02 0.05 0.10 0.20 0.50 1.00);

sub check_file {
    my $calc_file = shift;

    unless ( -e $calc_file ) {
        print STDERR "$calc_file does not exist\n";
        return ();
    }

    my $file_length_wc = `wc -l $calc_file`;
    my $file_length = $1 if $file_length_wc =~ m/^(\d+)/x;


    my $expected_length = shift;
    if ( defined $expected_length and ($expected_length != $file_length) ) {
        print "$calc_file\n";
        return ();
    }

    return $file_length;
}

sub check_group {
    my $expected_length = shift;
    my $prefix = shift;
    my $suffix = shift;

    my $values_ref = shift;
    my @values = @$values_ref;

    foreach my $i (@values) {
        check_file($prefix.$i.$suffix, $expected_length);
    }

}

sub check_all_scoring_functions {
    my $expected_length = shift;
    my $calc = shift;

    my @aref = ('cumulative');
    my @afunc= ('radial', 'normalized_frequency');
    my @acomp= ('reduced', 'complete');
    my @acuts= (4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15);

    my @all_sfs = ();

    foreach my $ref (@aref) {
    foreach my $func(@afunc){
    foreach my $comp(@acomp){
    foreach my $cuts(@acuts) {
        my $scoring_func = "${func}_${ref}_${comp}_${cuts}";
        next if $scoring_func eq "radial_mean_reduced_6";
        push @all_sfs, $scoring_func;
    }}}}

    return check_group($expected_length, "$calc/", ".lst", \@all_sfs);
}

sub check_run {

    my $protein = shift;
    my $top_percent = shift;

    my $calc = "${protein}_pocket/${top_percent}";

    my $score = check_file( "$calc/score.lst" );

    check_all_scoring_functions($score, $calc);
}

my $ROOT_DIR="$ENV{ROOT_DIR}";

if ( $ROOT_DIR eq "" ) {
    print "You must define \$ROOT_DIR\n";
    exit(0);
}

open my $all_lst, '<', "$ROOT_DIR/core.lst" or die "$!\n";

while ( <$all_lst> ) {

    chomp;
    foreach my $top_percent (@top_percent) {
        check_run ( $_, $top_percent );
    }

    
}

close $all_lst;
