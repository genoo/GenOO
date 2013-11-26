# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v2 - DBIC Result class for sequenced reads

=head1 SYNOPSIS

    # This class is not designed to be directly used in a DBIC schema because a 
    # table name is not defined. Rather it serves as a base class to be inherited
    # by an actual result class to provide a common column structure.
    
    # Offers more columns than GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v1
    
=head1 DESCRIPTION

    In High Troughput Sequencing analysis we usually have many db tables with similar
    structure and columns. DBIx::Class requires each Result class to specify the table name
    explicitly. This means that we would have to explicitly create a Result class for
    every db table. For this we created this class (does not specify a table name) which can
    be inherited by other Result classes and provide a common table structure.
    
    The class contains the basic common functionality for database tables that contain 
    sequenced reads. It offers accessor methods for table columns compatible with the
    rest of the GenOO framework. 
    
    It consumes the GenOO::Region role.
    
    As mentioned above this class should be used through inheritance. The reason for this
    is that it does not have a specific database table on which it maps. The table used
    within this class is defined as "Unknown" and should be specified by derived classes.
    
=cut

# Let the code begin...

package GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase::v2;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use Moose;
use namespace::autoclean;
use MooseX::MarkAsMethods autoclean => 1;


#######################################################################
############################   Inheritance   ##########################
#######################################################################
extends 'DBIx::Class::Core';


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
# The interface attributes section provides Moose like accessors for
# the table columns. These methods basically overide those created by
# DBIx::Class. The column types are defined at the end of the class in
# the "Package Methods" section

has 'strand' => (
	is => 'rw',
);

has 'rname' => (
	is => 'rw',
);

has 'start' => (
	is => 'rw',
);

has 'stop' => (
	is => 'rw',
);

has 'copy_number' => (
	is => 'rw', 
);

has 'sequence' => (
	is => 'rw',
);

has 'cigar' => (
	is => 'rw',
);

has 'mdz' => (
	is => 'rw',
);

has 'number_of_mappings' => (
	is => 'rw',
);

has 'query_length' => (
	is => 'rw',
);

has 'alignment_length' => (
	is => 'rw',
);

has 'extra' => (
	is => 'rw'
);


#######################################################################
##########################   Consumed roles   #########################
#######################################################################
with
	'GenOO::Region' => {
		-alias    => { mid_position => 'region_mid_position' },
		-excludes => 'mid_position',
	},
	'GenOO::Data::File::SAM::CigarAndMDZ' => {
	};


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub sequence_length {
	my ($self) = @_;
	
	return $self->query_length if defined $self->query_length;
	return CORE::length($self->sequence);
}


#######################################################################
#########################   Package Methods   #########################
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
	'number_of_mappings', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 1
	},
	'query_length', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
	'alignment_length', {
		data_type => 'integer',
		extra => { unsigned => 1 },
		is_nullable => 0
	},
);


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
