#!/usr/bin/perl -w

use strict;
my $gv = "build/text-retriever/gv";
my $find_cmd = "find $gv -name 'txt.xml' -print";
my $empty_doc = "<bibl xmlns='http://www.tei-c.org/ns/1.0'/>\n";

if(-d "$gv/registre/") {
    if(open(my $doc,">$gv/registre/capabilities.xml")) {
	print $doc $empty_doc;
	close $doc;
    } else {
	die "$gv/registre/capabilities.xml" , " $@\n";
    }
}

if(open(FIND,"$find_cmd |") ) {
    while(my $object = <FIND>) {
	chomp $object;
	$object =~ m|^(.*)/(txt.xml)$|;
	my $directory = $1;
#	print "$object\n\t";
	my %data = ();

	while(my $file = <$directory/*xml>) {
	    chomp $file;
	    next unless $file =~ m/.*xml/;
	    next if $file =~ m/txt.xml$/;
	    my $type = "ignore";
	    if($file =~ m/intro.xml/) {
		$type = "Indledning";
	    } elsif($file =~ m/com.xml/) {
		$type = "Kommentarer";
	    } elsif($file =~ m/txr.xml/) {
		$type = "Tekstredegørelser";
	    } elsif($file =~ m/v0.xml/) {
		$type = "Varianter";
	    }

	    my $rel = $file;
	    $rel =~ s|^(.*?)/([^/]+)$|$2|;
#	    print "$rel $type\n";
	    $data{$rel} = $type;
	}
	my $document = &caps(\%data);
	if(open(my $doc,">$directory/capabilities.xml")) {
	    print $doc $document;
	    close $doc;
	} else {
	    die "$directory/capabilities.xml" , " $@\n";
	}
    }

}

sub caps {
    my $data = shift;
    my $doc = '<?xml version="1.0" encoding="UTF-8" ?>' . "\n";
    $doc .= "<bibl xmlns='http://www.tei-c.org/ns/1.0'>\n";
    $doc .= "<ref type='Verk' target='txt.xml'/>\n";
    while( my ($key,$val) = each %$data) {
	next unless $key =~ m/xml$/;
	$doc .=  '<relatedItem type="' . $val . '" target="' . $key . '"/>'."\n";
    }
    $doc .= "</bibl>\n";
    return $doc;
}
