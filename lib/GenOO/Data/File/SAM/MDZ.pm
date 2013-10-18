# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::SAM::MDZ - Role - The MD:Z tag in a SAM file

=head1 SYNOPSIS

    This role when consumed requires specific attributes and provides
    methods to extract information from the MD:Z tag.

=head1 DESCRIPTION

    The cigar string does not usually contain information regarding the deletions.
    For this the MD:Z tag is usually provided. 
    
    MD:Z -> String for mismatching positions. Regex: [0-9]+(([A-Z]|\^[A-Z]+)[0-9]+)
    
    The MD field aims to achieve SNP/indel calling without looking at the reference.
    For example, a string `10A5^AC6' means from the leftmost reference base in the
    alignment, there are 10 matches followed by an A on the reference which is 
    different from the aligned read base; the next 5 reference bases are matches
    followed by a 2bp deletion from the reference; the deleted sequence is AC;
    the last 6 bases are matches. The MD field ought to match the CIGAR string.

=head1 EXAMPLES

    # Get the location information on the reference sequence
    $obj_with_role->mismatch_positions_on_reference_calculated_from_mdz; # (534515, 534529, ...)

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
sub mismatch_positions_on_reference_calculated_from_mdz {
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
