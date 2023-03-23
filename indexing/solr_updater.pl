#!/usr/bin/perl -w

use strict;

use URI::Template;
use LWP::UserAgent;
use Getopt::Long;

my $ua = LWP::UserAgent->new;

my $file_list    = "";
my $delete_all   = "";
my $delete_query = "";

#
# The commit to solr takes a looong time
#

my $timeout      = 720;

$ua->timeout($timeout);

my %param;

my $solrizer_template    = URI::Template->new("http://{exist_host}:{exist_port}/exist/rest/db/{service}/present.xq{?op,doc,c}");
my $solr_template        = URI::Template->new("http://{solr_host}:{solr_port}/solr/{collection}/update");
my $solr_commit_template = URI::Template->new("http://{solr_host}:{solr_port}/solr/{collection}/update{?commit,softCommit}");


my $result = GetOptions (
    "file-list=s"    =>  \$file_list,
    "delete-all=s"   =>  \$delete_all,
    "delete-query=s" =>  \$delete_query,
    "param=s"        =>  \%param);

if($param{'user'} && $param{'passwd'}) {
    $ua->credentials($param{'solr_host'}.':'.$param{'solr_port'}, "solr admins", $param{'user'}, $param{'passwd'} );
}

if($delete_all) {
    $delete_query = '*:*';
}

print STDERR "exist host: $param{'exist_host'}\n";
print STDERR "exist port: $param{'exist_port'}\n";

$param{'softCommit'} = 'true';
$param{'commit'}     = 'true';

$ua->agent("adl_solr_client/0.1 ");

my $list;
if(-f $file_list) {
    open($list,"<$file_list");
} elsif($file_list eq "-") {
    $list = *STDIN;
}

#
# Stuff below are neither parameters nor configuration. Editing it is more development.
#
################################################################################################

my $solr_uri =  $solr_template->process(%param);
my $solr_commit_uri = $solr_commit_template->process(%param);

if($delete_query && &promptUser("Really delete for query $delete_query (y/n)","n")) {

    my $solr_del='<delete><query>' .  $delete_query  . '</query></delete>';
    
# Create a delete request

    my $del_req = HTTP::Request->new(POST => $solr_uri);
    $del_req->content_type('text/xml; charset=utf-8');
    $del_req->content($solr_del);

# Pass request to the user agent and get a response back

    my $del_res = $ua->request($del_req);

# Check the outcome of the delete response

    if ($del_res->is_success) {
	print $del_res->content;
	&commit_it();
    } else {
	print STDERR "Failed deleting index " , $del_res->status_line, "\n";
    }

}

my $count = 0;
if($list) {
    while(my $file=<$list>) {
	chomp $file;
	next if ($file =~ m/^#/);
	$count++;

	print localtime() . "\n";

	my $response = &get_it($file);
	if($response->is_success) {
	    my $content = $response->content();

	    &send_it($file,$content);
	    if ($count % 50 == 0) {
		&commit_it();
		sleep(1) # give solr some rest
	    }
	} else {
	    print "Failure. Don't send to index: " . $response->status_line . "\n";
	}
    }
    &commit_it(); # commit at the end
}

sub get_it() {
    my $file = shift;

    my $c = '';
    my $f = '';

#
# This one is unforgivable:
#

    if($file !~ m/^.*?((letters)|(pmm)|(gv)|(lhv)|(adl)|(sks)|(tfs)|(lh)|(jura))\//) {
	die "$file seems to belong to a not yet implemented edition\n" .
	    "suggest that you edit line 127 and 131 in indexing/solr_updater.pl\n";
    }
    
    $file =~ s/^.*?((letters)|(pmm)|(gv)|(lhv)|(adl)|(sks)|(tfs)|(lh)|(jura))\///;

    $c = $1;
    $f = $file;

    print "$c $f \n";

    $param{'doc'}=$f;
    $param{'c'}=$c;
    my $exist_uri = $solrizer_template->process(%param);
    print "exist_uri $exist_uri\n";
    my $get_req = HTTP::Request->new(GET => $exist_uri);

    my $response = $ua->request($get_req);
    print $response->status_line . "\n";

    $response;

}

sub send_it() {
    my $file = shift;
    my $content = shift;

    print "$file\n";

# Create an update request
    print $solr_uri . "\n";
    # my $req = HTTP::Request->new(POST =>  $solr_commit_uri);
    my $req = HTTP::Request->new(POST => $solr_uri);
    $req->content_type('text/xml; charset=utf-8');
    $req->content($content);

# Pass request to the user agent and get a response back
    my $res = $ua->request($req);

# Check the outcome of the response
    if(!$res->is_success) {
	print "Failed updating " , $res->status_line, "\n";
	print STDERR "Failed updating $file\n" , $res->status_line, "\n";
	sleep(5);
    }

    print "Index successfully updated " , $res->content , "\n";

}



sub commit_it() {
    print "Committing $solr_commit_uri\n";
    my $commit_req = HTTP::Request->new(GET => $solr_commit_uri); 
    if($param{'user'} && $param{'passwd'}) {
	$ua->credentials($param{'solr_host'}.':'.$param{'solr_port'}, "solr admins", $param{'user'}, $param{'passwd'} );
    }
    my $response = $ua->request($commit_req);

    print $response->status_line . "\n";
    print $response->content() . "\n";
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
