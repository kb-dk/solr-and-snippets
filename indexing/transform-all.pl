#!/usr/bin/perl -w

use strict;

use strict;
use LWP::UserAgent;
use Getopt::Long;


use XML::LibXML;
use XML::LibXSLT;
use File::Path;
use FileHandle;

my $sheet  = 'exporters/common/preprocess.xsl';
my $source = '';
my $suffix = '';
my $target = '';

my $result = GetOptions (
    "sheet=s"      => \$sheet,
    "directory=s"  => \$source,
    "suffix=s"     => \$suffix);

if( !(-d $source && -f $sheet) ) {
    print STDERR "Usage $0 --sheet <xsl file> --directory <dir name> --suffix <file suffix>\n";
    exit(1);
}
my $parser = new XML::LibXML;
my $xslt   = new XML::LibXSLT;

my $style_doc = $parser->parse_file($sheet);
my $transformer  = $xslt->parse_stylesheet($style_doc);

open FILES,"find $source -name '*".$suffix."' -print |";

while(my $file=<FILES>) {
    chomp $file;
    next unless $file =~ m/([^\/]*?)\.$suffix$/;
    my $fileid = $1;
    my $doc = "";
    eval {
	$doc = $parser->parse_file($file);
    };
    if(ref($doc)) {
	my $results  = $transformer->transform($doc,
					       'fileid' => "'$fileid'");
	open XML,">$file";
	print XML $results->toString(1);
	close XML;
    } else {
	print STDERR "Failed to parse $file\n";
    }
}
