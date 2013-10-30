# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Type::DoubleHashArray - Object for a collection of GenOO::Region objects, with features

=head1 SYNOPSIS

    # Object that manages a collection of GenOO::Region objects. 

    # To initialize 
    my $locus_collection = GenOO::RegionCollection::DoubleHashArray->new({
        name          => undef,
        species       => undef,
        description   => undef,
        extra         => undef,
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the reference sequence name. Each such pair of keys correspond to an
    array reference which stores objects of the class L<GenOO::Region> sorted by start position.

=head1 EXAMPLES

    # Print records in FASTA format
    $locus_collection->print("FASTA",'STDOUT',"/data1/data/UCSC/hg19/chromosomes/");
    
    # ditto
    $locus_collection->print_in_fasta_format('STDOUT',"/data1/data/UCSC/hg19/chromosomes/");

=cut

# Let the code begin...

package GenOO::RegionCollection::Type::DoubleHashArray;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
#########################   Load GenOO modules   ######################
#######################################################################
use GenOO::Module::Search::Binary;
use GenOO::Data::Structure::DoubleHashArray;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'name' => (
	isa => 'Str',
	is  => 'rw'
);

has 'species' => (
	isa => 'Str',
	is  => 'rw'
);

has 'description' => (
	isa => 'Str',
	is  => 'rw'
);

has 'longest_record' => (
	is        => 'ro',
	builder   => '_find_longest_record',
	clearer   => '_clear_longest_record',
	init_arg  => undef,
	lazy      => 1,
);

has 'extra' => (
	is => 'rw'
);


#######################################################################
########################   Private attributes   #######################
#######################################################################
has '_container' => (
	is => 'ro',
	builder => '_build_container',
	init_arg => undef,
	lazy => 1
);

#######################################################################
##########################   Consumed Roles   #########################
#######################################################################
with 'GenOO::RegionCollection';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub add_record {
	my ($self, $record) = @_;
	$self->_container->add_entry($record->strand, $record->rname, $record);
	$self->_reset;
}

sub all_records {
	my ($self) = @_;
	
	my @all_records;
	$self->foreach_record_do(sub {
		push @all_records, $_[0];
	});
	
	return wantarray ? @all_records : \@all_records;
}

sub foreach_record_do {
	my ($self, $block) = @_;
	$self->_container->foreach_entry_do($block);
}

sub foreach_record_on_rname_do {
	my ($self, $rname, $block) = @_;
	$self->_container->foreach_entry_on_secondary_key_do($rname, $block);
}

sub records_count {
	my ($self) = @_;
	return $self->_container->entries_count;
}

sub strands {
	my ($self) = @_;
	return $self->_container->primary_keys();
}

sub rnames_for_strand {
	my ($self, $strand) = @_;
	return $self->_container->secondary_keys_for_primary_key($strand);
}

sub rnames_for_all_strands {
	my ($self) = @_;
	return $self->_container->secondary_keys_for_all_primary_keys();
}

sub longest_record_length {
	my ($self) = @_;
	return $self->longest_record->length;
}

sub is_empty {
	my ($self) = @_;
	return $self->_container->is_empty;
}

sub is_not_empty {
	my ($self) = @_;
	return $self->_container->is_not_empty;
}

sub foreach_overlapping_record_do {
	my ($self, $strand, $chr, $start, $stop, $block) = @_;
	
	$self->_container->sort_entries;
	
	# Get a reference on the array containing the records of the specified strand and rname
	my $records_ref = $self->_records_ref_for_strand_and_rname($strand, $chr) or return ();
	
	# Find the closest but greater value to a target value. Target value is defined such that
	# any records with smaller values are impossible to overlap with the requested region
	# This allows us to search only from that point onwards for overlap
	my $target_value = $start - $self->longest_record->length;
	my $index = GenOO::Module::Search::Binary->binary_search_for_value_greater_or_equal(
		$target_value, $records_ref,
		sub {
			return $_[0]->start
		}
	);
	
	# If a value close and greater than the target value exists scan downstream for overlaps
	if (defined $index) {
		while ($index < @$records_ref) {
			my $record = $records_ref->[$index];
			if ($record->start <= $stop) {
				if ($start <= $record->stop) {
					last if $block->($record) eq 'break_loop';
				}
			}
			else {
				last; # No chance to find overlap from now on
			}
			$index++;
		}
	}
}

sub records_overlapping_region {
	my ($self, $strand, $chr, $start, $stop) = @_;
	
	my @overlapping_records;
	$self->foreach_overlapping_record_do($strand, $chr, $start, $stop, 
		sub {
			my ($record) = @_;
			push @overlapping_records, $record;
		}
	);
	
	return @overlapping_records;
}

sub total_copy_number {
	my ($self, $block) = @_;
	
	my $total_copy_number = 0;
	$self->foreach_record_do( sub {$total_copy_number += $_[0]->copy_number} );
	
	return $total_copy_number;
}

sub total_copy_number_for_records_contained_in_region {
	my ($self, $strand, $rname, $start, $stop) = @_;
	
	my $total_copy_number = 0;
	$self->foreach_overlapping_record_do( $strand, $rname, $start, $stop, sub {$total_copy_number += $_[0]->copy_number} );
	
	return $total_copy_number;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _build_container {
	return GenOO::Data::Structure::DoubleHashArray->new(
		sorting_code_block => sub {return $_[0]->start <=> $_[1]->start}
	);
}

sub _find_longest_record {
	my ($self) = @_;
	
	my $longest_record;
	my $longest_record_length = 0;
	$self->foreach_record_do(
		sub {
			my ($record) = @_;
			
			if ($record->length > $longest_record_length) {
				$longest_record_length = $record->length;
				$longest_record = $record;
			}
		}
	);
	
	return $longest_record;
}

sub _records_ref_for_strand_and_rname {
	my ($self, $strand, $chr) = @_;
	return $self->_container->entries_ref_for_keys($strand, $chr);
}

sub _reset {
	my ($self) = @_;
	$self->_clear_longest_record;
}


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;
1;
