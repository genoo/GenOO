# POD documentation - main docs before the code

=head1 NAME

GenOO::Junction - A junction (eg exon-exon) object with features

=head1 SYNOPSIS

    # This class represents the connection of two genomic regions in its
    # simplest form. It basically only contains the connecting genomic positions
    
    # To instantiate
    my $junction = GenOO::Junction->new(
        species      => undef,
        strand       => undef,
        chromosome   => undef,
        start        => undef,
        stop         => undef,
    });

=head1 DESCRIPTION

    The GenOO::Junction class descibes a genomic junction.

=head1 EXAMPLES

    my $junction = GenOO::Junction->new(
        species     => transcript->species,
        strand      => transcript->strand,
        chromosome  => transcript->chromosome,
        start       => exon1->stop,
        stop        => exon2->start,
    );

=cut

# Let the code begin...

package GenOO::Junction;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Moose;
use namespace::autoclean;


#######################################################################
###########################   Inheritance   ###########################
#######################################################################
extends 'GenOO::GenomicRegion';


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'part_of' => (
	is       => 'rw',
	weak_ref => 1
);


#######################################################################
############################   Filanize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
