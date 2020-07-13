#!/usr/bin/perl
use warnings;
use utf8;

$inDir = shift;
$outDir = shift;

`mkdir $outDir` unless -e "$outDir";

use FindBin qw($Bin);
$Saxon = 'java -jar /usr/local/bin/saxon9he.jar';
#$Saxon = 'java -jar /home/tomaz/bin/saxon9he.jar';
$TEXT  = "$Saxon -xsl:$Bin/teiana2txt.xsl";

binmode(STDERR,'utf8');

if ($inDir =~ /\.xml/) {$procFiles = $inDir}
elsif (-d $inDir) {$procFiles = "$inDir/*.xml"}

foreach $inFile (glob $procFiles) {
    my $origFile = $inFile;
    ($Slice, $fName) = $inFile =~ m|([^/]+)/([^/]+)\.xml|;
    `mkdir $outDir/$Slice` unless -e "$outDir/$Slice";
    
    my $outFile = "$outDir/$Slice/$fName.txt";
    print STDERR "INFO: Converting $fName\n";

    my $status = system("$TEXT $inFile > $outFile");
    if ($status) {
	print STDERR "ERROR: Conversion to text for $inFile failed!\n";
	return 0;
    }
}
