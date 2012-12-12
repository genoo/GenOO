# POD documentation - main docs before the code

=head1 NAME

GenOO::Transcript - Corresponds to a gene transcript

=head1 SYNOPSIS

    # The class represents a transcript of a gene.
    # It extends the L<GenOO::GenomicRegion> class
    
    # Instantiate 
    my $transcript = GenOO::Transcript->new(
        name          => undef,
        species       => undef,
        strand        => undef,    #required
        chromosome    => undef,    #required
        start         => undef,    #required
        stop          => undef,    #required
        copy_number   => undef,    #defaults to 1
        sequence      => undef,
        splice_starts => undef,    #required
        splice_stops  => undef,    #required
        id            => undef,    #required
        gene          => undef,    #GenOO::Gene
        utr5          => undef,    #GenOO::Transcript::UTR5
        cds           => undef,    #GenOO::Transcript::CDS
        utr3          => undef,    #GenOO::Transcript::UTR3
        biotype       => undef,
    );

=head1 DESCRIPTION

    The Transcript class describes a transcript of a gene. It can have a backreference
    to the gene in which it belongs. Protein coding transcripts have functional regions
    such as 5'UTR, CDS and 3'UTR. The transcript class extends the L<GenOO::GenomicRegion>
    and implements the L<GenOO::Spliceable> role.

=head1 EXAMPLES

    # Get the exons of the transcript
    $transcript->exons
    
    # Get the introns of the transcript
    $transcript->introns
    
    # Check if the transcript codes for a protein
    $transcript->is_coding # 0 / 1
    $transcript->cds       # undef / GenOO::Transcript::CDS

=cut

# Let the code begin...

package GenOO::Transcript;

use Moose;
use namespace::autoclean;

use GenOO::Transcript::UTR5;
use GenOO::Transcript::CDS;
use GenOO::Transcript::UTR3;

extends 'GenOO::GenomicRegion';

has 'id' => (
	is       => 'rw',
	required => 1
);

has 'coding_start' => (
	isa => 'Int',
	is  => 'rw'
);

has 'coding_stop' => (
	isa => 'Int',
	is  => 'rw'
);

has 'biotype' => (
	isa       => 'Str',
	is        => 'rw',
	builder   => '_find_biotype',
	lazy      => 1,
);

has 'gene' => (
	isa       => 'GenOO::Gene',
	is        => 'rw',
	weak_ref  => 1
);

has 'utr5' => (
	isa       => 'GenOO::Transcript::UTR5',
	is        => 'rw',
	builder   => '_find_or_create_utr5',
	lazy      => 1
);

has 'cds' => (
	isa       => 'GenOO::Transcript::CDS',
	is        => 'rw',
	builder   => '_find_or_create_cds',
	lazy      => 1
);

has 'utr3' => (
	isa       => 'GenOO::Transcript::UTR3',
	is        => 'rw',
	builder   => '_find_or_create_utr3',
	lazy      => 1
);

with 'GenOO::Spliceable';

#######################################################################
#############################   Methods   #############################
#######################################################################
sub exons_split_by_function {
	my ($self) = @_;
	
	if ($self->is_coding) {
		my @exons;
		if (defined $self->utr5) {
			push @exons,@{$self->utr5->exons};
		}
		if (defined $self->cds) {
			push @exons,@{$self->cds->exons};
		}
		if (defined $self->utr3) {
			push @exons,@{$self->utr3->exons};
		}
		return \@exons;
	}
	else {
		return $self->exons;
	} 
}

sub is_coding {
	my ($self) = @_;
	
	if ($self->biotype eq 'coding') {
		return 1;
	}
	else {
		return 0;
	}
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _find_or_create_utr5 {
	my ($self) = @_;
	
	if (defined $self->coding_start and defined $self->coding_stop) {
		my $utr5_start = ($self->strand == 1) ? $self->start : $self->coding_stop + 1;
		my $utr5_stop = ($self->strand == 1) ? $self->coding_start - 1 : $self->stop;
		
		my ($splice_starts, $splice_stops) = _sanitize_splice_coords_within_limits(
			$self->splice_starts,
			$self->splice_stops,
			$utr5_start,
			$utr5_stop
		);
		
		return GenOO::Transcript::UTR5->new({
			strand        => $self->strand,
			chromosome    => $self->chromosome,
			start         => $utr5_start,
			stop          => $utr5_stop,
			splice_starts => $splice_starts,
			splice_stops  => $splice_stops,
			transcript    => $self
		});
	}
}

sub _find_or_create_cds {
	my ($self) = @_;
	
	if (defined $self->coding_start and defined $self->coding_stop) {
		my ($splice_starts, $splice_stops) = _sanitize_splice_coords_within_limits(
			$self->splice_starts,
			$self->splice_stops,
			$self->coding_start,
			$self->coding_stop
		);
		
		return GenOO::Transcript::CDS->new({
			strand        => $self->strand,
			chromosome    => $self->chromosome,
			start         => $self->coding_start,
			stop          => $self->coding_stop,
			splice_starts => $splice_starts,
			splice_stops  => $splice_stops,
			transcript    => $self
		});
	}
}

sub _find_or_create_utr3 {
	my ($self) = @_;
	
	if (defined $self->coding_start and defined $self->coding_stop) {
		my $utr3_start = ($self->strand == 1) ? $self->coding_stop + 1 : $self->start;
		my $utr3_stop = ($self->strand == 1) ? $self->stop : $self->coding_start - 1;
		
		my ($splice_starts, $splice_stops) = _sanitize_splice_coords_within_limits(
			$self->splice_starts,
			$self->splice_stops,
			$utr3_start,
			$utr3_stop
		);
		
		return GenOO::Transcript::UTR3->new({
			strand        => $self->strand,
			chromosome    => $self->chromosome,
			start         => $utr3_start,
			stop          => $utr3_stop,
			splice_starts => $splice_starts,
			splice_stops  => $splice_stops,
			transcript    => $self
		});
	}
}

sub _find_biotype {
	my ($self) = @_;
	
	if (defined $self->coding_start) {
		return 'coding';
	}
}

__PACKAGE__->meta->make_immutable;

1;
