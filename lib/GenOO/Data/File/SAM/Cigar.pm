# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::SAM::Cigar - Role that corresponds to the SAM file CIGAR string

=head1 SYNOPSIS

    This role when consumed requires specific attributes and provides
    methods to extract information from the CIGAR string as defined in
    the SAM format specifications.

=head1 DESCRIPTION

    The cigar string describes the alignment of a query on a reference sequence.
    This role offers methods that can extract information from the CIGAR string
    directly such as the positions on insertions, the total number of deletions, etc
    
    The CIGAR operations are given in the following table (set `*' if unavailable):
    Op   BAM  Description
    M    0    alignment match (can be a sequence match or mismatch)
    I    1    insertion to the reference
    D    2    deletion from the reference
    N    3    skipped region from the reference
    S    4    soft clipping (clipped sequences present in SEQ)
    H    5    hard clipping (clipped sequences NOT present in SEQ)
    P    6    padding (silent deletion from padded reference)
    =    7    sequence match
    X    8    sequence mismatch
    
    * H can only be present as the first and/or last operation.
    * S may only have H operations between them and the ends of the CIGAR string.
    * For mRNA-to-genome alignment, an N operation represents an intron. For other types of
      alignments, the interpretation of N is not defined.
    * Sum of lengths of the M/I/S/=/X operations shall equal the length of SEQ.

=head1 EXAMPLES

    # Get the location information on the reference sequence
    $obj_with_role->deletion_positions_on_query;   # (10, 19, ...)
    $obj_with_role->insertion_count;    # 3
    $obj_with_role->deletion_positions_on_reference;  # (43534511, 43534522, ...)

=cut

# Let the code begin...

package GenOO::Data::File::SAM::Cigar;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Moose::Role;
use namespace::autoclean;


#######################################################################
########################   Required attributes   ######################
#######################################################################
requires qw(cigar strand start);


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub M_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('M');
}

sub I_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('I');
}

sub D_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('D');
}

sub N_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('N');
}

sub S_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('S');
}

sub H_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('H');
}

sub P_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('P');
}

sub EQ_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('=');
}

sub X_count {
	my ($self) = @_;
	
	return $self->_total_operator_count('X');
}

sub insertion_count {
	my ($self) = @_;
	
	return $self->I_count;
}

sub deletion_count {
	my ($self) = @_;
	
	return $self->D_count;
}

sub deletion_positions_on_query {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my @deletion_positions;
	if ($self->cigar =~ /D/) {
		my $cigar = $self->cigar_relative_to_query;
		
		my $relative_position = 0;
		while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
			my $count = $1;
			my $identifier = $2;
			
			if ($identifier eq 'D') {
				push @deletion_positions, $relative_position - 1;
			}
			elsif ($identifier ne 'N' and $identifier ne 'P' and $identifier ne 'H') {
				$relative_position += $count;
			}
		}
	}
	
	return @deletion_positions;
}

sub mid_position {
	my ($self) = @_;
	# Read:   AGTGAT____GGA---GTGACTCA-C -> CIGAR: 2M1I3M4N3M3D1M1I3M1I2M1D1M  /  2=1I1=1X1=4N1=1X1=3D1=1I2=1X1I2=1D1=
    #             -      -        -
    # Genome: AG-GCTNNNNGTAGAGG-GAG-CAGC -> MD:Z:  3C1^NNNN1T1^GAG3G2^G1
	
	my $mid_position = $self->start - 1;
	my $mid_position_on_query = ($self->query_length - $self->S_count + 1) / 2;
	my $cigar = $self->cigar;
	
	while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
		my ($count, $identifier) = ($1, $2);
		if ($identifier eq 'D' or $identifier eq 'N' or $identifier eq 'P' or $identifier eq 'H') {
			$mid_position += $count;
		}
		elsif ($identifier eq 'M' or $identifier eq '=' or $identifier eq 'X') {
			if ($mid_position_on_query < $count) {
				return $mid_position + $mid_position_on_query;
			}
			$mid_position += $count;
			$mid_position_on_query -= $count;
		}
		elsif ($identifier eq 'I') {
			if ($mid_position_on_query < $count) {
				return $mid_position + 0.5;
			}
			$mid_position_on_query -= $count;
		}
	}
	
	return;
}


sub insertion_positions_on_query {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my @insertion_positions;
	if ($self->cigar =~ /I/) {
		my $cigar = $self->cigar_relative_to_query;
		
		my $relative_position = 0;
		while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
			my $count = $1;
			my $identifier = $2;
			
			if ($identifier eq 'I') {
				for (my $i=0; $i<$count; $i++) {
					push @insertion_positions, $relative_position;
					$relative_position++;
				}
			}
			elsif ($identifier ne 'D' and $identifier ne 'N' and $identifier ne 'P' and $identifier ne 'H') {
				$relative_position += $count;
			}
		}
	}
	
	return @insertion_positions;
}

sub mismatch_positions_on_query {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	if ($self->cigar =~ /X/) {
		my @mismatch_positions;
		my $cigar = $self->cigar_relative_to_query;
		
		my $relative_position = 0;
		while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
			my $count = $1;
			my $identifier = $2;
			
			if ($identifier eq 'X') {
				for (my $i=0; $i<$count; $i++) {
					push @mismatch_positions, $relative_position;
					$relative_position++;
				}
			}
			elsif ($identifier ne 'D' and $identifier ne 'N' and $identifier ne 'P' and $identifier ne 'H') {
				$relative_position += $count;
			}
		}
		return @mismatch_positions;
	}
	else {
		return $self->mismatch_positions_on_query_calculated_from_mdz();
	}
}

sub deletion_positions_on_reference {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my @deletion_positions;
	if ($self->cigar =~ /D/) {
		my $cigar = $self->cigar;
		
		my $relative_position = 0;
		while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
			my $count = $1;
			my $identifier = $2;
			
			if ($identifier eq 'D') {
				for (my $i=0; $i<$count; $i++) {
					push @deletion_positions, $self->start + $relative_position;
					$relative_position++;
				}
			}
			elsif ($identifier ne 'I' and $identifier ne 'P' and $identifier ne 'S' and $identifier ne 'H') {
				$relative_position += $count;
			}
		}
	}
	
	return @deletion_positions;
}

sub mismatch_positions_on_reference {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	if ($self->cigar =~ /X/) {
		my @mismatch_positions;
		my $cigar = $self->cigar;
		
		my $relative_position = 0;
		while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
			my $count = $1;
			my $identifier = $2;
			
			if ($identifier eq 'X') {
				for (my $i=0; $i<$count; $i++) {
					push @mismatch_positions, $self->start + $relative_position;
					$relative_position++;
				}
			}
			elsif ($identifier ne 'I' and $identifier ne 'P' and $identifier ne 'S' and $identifier ne 'H') {
				$relative_position += $count;
			}
		}
		return @mismatch_positions;
	}
	else {
		return $self->mismatch_positions_on_reference_calculated_from_mdz();
	}
}

sub cigar_relative_to_query {
	my ($self) = @_;
	
	my $cigar = $self->cigar;
	
	# if negative strand -> reverse the cigar string
	if (defined $self->strand and ($self->strand == -1)) {
		my $reverse_cigar = '';
		while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
			$reverse_cigar = $1.$2.$reverse_cigar;
		}
		return $reverse_cigar;
	}
	else {
		return $cigar;
	}
}


#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _total_operator_count {
	my ($self, $operator) = @_;
	
	my $cigar = $self->cigar;
	
	my $count = 0;
	while ($cigar =~ /(\d+)$operator/g) {
		$count += $1;
	}
	return $count;
}

1;
