#!/usr/bin/perl

use Git::Repository;

use LWP::UserAgent;
use Getopt::Long;

my $gitdir="";
my $file_list = "";

my $result = GetOptions (
    "gitdir=s"    => \$gitdir,
    "file_list=s" => \$file_list);

# start from an existing repository

open(FILES,">$file_list") if($file_list);


if($gitdir) {

    my $rep = Git::Repository->new( work_tree => $gitdir );

    $rep->run( 'pull' => "origin" => "master",
	       sub {
		   my ($file, $a, $b, $c) = split;
		   chomp $file;
		   if(-f "$gitdir/$file" ) {
		       if($file_list) {
			   print FILES "$file\n"; 
		       } else {
			   print "$file\n";
		       }
		   }
	       }
	)

} else {
    &usage();
}

sub usage {
    print STDERR <<END;

$0 --gitdir=<git project> --file_list=<list>

where

--gitdir is a local directory connected to your origin (usually at github)
--file_list is text file containing the names of updated files, one per line

if a file list isn't given, then the file names are written to standard output	

END
	
}
