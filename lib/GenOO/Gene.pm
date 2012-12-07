# POD documentation - main docs before the code

=head1 NAME

GenOO::Gene - Gene object, with features

=head1 SYNOPSIS

    # This is the main gene object
    # It represents a gene (a genomic region and a collection of transcripts)
    
    # To initialize 
    my $transcript = GenOO::Transcript->new({
        INTERNAL_ID    => undef,
        SPECIES        => undef,
        STRAND         => undef,
        CHR            => undef,
        START          => undef,
        STOP           => undef,
        ENSGID         => undef,
        NAME           => undef,
        REFSEQ         => undef,
        TRANSCRIPTS    => undef, # [] reference to array of gene objects
        DESCRIPTION    => undef,
        EXTRA_INFO     => undef,
    });

=head1 DESCRIPTION

    GenOO::Gene describes a gene. A gene is defined as a locus and as a collection of transcript. This means that it has
    genomic location attributes which are set in respect to the start and stop positions of its contained transcripts. 
    Whenever a transcript is added to a gene object the genomic coordinates of the gene are automatically updated. 
    It is not clear if the gene should have attributes like the biotype as it is not definite whether its contained
    transcripts would all have the same biotype or not.
    Whenever a gene object is created a unique id is associated with the object until it gets out of scope.

=head1 EXAMPLES

    my $gene = GenOO::Gene->by_ensgid('ENSG00000000143'); # using the class method to get the corresponding object

=head1 AUTHOR - Manolis Maragkakis, Panagiotis Alexiou

Email em.maragkakis@gmail.com, pan.alexiou@fleming.gr

=cut

# Let the code begin...

package GenOO::Gene;

use Moose;
use namespace::autoclean;

use GenOO::Transcript;

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

sub _reset {
	my ($self) = @_;
	
	$self->_clear_strand;
	$self->_clear_chromosome;
	$self->_clear_start;
	$self->_clear_stop;
}

__PACKAGE__->meta->make_immutable;

1;