# POD documentation - main docs before the code

=head1 NAME

GenOO::TranscriptCollection::Factory::FromGeneCollection - Factory to create GenOO::TranscriptCollection object from a GeneCollection

=head1 SYNOPSIS

    # Creates GenOO::TranscriptCollection object from a GeneCollection

    # Preferably use it through the generic GenOO::TranscriptCollection::Factory
    my $factory = GenOO::TranscriptCollection::Factory->create('FromGeneCollection',{
        gene_collection => $gene_collection
    });

=head1 DESCRIPTION

    An instance of this class is a concrete factory for the creation of a 
    L<GenOO::TranscriptCollection> object from a GeneCollection.
    It offers the method "read_collection" (as the consumed role requires) which returns the actual
    L<GenOO::TranscriptCollection> object in the form of L<GenOO::RegionCollection::Type::DoubleHashArray>.
    The latter is the implementation of the L<GenOO::RegionCollection> class based on the complex
    data structure L<GenOO::Data::Structure::DoubleHashArray>.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::TranscriptCollection::Factory->create('FromTranscriptCollection',{
        gene_collection => $gene_collection
    });
    
    # Return the actual GenOO::TranscriptCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::RegionCollection::Type::DoubleHashArray

=cut

# Let the code begin...

package GenOO::TranscriptCollection::Factory::FromGeneCollection;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
#######################   Load GenOO modules      #####################
#######################################################################
use GenOO::RegionCollection::Type::DoubleHashArray;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'gene_collection' => (
	isa      => 'GenOO::RegionCollection',
	is       => 'ro',
	required => 1
);


#######################################################################
##########################   Consumed Roles   #########################
#######################################################################
with 'GenOO::RegionCollection::Factory::Requires';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $collection = GenOO::RegionCollection::Type::DoubleHashArray->new;
	my @all_transcripts = map {@{$_->transcripts}} $self->gene_collection->all_records;
	map {$collection->add_record($_)} @all_transcripts;
	
	return $collection;
}

1;
