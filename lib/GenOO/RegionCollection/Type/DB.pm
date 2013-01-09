# POD documentation - main docs before the code

=head1 NAME

GenOO::RegionCollection::Type::DB - Class for a collection of GenOO::Region objects stored in a database.

=head1 SYNOPSIS

    # Object that corresponds to a collection of GenOO::Region objects.
    # To initialize 
    my $region_collection = GenOO::RegionCollection::DB->new({
        driver      => undef,
        host        => undef,
        database    => undef,
        table       => undef,
        user        => undef,
        password    => undef,
        port        => undef,
        record_type => undef,
        name        => undef,
        species     => undef,
        description => undef,
        extra       => undef,
        species     => undef,
        description => undef,
        extra       => undef,
    });


=head1 DESCRIPTION

    This class consumes the L<GenOO::RegionCollection> role.
    An object of this class is a collection of objects (records) consuming the L<GenOO::Region>
    role.The records are stored in a database (ie MySQL, SQLite, etc) and the class offers methods 
    for quering them and accessing specific characteristics (eg. longest record). When creating
    an object of this class it is necessary to provide the name of the class which corresponds to
    and can handle the records of the database (eg L<GenOO::Data::DB::Alignment::Record>). This
    is important because the class has been designed in a generic way so that it can support
    various table schemas with possible extra fields. The class does not know how to create
    the corresponding record objects and it relies on the provided class to do so. The class just
    passes the hash reference as returned by the DBI connector. Methods that return records, return 
    objects of the provided class. Note that columns which correspond to the required attributes 
    of L<GenOO::Region> must exist in the table schema (ie. strand, rname, start, stop,copy_number)

=head1 EXAMPLES

    # Get the records overlapping a specific region
    my @records = $region_collection->records_overlapping_region(1,'chr3',127726308,127792250);
    
    # Get the longest record
    my $longest_record = $region_collection->longest_record;
    
=cut

# Let the code begin...

package GenOO::RegionCollection::Type::DB;

use Moose;
use namespace::autoclean;

use GenOO::Data::DB::Connector;

has 'driver'      => (isa => 'Str', is => 'ro', required => 1);
has 'host'        => (isa => 'Str', is => 'ro', required => 1);
has 'database'    => (isa => 'Str', is => 'ro', required => 1);
has 'table'       => (isa => 'Str', is => 'ro', required => 1);
has 'user'        => (isa => 'Str', is => 'ro');
has 'password'    => (isa => 'Str', is => 'ro');
has 'port'        => (isa => 'Int', is => 'ro');
has 'record_type' => (isa => 'Str', is => 'ro', required => 1);
has 'name'        => (isa => 'Str', is => 'rw');
has 'species'     => (isa => 'Str', is => 'rw');
has 'description' => (isa => 'Str', is => 'rw');
has 'extra'       => (is => 'rw');

has 'longest_record' => (
	is        => 'ro',
	builder   => '_find_longest_record',
	clearer   => '_clear_longest_record',
	init_arg  => undef,
	lazy      => 1,
);

has '_db_connector' => (
	isa       => 'GenOO::Data::DB::Connector',
	is        => 'ro',
	builder   => '_build_db_connector',
	init_arg  => undef,
	lazy       => 1
);

has '_db_handle' => (
	is        => 'ro',
	builder   => '_build_db_handle',
	init_arg  => undef,
	lazy      => 1
);

has '_select_sum_copy_number_in_region' => (
	is        => 'ro',
	builder   => '_prepare_select_sum_copy_number_in_region',
	init_arg  => undef,
	lazy      => 1
);

with 'GenOO::RegionCollection';

sub BUILD {
	my $self = shift;

	eval 'require '.$self->record_type;
}

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
	
	my $select = $self->_db_handle->prepare(
		$self->_statement_select_star
	);
	
	$select->execute;
	
	while (my $hash_ref = $select->fetchrow_hashref) {
		my $record = $self->record_type->new($hash_ref);
		$block->($record);
	}
}

sub records_count {
	my ($self) = @_;
	
	my @res = $self->_db_handle->selectrow_array(
		'SELECT COUNT(*) FROM '.$self->_statement_table_name
	);
	
	return $res[0];
}

sub strands {
	my ($self) = @_;
	
	my $strands_ref = $self->_db_handle->selectcol_arrayref(
		'SELECT DISTINCT(strand) FROM '.$self->_statement_table_name
	);
	
	return sort @$strands_ref;
}

sub rnames_for_strand {
	my ($self, $strand) = @_;
	
	my $rname_ref = $self->_db_handle->selectcol_arrayref(
		'SELECT DISTINCT(rname) FROM '.$self->_statement_table_name.
		' WHERE strand='.$strand
	);
	
	return sort @$rname_ref;
}

sub rnames_for_all_strands {
	my ($self) = @_;
	
	my $rname_ref = $self->_db_handle->selectcol_arrayref(
		'SELECT DISTINCT(rname) FROM '.$self->_statement_table_name
	);
	
	return sort @$rname_ref;
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
	
	my $select = $self->_db_handle->prepare(
		$self->_statement_select_star.
		' WHERE `strand`=? AND `rname`=? AND `start` BETWEEN ? AND ? AND `stop` BETWEEN ? AND ?'
	);
	
	$select->execute($strand, $rname, $start, $stop, $start, $stop);
	
	while (my $hash_ref = $select->fetchrow_hashref) {
		my $record = $self->record_type->new($hash_ref);
		$block->($record);
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

sub total_copy_number_for_records_overlapping_region {
	my ($self, $strand, $rname, $start, $stop, $block) = @_;
	
	my @res = $self->_db_handle->selectrow_array($self->_select_sum_copy_number_in_region, {}, $strand, $rname, $start, $stop, $start, $stop);
	
	return $res[0] || 0;
}

#######################################################################
#########################   Private methods  ##########################
#######################################################################
sub _build_db_connector {
	my ($self) = @_;
	
	my $data = {
		driver   => $self->driver,
		host     => $self->host,
		database => $self->database,
	};
	
	($data->{user} = $self->user) if defined $self->user;
	($data->{password} = $self->password) if defined $self->password;
	($data->{port} = $self->port) if defined $self->port;
	
	return GenOO::Data::DB::Connector->new($data);
}

sub _build_db_handle {
	my ($self) = @_;
	
	return $self->_db_connector->handle;
}

sub _find_longest_record {
	my ($self) = @_;
	
	my $hashref = $self->_db_handle->selectrow_hashref(
		$self->_statement_select_star.
		' ORDER BY (stop-start+1) DESC LIMIT 1'
	);
	return $self->record_type->new($hashref);
}

sub _reset {
	my ($self) = @_;
	
	$self->_clear_longest_record;
}

sub _statement_select_star {
	my ($self) = @_;
	
	return 'SELECT * FROM '.$self->_statement_table_name;
}

sub _statement_table_name {
	my ($self) = @_;
	
	return '`'.$self->database.'`.`'.$self->table.'`';
}

sub _prepare_select_sum_copy_number_in_region {
	my ($self) = @_;
	
	return $self->_db_handle->prepare(
		'SELECT SUM(copy_number) FROM '.$self->_statement_table_name.
		' WHERE `strand`=? AND `rname`=? AND `start` BETWEEN ? AND ? AND `stop` BETWEEN ? AND ?'
	);
}


__PACKAGE__->meta->make_immutable;

1;
