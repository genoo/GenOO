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

package GenOO::Region;
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
	
	return undef if !defined $self->strand;
	
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

sub mid_position {
	my ($self) = @_;
	
	return ($self->start + $self->stop)/2;
}

sub mid_mid_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->mid_position - $from_locus->mid_position) * $self->strand;
}

sub mid_head_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->mid_position - $from_locus->head_position) * $self->strand;
}

sub mid_tail_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->mid_position - $from_locus->tail_position) * $self->strand;
}

sub head_mid_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->head_position - $from_locus->mid_position) * $self->strand;
}

sub head_head_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->head_position - $from_locus->head_position) * $self->strand;
}

sub head_tail_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->head_position - $from_locus->tail_position) * $self->strand;
}

sub tail_mid_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->tail_position - $from_locus->mid_position) * $self->strand;
}

sub tail_head_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->tail_position - $from_locus->head_position) * $self->strand;
}

sub tail_tail_distance_from {
	my ($self, $from_locus) = @_;
	
	die join(' ', 'Comparing relative position for regions on different reference (rname)',$self->rname,'ne',$from_locus->rname)."\n" if ($self->rname ne $from_locus->rname);
	return ($self->tail_position - $from_locus->tail_position) * $self->strand;
}

sub to_string {
	my ($self, $params) = @_;
	
	return $self->location;
}

sub overlaps_with_offset {
	my ($self, $region2, $use_strand, $offset) = @_;
	
	$offset //= 0;
	$use_strand //= 1;
	
	if (($use_strand == 0 or $self->strand == $region2->strand) and ($self->rname eq $region2->rname) and (($self->start-$offset) <= $region2->stop) and ($region2->start <= ($self->stop+$offset))) {
		return 1; #overlap
	}
	else {
		return 0; #no overlap
	}
}

sub overlaps {
	my ($self, $region2, $use_strand) = @_;
	
	$use_strand //= 1;
	
	if (($use_strand == 0 or $self->strand == $region2->strand) and ($self->rname eq $region2->rname) and ($self->start <= $region2->stop) and ($region2->start <= $self->stop)) {
		return 1; #overlap
	}
	else {
		return 0; #no overlap
	}
}

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
	my ($self, $region2, $use_strand) = @_;
	
	$use_strand //= 1;
	
	if (($use_strand == 0 or $self->strand == $region2->strand) and ($self->rname eq $region2->rname) and ($self->start <= $region2->start) and ($region2->stop <= $self->stop)) {
		return 1;
	}
	else {
		return 0;
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
