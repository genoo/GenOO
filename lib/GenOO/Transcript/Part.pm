# POD documentation - main docs before the code

=head1 NAME

GenOO::Transcript::Part - A functional region within a transcript consisting of spicing elements, with features

=head1 SYNOPSIS

    # This is the main region object.
    # Represents a functional region within
    # a transcript eg 3'UTR, CDS or 5'UTR
    # It supports splicing.
    
    # To initialize 
    my $region = GenOO::Transcript::Part->new({
        SPECIES      => undef,
        STRAND       => undef,
        CHR          => undef,
        START        => undef,
        STOP         => undef,
        SEQUENCE     => undef,
        NAME         => undef,
        TRANSCRIPT       => undef,
        SPLICE_STARTS    => undef,
        SPLICE_STOPS     => undef,
        SEQUENCE         => undef,
    });

=head1 DESCRIPTION

    Not provided yet

=head1 EXAMPLES

    Not provided yet

=cut

# Let the code begin...

package GenOO::Transcript::Part;

use Moose;
use namespace::autoclean;

extends 'GenOO::GenomicRegion';

has 'transcript' => (isa => 'GenOO::Transcript',is => 'rw', weak_ref => 1);

with 'GenOO::Spliceable';

__PACKAGE__->meta->make_immutable;

1;