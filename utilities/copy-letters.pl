#!/usr/bin/perl -w

use strict;

#
# This is so specific Grundtvigs Værker that it won't be useful for anything else
#
# In case you'd like to configure where you keep the data
#

my $where_is_it = "../letter-corpus/letter_books/";
my $where_should_it_go = "./build/text-retriever/letters/";

if( open(my $dta, '(cd ' . $where_is_it . ' ; find . -regextype posix-egrep  -regex ".*xml$" -type f -print) |' )) {
    while(my $file = <$dta>) {

	chomp $file;
	
	print "\n# $file\n";

	if($file =~ m|.*\/(\d+)\/(\d+)_(\d\d\d).xml|) {
	    my $barcode1 = $1;
	    my $barcode2 = $2;
	    my $vol = $3;
	    print "mkdir -p " . $where_should_it_go . $barcode1 . "\n";
	    my $destination = $where_should_it_go . $barcode1 . "/" . $vol . ".xml";
	    print "cp " . $where_is_it . $file . " " . $destination . "\n";
	}
    }
}

