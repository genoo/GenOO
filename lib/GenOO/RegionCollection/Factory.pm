# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory - Factory for creating L<GenOO::RegionCollection> objects

=head1 SYNOPSIS

    # It returns the requested factory implementation

    my $implementation = GenOO::RegionCollection::Factory->create('Implementation',
        {
            ARGUMENT_FOR_IMPLEMENTATION => undef
        }
    );
    
=head1 DESCRIPTION

    It helps to encapsulate the actual factories that handle the creation of the requested objects

=head1 EXAMPLES

    # Create a GFF implementation
    my $gff_implementation = GenOO::RegionCollection::Factory->create('GFF',
        {
            file => 'sample.gff'
        }
    );
    
    my $bed_implementation = GenOO::RegionCollection::Factory->create('BED',
        {
            file => 'sample.bed'
        }
    );

=cut

# Let the code begin...

package GenOO::RegionCollection::Factory;

use MooseX::AbstractFactory;

# Role that the implementations should implement
implementation_does [ qw( GenOO::RegionCollection::Factory::Requires ) ];

1;
