# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection - Role for a collection of GenOO::Region objects

=head1 SYNOPSIS

    # This role defines the interface for collections of L<GenOO::Region> objects
    # Cannot be initialized

=head1 DESCRIPTION

    This role defines the interface for collections of L<GenOO::Region> objects.
    All required attributes and subs must be present in classes that consume
    this role.

=cut

# Let the code begin...

package GenOO::RegionCollection;

use Moose::Role;
use namespace::autoclean;
use GenOO::RegionCollection::Factory;

requires qw ( 
	name
	species
	description
	longest_record
	add_record
	foreach_record_do
	records_count
	strands
	rnames_for_strand
	rnames_for_all_strands
	is_empty
	is_not_empty
	foreach_overlapping_record_do
	records_overlapping_region
);

#######################################################################
########################   Class Methods       ########################
#######################################################################
sub create_from {
	my ($class, @attributes) = @_;
	return GenOO::RegionCollection::Factory->create(@attributes)->read_collection;
}
1;
