# POD documentation - main docs before the code

=head1 NAME

GenOO::Gene - Gene object

=head1 SYNOPSIS

    # This object represents a gene (collection of transcripts)
    # It extends the L<GenOO::GenomicRegion> object
    
    # To initialize 
    my $gene = GenOO::Gene->new(
        name        => undef,    #required
        species     => undef,
        strand      => undef,    #can be inferred from transcripts
        chromosome  => undef,    #can be inferred from transcripts
        start       => undef,    #can be inferred from transcripts
        stop        => undef,    #can be inferred from transcripts
        copy_number => undef,    #defaults to 1
        sequence    => undef,
        description => undef,
        transcripts => reference to an array of L<GenOO::Transcript> objects
    );

=head1 DESCRIPTION

    GenOO::Gene describes a gene. A gene is defined as a genomic region (it has the strand, chromosome, start and stop
    attributes required by L<GenOO::GenomicRegion>) as well as collection of L<GenOO::Transcript> objects. The genomic
    location attributes can be inferred by the locations of the contained transcripts. The start position of the gene
    will be the smallest coordinate of all the contained transcripts etc.
    Whenever a transcript is added to a gene object the genomic coordinates of the gene are automatically updated.
    It is a good idea NOT to set the genomic location of the gene directly but to let it be inferred by the transcripts.

=head1 EXAMPLES
    # Create a new gene object
    my $gene = GenOO::Gene->new(
        name        => '2310016C08Rik',
        description => 'hypoxia-inducible gene 2 protein isoform 2',
        transcripts => [
                                GenOO::Transcript->new(
                                        id            => 'uc012eiw.1',
                                        strand        => 1,
                                        chromosome    => 'chr6',
                                        start         => 29222487,
                                        stop          => 29225448,
                                        coding_start  => 29222571,
                                        coding_stop   => 29224899,
                                        biotype       => 'coding',
                                        splice_starts => [29222487,29224649],
                                        splice_stops  => [29222607,29225448]
                                ),
                                GenOO::Transcript->new(
                                        id            => 'uc009bdd.2',
                                        strand        => 1,
                                        chromosome    => 'chr6',
                                        start         => 29222625,
                                        stop          => 29225448,
                                        coding_start  => 29224705,
                                        coding_stop   => 29224899,
                                        biotype       => 'coding',
                                        splice_starts => [29222625,29224649],
                                        splice_stops  => [29222809,29225448]
                                )
                        ],
    );
    
    # Get gene information
    $gene->strand;     # 1
    $gene->chromosome; # chr6
    $gene->start;      # 29222487
    $gene->stop;       # 29225448

=cut

# Let the code begin...

package GenOO::Gene;

use Moose;
use namespace::autoclean;

extends 'GenOO::GenomicRegion';

has 'name' => (
	isa      => 'Str',
	is       => 'rw',
	required => 1
);

has 'description' => (
	isa => 'Str',
	is  => 'rw'
);

has 'transcripts' => (
	isa     => 'ArrayRef[GenOO::Transcript]',
	is      => 'rw',
	default => sub {[]}
);

has 'strand' => (
	is      => 'rw',
	builder => '_find_strand',
	clearer => '_clear_strand',
	lazy    => 1,
);

has 'chromosome' => (
	is      => 'rw',
	builder => '_find_chromosome',
	clearer => '_clear_chromosome',
	lazy    => 1,
);

has 'start' => (
	is      => 'rw',
	builder => '_find_start',
	clearer => '_clear_start',
	lazy    => 1,
);

has 'stop' => (
	is      => 'rw',
	builder => '_find_stop',
	clearer => '_clear_stop',
	lazy    => 1,
);

has 'exonic_regions' => (
	traits  => ['Array'],
	is      => 'ro',
	builder => '_build_exonic_regions',
	clearer => '_clear_exonic_regions',
	handles => {
		all_exonic_regions    => 'elements',
		exonic_regions_count  => 'count',
	},
	lazy    => 1
);

has 'utr5_exonic_regions' => (
	traits  => ['Array'],
	is      => 'ro',
	builder => '_build_utr5_exonic_regions',
	clearer => '_clear_utr5_exonic_regions',
	handles => {
		all_utr5_exonic_regions    => 'elements',
		utr5_exonic_regions_count  => 'count',
	},
	lazy    => 1
);

has 'cds_exonic_regions' => (
	traits  => ['Array'],
	is      => 'ro',
	builder => '_build_cds_exonic_regions',
	clearer => '_clear_cds_exonic_regions',
	handles => {
		all_cds_exonic_regions    => 'elements',
		cds_exonic_regions_count  => 'count',
	},
	lazy    => 1
);

has 'utr3_exonic_regions' => (
	traits  => ['Array'],
	is      => 'ro',
	builder => '_build_utr3_exonic_regions',
	clearer => '_clear_utr3_exonic_regions',
	handles => {
		all_utr3_exonic_regions    => 'elements',
		utr3_exonic_regions_count  => 'count',
	},
	lazy    => 1
);

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub coding_transcripts {
	my ($self) = @_;
	
	if (defined $self->transcripts) {
		return [grep {$_->is_coding} @{$self->transcripts}];
	}
	else {
		warn "No transcripts found for ".$self->name."\n";
		return undef;
	}
}

sub non_coding_transcripts {
	my ($self) = @_;
	
	if (defined $self->transcripts) {
		return [grep {not $_->is_coding} @{$self->transcripts}];
	}
	else {
		warn "No transcripts found for ".$self->name."\n";
		return undef;
	}
}

sub add_transcript {
	my ($self, $transcript) = @_;
	
	if (defined $transcript and ($transcript->isa('GenOO::Transcript'))) {
		push @{$self->transcripts}, $transcript;
		$self->_reset;
	}
	else {
		warn 'Object "'.ref($transcript).'" is not a GenOO::Transcript ... skipped';
	}
}

sub constitutive_exonic_regions {
	my ($self) = @_;
	
	my %counts;
	foreach my $transcript (@{$self->transcripts}) {
		foreach my $exon (@{$transcript->exons}) {
			$counts{$exon->location}++;
		}
	}
	
	my @constitutive_exons;
	my $transcript_count = @{$self->transcripts};
	foreach my $transcript (@{$self->transcripts}) {
		foreach my $exon (@{$transcript->exons}) {
			if (exists $counts{$exon->location} and ($counts{$exon->location} == $transcript_count)) {
				push @constitutive_exons, GenOO::GenomicRegion->new(
					strand     => $exon->strand,
					chromosome => $exon->chromosome,
					start      => $exon->start,
					stop       => $exon->stop
				);
				
				delete $counts{$exon->location};
			}
		}
	}
	return \@constitutive_exons;
}

sub constitutive_coding_exonic_regions {
	my ($self) = @_;
	
	my %counts;
	foreach my $transcript (@{$self->transcripts}) {
		foreach my $exon (@{$transcript->exons}) {
			$counts{$exon->location}++;
		}
	}
	
	my @constitutive_exons;
	my $transcript_count = @{$self->coding_transcripts};
	foreach my $transcript (@{$self->transcripts}) {
		foreach my $exon (@{$transcript->exons}) {
			if (exists $counts{$exon->location} and ($counts{$exon->location} == $transcript_count)) {
				push @constitutive_exons, GenOO::GenomicRegion->new(
					strand     => $exon->strand,
					chromosome => $exon->chromosome,
					start      => $exon->start,
					stop       => $exon->stop
				);
				
				delete $counts{$exon->location};
			}
		}
	}
	return \@constitutive_exons;
}

sub has_coding_transcript {
	my ($self) = @_;
	
	foreach my $transcript (@{$self->transcripts}) {
		if ($transcript->is_coding) {
			return 1;
		}
	}
	
	return 0;
}

sub exonic_length {
	my ($self) = @_;
	
	my $exonic_length = 0;
	foreach my $region ($self->all_exonic_regions) {
		$exonic_length += $region->length
	}
	
	return $exonic_length;
}

sub utr5_exonic_length {
	my ($self) = @_;
	
	my $exonic_length = 0;
	foreach my $region ($self->all_utr5_exonic_regions) {
		$exonic_length += $region->length
	}
	
	return $exonic_length;
}

sub cds_exonic_length {
	my ($self) = @_;
	
	my $exonic_length = 0;
	foreach my $region ($self->all_cds_exonic_regions) {
		$exonic_length += $region->length
	}
	
	return $exonic_length;
}

sub utr3_exonic_length {
	my ($self) = @_;
	
	my $exonic_length = 0;
	foreach my $region ($self->all_utr3_exonic_regions) {
		$exonic_length += $region->length
	}
	
	return $exonic_length;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _find_strand {
	my ($self) = @_;
	
	my $strand;
	if (defined $self->transcripts) {
		$strand = $self->transcripts->[0]->strand;
	}
	
	if (not defined $strand) {
		die "No strand found for ".$self->name."\n";
	}
	else {
		return $strand;
	}
}

sub _find_chromosome {
	my ($self) = @_;
	
	my $chromosome;
	if (defined $self->transcripts) {
		$chromosome = $self->transcripts->[0]->chromosome;
	}
	
	if (not defined $chromosome) {
		die "No chromosome found for ".$self->name."\n";
	}
	else {
		return $chromosome;
	}
}

sub _find_start {
	my ($self) = @_;
	
	my $start;
	if (defined $self->transcripts) {
		foreach my $transcript (@{$self->transcripts}) {
			if ((not defined $start) or ($start > $transcript->start)) {
				$start = $transcript->start;
			}
		}
	}
	
	if (not defined $start) {
		die "No start found for ".$self->name."\n";
	}
	else {
		return $start;
	}
}

sub _find_stop {
	my ($self) = @_;
	
	my $stop;
	if (defined $self->transcripts) {
		foreach my $transcript (@{$self->transcripts}) {
			if ((not defined $stop) or ($stop < $transcript->stop)) {
				$stop = $transcript->stop;
			}
		}
	}
	
	if (not defined $stop) {
		die "No stop found for ".$self->name."\n";
	}
	else {
		return $stop;
	}
}

sub _build_exonic_regions {
	my ($self) = @_;
	
	my @all_exons;
	foreach my $transcript (@{$self->transcripts}) {
		foreach my $exon (@{$transcript->exons}) {
			push @all_exons, $exon;
		}
	}
	
	return $self->_merge_exons(\@all_exons);
}

sub _build_utr5_exonic_regions {
	my ($self) = @_;
	
	my @all_exons;
	foreach my $transcript (@{$self->transcripts}) {
		next if !$transcript->is_coding;
		next if !defined $transcript->utr5;
		foreach my $exon (@{$transcript->utr5->exons}) {
			push @all_exons, $exon;
		}
	}
	
	return $self->_merge_exons(\@all_exons);
}

sub _build_cds_exonic_regions {
	my ($self) = @_;
	
	my @all_exons;
	foreach my $transcript (@{$self->transcripts}) {
		next if !$transcript->is_coding;
		foreach my $exon (@{$transcript->cds->exons}) {
			push @all_exons, $exon;
		}
	}
	
	return $self->_merge_exons(\@all_exons);
}

sub _build_utr3_exonic_regions {
	my ($self) = @_;
	
	my @all_exons;
	foreach my $transcript (@{$self->transcripts}) {
		next if !$transcript->is_coding;
		next if !defined $transcript->utr3;
		foreach my $exon (@{$transcript->utr3->exons}) {
			push @all_exons, $exon;
		}
	}
	
	return $self->_merge_exons(\@all_exons);
}

sub _merge_exons {
	my ($self, $exons) = @_;
	
	my @sorted_exons = sort{$a->start <=> $b->start} @$exons;
	
	my @exonic_regions;
	foreach my $exon (@sorted_exons) {
		my $merge_region = $exonic_regions[-1];
		if (defined $merge_region and $merge_region->overlaps($exon)) {
			$merge_region->stop($exon->stop) if $exon->stop > $merge_region->stop;
		}
		else {
			push @exonic_regions, GenOO::GenomicRegion->new(
				strand      => $exon->strand,
				chromosome  => $exon->chromosome,
				start       => $exon->start,
				stop        => $exon->stop,
			);
		}
	}
	
	return \@exonic_regions;
}

sub _reset {
	my ($self) = @_;
	
	$self->_clear_strand;
	$self->_clear_chromosome;
	$self->_clear_start;
	$self->_clear_stop;
	$self->_clear_exonic_regions;
	$self->_clear_utr5_exonic_regions;
	$self->_clear_cds_exonic_regions;
	$self->_clear_utr3_exonic_regions;
}

__PACKAGE__->meta->make_immutable;

1;