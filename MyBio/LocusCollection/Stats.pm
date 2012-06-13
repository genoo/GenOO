# POD documentation - main docs before the code

=head1 NAME

MyBio::LocusCollection::Stats - Object for managing statistics for MyBio::LocusCollection

=head1 SYNOPSIS

    # Object that offers methods calculating statistics for MyBio::LocusCollection. 

    # To initialize (NOTE: Should ONLY be instantiated through a locus collection object)
    my $locus_collection_stats = MyBio::LocusCollection::Stats->new({
        COLLECTION   => undef,
    });


=head1 DESCRIPTION

    This class offers methods for calculating several statistical measures for a Track. It does not
    make any assumpions for the internal data structure of the Track. Note that it should not be
    instantiated by itself but rather through a locus collection object. The reason is that it weakens the reference
    to the locus collection and therefore when the locus collection falls out of scope even though the stats object is still
    within scope the internal structure is corrupted.

=head1 EXAMPLES

    # Calculate the length for the longest entry
    $locus_collection_stats->get_or_find_length_for_longest_entry();

=cut

# Let the code begin...

package MyBio::LocusCollection::Stats;
use strict;
use Scalar::Util qw/weaken/;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->set_collection($$data{COLLECTION});
	$self->init_stats;
	
	return $self;
}

#######################################################################
#############################   Setters   #############################
#######################################################################
sub set_collection {
	my ($self, $value) = @_;
	if (defined $value) {
		$self->{COLLECTION} = $value;
		weaken($self->{COLLECTION});
	}
}

#######################################################################
#############################   Getters   #############################
#######################################################################
sub get_collection {
	my ($self) = @_;
	return $self->{COLLECTION};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub init_stats {
	my ($self) = @_;
	$self->reset;
}

sub reset {
	my ($self) = @_;
	$self->{LONGEST_LENGTH} = undef;
}

sub entries_count {
	my ($self) = @_;
	return $self->get_collection->entries_count;
}

sub get_or_find_length_for_longest_entry {
	my ($self) = @_;
	
	if (!defined $self->{LONGEST_LENGTH}) {
		$self->find_length_for_longest_entry;
	}
	return $self->{LONGEST_LENGTH};
}

sub find_length_for_longest_entry {
	my ($self) = @_;
	
	if ($self->collection_is_not_empty) {
		my $longest_entry_length = 0;
		my $iterator = $self->get_collection->entries_iterator;
		while (my $entry = $iterator->next) {
			if ($entry->get_length() > $longest_entry_length) {
				$longest_entry_length = $entry->get_length();
			}
		}
		
		$self->{LONGEST_LENGTH} = $longest_entry_length;
	}
}

sub collection_is_empty {
	my ($self) = @_;
	
	if ($self->entries_count == 0) {
		return 1;
	}
	else {
		return 0;
	}
}

sub collection_is_not_empty {
	my ($self) = @_;
	
	if ($self->entries_count > 0) {
		return 1;
	}
	else {
		return 0;
	}
}

1;
