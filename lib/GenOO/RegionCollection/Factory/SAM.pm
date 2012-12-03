# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory::SAM - Factory for creating GenOO::RegionCollection object from a SAM formatted file

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection object from a SAM formatted file 

    # It should not be used directly but through the generic GenOO::RegionCollection::Factory as follows
    my $factory = GenOO::RegionCollection::Factory->new({
        type => 'SAM'
        file => 'sample.sam'
    });

=head1 DESCRIPTION

    Implements the Track::Factory interface and uses the SAM parser to create a 
    GenOO::RegionCollection object from a SAM formatted file.

=head1 EXAMPLES

    # Create the factory
    my $factory = GenOO::RegionCollection::Factory->new({
        type => 'SAM'
        file => 'sample.sam'
    });
    
    # ditto (preferably)
    my $factory = GenOO::RegionCollection::Factory->instantiate({
        type => 'SAM'
        file => 'sample.sam'
    });

=cut

# Let the code begin...

package GenOO::RegionCollection::Factory::SAM;

use Moose;
use namespace::autoclean;

use GenOO::RegionCollection::Type::DoubleHashArray;
use GenOO::Data::File::SAM;

has 'file' => (is => 'Str', is => 'ro');
has 'extra' => (is => 'rw');

with 'GenOO::RegionCollection::Factory::Requires';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $collection = GenOO::RegionCollection::Type::DoubleHashArray->new;
	
	my $parser = GenOO::Data::File::SAM->new({
		FILE => $self->file,
	});
	while (my $record = $parser->next_record) {
		if ($record->is_mapped) {
			$collection->add_record($record);
		}
	}
	
	return $collection;
}

1;
