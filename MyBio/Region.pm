# POD documentation - main docs before the code

=head1 NAME

MyBio::Region - Role that represents a region on a reference sequence

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

package MyBio::Region;
use Moose::Role;

requires qw(strand rname start stop copy_number);

has 'length' => (
	is        => 'ro',
	builder   => '_calculate_length',
	init_arg  => undef,
	lazy      => 1,
);

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub location {
	my ($self) = @_;
	
	return $self->rname . ':' . $self->start . '-' . $self->stop . ':' . $self->strand;
}

sub strand_symbol {
	my ($self) = @_;
	
	if ($self->strand == 1) {
		return '+';
	}
	elsif ($self->strand == -1) {
		return '-';
	}
	return undef;
}

sub head_position {
	my ($self) = @_;
	
	if ($self->strand == 1) {
		return $self->start;
	}
	elsif ($self->strand == -1) {
		return $self->stop;
	}
	else {
		return undef;
	}
}

sub tail_position {
	my ($self) = @_;
	
	if ($self->strand == 1) {
		return $self->stop;
	}
	elsif ($self->strand == -1) {
		return $self->start;
	}
	else {
		return undef;
	}
}

sub head_head_distance_from {
	my ($self, $from_locus) = @_;
	
	return ($self->head_position - $from_locus->head_position) * $self->strand;
}

sub head_tail_distance_from {
	my ($self, $from_locus) = @_;
	
	return ($self->head_position - $from_locus->tail_position) * $self->strand;
}

sub tail_head_distance_from {
	my ($self, $from_locus) = @_;
	
	return ($self->tail_position - $from_locus->head_position) * $self->strand;
}

sub tail_tail_distance_from {
	my ($self, $from_locus) = @_;
	
	return ($self->tail_position - $from_locus->tail_position) * $self->strand;
}

sub to_string {
	my ($self, $params) = @_;
	
	my $method = delete $params->{'METHOD'};
	if ($method eq 'BED') {
		warn 'Deprecated call of "to_string" in '.
		     (caller)[1].' line '.(caller)[2].'. '.
		     'Classes implementing the role should '.
		     'provide their own "to_string" method for advanced calls';
		return $self->_to_string_bed;
	}
	else {
		return $self->location;
	}
}

sub overlaps {
	my ($self,$region2,$params) = @_;
	
	if ((!defined $params) or (UNIVERSAL::isa( $params, "HASH" ))){
		my $offset = defined $params->{OFFSET} ? $params->{OFFSET} : 0;
		my $use_strand = defined $params->{USE_STRAND} ? $params->{USE_STRAND} : 0;
		
		if ((($use_strand == 0) or ($self->strand eq $region2->strand)) and ($self->rname eq $region2->rname) and (($self->start-$offset) <= $region2->stop) and ($region2->start <= ($self->stop+$offset))) {
			return 1; #overlap
		}
		else {
			return 0; #no overlap
		}
	}
	else {
		die "\n\nUnknown or no method provided when calling ".(caller(0))[3]." in script $0\n\n";
	}
}

=head2 get_overlap_length
  Arg [1]    : locus. Locus object self is compared to.
  Description: Return the number of nucleotides of self that are covered by provided locus
  Returntype : int
=cut
sub overlap_length {
	my ($self, $region2) = @_;
	
	if ($self->overlaps($region2)) {
		my $max_start = $self->start > $region2->start ? $self->start : $region2->start;
		my $min_stop = $self->stop < $region2->stop ? $self->stop : $region2->stop;
		return $min_stop - $max_start + 1 ;
	}
	else {
		return 0;
	}
}

sub contains {
	my ($self,$region2,$params) = @_;
	
	if (!defined $params or UNIVERSAL::isa($params, 'HASH')) {
		my $percent = defined $params->{PERCENT} ? $params->{PERCENT} : 1;
		my $overhang = 0;
		my $left_overhang = ($self->start - $region2->start);
		my $right_overhang = ($region2->stop - $self->stop);
		if ($left_overhang > 0) {
			$overhang += $left_overhang;
		}
		if ($right_overhang > 0) {
			$overhang += $right_overhang;
		}
		if (($overhang / $region2->length) <= (1-$percent)) {
			return 1;
		}
		return 0;
	}
	else {
		die "\n\nUnknown or no method provided when calling ".(caller(0))[3]." in script $0\n\n";
	}
}

sub contains_position {
	my ($self, $position) = @_;
	
	if (($self->start <= $position) and ($position <= $self->stop)) {
		return 1;
	}
	else {
		return 0;
	}
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _calculate_length {
	my ($self) = @_;
	
	return $self->stop - $self->start + 1;
}

sub _to_string_bed {
	my ($self) = @_;
	
	my $strand_symbol = $self->strand_symbol || '.';
	my $name = $self->name || '.';
	my $score = $self->copy_number || 1;
	
	return $self->rname."\t".$self->start."\t".($self->stop+1)."\t".$name."\t".$score."\t".$strand_symbol;
}

1;
