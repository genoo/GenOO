# POD documentation - main docs before the code

=head1 NAME

GenOO::TranscriptCollection - Role for a collection of GenOO::Transcript objects

=head1 SYNOPSIS

    # This role defines the interface for collections of L<GenOO::Transcript> objects
    # Cannot be initialized

=head1 DESCRIPTION

    This role defines the interface for collections of L<GenOO::Transcript> objects.
    All required attributes and subs must be present in classes that consume
    this role.

=cut

# Let the code begin...

package GenOO::TranscriptCollection;

use Moose::Role;
use namespace::autoclean;
use GenOO::TranscriptCollection::Factory;

#######################################################################
########################   Class Methods       ########################
#######################################################################
sub create_from {
	my ($class, @attributes) = @_;
	return GenOO::TranscriptCollection::Factory->create(@attributes)->read_collection;
}
1;
