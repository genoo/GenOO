package MyBio::MySub;

# Contains useful functions

use warnings;
use strict;

our $VERSION = '1.0';

sub read_fasta {
# Reads a fasta file
	my ($file,$requested_header) = @_;
	
	my $header;
	my %sequence;
	open (my $FASTA,"<",$file) or die "Cannot open file $file: $!";
	while (my $line = <$FASTA>){
		chomp($line);
		if (substr($line,0,1) eq ">") {
			$header = substr($line,1);
		}
		if (substr($line,0,1) ne ">") {
			$sequence{$header} .= $line;
		}
	}
	close $FASTA;
	
	if (defined $requested_header) {
		return $sequence{$requested_header};
	}
	else {
		return \%sequence;
	}
}