# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Factory::DB - Factory for creating GenOO::RegionCollection object from a database table

=head1 SYNOPSIS

    # Creates GenOO::RegionCollection object from a database table 

    # Preferably use it through the generic GenOO::RegionCollection::Factory
    my $db_factory_implementation = GenOO::RegionCollection::Factory->new('DB',
        {
            driver      => undef,
            host        => undef,
            database    => undef,
            table       => undef,
            record_type => undef,
            user        => undef,
            password    => undef,
            port        => undef,
        }
    );

=head1 DESCRIPTION

    An instance of this class is a concrete factory for a GenOO::RegionCollection
    object. It offers the method "read_collection" (as the consumed role requires)
    which returns the actual GenOO::RegionCollection object in the form of 
    GenOO::RegionCollection::Type::DB. The latter is the implementation of the 
    GenOO::RegionCollection class based on a database table.

=head1 EXAMPLES

    # Create a concrete factory
    my $factory_implementation = GenOO::RegionCollection::Factory->new('DB',
        {
            file => 'sample.sam'
        }
    );
    
    # Return the actual GenOO::RegionCollection object
    my $collection = $factory_implementation->read_collection;
    print ref($collection) # GenOO::RegionCollection::Type::DB
    
=cut

# Let the code begin...

package GenOO::RegionCollection::Factory::DBIC;

use Moose;
use namespace::autoclean;

use GenOO::RegionCollection::Type::DBIC;

has 'driver'      => (isa => 'Str', is => 'ro', default => 'mysql');
has 'host'        => (isa => 'Str', is => 'ro', default => 'localhost');
has 'database'    => (isa => 'Str', is => 'ro', required => 1);
has 'table'       => (isa => 'Str', is => 'ro', required => 1);
has 'user'        => (isa => 'Str', is => 'ro');
has 'password'    => (isa => 'Str', is => 'ro');
has 'port'        => (isa => 'Int', is => 'ro', default => 3306);

with 'GenOO::RegionCollection::Factory::Requires';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $init_data = {
		database    => $self->database,
		table       => $self->table,
	};
	($init_data->{driver}   = $self->driver)   if defined $self->driver;
	($init_data->{host}     = $self->host)     if defined $self->host;
	($init_data->{user}     = $self->user)     if defined $self->user;
	($init_data->{password} = $self->password) if defined $self->password;
	($init_data->{port}     = $self->port)     if defined $self->port;
	
	return GenOO::RegionCollection::Type::DBIC->new($init_data);
}

1;
