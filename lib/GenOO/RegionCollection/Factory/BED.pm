# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory::BED - Factory for creating GenOO::RegionCollection object from a BED file

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection object from a BED file 

    # Preferably use it through the generic GenOO::RegionCollection::Factory
    my $factory = GenOO::RegionCollection::Factory->create('BED',
        {
            file => 'sample.bed'
        }
    );

=head1 DESCRIPTION

    An instance of this class is a concrete factory for the creation of a 
    L<GenOO::RegionCollection> object from a BED file. It offers the method 
    "read_collection" (as the consumed role requires) which returns the actual
    L<GenOO::RegionCollection> object in the form of 
    L<GenOO::RegionCollection::Type::DoubleHashArray>. The latter is the implementation
    of the L<GenOO::RegionCollection> class based on the complex data structure
    L<GenOO::Data::Structure::DoubleHashArray>.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::RegionCollection::Factory->create('BED',
        {
            file => 'sample.bed'
        }
    );
    
    # Return the actual GenOO::RegionCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::RegionCollection::Type::DoubleHashArray

=cut

# Let the code begin...

package GenOO::RegionCollection::Factory::BED;

use Moose;
use namespace::autoclean;

use GenOO::RegionCollection::Type::DoubleHashArray;
use GenOO::Data::File::BED;

has 'file' => (is => 'Str', is => 'ro', required => 1);

with 'GenOO::RegionCollection::Factory::Requires';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $collection = GenOO::RegionCollection::Type::DoubleHashArray->new;
	
	my $parser = GenOO::Data::File::BED->new({
		FILE => $self->file,
	});
	while (my $record = $parser->next_record) {
		$collection->add_record($record);
	}
	
	return $collection;
}

1;
