# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::Structure::DoubleHashArray - Object for a data structure which corresponds of a 2D hash whose values are references to array

=head1 SYNOPSIS

    # To initialize 
    my $structure = GenOO::Data::Structure::DoubleHashArray->new();


=head1 DESCRIPTION

    This class corresponds to a data structure which is a 2D hash whose primary key could be for
    example the strand, its secondary key the chromosome and each value an array reference with
    objects that consume the L<GenOO::Region> role.

=head1 EXAMPLES

    # Add an entry to the structure
    $structure->add_entry($primary_key, $secondary_key, $entry);

=cut

# Let the code begin...

package GenOO::Data::Structure::DoubleHashArray;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'sorting_code_block' => (
	isa      => 'CodeRef',
	is       => 'ro',
	default  => sub { sub {return $_[0] <=> $_[1]} }
);

has 'entries_count' => (
	traits  => ['Counter'],
	is      => 'ro',
	isa     => 'Num',
	default => 0,
	handles => {
		_inc_entries_count   => 'inc',
		_reset_entries_count => 'reset',
	},
);

has 'is_sorted' => (
	traits  => ['Bool'],
	is      => 'rw',
	isa     => 'Bool',
	default => 0,
	handles => {
		_set_is_sorted   => 'set',
		_unset_is_sorted => 'unset',
		is_not_sorted    => 'not',
	},
);


#######################################################################
########################   Private attributes   #######################
#######################################################################
has '_structure' => (
	traits    => ['Hash'],
	is        => 'ro',
	isa       => 'HashRef[HashRef[ArrayRef]]',
	default   => sub { {} },
);


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub foreach_entry_do {
	my ($self, $block) = @_;
	
	A: foreach my $primary_key (keys %{$self->_structure}) {
		foreach my $secondary_key (keys %{$self->_structure->{$primary_key}}) {
			foreach my $entry (@{$self->_structure->{$primary_key}->{$secondary_key}}) {
				my $return_code = $block->($entry);
				last A if (defined $return_code and $return_code eq 'break_loop');
			}
		}
	}
	return 0;
}

sub foreach_entry_on_secondary_key_do {
	my ($self, $secondary_key, $block) = @_;
	
	A: foreach my $primary_key (keys %{$self->_structure}) {
		next if not defined $self->_structure->{$primary_key}->{$secondary_key};
		foreach my $entry (@{$self->_structure->{$primary_key}->{$secondary_key}}) {
			my $return_code = $block->($entry);
			last A if (defined $return_code and $return_code eq 'break_loop');
		}
	}
}

sub add_entry {
	my ($self, $primary_key, $secondary_key, $entry) = @_;
	
	unless (exists $self->_structure->{$primary_key}) {
		$self->_structure->{$primary_key} = {};
	}
	push @{$self->_structure->{$primary_key}->{$secondary_key}}, $entry;
	
	$self->_inc_entries_count;
	$self->_unset_is_sorted;
}

sub primary_keys {
	my ($self) = @_;
	return sort keys %{$self->_structure};
}

sub secondary_keys_for_primary_key {
	my ($self, $primary_key) = @_;
	return sort keys %{$self->_structure->{$primary_key}};
}

sub secondary_keys_for_all_primary_keys {
	my ($self) = @_;
	
	my %secondary_keys;
	foreach my $primary_key ($self->primary_keys) {
		foreach my $secondary_key ($self->secondary_keys_for_primary_key($primary_key)) {
			$secondary_keys{$secondary_key} = 1;
		}
	}
	return (sort keys %secondary_keys);
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
	
	if (defined $self->entries_count and $self->entries_count > 0) {
		return 1;
	}
	else {
		return 0;
	}
}

sub sort_entries {
	my ($self) = @_;
	
	if ($self->is_not_sorted) {
		foreach my $primary_key (keys %{$self->_structure}) {
			foreach my $secondary_key (keys %{$self->_structure->{$primary_key}}) {
				my $entries_ref = $self->_structure->{$primary_key}->{$secondary_key};
				@$entries_ref = sort {$self->sorting_code_block->($a,$b)} @$entries_ref;
			}
		}
		$self->_set_is_sorted();
	}
}

sub entries_ref_for_keys {
	my ($self, $primary_key, $secondary_key) = @_;
	
	if (exists $self->_structure->{$primary_key}) {
		return $self->_structure->{$primary_key}->{$secondary_key};
	}
	else {
		return undef;
	}
}


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
