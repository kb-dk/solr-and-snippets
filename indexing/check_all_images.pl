#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use Getopt::Long;

use File::Path;
use FileHandle;

use XML::LibXML;

my $ua = LWP::UserAgent->new;

my $exist_url = "http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/";
my $image_server = "http://kb-images.kb.dk/public/";

print STDOUT "<missing>";
while(my $file=<>) {
     chomp $file;
     $file =~ s|^.*?adl/||;


     my $get_req = HTTP::Request->new(GET => $exist_url.$file);
     my $response = $ua->request($get_req);
     if ($response->is_success) {
     my $content = $response->content();

     my $xml = XML::LibXML->load_xml(
        string => $content
     );
    my @pbs = $xml->getElementsByTagName('pb');

    for my $pb (@pbs) {
        my $facs = $pb->getAttribute('facs');
        my $xmlid = $pb->getAttribute('xml:id') || "";
        my $image_url = $image_server.$facs."/full/full/0/native.jpg";
	my $head_req =  HTTP::Request->new(HEAD => $image_url);
        my $code = $ua->request($head_req)->code;
        print STDERR "$file ; $xmlid ; $facs ; $image_url ; $code \n";
        if ($code != 200) { 
        	print STDOUT $pb->toString() . "\n"
	}
       
    };
   } 

}
print STDOUT "</missing>";


