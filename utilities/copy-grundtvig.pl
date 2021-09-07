#!/usr/bin/perl -w

use strict;

#
# This is so specific Grundtvigs Værker that it won't be useful for anything else
#
# In case you'd like to configure where you keep the GV
#

my $where_is_grundtvig = "../GV/";
my $where_should_it_go = "./build/text-retriever/";

my $published_files = `perl -ne 's/\n/ /; print;' gv_filter/txtFilter.txt`;

my $doc_cmd = 'ls ' . $published_files;

# my $doc_cmd = "find . -regextype sed -regex '^.*18[0-9][0-9]GV.*\$' -type f -print";
my $authority_cmd =  "find shared/registre -name '*.xml' -print";

my $find_cmds = "(cd $where_is_grundtvig ; $authority_cmd ; $doc_cmd )|";

if( open(my $gv, $find_cmds) ) {
    while(my $file = <$gv>) {
	chomp $file;
	my $uri = "";
	if($file =~ m/(18\d\d)_(\d+[a-zA-Z]?)_?(\d+)?_(col|com|intro|txr|txt|v0).xml$/) {
	    if($3) {
		$uri = join '/',("gv",join("_",$1,$2,$3),$4);
	    } else {
		$uri = join '/',("gv",join("_",$1,$2),$4);
	    }
	    my $path = $uri;
	    print "# uri before $uri\n";
	    print "# $path\n";
	    $uri =~ s/col$/kolofon/;
	    print "# uri after $uri\n";
	    $path =~ s/[^\/]+$//;
	    $file =~ s/^\.\///;

	    my $copy = "cp  $where_is_grundtvig$file $where_should_it_go$uri.xml";
	    my $transform = "xsltproc   utilities/add-id.xsl $where_is_grundtvig$file > $where_should_it_go$uri.xml";

#	    print "mkdir -p  $where_should_it_go$path ; $copy\n";
	    print "mkdir -p  $where_should_it_go$path ; $transform\n";
	} elsif( $file =~ m/shared\/registre\/(bible|myth|pers|place|title).xml$/) {
	    my $uri = $where_should_it_go . "/gv/registre/" . $1 .".xml";
	    my $path = $uri;
	    $path =~ s/[^\/]+$//;
	    my $transform = "xsltproc   utilities/add-id.xsl $where_is_grundtvig$file > $uri";
	    print "mkdir -p  $path ; $transform\n";
	}
    }
}
