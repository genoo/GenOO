# POD documentation - main docs before the code

=head1 NAME

GenOO::Region - Role that represents a region on a reference sequence

=head1 SYNOPSIS

    This role when consumed requires specific attributes and provides
    methods that correspond to a region on a reference sequence.

=head1 DESCRIPTION

    A region object is an area on another reference sequence. It has a
    specific start and stop position on the reference and a specific 
    direction (strand). It has methods that combine the direction with
    the positional information a give positions for the head or the tail
    of the region. It also offers methods that calculate distances or
    overlaps with other object that also consume the role.

=head1 EXAMPLES

    # Get the location information on the reference sequence
    $obj_with_role->start;   # 10
    $obj_with_role->stop;    # 20
    $obj_with_role->strand;  # -1
    
    # Get the head position on the reference sequence
    $obj_with_role->head_position;  # 20

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
sub mismatch_positions_on_query {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my $cigar = $self->cigar;
	
	# Find positions of insertions and deletions (dashes) on the query sequence
	my @deletion_positions;
	my @insertion_positions;
	my $position = 0;
	while ($cigar =~ /(\d+)([A-Z])/g) {
		my $count = $1;
		my $identifier = $2;
		
		if ($identifier eq 'D') {
			push (@deletion_positions, $position + $_) for (0..$count-1)
		}
		elsif ($identifier eq 'I') {
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
