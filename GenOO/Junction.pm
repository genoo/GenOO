# POD documentation - main docs before the code

=head1 NAME

GenOO::Junction - A junction object with features

=head1 SYNOPSIS

    # This is the main region object.
    # Represents a spliced region with introns and exons
    
    # To initialize 
    my $junction = GenOO::Junction->new({
        SPECIES      => undef,
        STRAND       => undef,
        CHR          => undef,
        START        => undef,
        STOP         => undef,
        NAME         => undef,
    });

=head1 DESCRIPTION

    The GenOO::Junction class descibes a genomic junction.

=head1 EXAMPLES

    Not provided yet

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package GenOO::Junction;

use strict;

use base qw( GenOO::_Initializable );

sub _init {
	my ($self,$data) = @_;
	
	$self->set_species($$data{SPECIES});
	$self->set_strand($$data{STRAND});
	$self->set_chr($$data{CHR});
	$self->set_start($$data{START});
	$self->set_stop($$data{STOP});
	$self->set_name($$data{NAME});
	$self->set_slice($$data{SLICE});
	$self->set_extra($$data{EXTRA_INFO});
	
	return $self;
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_species {
	return $_[0]->{SPECIES};
}
sub get_strand {
	return $_[0]->{STRAND};
}
sub get_chr {
	return $_[0]->{CHR};
}
sub get_start {
	return $_[0]->{START};
}
sub get_stop {
	return $_[0]->{STOP};
}
sub get_name {
	return $_[0]->{NAME};
}
sub get_slice {
	return $_[0]->{SLICE};
}
sub get_extra {
	return $_[0]->{EXTRA_INFO};
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_species {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{SPECIES} = uc($value);
	}
}
sub set_strand {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/^\+$/1/;
		$value =~ s/^\-$/-1/;
		$self->{STRAND} = $value;
	}
}
sub set_chr {
	my ($self,$value) = @_;
	if (defined $value) {
		$value =~ s/>*chr//;
		$self->{CHR} = $value;
	}
}
sub set_start {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{START} = $value;
	}
}
sub set_stop {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{STOP} = $value;
	}
}
sub set_name {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{NAME} = $value;
	}
}
sub set_slice {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{SLICE} = $value;
	}
}
sub set_extra {
	my ($self,$value) = @_;
	if (defined $value) {
		$self->{EXTRA_INFO} = $value;
	}
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub get_strand_symbol {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return '+';
	}
	elsif ($self->get_strand == -1) {
		return '-';
	}
	else {
		return undef;
	}
}

sub get_5p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_start;
	}
	else {
		return $self->get_stop;
	}
}

sub get_3p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_stop;
	}
	else {
		return $self->get_start;
	}
}

sub get_location {
	my ($self) = @_;
	return $self->get_chr.":".$self->get_start."-".$self->get_stop.":".$self->get_strand;
}

sub to_string {
	my ($self,$method,@attributes) = @_;
	
	if ($method eq "BED") {
		return $self->to_bed;
	}
	else {
		return $self->get_location;
	}
}

sub to_bed {
	my ($self) = @_;
	
	my $strand = defined $self->get_strand_symbol ? $self->get_strand_symbol : '.';
	my $name = defined $self->get_name ? $self->get_name : ".";
	
	return join("\t",(
		'chr'.$self->get_chr,
		$self->get_start,
		$self->get_stop + 1,
		$name,
		0,
		$strand
	));
}

sub get_5p_5p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_5p - $from_locus->get_5p) * $self->get_strand;
}

sub get_5p_3p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_5p - $from_locus->get_3p) * $self->get_strand;
}

sub get_3p_5p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_3p - $from_locus->get_5p) * $self->get_strand;
}

sub get_3p_3p_distance_from {
	my ($self,$from_locus) = @_;
	return ($self->get_3p - $from_locus->get_3p) * $self->get_strand;
}

sub get_spliced_start_relative_to_slice {
	my ($self) = @_;
	
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_5p;
	}
	else {
		return $self->get_slice->get_exonic_length - $self->get_spliced_relative_5p - 1;
	}
}

sub get_spliced_stop_relative_to_slice {
	my ($self) = @_;
	
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_3p;
	}
	else {
		return $self->get_slice->get_exonic_length - $self->get_spliced_relative_3p - 1;
	}
}

sub get_spliced_relative_5p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_start;
	}
	else {
		return $self->get_spliced_relative_stop;
	}
}

sub get_spliced_relative_3p {
	my ($self) = @_;
	if ($self->get_strand == 1) {
		return $self->get_spliced_relative_stop;
	}
	else {
		return $self->get_spliced_relative_start;
	}
}

sub get_spliced_relative_start {
	my ($self) = @_;
	return $self->to_spliced_relative($self->get_start);
}

sub get_spliced_relative_stop {
	my ($self) = @_;
	return $self->to_spliced_relative($self->get_stop);
}

sub to_spliced_relative {
	my ($self, $abs_pos) = @_;
	
	if (defined $self->get_slice and $self->get_slice->is_position_within_exon($abs_pos)) {
		my $relative_pos = $abs_pos - $self->get_slice->get_start;
		my $introns = $self->get_slice->get_introns;
		foreach my $intron (@$introns) {
			if ($intron->get_stop < $abs_pos) {
				$relative_pos -= $intron->get_length;
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
