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

use Moose;
use namespace::autoclean;

use GenOO::Module::Search::Binary;
use GenOO::Data::Structure::DoubleHashArray;


has 'name' => (isa => 'Str', is => 'rw');
has 'species' => (isa => 'Str', is => 'rw');
has 'description' => (isa => 'Str', is => 'rw');
has 'extra' => (is => 'rw');
has 'longest_record' => (
	is        => 'ro',
	builder   => '_find_longest_record',
	clearer   => '_clear_longest_record',
	init_arg  => undef,
	lazy      => 1,
);
has '_container' => (
	is => 'ro',
	builder => '_build_container',
	init_arg => undef,
	lazy => 1
);

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
					$block->($record);
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


#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _build_container {
	return GenOO::Data::Structure::DoubleHashArray->new({
		SORTING_CODE_BLOCK => sub {return $_[0]->start <=> $_[1]->start}
	});
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
#######################   Deprecated Methods   ########################
#######################################################################
sub longest_entry {
	my ($self) = @_;
	warn 'Deprecated method "longest_entry". Use "longest_record" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->longest_record;
}

sub add_entry {
	my ($self, $record) = @_;
	warn 'Deprecated method "add_entry". Use "add_record" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->add_record($record);
}

sub foreach_entry_do {
	my ($self, $block) = @_;
	warn 'Deprecated method "foreach_entry_do". Use "foreach_record_do" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->foreach_record_do($block);
}

sub longest_entry_length {
	my ($self) = @_;
	warn 'Deprecated method "longest_entry_length". Use "longest_record->length" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->longest_record->length;
}

sub entries_count {
	my ($self) = @_;
	warn 'Deprecated method "entries_count". Use "records_count" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->records_count;
}

sub entries_overlapping_region {
	my ($self, $strand, $chr, $start, $stop) = @_;
	warn 'Deprecated method "entries_overlapping_region". Use "records_overlapping_region" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->records_overlapping_region($strand, $chr, $start, $stop);
}

sub chromosomes_for_strand {
	my ($self, $strand) = @_;
	warn 'Deprecated method "chromosomes_for_strand". Use "rnames_for_strand" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->rnames_for_strand($strand);
}

sub chromosomes_for_all_strands {
	my ($self, $strand) = @_;
	warn 'Deprecated method "chromosomes_for_all_strands". Use "rnames_for_all_strands" instead in '.(caller)[1].' line '.(caller)[2]."\n";
	return $self->rnames_for_all_strands;
}


__PACKAGE__->meta->make_immutable;
1;
