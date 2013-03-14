# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Type::DBIC - Class for a collection of GenOO::Region objects stored in a database.

=head1 SYNOPSIS

    # Object that corresponds to a collection of GenOO::Region objects.
    # To initialize 
    my $region_collection = GenOO::RegionCollection::DB->new(
        driver      => undef,
        host        => undef,
        database    => undef,
        table       => undef,
        user        => undef,
        password    => undef,
        port        => undef,
        name        => undef,
        species     => undef,
        description => undef,
        extra       => undef,
    );


=head1 DESCRIPTION

    This class consumes the L<GenOO::RegionCollection> role.
    An instance of this class corresponds to a collection of records consuming the L<GenOO::Region>
    role.The records are stored in a database (ie MySQL, SQLite, etc) and the class offers methods 
    for quering them and accessing specific characteristics (eg. longest record). Internally the class
    rests on DBIx::Class for the database access and for defining the appropriate result objects.
    Note that the columns which correspond to the required attributes of L<GenOO::Region> must exist
    in the table schema (ie. strand, rname, start, stop, copy_number)

=head1 EXAMPLES

    # Get the records overlapping a specific region
    my @records = $region_collection->records_overlapping_region(1,'chr3',127726308,127792250);
    
    # Get the longest record
    my $longest_record = $region_collection->longest_record;
    
=cut

# Let the code begin...

package GenOO::RegionCollection::Type::DBIC;

use Moose;
use namespace::autoclean;

use GenOO::Data::DB::DBIC::Species::Schema;

has 'driver'      => (isa => 'Str', is => 'ro', default => 'mysql');
has 'host'        => (isa => 'Str', is => 'ro', default => 'localhost');
has 'database'    => (isa => 'Str', is => 'ro', required => 1);
has 'table'       => (isa => 'Str', is => 'ro', required => 1);
has 'user'        => (isa => 'Str', is => 'ro');
has 'password'    => (isa => 'Str', is => 'ro');
has 'port'        => (isa => 'Int', is => 'ro', default => 3306);
has 'name'        => (isa => 'Str', is => 'rw');
has 'species'     => (isa => 'Str', is => 'rw');
has 'description' => (isa => 'Str', is => 'rw');
has 'extra'       => (is => 'rw');

has 'schema' => (
	isa       => 'GenOO::Data::DB::DBIC::Species::Schema',
	is        => 'ro',
	builder   => '_init_schema',
	init_arg  => undef,
	lazy      => 1,
);

has 'resultset' => (
	is        => 'ro',
	builder   => '_init_resultset',
	init_arg  => undef,
	lazy      => 1,
);

has 'longest_record' => (
	is        => 'ro',
	builder   => '_find_longest_record',
	clearer   => '_clear_longest_record',
	init_arg  => undef,
	lazy      => 1,
);

with 'GenOO::RegionCollection';

#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub add_record {
	my ($self, $record) = @_;
	
	warn 'Method "add_record" has not been implemented yet'; # TODO
	$self->_reset;
}

sub foreach_record_do {
	my ($self, $block) = @_;
	
	while (my $record = $self->resultset->next) {
		$block->($record);
	}
}

sub records_count {
	my ($self) = @_;
	
	return $self->resultset->count || 0;
}

sub strands {
	my ($self) = @_;
	
	return $self->resultset->search({},{
		columns  => [ qw/strand/ ],
		distinct => 1
	})->get_column('strand')->all;
}

sub rnames_for_strand {
	my ($self, $strand) = @_;
	
	return $self->resultset->search({
		strand => $strand
	},{
		columns  => [ qw/strand/ ],
		distinct => 1
	})->get_column('rname')->all;
}

sub rnames_for_all_strands {
	my ($self) = @_;
	
	return $self->resultset->search({},{
		columns  => [ qw/rname/ ],
		distinct => 1
	})->get_column('rname')->all;;
}

sub is_empty {
	my ($self) = @_;
	
	if ($self->records_count > 0) {
		return 0;
	}
	else {
		return 1;
	}
}

sub is_not_empty {
	my ($self) = @_;
	
	return !$self->is_empty;
}

sub foreach_overlapping_record_do {
	my ($self, $strand, $rname, $start, $stop, $block) = @_;
	
	my $rs = $self->resultset->search({
		strand => $strand,
		rname => $rname,
		start => { '-between' => [$start, $stop] },
		stop => { '-between' => [$start, $stop] },
	});
	
	while (my $record = $rs->next) {
		$block->($record);
	}
}

sub records_overlapping_region {
	my ($self, $strand, $rname, $start, $stop) = @_;
	
	return $self->resultset->search({
		strand => $strand,
		rname => $rname,
		start => { '-between' => [$start, $stop] },
		stop => { '-between' => [$start, $stop] },
	})->all;
}

sub total_copy_number_for_records_contained_in_region {
	my ($self, $strand, $rname, $start, $stop) = @_;
	
	return $self->resultset->search({
		strand => $strand,
		rname => $rname,
		start => { '-between' => [$start, $stop] },
		stop => { '-between' => [$start, $stop] },
	})->get_column('copy_number')->sum || 0;
}

sub total_copy_number {
	my ($self) = @_;
	
	return $self->resultset->get_column('copy_number')->sum || 0;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _init_schema {
	my ($self) = @_;
	
	my $connection_str = 'dbi:'.$self->driver.':dbname='.$self->database.';host='.$self->host.';port='.$self->port;
	
	return GenOO::Data::DB::DBIC::Species::Schema->connect($connection_str, $self->user, $self->password);
}

sub _init_resultset {
	my ($self) = @_;
	
	return $self->schema->sample_resultset($self->table);
}

sub _find_longest_record {
	my ($self) = @_;
	
	return $self->resultset->search({}, {
		order_by => { -desc => 'stop-start+1' },
		rows => 1,
	})->single;
}

sub _reset {
	my ($self) = @_;
	
	$self->_clear_longest_record;
}


__PACKAGE__->meta->make_immutable;

1;
