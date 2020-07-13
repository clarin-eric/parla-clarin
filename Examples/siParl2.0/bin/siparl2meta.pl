#!/usr/bin/perl
use warnings;
use utf8;
use FindBin qw($Bin);

$what = shift;
$rootTEI = shift;
$inDir = shift;
$outDir = shift;

use File::Temp qw/ tempfile tempdir /;  #creation of tmp files and directory
$tmpDir="/tmp";
my $tempDir = tempdir(DIR => $tmpDir, CLEANUP => 1);

binmode(STDOUT, 'utf8');
binmode(STDERR, 'utf8');

$Saxon = 'java -jar /home/tomaz/bin/saxon9he.jar';
$TEI2META  = "$Bin/siparl2meta.xsl";

if ($what eq 'sessions') {
    $header = "ID\tDate\tTitles\tMandate-slv\tMandate-eng\tOrganisations\tTypes-slv\tTypes-eng\n";
}
elsif ($what eq 'speeches') {
    $header = "Speech-ID\tSpeaker-ID\tSpeaker-Name\tSex\tBirth\tDeath\tType-slv\tType-eng\tRole-slv\tRole-eng\tParty-Init\tParty-slv\tParty-eng\tnotes\tgaps\tnames\tsegs\tsents\twords\ttokens\n";
}
else {die "First parameter should be 'sessions' or 'speeches'!|\n"}

($Slice) = $inDir =~ m|/([^/]+)|;
$outFile = "$outDir/$Slice-$what.tsv";
open(OUT, '>:utf8', $outFile) or die;
print OUT $header;

foreach $inFile (glob "$inDir/*.xml") {
    print STDERR "INFO: Converting $inFile\n";
    $tmp_out = "$tempDir/out.tmp";
    $status = system("$Saxon what=$what tei=$rootTEI -xsl:$TEI2META $inFile > $tmp_out");
    die "ERROR: Conversion to $tmp_out failed!\n"
	if $status;
    open TBL, '<:utf8', $tmp_out or die;
    while (<TBL>) {
	print OUT;
    }
    close TBL;
}
close OUT
