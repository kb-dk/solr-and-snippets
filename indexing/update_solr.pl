#!/usr/bin/perl -w

use strict;

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;

$ua->agent("adl_solr_client/0.1 ");

#
# You have to edit the $solr_host_port variable
#

# my $solr_host_port = 'localhost:8983';

my $solr_host_port = 'disdev-01.kb.dk:8081';


#
# Stuff below should not be regarded as configuration. Editing it is more development.
#
################################################################################################
# http://localhost:8983/solr/#/collection1/documents

# my $collection = "solr/cop-editions";
my $collection = "solr/adl";

my $solr_xml="http://$solr_host_port/$collection/update?commit=true";
my $solr_del='<delete><query>*:*</query></delete>';

if(1) {
# Create a delete request
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

	my $count = 0;
	while(my $file=<>) {
	    chomp $file;
	    $count++;

#	    last if $count > 5;

	    my $content = &get_it($file);
	    &send_it($file,$content);

	}



sub url() {
    my $coll = shift;
    my $file = shift;

    my $exist_solrizer = "http://bifrost-test-01.kb.dk:8080/exist/rest/db/adl/present.xq?c=". $coll .
                          "&op=solrize&doc=" . $file;

    return  $exist_solrizer;
			  
}

sub get_it() {
    my $file = shift;

#	$del_req->content_type('text/xml; charset=utf-8');
#	$del_req->content($solr_del);

    $file =~ s|^.*?adl/||;
    my $c = '';
    my $f = '';

    ($c,$f) = split(/\//,$file);
    my $exist_xml = &url($c,$f);
    my $get_req = HTTP::Request->new(GET => $exist_xml);
    my $response = $ua->request($get_req);
    print $response->status_line . "\n";

    $response->content();

}

sub send_it() {
    my $file = shift;
    my $content = shift;

    print "$file\n";

# Create an update request
    print $solr_xml . "\n";
    my $req = HTTP::Request->new(POST => $solr_xml);
    $req->content_type('text/xml; charset=utf-8');
    $req->content($content);

# Pass request to the user agent and get a response back
    my $res = $ua->request($req);

# Check the outcome of the response
    if ($res->is_success) {
	print "Index successfully updated " , $res->content , "\n";
    } else {
	print "Failed updating " , $res->status_line, "\n";
	print STDERR "Failed updating $file\n" , $res->status_line, "\n";
	print STDERR "$content\n";
    }

}
