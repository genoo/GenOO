# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory::BED - Factory for creating GenOO::RegionCollection object from a BED formatted file

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection object from a BED formatted file 

    # It should not be used directly but through the generic GenOO::RegionCollection::Factory as follows
    my $factory = GenOO::RegionCollection::Factory->new({
        type => 'BED'
        file => 'sample.bed'
    });

=head1 DESCRIPTION

    Implements the Track::Factory interface and uses the BED parser to create a 
    GenOO::RegionCollection object from a BED formatted file.

=head1 EXAMPLES

    # Create the factory
    my $factory = GenOO::RegionCollection::Factory->new({
        type => 'BED'
        file => 'sample.bed'
    });
    
    # ditto (preferably)
    my $factory = GenOO::RegionCollection::Factory->instantiate({
        type => 'BED'
        file => 'sample.bed'
    });

=cut

# Let the code begin...

package GenOO::RegionCollection::Factory::BED;

use Moose;
use namespace::autoclean;

use GenOO::RegionCollection::Type::DoubleHashArray;
use GenOO::Data::File::BED;

has 'file' => (is => 'Str', is => 'ro');
has 'extra' => (is => 'rw');

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
