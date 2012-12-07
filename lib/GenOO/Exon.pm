package GenOO::Exon;

use Moose;
use namespace::autoclean;

extends 'GenOO::GenomicRegion';

has 'part_of' => (is => 'rw', weak_ref => 1);


__PACKAGE__->meta->make_immutable;

1;