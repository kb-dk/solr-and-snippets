#!/usr/bin/perl -w

use strict;
use utf8;

binmode STDERR, ':utf8';
binmode STDOUT, ':utf8';
binmode STDIN, ':utf8';

my %endings;
my @endings_list = ();
my @poem = ();
my %found;
my $rhyme_structure = '';
my @chars = ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o');

while(my $line = <STDIN>) {
    next if $line =~ m/^\s*$/;
    next if $line =~ m/^#/;
    
    $line =~ s/[\.,;]/ /g;
    
    chomp($line);

    my $seq; my $text;

    ($seq,$text) = split /\s---\s/,$line;
    push @poem,$text;
    reverse($text) =~ m/(\w\w\w)(.*$)/;
    my $the_end = $1;

    print $the_end . " --- $seq\n";
    $endings{$the_end} .= "$seq ";
    $endings_list[$seq] .= "$the_end ";
}

foreach my $num (1..14) {
    my $current = $endings_list[$num];
    print shift @poem;
#    print "\t\t# $current";
    
    if(!exists $found{$current}) { #  && $found{$current} !~ m/.../
	$found{$current} = shift @chars;
    }

    $rhyme_structure .= $found{$current};
    
    print "\t\t\t" . $found{$current};


    print "\n";
}

print "$rhyme_structure\n";
