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

package GenOO::Data::File::SAM::MDZ;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Moose::Role;
use namespace::autoclean;


#######################################################################
########################   Required attributes   ######################
#######################################################################
requires qw(mdz start);


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub deletion_positions_on_reference {
	my ($self) = @_;
	#Tag:    AGTGATGGGA------GGATGTCTCGTCTGTGAGTTACAGCA -> CIGAR: 2M1I7M6D26M
	#            -   -
	#Genome: AG-GCTGGTAGCTCAGGGATGTCTCGTCTGTGAGTTACAGCA -> MD:Z:  3C3T1^GCTCAG26
	
	my @deletion_positions;
	my $mdz = $self->mdz;
	
	if ($mdz =~ /\^/) {
		my $relative_position = 0;
		while ($mdz ne '') {
			if ($mdz =~ s/^(\d+)//) {
				$relative_position += $1;
			}
			elsif ($mdz =~ s/^\^([A-Z]+)//) {
				my $deletion_length = CORE::length($1);
				for (my $i=0;$i<$deletion_length;$i++) {
					push @deletion_positions, $self->start + $relative_position + $i;
				}
				$relative_position += $deletion_length;
			}
			elsif ($mdz =~ s/^\w//) {
				$relative_position += 1;
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

	my @mismatch_positions;
	my $mdz = $self->mdz;
	
	if ($mdz =~ /\w/) {
		my $relative_position = 0;
		while ($mdz ne '') {
			if ($mdz =~ s/^(\d+)//) {
				$relative_position += $1;
			}
			elsif ($mdz =~ s/^\^([A-Z]+)//) {
				my $deletion_length = CORE::length($1);
				$relative_position += $deletion_length;
			}
			elsif ($mdz =~ s/^\w//) {
				push @mismatch_positions, $self->start + $relative_position;
				$relative_position += 1;
			}
		}
	}
	
	return @mismatch_positions;
}

1;
