package GenOO::MySub;

# Contains useful functions

use strict;

our $VERSION = '1.0';

# sub read_fasta {
# # Reads a fasta file
# 	my ($file,$requested_header) = @_;
# 	
# 	my $header;
# 	my %sequence;
# 	open (my $FASTA,"<",$file) or die "Cannot open file $file: $!";
# 	while (my $line = <$FASTA>){
# 		chomp($line);
# 		if (substr($line,0,1) eq ">") {
# 			$header = substr($line,1);
# 		}
# 		else {
# 			$sequence{$header} .= $line;
# 		}
# 	}
# 	close $FASTA;
# 	
# 	if (defined $requested_header) {
# 		return $sequence{$requested_header};
# 	}
# 	else {
# 		return \%sequence;
# 	}
# }

sub read_fasta {
# Reads a fasta file
	my ($file,$requested_header) = @_;
	
	if (defined $requested_header) {
		return read_fasta_seq_for_requested_header($file,$requested_header);
	}
	else {
		return read_fasta_sequences_in_hash($file);
	}
}

sub read_fasta_sequences_in_hash {
	my ($file) = @_;
	
	my $header;
	my $seq;
	my %sequence;
	open (my $FASTA,"<",$file) or die "Cannot open file $file: $!";
	while (my $line = <$FASTA>){
		chomp($line);
		if ($line =~ /^>/) {
			if ($seq) {
				$sequence{$header} = $seq;
				$seq = '';
			}
			$header = substr($line,1);
		}
		else {
			$seq .= $line;
		}
	}
	if ($seq) {
		$sequence{$header} = $seq;
	}
	close $FASTA;
	
	return \%sequence;
}

sub read_fasta_seq_for_requested_header {
# Reads a fasta file
	my ($file,$requested_header) = @_;
	
	open (my $FASTA,"<",$file) or die "Cannot open file $file: $!";
	while (my $line = <$FASTA>){
		chomp($line);
		if ($line =~ /^>$requested_header$/) {
			my $seq = '';
			while ($line = <$FASTA>) {
				chomp($line);
				if ($line =~ /^>/) {
					return $seq;
				}
				else {
					$seq .= $line;
				}
			}
			return $seq;
		}
	}
	close $FASTA;
	return undef;
}