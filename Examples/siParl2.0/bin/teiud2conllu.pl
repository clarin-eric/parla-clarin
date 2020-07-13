#!/usr/bin/perl
# Make CONLL-U from UD-annotated TEI
use warnings;
use utf8;
use FindBin qw($Bin);
# use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
# `mkdir $Bin/tmp` unless -e "$Bin/tmp";
# $tmpDir="$Bin/tmp";
# my $tempDir = tempdir(DIR => $tmpDir, CLEANUP => 1);

$Saxon = 'java -jar /home/tomaz/bin/saxon9he.jar';
$CNV  = "$Bin/teiud2conllu.xsl";

binmode STDERR, 'utf8';

$in_dir = shift;
$out_dir = shift;

$in_tei = $in_dir;
$in_tei =~ s|//+|/|g;

foreach my $teiFile (glob $in_tei) {
    my ($slice, $fname) = $teiFile =~ m|([^/]+)/([^/]+)\.xml$|
	or die "Bad input $teiFile!\n";
    $out_tei = "$out_dir/$slice";
    `mkdir $out_tei` unless -e $out_tei;
    $tei_out = "$out_tei/$fname.conllu";
    print STDERR "INFO: processing $slice/$fname\n";
    $status = system("$Saxon -xsl:$CNV $teiFile > $tei_out");
    die "ERROR: Conversion to TEI for $teiFile failed!\n"
	if $status;
}
