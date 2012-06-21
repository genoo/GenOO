# POD documentation - main docs before the code

=head1 NAME

MyBio::LocusCollection::Container - Container for the data of MyBio::LocusCollection class

=head1 SYNOPSIS

    # To initialize 
    my $structure = MyBio::LocusCollection::Container->new();


=head1 DESCRIPTION

    This class corresponds to a data structure which is a 2D hash whose primary key is the strand,
    its secondary key the chromosome and its value an array reference with objects that support the
    interface of L<MyBio::Locus>.

=head1 EXAMPLES

    # Add an entry to the structure
    $structure->add_entry($key1, $key2, $entry);

=cut

# Let the code begin...

package MyBio::LocusCollection::Container;
use strict;

use MyBio::Module::Search::Binary;
use MyBio::Data::Structure::DoubleHashArray;

use base qw(MyBio::Data::Structure::DoubleHashArray);

sub _init {
	my ($self,$data) = @_;
	
	$self->SUPER::_init($data);
	
	return $self;
}

#######################################################################
########################   Accessor Methods   #########################
#######################################################################
sub sorted {
	my ($self) = @_;
	return $self->{SORTED};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub init {
	my ($self) = @_;
	$self->SUPER::init;
}

sub reset {
	my ($self) = @_;
	delete $self->{SORTED};
	delete $self->{LONGEST_ENTRY_LENGTH};
}

sub add_entry {
	my ($self, $entry) = @_;
	$self->SUPER::add_entry($entry->get_strand, $entry->get_chr, $entry);
	$self->reset;
}

sub get_or_find_longest_entry_length {
	my ($self) = @_;
	
	if (!defined $self->{LONGEST_ENTRY_LENGTH}) {
		$self->find_and_set_longest_entry_length;
	}
	return $self->{LONGEST_ENTRY_LENGTH};
}

sub find_and_set_longest_entry_length {
	my ($self) = @_;
	
	my $longest_entry_length = 0;
	$self->foreach_entry_do(
		sub {
			my ($entry) = @_;
			
			if ($entry->get_length > $longest_entry_length) {
				$longest_entry_length = $entry->get_length;
			}
		}
	);
	
	$self->{LONGEST_ENTRY_LENGTH} = $longest_entry_length;
}

sub strands {
	my ($self) = @_;
	return $self->SUPER::primary_keys();
}

sub chromosomes_for_strand {
	my ($self, $strand) = @_;
	return $self->secondary_keys_for_primary_key($strand);
}

sub chromosomes_for_all_strands {
	my ($self) = @_;
	return $self->secondary_keys_for_all_primary_keys();
}

sub entries_ref_for_strand_and_chromosome {
	my ($self, $strand, $chr) = @_;
	return $self->entries_ref_for_keys($strand, $chr);
}

sub sort_entries {
	my ($self) = @_;
	
	foreach my $strand ($self->strands) {
		foreach my $chr ($self->chromosomes_for_strand($strand)) {
			my $entries_array_ref = $self->entries_ref_for_strand_and_chromosome($strand, $chr);
			@$entries_array_ref = sort {$a->get_start <=> $b->get_start} @$entries_array_ref;
		}
	}
	$self->set_sorted;
}

sub set_sorted {
	my ($self) = @_;
	$self->{SORTED} = 1;
}

sub entries_overlapping_region {
	my ($self, $strand, $chr, $start, $stop) = @_;
	
	my $entries_ref = $self->entries_ref_for_strand_and_chromosome($strand, $chr) or return ();
	
	$self->sort_entries unless $self->sorted;
	
	my $target_value = $start - $self->get_or_find_longest_entry_length;
	my $index = MyBio::Module::Search::Binary->binary_search_for_value_greater_or_equal($target_value, $entries_ref, sub {return $_[0]->get_start});
	
	my @overlapping_entries;
	while ($index < @$entries_ref) {
		my $entry = $entries_ref->[$index];
		if ($entry->get_start <= $stop) {
			if ($start <= $entry->get_stop) {
				push @overlapping_entries, $entry;
			}
		}
		else {
			last;
		}
		
		$index++;
	}
	return @overlapping_entries;
}


1;
