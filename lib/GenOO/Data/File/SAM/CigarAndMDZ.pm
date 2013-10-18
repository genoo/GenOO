# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::SAM::CigarAndMDZ - Role that combines SAM CIGAR string with MD:Z tag

=head1 SYNOPSIS

    This role when consumed requires specific attributes and provides
    methods to extract information from the CIGAR string in combination
    with the MD:Z tag.

=head1 DESCRIPTION

    The cigar string does not usually contain information regarding the deletions.
    For this the MD:Z tag is usually provided. Combining the CIGAR information with
    the MD:Z tag we can extract information such as for example the deletion positions
    on the query sequence.

=head1 EXAMPLES

    # Get the location information on the reference sequence
    $obj_with_role->mismatch_positions_on_query_calculated_from_mdz;   # (10, 19)

=cut

# Let the code begin...

package GenOO::Data::File::SAM::CigarAndMDZ;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Moose::Role;
use namespace::autoclean;


#######################################################################
########################   Required attributes   ######################
#######################################################################
requires qw(query_length);


#######################################################################
##########################   Consumed Roles   #########################
#######################################################################
with 'GenOO::Data::File::SAM::Cigar', 'GenOO::Data::File::SAM::MDZ';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub mismatch_positions_on_query_calculated_from_mdz {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my $cigar = $self->cigar;
	
	# Find positions of insertions and deletions (dashes) on the query sequence
	my @deletion_positions;
	my @insertion_positions;
	my $position = 0;
	while ($cigar =~ /(\d+)([MIDNSHP=X])/g) {
		my $count = $1;
		my $identifier = $2;
		
		if ($identifier eq 'D' or $identifier eq 'N' or $identifier eq 'P' or $identifier eq 'H') {
			push (@deletion_positions, $position + $_) for (0..$count-1)
		}
		elsif ($identifier eq 'I' or $identifier eq 'S') {
			push (@insertion_positions, $position + $_) for (0..$count-1)
		}
		$position += $count;
	}
	
	my @mismatch_positions_on_reference = $self->mismatch_positions_on_reference;
	my @relative_mismatch_positions_on_reference = map {$_ - $self->start} @mismatch_positions_on_reference;
	
	my @mismatch_positions;
	foreach my $relative_mismatch_position_on_reference (@relative_mismatch_positions_on_reference) {
		my $deletion_adjustment = _how_many_are_smaller($relative_mismatch_position_on_reference, \@deletion_positions);
		my $insertion_adjustment = _how_many_are_smaller($relative_mismatch_position_on_reference, \@insertion_positions);
		
		my $mismatch_position_on_query = $relative_mismatch_position_on_reference - $deletion_adjustment + $insertion_adjustment;
		
		if ($self->strand == -1) {
			$mismatch_position_on_query = ($self->query_length - 1) - $mismatch_position_on_query;
		}
		
		push @mismatch_positions, $mismatch_position_on_query;
	}
	
	return @mismatch_positions;
}


#######################################################################
#######################   Private Subroutines  ########################
#######################################################################
sub _how_many_are_smaller {
	my ($value, $array) = @_;
	
	my $count = 0;
	foreach my $array_value (@$array) {
		if ($array_value < $value) {
			$count++;
		}
	}
	return $count;
}

1;
