# POD documentation - main docs before the code

=head1 NAME

GenOO::Transcript::Part - A functional region within a transcript consisting of spliceable elements

=head1 SYNOPSIS

    # This is the main region object.
    # Represents a functional region within
    # a transcript eg 3'UTR, CDS or 5'UTR
    # It supports splicing.
    
    # To initialize 
    my $region = GenOO::Transcript::Part->new({
        species      => undef,
        strand       => undef,    #required
        chromosome   => undef,    #required
        start        => undef,    #required
        stop         => undef,    #required
        name         => undef,
        sequence     => undef,
        transcript   => undef,    #backreference to a L<GenOO::Transcript> object
        splice_starts    => undef,    #reference to an array of splice starts
        splice_stops     => undef,    #reference to an array of splice stops
    });

=head1 DESCRIPTION

    A transcript part can be any functional part of a transcript. It is usually used for the 3'UTR
    5'UTR, coding region (CDS) etc. It has a genomic location (start, stop, chromosome, strand), 
    it is spliceable (splice_starts, splice_stops, exons, introns etc) and is connected to a 
    transcript object.

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