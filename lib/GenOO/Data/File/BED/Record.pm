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
has 'block_sizes'       => (isa => 'ArrayRef', is => 'ro');
has 'block_starts'      => (isa => 'ArrayRef', is => 'ro');
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

#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable;

1;
