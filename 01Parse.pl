#!/usr/bin/perl

use strict;
use warnings;

###################################
# Read files
sub read_file {
	# filename
	my ($input_file) = @_;
	my @array        = ();
	# open file
	open(FILE, "<", $input_file ) || die "Can't open $input_file: $!";
	while (my $row = <FILE>) {
		chomp($row);
		push (@array,$row);
	}
	close (FILE);
	# return array
	return @array;
}


#<Atom name=
#<Bond from=
#foreach my $key (keys %HashMult){

my %HashData    = ();
my @FirstIndex  = ();
my @SecondIndex = ();
#
my $residuename;

my ($fileXML) = @ARGV;

if (not defined $fileXML) {
	die "\n01Parse must be run with:\n\nUsage:\n\tperl 01Parse.pl [XML-file]\n\n\n";
	exit(1);
}
# Read and parse XYZ format
my @data_file    = read_file($fileXML);
my $count = 0;
foreach my $data (@data_file) {
	#<Residue name="STG">
	if (($data=~/Residue/i) && ($data=~/name/i)) {
		$residuename = $data;
	}
	if (($data=~/Atom/i) && ($data=~/name/i)) {
		my @tmp = split ("\"",$data);
		$HashData{$count} = $tmp[1];
		$count++;
	}
	if (($data=~/Bond/i) && ($data=~/from/i)) {
		my @tmp = split ("\"",$data);
		push (@FirstIndex,$tmp[1]);
		push (@SecondIndex,$tmp[3]);
	}
}
#
#<Residue name="HOH">
#  <Bond from="O" to="H1"/>
#  <Bond from="O" to="H2"/>
#</Residue>
print " $residuename\n";
for ( my $i = 0 ; $i < scalar (@FirstIndex) ; $i = $i + 1 ){
	print "   <Bond from=\"$HashData{$FirstIndex[$i]}\" to=\"$HashData{$SecondIndex[$i]}\"/>\n";
}
print " </Residue>\n";
