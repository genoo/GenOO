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


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Modern::Perl;
use autodie;
use Moose;
use namespace::autoclean;


#######################################################################
########################   Load GenOO modules   #######################
#######################################################################
use GenOO::RegionCollection::Type::DBIC;


#######################################################################
#######################   Interface attributes   ######################
#######################################################################
has 'dsn' => (
	isa      => 'Str',
	is       => 'ro',
	builder  => '_build_dsn',
	lazy     => 1
);

has 'user' => (
	isa => 'Maybe[Str]',
	is => 'ro'
);

has 'password' => (
	isa => 'Maybe[Str]',
	is  => 'ro'
);

has 'attributes' => (
	traits    => ['Hash'],
	is        => 'ro',
	isa       => 'HashRef[Str]',
	default   => sub { {} },
);

has 'driver' => (
	isa => 'Str',
	is  => 'ro',
);

has 'database' => (
	isa => 'Str',
	is  => 'ro',
);

has 'table' => (
	isa => 'Str',
	is  => 'ro',
);

has 'records_class' => (
	is        => 'ro',
);

has 'host' => (
	isa => 'Maybe[Str]',
	is  => 'ro',
);

has 'port' => (
	isa => 'Maybe[Int]',
	is  => 'ro',
);


#######################################################################
##########################   Consumed Roles   #########################
#######################################################################
with 'GenOO::RegionCollection::Factory::Requires';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub read_collection {
	my ($self) = @_;
	
	my $init_data = {
		dsn    => $self->dsn,
	};
	($init_data->{table}         = $self->table)         if defined $self->table;
	($init_data->{attributes}    = $self->attributes)    if defined $self->attributes;
	($init_data->{user}          = $self->user)          if defined $self->user;
	($init_data->{password}      = $self->password)      if defined $self->password;
	($init_data->{records_class} = $self->records_class) if defined $self->records_class;
	
	return GenOO::RegionCollection::Type::DBIC->new($init_data);
}

#######################################################################
#########################   Private Methods   #########################
#######################################################################
sub _build_dsn {
	my ($self) = @_;
	
	my $dsn = 'dbi:'.$self->driver.':database='.$self->database;
	$dsn .= ';host='.$self->host if defined $self->host;
	$dsn .= ';port='.$self->port if defined $self->port;
	
	return $dsn;
}

1;
