#!/usr/bin/perl -w

use strict;
use Getopt::Long;

#
# A variant of copy-letters.pl for Grundtvigs Værker letter data.
#
# Like copy-letters.pl it emits shell commands (mkdir -p / cp) on stdout that map
#   <src>/.../<barcode>/<NNN>_<vol>.xml  ->  <dst>/<barcode>/<vol>.xml
# so you pipe it to a shell:  perl copy-letters-list.pl ... | sh
#
# The difference: it can copy a *specific list of files* instead of everything.
#
#   * With a list  -> only those files are processed.
#     Provide the list as command-line arguments, and/or via --from-file <file>
#     (one path per line), and/or piped on stdin. Blank lines and lines starting
#     with '#' are ignored.
#   * Without a list -> it does exactly what copy-letters.pl does now: scan the
#     whole source dir with find and emit commands for every matching *.xml.
#
# A listed path may be absolute, or relative to the current dir (used as given if
# it exists), or relative to --src the same way find output is (then --src is
# prepended). This means you can feed it the very paths `find` would have printed.
#

my $where_is_it        = "../letter-corpus/letter_books/";  # --src
my $where_should_it_go = "./build/text-retriever/letters/"; # --dst
my $list_file          = '';                                # --from-file
my $help               = 0;

GetOptions(
    "src=s"       => \$where_is_it,
    "dst=s"       => \$where_should_it_go,
    "from-file=s" => \$list_file,
    "help|h"      => \$help,
) or die "Try --help\n";

usage() if $help;

# Normalise trailing slashes so path building matches the original script.
$where_is_it        .= '/' unless $where_is_it        =~ m{/$};
$where_should_it_go .= '/' unless $where_should_it_go =~ m{/$};

# ---- Collect an explicit file list, if any --------------------------------

my @files = @ARGV;   # positional args are file paths

if ($list_file) {
    open(my $lf, '<', $list_file) or die "Cannot open list file '$list_file': $!\n";
    push @files, read_list($lf);
    close $lf;
}

# Read stdin only when it is piped (not a terminal) and no explicit list given.
if (!@files && !-t STDIN) {
    push @files, read_list(\*STDIN);
}

# ---- Emit commands ---------------------------------------------------------

if (@files) {
    emit($_) for @files;
} else {
    # No list: original behaviour — scan the whole source tree.
    my $find = '(cd ' . $where_is_it
             . ' ; find . -regextype posix-egrep  -regex ".*xml$" -type f -print) |';
    if (open(my $dta, $find)) {
        while (my $file = <$dta>) {
            emit($file);
        }
        close $dta;
    }
}

# ---------------------------------------------------------------------------

sub emit {
    my ($file) = @_;
    chomp $file;
    return if $file =~ /^\s*$/;

    # Leading dirs are optional so a path whose first segment is the barcode
    # (e.g. 001991743/001991743_000.xml) matches too, not only find-style ./...
    if ($file =~ m|(?:.*/)?(\d+)/(\d+)_(.\d\d).xml|) {
        my $barcode1 = $1;
        my $vol      = $3;
        my $src      = source_path($file);
        my $destination = $where_should_it_go . $barcode1 . "/" . $vol . ".xml";
        print "mkdir -p " . $where_should_it_go . $barcode1 . "\n";
        print "cp " . $src . " " . $destination . "\n";
    } else {
        print "\n# $file\n";
    }
}

# Where to read the source file from. Keeps parity with copy-letters.pl: a
# find-style relative path (e.g. ./<barcode>/<file>.xml) gets --src prepended.
sub source_path {
    my ($f) = @_;
    return $f if $f =~ m{^/};   # absolute path: use as given
    return $f if -e $f;         # exists relative to cwd: use as given
    return $where_is_it . $f;   # otherwise treat as src-relative (find style)
}

sub read_list {
    my ($fh) = @_;
    my @out;
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*$/;    # blank
        next if $line =~ /^\s*#/;    # comment
        push @out, $line;
    }
    return @out;
}

sub usage {
    print <<"END";
Usage: $0 [options] [file ...]

Emit shell (mkdir -p / cp) commands mapping letter XML files
    <src>/.../<barcode>/<NNN>_<vol>.xml  ->  <dst>/<barcode>/<vol>.xml
Pipe the output to a shell to actually copy:  $0 ... | sh

Options:
    --src <dir>        source dir (default: $where_is_it)
    --dst <dir>        destination dir (default: $where_should_it_go)
    --from-file <f>    read the list of files to copy from <f> (one path/line;
                       blank lines and #comments ignored)
    -h, --help         this help

File list (any combination; if none given, scan the whole --src tree):
    - as command-line arguments
    - via --from-file
    - piped on stdin

Listed paths may be absolute, relative to the current dir, or relative to --src
(the same form `find` prints), in which case --src is prepended.

Examples:
    $0 | sh                                  # copy everything (as before)
    $0 ./001663560/000_001.xml | sh          # copy one file (src-relative)
    $0 --from-file to_copy.txt | sh          # copy the files listed in to_copy.txt
    grep -l changed *.xml | $0 | sh          # copy files chosen upstream
END
    exit 0;
}
