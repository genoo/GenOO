# POD documentation - main docs before the code

=head1 NAME

GenOO::Transcript::UTR3 - Transcript part (coding sequence)

=head1 SYNOPSIS

    # This is a L<GenOO::Transcript::Part> object corresponding to the 3'UTR region of a transcript
    
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

    Extends L<GenOO::Transcript::Part>

=head1 EXAMPLES

    Not provided yet

=cut

# Let the code begin...

package GenOO::Transcript::UTR3;

use Moose;
use namespace::autoclean;

extends 'GenOO::Transcript::Part';

__PACKAGE__->meta->make_immutable;

1;