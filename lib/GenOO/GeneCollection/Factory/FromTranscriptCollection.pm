# POD documentation - main docs before the code

=head1 NAME

GenOO::GeneCollection::Factory::FromTranscriptCollection - Factory for creating GenOO::GeneCollection object from a Transcript Collection and a hash{transcript_name} = genename

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection object from a Transcript Collection and a hash 

    # Preferably use it through the generic GenOO::GeneCollection::Factory
    my $factory = GenOO::GeneCollection::Factory->create(
        'FromTranscriptCollection',
        {
            annotation_hash => \%annotation,
            transcript_collection => $transcript_collection
        }
    );

=head1 DESCRIPTION

    An instance of this class is a concrete factory for the creation of a 
    L<GenOO::RegionCollection> object from a Transcript Collection (also a L<GenOO::RegionCollection> object)
    and a hash that has transcript names as keys and gene names as values. 
    It offers the method "read_collection" (as the consumed role requires) which returns the actual
    L<GenOO::RegionCollection> object in the form of L<GenOO::RegionCollection::Type::DoubleHashArray>.
    The latter is the implementation of the L<GenOO::RegionCollection> class based on the complex
    data structure L<GenOO::Data::Structure::DoubleHashArray>.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::GeneCollection::Factory->create(
        'FromTranscriptCollection',
        {
            annotation_hash => \%annotation,
            transcript_collection => $transcript_collection
        }
    );
    
    # Return the actual GenOO::RegionCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::RegionCollection::Type::DoubleHashArray

=cut

# Let the code begin...

package GenOO::GeneCollection::Factory::FromTranscriptCollection;

use Moose;
use namespace::autoclean;

use GenOO::RegionCollection::Type::DoubleHashArray;
use GenOO::Gene;

has 'annotation_hash'       => (
	isa      => 'HashRef', 
	is       => 'ro', 
	required => 1
);
has 'transcript_collection' => (
	isa      => 'GenOO::RegionCollection',
	is       => 'ro',
	required => 1
);

with 'GenOO::RegionCollection::Factory::Requires';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $collection = GenOO::RegionCollection::Type::DoubleHashArray->new;
	my @all_genes = $self->_make_list_of_genes;
	foreach my $gene ( @all_genes ) {
		$collection->add_record($gene);
	}
	return $collection;
}

sub _make_list_of_genes {
	my ($self) = @_;
	
	my @outgenes;
	my %transcripts_for_genename;
	$self->transcript_collection->foreach_record_do( sub {
		my ($transcript) = @_;
		
		if (exists $self->annotation_hash->{$transcript->id}){
			my $gene_name = $self->annotation_hash->{$transcript->id};
			push @{$transcripts_for_genename{$gene_name}}, $transcript; 
		}
	});
	
	foreach my $genename (keys %transcripts_for_genename) {
		my ($merged_regions,$included_transcripts) = _merge($transcripts_for_genename{$genename});
		for (my $i=0;$i<@$merged_regions;$i++) {
			my $gene = GenOO::Gene->new(
				name        => $genename,
				transcripts => $$included_transcripts[$i]
			);
			foreach my $transcript (@{$gene->transcripts}) {
				$transcript->gene($gene);
			}
			push @outgenes, $gene;
		}
	}
	
	return @outgenes;
}

sub _merge {
	my ($regions_ref, $params) = @_;
	
	my $offset = exists $params->{'OFFSET'} ? $params->{'OFFSET'} : 0;
	my $use_strand = exists $params->{'USE_STRAND'} ? $params->{'USE_STRAND'} : 1;
	
	my @sorted_regions = (@$regions_ref > 1) ? sort{$a->start <=> $b->start} @$regions_ref : @$regions_ref;
	
	my @merged_regions;
	my @included_regions;
	foreach my $region (@sorted_regions) {
		
		my $merged_region = $merged_regions[-1];
		if (defined $merged_region and $merged_region->overlaps($region, $use_strand, $offset)) {
			if (wantarray) {
				push @{$included_regions[-1]}, $region;
			}
			if ($region->stop() > $merged_region->stop) {
				$merged_region->stop($region->stop);
			}
		}
		else {
			push @merged_regions, GenOO::GenomicRegion->new
			(
				start      => $region->start,
				stop       => $region->stop,
				strand     => $region->strand,
				chromosome => $region->chromosome,
			);
			if (wantarray) {
				push @included_regions,[$region];
			}
		}
	}

	if (wantarray) {
		return (\@merged_regions, \@included_regions);
	}
	else {
		return \@merged_regions;
	}
}

1;
