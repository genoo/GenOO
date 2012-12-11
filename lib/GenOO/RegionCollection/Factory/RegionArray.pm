# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory::RegionArray - Factory for creating a RegionCollection from array of regions

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection from a array of L<Region> objects

    # Preferably use it through the generic GenOO::RegionCollection::Factory
    my $factory = GenOO::RegionCollection::Factory->new('RegionArray',
        {
            array => \@array_with_regions
        }
    );

=head1 DESCRIPTION

    An instance of this class is a concrete factory for the creation of a 
    L<GenOO::RegionCollection> from an array of L<Region> objects. It offers the method 
    "read_collection" (as the consumed role requires) which returns the actual
    L<GenOO::RegionCollection> object in the form of 
    L<GenOO::RegionCollection::Type::DoubleHashArray>. The latter is the implementation
    of the L<GenOO::RegionCollection> class based on the complex data structure
    L<GenOO::Data::Structure::DoubleHashArray>.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::RegionCollection::Factory->new('RegionArray',
        {
             array => \@array_with_regions
        }
    );
    
    # Return the actual GenOO::RegionCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::RegionCollection::Type::DoubleHashArray

=cut

# Let the code begin...

package GenOO::RegionCollection::Factory::RegionArray;

use Moose;
use namespace::autoclean;

use GenOO::RegionCollection::Type::DoubleHashArray;

has 'array' => (is => 'ArrayRef', is => 'ro');

with 'GenOO::RegionCollection::Factory::Requires';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $collection = GenOO::RegionCollection::Type::DoubleHashArray->new;
	
	foreach my $record ( @{$self->array} ) {
		$collection->add_record($record);
	}
	
	return $collection;
}

1;
