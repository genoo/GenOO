# POD documentation - main docs before the code

=head1 NAME

GenOO::Spliceable - Role for a region that can be spliced

=head1 SYNOPSIS

    # This role provides regions with the splicing attributes and methods
    
=head1 DESCRIPTION

    An object that consumes this role gets splicing attributes and methods such as exons and
    introns. The key attributes of this class are "splice_starts" and "splice_stops"
    which are sorted arrays of coordinates that define the intervals for exons.
    
    -------------EXON_1-----------            ------------EXON_2------------
    SPLICE_START_1...SPLICE_STOP_1...INTRON...SPLICE_START_2...SPLICE_STOP_2...INTRON...

=head1 EXAMPLES

    # Get the location information on the reference sequence
    $obj_with_role->exons;
    $obj_with_role->introns;
    
    # Check if a position is within an exon or an intron
    $obj_with_role->is_position_within_exon(120);    # 1/0
    $obj_with_role->is_position_within_intron(120);  # 0/1
    
    # Get the length of the exonic region
    $obj_with_role->exonic_length;

=cut

# Let the code begin...

package GenOO::Spliceable;

use Moose::Role;
use Moose::Util::TypeConstraints;
use namespace::autoclean;

use GenOO::Exon;
use GenOO::Intron;
use GenOO::Junction;

# Define new data type
subtype 'SortedArrayRef', as 'ArrayRef', where { _sorted_array() };

# Define coercions to new data type
coerce 'SortedArrayRef', from 'ArrayRef', via { [sort {$a <=> $b} @{$_}] };
coerce 'SortedArrayRef', from 'Str'     , via { [sort {$a <=> $b} (split(/\D+/,$_))] };

# Define attributes
has 'splice_starts' => (
	isa      => 'SortedArrayRef',
	is       => 'ro',
	writer   => '_set_splice_starts',
	required => 1,
	coerce   => 1
);

has 'splice_stops' => (
	isa      => 'SortedArrayRef',
	is       => 'ro',
	writer   => '_set_splice_stops',
	required => 1,
	coerce   => 1
);

has 'exons' => (
	isa       => 'ArrayRef',
	is        => 'ro',
	builder   => '_create_exons',
	init_arg  => undef,
	lazy      => 1,
);

has 'introns' => (
	isa       => 'ArrayRef',
	is        => 'ro',
	builder   => '_create_introns',
	init_arg  => undef,
	lazy      => 1,
);

# Define consumed roles
with 'GenOO::Region';


sub BUILD {
	my $self = shift;
	
	$self->_sanitize_splice_starts_and_stops;
}

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub is_position_within_exon {
	my ($self, $position) = @_;
	
	my $exons = $self->exons;
	foreach my $exon (@$exons) {
		if ($exon->contains_position($position)) {
			return 1;
		}
	}
	return 0;
}

sub is_position_within_intron {
	my ($self, $position) = @_;
	
	my $introns = $self->introns;
	foreach my $intron (@$introns) {
		if ($intron->contains_position($position)) {
			return 1;
		}
	}
	return 0;
}

sub exon_exon_junctions {
	my ($self) = @_;
	
	my @junctions;
	my @junction_starts;
	my @junction_stops;
	
	my $exons = $self->exons;
	if (@$exons > 1) {
		for (my $i=0;$i<@$exons-1;$i++) {
			push @junction_starts, $$exons[$i]->stop;
			push @junction_stops, $$exons[$i+1]->start;
		}
	}
	
	my $junctions_count = @junction_starts == @junction_stops ? @junction_starts : die "Junctions starts are not of the same size as junction stops\n";
	for (my $i=0;$i<$junctions_count;$i++) {
		push @junctions, GenOO::Junction->new(
			species      => $self->species,
			strand       => $self->strand,
			chromosome   => $self->chromosome,
			start        => $junction_starts[$i],
			stop         => $junction_stops[$i],
			part_of      => $self,
		);
	}
	return \@junctions;
}

sub exonic_sequence {
	my ($self) = @_;
	
	if (defined $self->sequence) {
		my $exonic_sequence = '';
		
		my $seq = $self->strand == 1 ? $self->sequence : reverse($self->sequence);
		foreach my $exon (@{$self->exons}) {
			$exonic_sequence .= substr($seq, ($exon->start - $self->start), $exon->length);
		}
		
		if ($self->strand == 1) {
			return $exonic_sequence;
		}
		else {
			return reverse($exonic_sequence);
		}
	}
}

sub exonic_length {
	my ($self) = @_;
	
	my $length = 0;
	foreach my $exon (@{$self->exons}) {
		$length += $exon->length;
	}
	
	return $length;
}

sub intronic_length {
	my ($self) = @_;
	
	my $length = 0;
	foreach my $intron (@{$self->introns}) {
		$length += $intron->length;
	}
	
	return $length;
}

sub relative_exonic_position {
	my ($self, $abs_pos) = @_;
	
	if ($self->is_position_within_exon($abs_pos)) {
		my $relative_pos = $abs_pos - $self->start;
		foreach my $intron (@{$self->introns}) {
			if ($intron->stop < $abs_pos) {
				$relative_pos -= $intron->length;
			}
			else {
				last;
			}
		}
		return $relative_pos;
	}
	else {
		return undef;
	}
}

sub set_splice_starts_and_stops {
	my ($self, $splice_starts, $splice_stops) = @_;
	
	$self->_set_splice_starts($splice_starts);
	$self->_set_splice_stops($splice_stops);
	$self->_sanitize_splice_starts_and_stops;
}

#######################################################################
#######################   Private Methods  ############################
#######################################################################
sub _create_exons {
	my ($self) = @_;
	
	my $exon_starts = $self->splice_starts;
	my $exon_stops = $self->splice_stops;
	
	my @exons;
	for (my $i=0;$i<@{$exon_starts};$i++) {
		push @exons, GenOO::Exon->new({
			strand     => $self->strand,
			chromosome => $self->rname,
			start      => $$exon_starts[$i],
			stop       => $$exon_stops[$i],
			part_of    => $self
		});
	}
	
	return \@exons;
}

sub _create_introns {
	my ($self) = @_;
	
	my $exon_starts = $self->splice_starts;
	my $exon_stops = $self->splice_stops;
	
	my @introns;
	
	if ($self->start < $$exon_starts[0]) {
		push @introns, GenOO::Intron->new({
			strand     => $self->strand,
			chromosome => $self->rname,
			start      => $self->start,
			stop       => $$exon_starts[0] - 1,
			part_of    => $self,
		});
	}
	
	for (my $i=1;$i<@{$exon_starts};$i++) {
		push @introns, (GenOO::Intron->new({
			strand     => $self->strand,
			chromosome => $self->rname,
			start      => ${$exon_stops}[$i-1] + 1,
			stop       => ${$exon_starts}[$i] - 1,
			part_of    => $self,
		}));
	}
	
	if ($self->stop > $$exon_stops[-1]) {
		push @introns, (GenOO::Intron->new({
			strand     => $self->strand,
			chromosome => $self->rname,
			start      => $$exon_stops[-1] + 1,
			stop       => $self->stop,
			part_of    => $self,
		}));
	}
	
	return \@introns;
}

sub _sanitize_splice_starts_and_stops {
	my ($self) = @_;
	
	my $splice_starts = $self->splice_starts;
	my $splice_stops = $self->splice_stops;
	
	if (@$splice_starts != @$splice_stops) {
		die "Error: Spice starts array is not of the same size as splice_stops (".scalar @$splice_starts."!=".scalar @$splice_stops.")\n";
	}
	
	my $index = 0;
	while ($index < (@$splice_starts-1)) {
		if ($$splice_stops[$index] == $$splice_starts[$index+1] - 1) {
			$$splice_stops[$index] = $$splice_stops[$index+1];
			splice @$splice_starts, $index+1, 1;
			splice @$splice_stops, $index+1, 1;
		}
		else {
			$index++;
		}
	}
}

#######################################################################
#######################   Private Routines  ###########################
#######################################################################
sub _sanitize_splice_coords_within_limits {
	my ($pre_splice_starts, $pre_splice_stops, $start, $stop) = @_;
	
	my @splice_starts;
	my @splice_stops;
	for (my $i=0;$i<@$pre_splice_starts;$i++) {
		if ($$pre_splice_stops[$i] < $start) {
			next;
		}
		elsif ($$pre_splice_starts[$i] > $stop) {
			next;
		}
		else { #if the exon overlaps or is contained in the UTR5
			if ($start >= $$pre_splice_starts[$i]) {
				push @splice_starts, $start;
			}
			else {
				push @splice_starts, $$pre_splice_starts[$i];
			}
			if ($stop < $$pre_splice_stops[$i]) {
				push @splice_stops, $stop;
			}
			else {
				push @splice_stops, $$pre_splice_stops[$i];
			}
		}
	}
	return \@splice_starts, \@splice_stops;
}

sub _sorted_array {
	my $arrayref = $_;
	
	if (@{$arrayref} > 1){
		for (my $i = 1; $i < @{$arrayref}; $i++){
			if ($$arrayref[$i] < $$arrayref[$i-1]){
				return 0;
			}
		}
		return 1;
	}
	return 1;
}

1;