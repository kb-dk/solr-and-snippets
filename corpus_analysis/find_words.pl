#!/usr/bin/perl -w

use strict;
use utf8;

my $unique = 0;
if($ARGV[0] =~ m/unique/) {
    $unique = 1;
}

binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';
binmode STDIN, ':utf8';

open(my $uniqifier, "| sort | uniq ") if $unique;
binmode $uniqifier, ':utf8' if $unique;
while(my $line = <STDIN>) {
    next if $line =~ m/^\s*$/;
    next if $line =~ m/^#/;

    chomp($line);
    $line =~ s/([^[:space:][:alpha:]])/ /g;
    $line = lc $line;

    my @words = split /\s+/,$line;

    while(my $w = shift @words) {
	if( $unique ) {
	    print  $uniqifier "$w\n";
	} else {
	    print "$w\n";
	}
    }
    
}

