package GenOO::Intron;

use Moose;
use namespace::autoclean;

extends 'GenOO::GenomicRegion';

has 'part_of' => (is => 'rw', weak_ref => 1);

use base qw(GenOO::Locus);


__PACKAGE__->meta->make_immutable;

1;