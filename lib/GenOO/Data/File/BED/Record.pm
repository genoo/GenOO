# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::File::BED::Record - Object representing a record of a bed file

=head1 SYNOPSIS

    # Object representing a record of a bed file 

    # To initialize 
    my $record = GenOO::Data::File::BED::Record->new({
        CHR          => undef,
        START        => undef,
        STOP_1       => undef,
        NAME         => undef,
        SCORE        => undef,
        STRAND       => undef,
        THICK_START  => undef,
        THICK_STOP   => undef,
        RGB          => undef,
        BLOCK_COUNT  => undef,
        BLOCK_SIZES  => undef,
        BLOCK_STARTS => undef,
        EXTRA_INFO   => undef,
    });


=head1 DESCRIPTION

    This object represents a record of a bed file and offers methods for accessing the different attributes.
    It implements several additional methods that transform original attributes in more manageable attributes.

=head1 EXAMPLES

    # Return 1 or -1 for the strand
    my $strand = $record->strand();

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
has 'block_sizes'       => (isa => 'ArrayRef', is => 'ro');
has 'block_starts'      => (isa => 'ArrayRef', is => 'ro');
has 'extra'             => (is => 'rw');
has 'copy_number'       => (isa => 'Int', is => 'ro', default => 1, lazy => 1);

# Define consuming roles
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
sub stop_1_based {
	my ($self) = @_;
	return $self->stop + 1;
}

#######################################################################
#########################   General Methods   #########################
#######################################################################

__PACKAGE__->meta->make_immutable;
1;
