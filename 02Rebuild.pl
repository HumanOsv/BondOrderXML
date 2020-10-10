#!/usr/bin/perl

use strict;
use warnings;

###################################
# Extract data XML file
sub ExtractXML {
	# filename
	my ($String,$data)    = @_;
	#
	my @data_file = @{$data};
	#
	my $count       = 0;
	my @IndexCount  = ();
	my @arrayTmp    = ();
	#
	foreach my $data (@data_file) {
		if ( $data=~/$String/i ) {
			push (@IndexCount,$count);
		}
		$count++;
	}
	#
	foreach my $i ( $IndexCount[0] ... $IndexCount[1] ) {
		push (@arrayTmp,$data_file[$i]);
	}
	return @arrayTmp;
}
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

#
#
my ($fileXML,$chain) = @ARGV;

if (not defined $fileXML) {
	die "\n01Rebuild must be run with:\n\nUsage:\n\tperl 02Rebuild.pl [XML-file] Chain\n\n\n";
	exit(1);
}

if (not defined $chain) {
	die "\n01Rebuild must be run with:\n\nUsage:\n\tperl 02Rebuild.pl [XML-file] Chain\n\n\n";
	exit(1);
}

# Read and parse XYZ format
my @data_file   = read_file($fileXML);
#
#my $chain = "A";
#
(my $without_extension = $fileXML) =~ s/\.[^.]+$//;
#
my @AtomTypes            = ExtractXML ("AtomTypes",\@data_file);
my @Residues             = ExtractXML ("Residues",\@data_file);
my @HarmonicBondForce    = ExtractXML ("HarmonicBondForce",\@data_file);
my @HarmonicAngleForce   = ExtractXML ("HarmonicAngleForce",\@data_file);
my @PeriodicTorsionForce = ExtractXML ("PeriodicTorsionForce",\@data_file);
my @NonbondedForce       = ExtractXML ("NonbondedForce",\@data_file);
#
#
open(FILE, ">$without_extension-$chain.xml");
#
# <Type name="opls_824" class="C824" element="C" mass="12.011000" />
print FILE "<ForceField>\n";
print FILE "$AtomTypes[0]\n";
foreach my $i (@AtomTypes) {
	if ( ($i=~/Type/i) && ($i=~/name/i)  ) {
		my @tmp1 = split (" ",$i);
		my @tmp2 = split ("\"",$tmp1[1]);
		print FILE "<Type name=\"$tmp2[1]$chain\"";
		for (my $i=2 ; $i< scalar (@tmp1) ; $i++) {
			print FILE " $tmp1[$i]";
		}
		print FILE "\n";
	}
}
print FILE "$AtomTypes[-1]\n";
#
# <Atom name="C00" type="opls_800" />
print FILE "$Residues[0]\n";
print FILE "$Residues[1]\n";
foreach my $i (@Residues) {
	if ( ($i=~/Atom/i) && ($i=~/type/i)  ) {
		my @tmp1 = split (" ",$i);
		my @tmp2 = split ("\"",$tmp1[2]);
		print FILE "$tmp1[0] $tmp1[1] type=\"$tmp2[1]$chain\" /> \n";
	}
}
# <Bond from="0" to="1"/>
foreach my $i (@Residues) {
	if ( ($i=~/Bond/i) && ($i=~/from/i)  ) {
		print FILE "$i\n";
	}
}
print FILE "</Residue>\n";
print FILE "$Residues[-1]\n";
#
#
#
foreach my $i (@HarmonicBondForce)    { print FILE "$i\n"; }
foreach my $i (@HarmonicAngleForce)   { print FILE "$i\n"; }
foreach my $i (@PeriodicTorsionForce) { print FILE "$i\n"; }
#
#
# <Atom type="opls_834" charge="0.061500" sigma="0.250000" epsilon="0.125520" />
print FILE "$NonbondedForce[0]\n";
foreach my $i (@NonbondedForce) {
	if ( ($i=~/Atom/i) && ($i=~/type/i)  ) {
		my @tmp1 = split (" ",$i);
		my @tmp2 = split ("\"",$tmp1[1]);
		print FILE "<Atom type=\"$tmp2[1]$chain\"";
		for (my $i=2 ; $i< scalar (@tmp1) ; $i++) {
			print FILE " $tmp1[$i]";
		}
		print FILE "\n";
	}
}
print FILE "$NonbondedForce[-1]\n";
print FILE "</ForceField>\n";
close (FILE);
