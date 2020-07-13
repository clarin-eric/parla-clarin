#!/usr/bin/perl
use warnings;
use utf8;
use FindBin qw($Bin);

$inDir = shift;
$outDir = shift;

binmode(STDERR, 'utf8');

`mkdir $outDir` unless -e "$outDir";

$Saxon = 'java -jar /home/tomaz/bin/saxon9he.jar';
$TEI2VERT  = "$Bin/siparl2vert.xsl";
$POLISH = "$Bin/parla-xml2vert.pl";

binmode(STDERR,'utf8');

if ($inDir =~ /\.xml/) {$procFiles = $inDir}
elsif (-d $inDir) {$procFiles = "$inDir/*.xml"}

($inBase) = $procFiles =~ m|(.+)/[^/]+/[^/]+\.xml|;
$rootTEI = "$Bin/../$inBase/siParl-ana.xml";
$rootTEI = "$Bin/../$inBase/siParl-ana-sample.xml" unless -e $rootTEI;
die "Can't find root TEI file with teiHeader: $rootTEI\n"
    unless -e $rootTEI;

foreach $inFile (glob $procFiles) {
    my ($Slice, $fName) = $inFile =~ m|/([^/]+)/([^/]+)\.xml|
	or die "Weird input file $inFile\n";
    `mkdir $outDir/$Slice` unless -e "$outDir/$Slice";
    $fName =~ s/-ana//;
    my $outFile = "$outDir/$Slice/$fName.vert";
    print STDERR "INFO: Converting $fName\n";
    my $status = system("$Saxon tei=$rootTEI -xsl:$TEI2VERT $inFile | $POLISH > $outFile");
    die "ERROR: Conversion to vert for $inFile failed!\n"
	if $status;
}
