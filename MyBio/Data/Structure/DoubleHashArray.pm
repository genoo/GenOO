# POD documentation - main docs before the code

=head1 NAME

MyBio::Data::Structure::DoubleHashArray - Object for a data structure which corresponds of a 2D hash whose values are references to array

=head1 SYNOPSIS

    # To initialize 
    my $structure = MyBio::Data::Structure::DoubleHashArray->new();


=head1 DESCRIPTION

    This class corresponds to a data structure which is a 2D hash whose primary key could be for
    example the strand, its secondary key the chromosome and each value an array reference with
    objects of the class L<MyBio::Locus>.

=head1 EXAMPLES

    # Add an entry to the structure
    $structure->add_entry($primary_key, $secondary_key, $entry);

=cut

# Let the code begin...

package MyBio::Data::Structure::DoubleHashArray;
use strict;

use base qw(MyBio::_Initializable);

sub _init {
	my ($self,$data) = @_;
	
	$self->init;
	
	return $self;
}

#######################################################################
########################   Accessor Methods   #########################
#######################################################################
sub structure {
	my ($self) = @_;
	return $self->{STRUCTURE};
}

sub entries_count {
	my ($self) = @_;
	return $self->{ENTRY_COUNT};
}

#######################################################################
#########################   General Methods   #########################
#######################################################################
sub init {
	my ($self) = @_;
	$self->{STRUCTURE} = {};
}

sub foreach_entry_do {
	my ($self, $block) = @_;
	
	foreach my $primary_key (keys %{$self->structure}) {
		foreach my $secondary_key (keys %{$self->structure->{$primary_key}}) {
			foreach my $entry (@{$self->structure->{$primary_key}->{$secondary_key}}) {
				$block->($entry);
			}
		}
	}
}

sub add_entry {
	my ($self, $primary_key, $secondary_key, $entry) = @_;
	
	unless (exists $self->structure->{$primary_key}) {
		$self->structure->{$primary_key} = {};
	}
	push @{$self->structure->{$primary_key}->{$secondary_key}},$entry;
	$self->increment_entries_count;
}

sub increment_entries_count {
	my ($self) = @_;
	$self->{ENTRY_COUNT}++;
}

sub primary_keys {
	my ($self) = @_;
	return keys %{$self->structure};
}

sub secondary_keys_for_primary_key {
	my ($self, $primary_key) = @_;
	return keys %{$self->structure->{$primary_key}};
}

sub secondary_keys_for_all_primary_keys {
	my ($self) = @_;
	
	my %secondary_keys;
	foreach my $primary_key ($self->primary_keys) {
		foreach my $secondary_key ($self->secondary_keys_for_primary_key($primary_key)) {
			$secondary_keys{$secondary_key} = 1;
		}
	}
	return keys %secondary_keys;
}

sub entries_ref_for_keys {
	my ($self, $primary_key, $secondary_key) = @_;
	
	if (exists $self->structure->{$primary_key}) {
		return $self->structure->{$primary_key}->{$secondary_key};
	}
	else {
		return undef;
	}
}

sub is_empty {
	my ($self) = @_;
	
	if ($self->entries_count == 0) {
		return 1;
	}
	else {
		return 0;
	}
}

sub is_not_empty {
	my ($self) = @_;
	
	if ($self->entries_count > 0) {
		return 1;
	}
	else {
		return 0;
	}
}

1;
