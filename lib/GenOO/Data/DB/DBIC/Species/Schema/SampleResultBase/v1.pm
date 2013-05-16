# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v1 - Base class for DBIx::Class compatible sequencing sample

=head1 SYNOPSIS

    # The class contains the common structure of sequencing sample database tables
    # It is not designed to be used as is but rather to be inherited.
    
=head1 DESCRIPTION

    The class contains the basic common functionality for database tables that correspond to sequencing
    samples. It offers accessor methods for table columns compatible with the rest of the GenOO framework.
    It consumes the GenOO::Region role. 
    
    This class is not designed to be instantiated but should rather be used through inheritance. The most 
    important reason why this happens is that it does not has a specific database table on which it can map.
    The table used within this class is defined as "Unknown" and should be overriden by derived classes.
    
=cut

# Let the code begin...

package GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v1;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

has 'strand'      => (is => 'rw', required => 1);
has 'rname'       => (isa => 'Str', is => 'rw', required => 1);
has 'start'       => (isa => 'Int', is => 'rw', required => 1);
has 'stop'        => (isa => 'Int', is => 'rw', required => 1);
has 'copy_number' => (isa => 'Int', is => 'rw', required => 1);
has 'sequence'    => (isa => 'Str', is => 'rw', required => 1);
has 'cigar'       => (isa => 'Str', is => 'rw', required => 1);
has 'mdz'         => (isa => 'Str', is => 'rw', required => 1);
has 'extra'       => (is => 'rw');

with 'GenOO::Region', 'GenOO::Data::File::SAM::CigarAndMDZ';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub sequence_length {
	my ($self) = @_;
	
	return CORE::length($self->sequence);
}

sub query_length {
	my ($self) = @_;
	
	return $self->sequence_length;
}

#######################################################################
#######################   Call Package Methods   ######################
#######################################################################
__PACKAGE__->table('Unknown');

__PACKAGE__->add_columns(
	'strand', {
		data_type => 'integer',
		is_nullable => 0,
		size => 1
	},
	'rname', {
		data_type => 'varchar',
		is_nullable => 0,
		size => 250
	},
	'start', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
	'stop', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
	'copy_number', {
		data_type => 'integer',
		default_value => 1,
		extra => { unsigned => 1 },
		is_nullable => 0,
	},
	'sequence', {
		data_type => 'varchar',
		is_nullable => 0,
		size => 250
	},
	'cigar', {
		data_type => 'varchar',
		is_nullable => 0,
		size => 250
	},
	'mdz', {
		data_type => 'varchar',
		is_nullable => 1,
		size => 250
	},
	'number_of_best_hits', {
		data_type => 'integer',
		is_nullable => 1
	},
);

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
