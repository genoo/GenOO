# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory::SAM - Factory for creating GenOO::RegionCollection object from a SAM file

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection object from a SAM file 

    # Preferably use it through the generic GenOO::RegionCollection::Factory
    my $factory = GenOO::RegionCollection::Factory->new('SAM',
        {
            file => 'sample.sam'
        }
    );

=head1 DESCRIPTION

    An instance of this class is a concrete factory for the creation of a 
    L<GenOO::RegionCollection> object from a SAM file. It offers the method 
    "read_collection" (as the consumed role requires) which returns the actual
    L<GenOO::RegionCollection> object in the form of 
    L<GenOO::RegionCollection::Type::DoubleHashArray>. The latter is the implementation
    of the L<GenOO::RegionCollection> class based on the complex data structure
    L<GenOO::Data::Structure::DoubleHashArray>.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::RegionCollection::Factory->new('SAM',
        {
            file => 'sample.sam'
        }
    );
    
    # Return the actual GenOO::RegionCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::RegionCollection::Type::DoubleHashArray

=cut

# Let the code begin...

package GenOO::RegionCollection::Factory::SAM;

use Moose;
use namespace::autoclean;

use GenOO::RegionCollection::Type::DoubleHashArray;
use GenOO::Data::File::SAM;

has 'file' => (is => 'Str', is => 'ro');
has 'filter_code' => (isa => 'CodeRef', is => 'ro', default => sub{sub{return 1;}} );

with 'GenOO::RegionCollection::Factory::Requires';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $collection = GenOO::RegionCollection::Type::DoubleHashArray->new;
	
	my $parser = GenOO::Data::File::SAM->new(
		file => $self->file,
	);
	while (my $record = $parser->next_record) {
		if (($record->is_mapped) and ($self->filter_code->($record))){
			$collection->add_record($record);
		}
	}
	
	return $collection;
}

1;
