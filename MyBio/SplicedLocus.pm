# POD documentation - main docs before the code

=head1 NAME

MyBio::SplicedLocus - A region consisting of spicing elements

=head1 SYNOPSIS

    # This is the main region object.
    # Represents a spliced region with introns and exons
   
    # To initialize 
    my $region = MyBio::SplicedLocus->new({
        SPECIES      => undef,
        STRAND       => undef,
        CHR          => undef,
        START        => undef,
        STOP         => undef,
        SEQUENCE     => undef,
        SPLICE_STARTS    => undef,
        SPLICE_STOPS     => undef,
    });

=head1 DESCRIPTION

    The SplicedLocus class describes a genomic region where Introns and Exons are defined.
    The main difference from the Locus class is the attributes SPLICE_STARTS and SPLICE_STOPS
    which enable the class to define genomic intervals within the SPLICE_STARTS and SPLICE_STOPS
    which are called Exons and the complement regions which are called Introns
    
    Graphically:
    LocusStart ..(INTRON_1).. SPLICE_START_1 ..(EXON_1)..SPLICE_STOP_1 ..(INTRON_2)..SPLICE_START_2 ..(EXON_2)..SPLICE_STOP_2..Locus_stop

=head1 EXAMPLES

    Not provided yet

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package MyBio::SplicedLocus;

use strict;

use MyBio::Transcript::Exon;
use MyBio::Transcript::Intron;
use MyBio::Junction;

our $VERSION = '1.0';

use base qw(MyBio::Locus);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	$self->set_splice_starts($$data{SPLICE_STARTS});  # [] reference to array of splice starts
	$self->set_splice_stops($$data{SPLICE_STOPS});  # [] reference to array of splice stops
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_splice_starts {
	if (defined $_[1]) {
		return ${$_[0]->{SPLICE_STARTS}}[$_[1]];
	}
	elsif (defined $_[0]->{SPLICE_STARTS}) {
		return $_[0]->{SPLICE_STARTS}; # return the reference to the array with the splice starts
	}
	else {
		[];
	}
}
sub get_splice_stops {
	if (defined $_[1]) {
		return ${$_[0]->{SPLICE_STOPS}}[$_[1]];
	}
	elsif (defined $_[0]->{SPLICE_STOPS}) {
		return $_[0]->{SPLICE_STOPS}; # return the reference to the array with the splice stops
	}
	else {
		[];
	}
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_splice_starts {
	my ($self,$value) = @_;
	if (defined $value) {
		if (ref($value) eq '') {
			$self->{SPLICE_STARTS} = [sort {$a <=> $b} (split(/\D+/,$value))];
		}
		else {
			$self->{SPLICE_STARTS} = [sort {$a <=> $b} @$value];
		}
	}
}
sub set_splice_stops {
	my ($self,$value) = @_;
	if (defined $value) {
		if (ref($value) eq '') {
			$self->{SPLICE_STOPS} = [sort {$a <=> $b} (split(/\D+/,$value))];
		}
		else {
			$self->{SPLICE_STOPS} = [sort {$a <=> $b} @$value];
		}
	}
}

#######################################################################
#############################   Methods   #############################
#######################################################################
sub is_position_within_exon {
	my ($self, $position) = @_;
	
	my $exons = $self->get_exons();
	foreach my $exon (@$exons) {
		if ($exon->contains_position($position)) {
			return 1;
		}
	}
}

sub is_position_within_intron {
	my ($self, $position) = @_;
	
	my $introns = $self->get_introns();
	foreach my $intron (@$introns) {
		if ($intron->contains_position($position)) {
			return 1;
		}
	}
}

sub get_exon_exon_junctions {
	my ($self) = @_;
	
	my @junctions;
	my @junction_starts;
	my @junction_stops;
	
	my $exons = $self->get_exons();
	if (@$exons > 1) {
		for (my $i=0;$i<@$exons-1;$i++) {
			push @junction_starts, $$exons[$i]->stop;
			push @junction_stops, $$exons[$i+1]->start;
		}
	}
	
	my $junctions_count = @junction_starts == @junction_stops ? @junction_starts : die "Junctions starts are not of the same size as junction stops\n";
	for (my $i=0;$i<$junctions_count;$i++) {
		push @junctions, MyBio::Junction->new({
			SPECIES      => $self->species,
			STRAND       => $self->strand,
			CHR          => $self->chr,
			START        => $junction_starts[$i],
			STOP         => $junction_stops[$i],
			SLICE        => $self,
		});
	}
	return @junctions;
}

sub get_exonic_sequence {
	my ($self) = @_;
	
	my $exonic_sequence = '';
	my $locus_seq = $self->strand == 1 ? $self->sequence : reverse($self->sequence);
	if (defined $locus_seq) {
		foreach my $exon (@{$self->get_exons}) {
			$exonic_sequence .= substr($locus_seq,($exon->start - $self->start),$exon->length);
		}
	}
	
	if ($self->strand == 1) {
		return $exonic_sequence;
	}
	else {
		return reverse($exonic_sequence);
	}
}

sub get_exons {
	my ($self,$value) = @_;
	if (!defined $self->{EXONS}) {
		$self->set_exons(); # try to set the exons first
	}
	
	if (defined $value) {
		if (defined $self->{EXONS}) {
			return ${$self->{EXONS}}[$value];
		}
		else {
			return undef;
		}
	}
	elsif (defined $self->{EXONS}) {
		return $self->{EXONS};
	}
	else {
		return [];
	}
}

sub set_exons {
	my ($self,$value) = @_;
	
	if (defined $value) {
		$self->{EXONS} = [sort {$a->start <=> $b->start} @$value];
		return 0;
	}
	elsif (@{$self->get_splice_starts} > 0 and @{$self->get_splice_stops} > 0) {
		$self->_set_exons_from_splicing();
		return 0;
	}
	else {
		return 1;
	}
}

sub get_introns {
	my ($self,$value) = @_;
	if (!defined $self->{INTRONS}) {
		$self->set_introns(); # try to set the introns
	}
	
	if (defined $value) {
		if (defined $self->{INTRONS}) {
			return ${$self->{INTRONS}}[$value];
		}
		else {
			return undef;
		}
	}
	elsif (defined $self->{INTRONS}) {
		return $self->{INTRONS};
	}
	else {
		return [];
	}
}

sub set_introns {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{INTRONS} = [sort {$a->start <=> $b->start} @$value];
		return 0;
	}
	elsif (@{$self->get_splice_starts} > 0 and @{$self->get_splice_stops} > 0) {
		$self->_set_introns_from_splicing();
		return 0;
	}
	else {
		return 1;
	}
}

sub get_intron_exon_junctions {
	my ($self) = @_;
	if (@{$self->get_exons} < 1) {
		return [];
	}
	elsif (!defined $self->start or !defined $self->stop) {
		warn "$self undefined start: $self->start or stop: $self->stop!\n";
		return []; 
	}
	
	my @junctions = ();
	foreach my $exon (@{$self->get_exons}) {
		if ($self->start < $exon->start) {
			push @junctions,MyBio::Locus->new({
				STRAND       => $exon->strand,
				CHR          => $exon->chr,
				START        => $exon->start-1,
				STOP         => $exon->start,
			});
		}
		if ($self->stop > $exon->stop) {
			push @junctions,MyBio::Locus->new({
				STRAND       => $exon->strand,
				CHR          => $exon->chr,
				START        => $exon->stop,
				STOP         => $exon->stop,
			});
		}
	}
	return \@junctions;
}

sub get_exonic_length {
	my ($self) = @_;
	
	my ($length, $starts, $stops) = (0, $self->get_splice_starts, $self->get_splice_stops);
	for (my $i=0; $i<@$starts; $i++)  {
		$length += $$stops[$i] - $$starts[$i] + 1;
	}
	return $length;
}

sub push_splice_start_stop_pair {
	my ($self,$start,$stop) = @_;
	if (defined $start and defined $stop) {
		if ((@{$self->get_splice_starts} == 0) and (@{$self->get_splice_stops} == 0)) {
			$self->set_splice_starts([$start]);
			$self->set_splice_stops([$stop]);
		}
		else {
			my $splice_starts = $self->get_splice_starts;
			my $splice_stops = $self->get_splice_stops;
			if ($stop < $$splice_starts[0]) {
				if ($stop == $$splice_starts[0] - 1) {
					$$splice_starts[0] = $start;
				}
				else {
					unshift @$splice_starts,$start;
					unshift @$splice_stops,$stop;
				}
			}
			else {
				for (my $i=@$splice_stops-1;$i>=0;$i--) {
					if ($start > $$splice_stops[$i]) {
						if ($start == $$splice_stops[$i] + 1) {
							if (defined $$splice_starts[$i+1] and ($stop == $$splice_starts[$i+1] - 1)) {
								$$splice_stops[$i] = $$splice_stops[$i+1];
								splice @$splice_starts, $i+1, 1;
								splice @$splice_stops, $i+1, 1;
							}
							else {
								$$splice_stops[$i] = $stop;
							}
						}
						elsif (defined $$splice_starts[$i+1] and ($stop == $$splice_starts[$i+1] - 1)) {
							$$splice_starts[$i+1] = $start;
						}
						else {
							splice @$splice_starts, $i+1, 0, $start;
							splice @$splice_stops, $i+1, 0, $stop;
						}
						last;
					}
				}
			}
		}
	}
}

sub set_splicing_info {
	my ($self, $pre_splice_starts, $pre_splice_stops, $start, $stop) = @_;
	my @splice_starts;
	my @splice_stops;
	if (!defined $start and !defined $stop) {
		$start = $self->get_start;
		$stop = $self->stop;
	}
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
	$self->set_splice_starts(\@splice_starts);
	$self->set_splice_stops(\@splice_stops);
}

sub _set_exons_from_splicing {
	my ($self) = @_;
# 	warn "Method ".(caller(0))[3]." has not been tested for bugs. Please check and remove warning";
	my $exon_starts = $self->get_splice_starts;
	my $exon_stops = $self->get_splice_stops;
	for (my $i=0;$i<@{$exon_starts};$i++) {
		$self->push_exon(MyBio::Transcript::Exon->new({
			SPECIES    => $self->species,
			STRAND     => $self->strand,
			CHR        => $self->chr,
			START      => $$exon_starts[$i],
			STOP       => $$exon_stops[$i],
			WHERE      => $self,
		}));
	}
}

sub _set_introns_from_splicing {
	my ($self) = @_;
# 	warn "Method ".(caller(0))[3]." has not been tested for bugs. Please check and remove warning";
	my $exon_starts = $self->get_splice_starts;
	my $exon_stops = $self->get_splice_stops;
	if ($self->start < $$exon_starts[0]) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->species,
			STRAND     => $self->strand,
			CHR        => $self->chr,
			START      => $self->start,
			STOP       => $$exon_starts[0] - 1,
			WHERE      => $self,
		}));
	}
	for (my $i=1;$i<@{$exon_starts};$i++) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->species,
			STRAND     => $self->strand,
			CHR        => $self->chr,
			START      => ${$exon_stops}[$i-1] + 1,
			STOP       => ${$exon_starts}[$i] - 1,
			WHERE      => $self,
		}));
	}
	if ($self->stop > $$exon_stops[-1]) {
		$self->push_intron(MyBio::Transcript::Intron->new({
			SPECIES    => $self->species,
			STRAND     => $self->strand,
			CHR        => $self->chr,
			START      => $$exon_stops[-1] + 1,
			STOP       => $self->stop,
			WHERE      => $self,
		}));
	}
}

sub push_exon {
	my ($self, $exon) = @_;
	unless (defined $self->{EXONS}) {
		$self->{EXONS} = [];
	}
	$exon->set_where($self);
	push @{$self->{EXONS}}, $exon;
}

sub push_intron {
	my ($self, $intron) = @_;
	unless (defined $self->{INTRONS}) {
		$self->{INTRONS} = [];
	}
	$intron->set_where($self);
	push @{$self->{INTRONS}}, $intron;
}

sub to_spliced_relative {
	my ($self, $abs_pos) = @_;
	
	if ($self->is_position_within_exon($abs_pos)) {
		my $relative_pos = $abs_pos - $self->start;
		my $introns = $self->get_introns;
		foreach my $intron (@$introns) {
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

1;