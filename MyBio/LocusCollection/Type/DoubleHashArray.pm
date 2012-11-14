# POD documentation - main docs before the code

=head1 NAME

MyBio::LocusCollection::Type::DoubleHashArray - Object for a collection of MyBio::Locus objects, with features

=head1 SYNOPSIS

    # Object that manages a collection of MyBio::Locus objects. 

    # To initialize 
    my $locus_collection = MyBio::LocusCollection::DoubleHashArray->new({
        name          => undef,
        species       => undef,
        description   => undef,
        extra         => undef,
    });


=head1 DESCRIPTION

    The primary data structure of this object is a 2D hash whose primary key is the strand 
    and its secondary key is the chromosome name. Each such pair of keys correspond to an
    array reference which stores objects of the class L<MyBio::Locus> sorted by start position.

=head1 EXAMPLES

    # Print entries in FASTA format
    $locus_collection->print("FASTA",'STDOUT',"/data1/data/UCSC/hg19/chromosomes/");
    
    # ditto
    $locus_collection->print_in_fasta_format('STDOUT',"/data1/data/UCSC/hg19/chromosomes/");

=cut

# Let the code begin...

package MyBio::LocusCollection::Type::DoubleHashArray;

use Moose;
use namespace::autoclean;

use MyBio::MySub;
use MyBio::Module::Search::Binary;
use MyBio::Data::Structure::DoubleHashArray;


has 'name' => (isa => 'Str', is => 'rw');
has 'species' => (isa => 'Str', is => 'rw');
has 'description' => (isa => 'Str', is => 'rw');
has 'extra' => (is => 'rw');
has 'longest_entry' => (
	is        => 'ro',
	builder   => '_find_longest_entry',
	clearer   => '_clear_longest_entry',
	init_arg  => undef,
	lazy      => 1,
);
has '_container' => (
	is => 'ro',
	builder => '_build_container',
	init_arg => undef,
	lazy => 1
);

with 'MyBio::LocusCollection';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub add_entry {
	my ($self, $entry) = @_;
	$self->_container->add_entry($entry->strand, $entry->chr, $entry);
	$self->_reset;
}

sub foreach_entry_do {
	my ($self, $block) = @_;
	$self->_container->foreach_entry_do($block);
}

sub entries_count {
	my ($self) = @_;
	return $self->_container->entries_count;
}

sub strands {
	my ($self) = @_;
	return $self->_container->primary_keys();
}

sub chromosomes_for_strand {
	my ($self, $strand) = @_;
	return $self->_container->secondary_keys_for_primary_key($strand);
}

sub chromosomes_for_all_strands {
	my ($self) = @_;
	return $self->_container->secondary_keys_for_all_primary_keys();
}

sub longest_entry_length {
	my ($self) = @_;
	return $self->longest_entry->length;
}

sub is_empty {
	my ($self) = @_;
	return $self->_container->is_empty;
}

sub is_not_empty {
	my ($self) = @_;
	return $self->_container->is_not_empty;
}

sub entries_overlapping_region {
	my ($self, $strand, $chr, $start, $stop) = @_;
	
	$self->_container->sort_entries;
	my $entries_ref = $self->_entries_ref_for_strand_and_chromosome($strand, $chr) or return ();
	
	my $target_value = $start - $self->longest_entry->length;
	my $index = MyBio::Module::Search::Binary->binary_search_for_value_greater_or_equal($target_value, $entries_ref, sub {return $_[0]->start});
	
	if (defined $index) {
		my @overlapping_entries;
		while ($index < @$entries_ref) {
			my $entry = $entries_ref->[$index];
			if ($entry->start <= $stop) {
				if ($start <= $entry->stop) {
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
	else {
		return ();
	}
}


#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _build_container {
	return MyBio::Data::Structure::DoubleHashArray->new({
		SORTING_CODE_BLOCK => sub {return $_[0]->start <=> $_[1]->start}
	});
}

sub _find_longest_entry {
	my ($self) = @_;
	
	my $longest_entry;
	my $longest_entry_length = 0;
	$self->foreach_entry_do(
		sub {
			my ($entry) = @_;
			
			if ($entry->length > $longest_entry_length) {
				$longest_entry_length = $entry->length;
				$longest_entry = $entry;
			}
		}
	);
	
	return $longest_entry;
}

sub _entries_ref_for_strand_and_chromosome {
	my ($self, $strand, $chr) = @_;
	return $self->_container->entries_ref_for_keys($strand, $chr);
}

sub _reset {
	my ($self) = @_;
	$self->_clear_longest_entry;
}

#######################################################################
##################   Methods that modify the object  ##################
#######################################################################
=head2 set_sequence_for_all_entries
  Arg [1]    : Hash reference containing parameters.
               Required parameters:
                  1/ CHR_FOLDER: The folder that contains fasta files with the chromosome sequences
  Example    : set_sequence_for_all_entries({
                 CHR_FOLDER       => "/chromosomes/hg19/"
               })
  Description: Sets the sequence attribute for all entries in the LocusCollection.
=cut
sub set_sequence_for_all_entries {
	my ($self, $params) = @_;
	
	my $chr_folder = delete $params->{'CHR_FOLDER'};
	unless (defined $chr_folder) {
		die "Error. The CHR_FOLDER must be specified in ".(caller(0))[3]."\n";
	}
	
	my $current_chr;
	my $current_chr_seq;
	$self->foreach_entry_do( sub {
		my ($entry) = @_;
		
		if ($entry->chr ne $current_chr) {
			my $chr_file = $chr_folder.'/'.$entry->chr.'.fa';
			if (-e $chr_file) {
				$current_chr_seq = MyBio::MySub::read_fasta($chr_file, $entry->chr);
				$current_chr = $entry->chr;
			}
			else {
				warn "Skipping chromosome. File $chr_file does not exist";
				next;
			}
		}
		
		my $entry_seq = substr($current_chr_seq, $entry->start, $entry->length);
		if ($entry->strand == -1) {
			$entry_seq = reverse($entry_seq);
			if ($entry_seq =~ /U/i) {
				$entry_seq =~ tr/ATGCUatgcu/UACGAuacga/;
			}
			else {
				$entry_seq =~ tr/ATGCUatgcu/TACGAtacga/;
			}
		}
		$entry->set_sequence($entry_seq);
	});
}

__PACKAGE__->meta->make_immutable;
1;
