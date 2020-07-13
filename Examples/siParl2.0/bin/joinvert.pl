#!/usr/bin/perl
use warnings;
use utf8;
$inFiles = shift;
$outFile = shift;
binmode(STDOUT,'utf8');
binmode(STDERR,'utf8');

foreach $inFile (glob $inFiles) {
    ($date) = $inFile =~ /[._-](\d\d\d\d-\d\d-\d\d)[._-]/
	or die "Bad filename $inFile!\n";
    push @{$file{$date}}, $inFile;
}
unlink $outFile;
foreach $date (reverse sort keys %file) {
    print STDERR ">>$date\n";
    foreach $f (@{$file{$date}}) {
	`cat $f >> $outFile`;
    }
}
