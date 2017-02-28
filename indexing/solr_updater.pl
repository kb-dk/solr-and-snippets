#!/usr/bin/perl -w

use strict;

use URI::Template;
use LWP::UserAgent;
use Getopt::Long;

my $ua = LWP::UserAgent->new;

my $file_list         = "";
my $delete_all        = "";
my %param;

my $solrizer_template = URI::Template->new("http://{exist_host}:{exist_port}/exist/rest/db/{service}/present.xq{?op,doc,c}");
my $solr_template     = URI::Template->new("http://{solr_host}:{solr_port}/solr/{collection}/update{?softCommit}");

my $result = GetOptions (
    "file-list=s"        =>  \$file_list,
    "delete-all=s"       =>  \$delete_all,
    "param=s"            =>  \%param);

$param{'softCommit'}='true';

$ua->agent("adl_solr_client/0.1 ");

my $list;
if($file_list) {
    open($list,"<$file_list");
} else {
    $list = *STDIN;
}

#
# Stuff below are neither parameters nor configuration. Editing it is more development.
#
################################################################################################

my $solr_uri =  $solr_template->process(%param);

if($delete_all && &promptUser("Really delete index (y/n)","n")) {

    my $solr_del='<delete><query>*:*</query></delete>';
    
# Create a delete request

    my $del_req = HTTP::Request->new(POST => $solr_uri);
    $del_req->content_type('text/xml; charset=utf-8');
    $del_req->content($solr_del);

# Pass request to the user agent and get a response back

    my $del_res = $ua->request($del_req);

# Check the outcome of the delete response

    if ($del_res->is_success) {
	print $del_res->content;
    } else {
	print STDERR "Failed deleting index " , $del_res->status_line, "\n";
    }

}

my $count = 0;
while(my $file=<$list>) {
    chomp $file;
    $count++;

    my $content = &get_it($file);
    &send_it($file,$content);

}



sub get_it() {
    my $file = shift;

    $file =~ s|^.*?adl/||;
    my $c = '';
    my $f = '';

    ($c,$f) = split(/\//,$file);
    $param{'doc'}=$f;
    $param{'c'}=$c;
    my $exist_uri = $solrizer_template->process(%param);
    print "$exist_uri\n";
    my $get_req = HTTP::Request->new(GET => $exist_uri);
    my $response = $ua->request($get_req);
    print $response->status_line . "\n";

    $response->content();

}

sub send_it() {
    my $file = shift;
    my $content = shift;

    print "$file\n";

# Create an update request
    print $solr_uri . "\n";
    my $req = HTTP::Request->new(POST => $solr_uri);
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

sub promptUser {
   my $promptString = shift;
   my $defaultValue = shift;

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after print
   $_ = <STDIN>;         # get the input from STDIN

   chomp;

   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}
