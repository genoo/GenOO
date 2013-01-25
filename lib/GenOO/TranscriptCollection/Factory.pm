# POD documentation - main docs before the code

=head1 NAME

GenOO::TranscriptCollection::Factory - Factory for creating L<GenOO::TranscriptCollection> objects

=head1 SYNOPSIS

    # It returns the requested factory implementation

    my $implementation = GenOO::TranscriptCollection::Factory->create('Implementation',
        {
            ARGUMENT_FOR_IMPLEMENTATION => undef
        }
    );
    
=head1 DESCRIPTION

    It helps to encapsulate the actual factories that handle the creation of the requested objects

=head1 EXAMPLES

    # Create a GTF implementation
    my $gtf_implementation = GenOO::TranscriptCollection::Factory->create('GTF',
        {
            file => 'sample.gtf'
        }
    );

=cut

# Let the code begin...

package GenOO::TranscriptCollection::Factory;

use MooseX::AbstractFactory;

# Role that the implementations should implement
implementation_does [ qw( GenOO::RegionCollection::Factory::Requires ) ];

1;
