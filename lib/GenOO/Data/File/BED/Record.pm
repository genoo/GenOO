# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::BED::Record - Object representing a record of a bed file

=head1 SYNOPSIS

    # Object representing a record of a bed file 

    # To initialize 
    my $record = GenOO::Data::File::BED::Record->new({
        rname             => undef,
        start             => undef,
        stop_1based       => undef,
        name              => undef,
        score             => undef,
        strand_symbol     => undef,
        thick_start       => undef,
        thick_stop_1based => undef,
        rgb               => undef,
        block_count       => undef,
        block_sizes       => undef,
        block_starts      => undef,
        copy_number       => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a bed file and offers methods for accessing the different attributes.
    It implements several additional methods that transform original attributes in more manageable attributes.

=head1 EXAMPLES

    # Return strand
    my $strand = $record->strand; # -1
    my $strand_symbol = $record->strand_symbol; # -
    
    # Return stop position
    my $stop = $record->stop; #10
    my $stop_1based = $record->stop_1based; #11
    
    # Return location
    my $location = $record->location;

=cut

# Let the code begin...

package GenOO::Data::File::BED::Record;

use Moose;
use namespace::autoclean;

# Define the attributes
has 'rname'             => (isa => 'Str', is => 'ro', required => 1);
has 'start'             => (isa => 'Int', is => 'ro', required => 1);
has 'stop'              => (isa => 'Int', is => 'ro', required => 1);
has 'name'              => (isa => 'Str', is => 'ro', required => 1);
has 'score'             => (isa => 'Num', is => 'ro', required => 1);
has 'strand'            => (isa => 'Int', is => 'ro', required => 1);
has 'thick_start'       => (isa => 'Int', is => 'ro');
has 'thick_stop_1based' => (isa => 'Int', is => 'ro');
has 'rgb'               => (isa => 'Str', is => 'ro');
has 'block_count'       => (isa => 'Int', is => 'ro');
has 'block_sizes' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[Int]',
	default => sub { [] },
	handles => {
		all_block_sizes    => 'elements',
		add_block_size     => 'push',
		map_block_sizes    => 'map',
		filter_block_sizes => 'grep',
		find_block_size    => 'first',
		get_block_size     => 'get',
		join_block_sizes   => 'join',
		count_block_sizes  => 'count',
		has_block_sizes    => 'count',
		has_no_block_sizes => 'is_empty',
		sorted_block_sizes => 'sort',
	},
);
has 'block_starts' => (
	traits  => ['Array'],
	is      => 'ro',
	isa     => 'ArrayRef[Int]',
	default => sub { [] },
	handles => {
		all_block_starts    => 'elements',
		add_block_start     => 'push',
		map_block_starts    => 'map',
		filter_block_starts => 'grep',
		find_block_start    => 'first',
		get_block_start     => 'get',
		join_block_starts   => 'join',
		count_block_starts  => 'count',
		has_block_starts    => 'count',
		has_no_block_starts => 'is_empty',
		sorted_block_starts => 'sort',
	},
);
has 'extra'             => (is => 'rw');
has 'copy_number'       => (isa => 'Int', is => 'ro', default => 1, lazy => 1);

# Consume roles
with 'GenOO::Region';

# Before object creation edit the hash with the arguments to resolve 1 based and strand symbol
around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;
	
	my $argv_hash_ref = $class->$orig(@_);
	
	if (exists $argv_hash_ref->{stop_1based}) {
		$argv_hash_ref->{stop} = $argv_hash_ref->{stop_1based} - 1;
	}
	if (exists $argv_hash_ref->{strand_symbol}) {
		if ($argv_hash_ref->{strand_symbol} eq '+') {
			$argv_hash_ref->{strand} = 1;
		}
		elsif ($argv_hash_ref->{strand_symbol} eq '-') {
			$argv_hash_ref->{strand} = -1;
		}
	}
	
	return $argv_hash_ref;
};

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub stop_1based {
	my ($self) = @_;
	return $self->stop + 1;
}

sub to_string {
	my ($self) = @_;
	
	my @fields = (
		$self->rname, 
		$self->start,
		$self->stop_1based,
		$self->name,
		$self->score,
		$self->strand_symbol);
	
	push @fields, $self->thick_start if defined $self->thick_start;
	push @fields, $self->thick_stop_1based if defined $self->thick_stop_1based;
	push @fields, $self->rgb if defined $self->rgb;
	push @fields, $self->block_count if defined $self->block_count;
	push @fields, $self->join_block_sizes(",") if $self->has_block_sizes;
	push @fields, $self->join_block_starts(",") if $self->has_block_starts;
	
	return join("\t", @fields);
}

#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
