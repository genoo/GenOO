# POD documentation - main docs before the code

=head1 NAME

MyBio::LocusCollection - Role for a collection of MyBio::Locus objects

=head1 SYNOPSIS

    # This role defines the interface for collections of L<MyBio::Locus> objects
    # Cannot be initialized

=head1 DESCRIPTION

    This role defines the interface for collections of L<MyBio::Locus> objects.
    All required attributes and subs must be present in classes that consume
    this role.

=cut

# Let the code begin...

package MyBio::LocusCollection;
use Moose::Role;
use namespace::autoclean;

requires qw ( 
	name
	species
	description
	extra
	longest_entry
	add_entry
	foreach_entry_do
	entries_count
	strands
	chromosomes_for_strand
	chromosomes_for_all_strands
	longest_entry_length
	is_empty
	is_not_empty
	entries_overlapping_region
);

1;
