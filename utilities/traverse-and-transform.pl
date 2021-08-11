#!/usr/bin/perl -w

use strict;

my $saxon_xslt = "java -jar  /home/slu/saxon/saxon9he.jar ";
my $sheet = "/home/slu/projects/solr-and-snippets/utilities/add-id.xsl";

if(open(FIND,"find . -name '*.xml' -print |")) {
    while(my $file = <FIND>) {
	next if $file =~ /schemas.xml/;
	next if $file =~ /capabiliti.*xml/;
	print "\n# $file\n";
	chomp $file;
	my $out = $file."_shit";
	print "$saxon_xslt $file $sheet > $out" . "\n";
	print  "xmllint --format $out > $file" . "\n";
	print  "rm $out" . "\n";
    }
}
