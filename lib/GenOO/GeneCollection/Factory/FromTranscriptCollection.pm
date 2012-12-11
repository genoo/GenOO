# POD documentation - main docs before the code

=head1 NAME

GenOO::GeneCollection::Factory::FromTranscriptCollection - Factory for creating GenOO::GeneCollection object from a Transcript Collection and a hash{transcript_name} = genename

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection object from a Transcript Collection and a hash 

    # Preferably use it through the generic GenOO::GeneCollection::Factory
    my $factory = GenOO::GeneCollection::Factory->create(
        'FromTranscriptCollection',
        {
            annotation_hash => %annotation,
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
            annotation_hash => %annotation,
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
	
	my %genes;
	my %transcripts_for_genename;
	$self->transcript_collection->foreach_record_do( sub {
		my $entry = $_;
		my %annotation_hash = $self->annotation_hash;
		my $transcript_name = $entry->id;
		my $transcript_obj = $entry;
		my $gene_name;
		if (exists $annotation_hash{$transcript_name}){
			$gene_name = $annotation_hash{$transcript_name};
			push @{$transcripts_for_genename{$gene_name}},$transcript_obj; 
		}
		else {next;}
		
		
		
# 		if (!exists $genes{$gene_name}){
# 			$genes{$gene_name} = GenOO::Gene->new(
# 				name         =>    $gene_name,
# 				transcripts  =>    [$transcript_obj],
# 			)
# 		}
# 		else {
# 			$genes{$gene_name}->add_transcript($transcript_obj);
# 		}
	});
	
	foreach my $genename (keys %transcripts_for_genename) {
		my ($merged_loci,$included_transcripts) = GenOO::Helper::Locus::merge($transcripts_for_genename{$genename});
		for (my $i=0;$i<@$merged_loci;$i++) {
			my $gene = GenOO::Gene->new($$merged_loci[$i]);
			$gene->set_name($genename);
			foreach my $transcript (@{$$included_transcripts[$i]}) {
# 				$gene->set_description(delete $transcript->{TEMP_DESCRIPTION});
# 				$gene->add_transcript($transcript);
				$transcript->set_gene($gene);
			}
			$genes{$genename} = $gene;
		}
	}
	
	
	return values %genes;
}

1;
