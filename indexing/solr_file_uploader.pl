#!/usr/bin/perl -w

use strict;

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;

$ua->agent("adl_solr_client/0.1 ");

#
# You have to edit the $solr_host_port variable
#

my $solr_host_port = 'localhost:8983';
#my $solr_host_port = 'disdev-01.kb.dk:8081';

#
# Stuff below should not be regarded as configuration. Editing it is more development.
#
################################################################################################
# http://localhost:8983/solr/#/collection1/documents
my $collection = "solr/cop-editions";

my $solr_xml="http://$solr_host_port/$collection/update?commit=true";
my $solr_del= ''; #'<delete><query>*:*</query></delete>';

my $target    = $ARGV[0]; 
# my $target    = 'shit/';

if (open(FIND,"find $target -name '*.xml' -print|")) {

    if(0) {

# Create a delete request

	$solr_del= '<delete><query>*:*</query></delete>';

	my $del_req = HTTP::Request->new(POST => $solr_xml);
	$del_req->content_type('text/xml; charset=utf-8');
	$del_req->content($solr_del);

# Pass request to the user agent and get a response back
	my $del_res = $ua->request($del_req);

# Check the outcome of the delete response
	if ($del_res->is_success) {
	    print STDERR $del_res->content;
	} else {
	    print STDERR "Failed deleting index " , $del_res->status_line, "\n";
	}

    }

# We cannot take for granted that there exists an index to begin with. So we
# do try to update even if we failed to delete.

	while(my $file=<FIND>) {
	    chomp $file;
	    &send_it($file);
	}

} else {
    die "Cannot open pipe from find\n";
}

sub send_it() {
    my $file = shift;

    print "$file\n";

# Create an update request
    print $solr_xml;
    my $req = HTTP::Request->new(POST => $solr_xml);
    my $content = `cat $file`;
    $req->content_type('text/xml; charset=utf-8');
    $req->content($content);

# Pass request to the user agent and get a response back
    my $res = $ua->request($req);

# Check the outcome of the response
    if ($res->is_success) {
	print STDERR "Index successfully updated " , $res->content , "\n";
    } else {
	print STDERR "Failed updating " , $res->status_line, "\n";
    }

}
