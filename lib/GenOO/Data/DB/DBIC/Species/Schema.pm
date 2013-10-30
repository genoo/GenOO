# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::DB::DBIC::Species::Schema - Schema object

=head1 SYNOPSIS

    # All the database manipulation with DBIx::Class is done via one central Schema object
    # which maintains the connection to the database. This class inherits from DBIx::Class::Schema
    # and loads the tables with sequencing reads automatically.
    
    # To create a schema object, call connect on GenOO::Data::DB::DBIC::Species::Schema, passing it a Data Source Name.
    GenOO::Data::DB::DBIC::Species::Schema->connect("$connection_string");

=head1 DESCRIPTION

    -- Requesting a resultset with "sample_resultset"
    In High Troughput Sequencing analysis we usually have many db tables with similar
    structure and columns. Unfortunalely, DBIx::Class requires each Result class to specify
    the table name explicitly which means that we would have to explicitly create a Result class
    for every db table. To avoid this, upon request we dynamically create (meta-programming) a new Result class for the provided table name. The new Result class inherits the table structure from
    a base class which is also provided.
    
    One can also hard code a Result class under the namespace  GenOO::Data::DB::DBIC::Species::Schema::Result and it will also be registered under the schema.
    
    The implementation follows draegtun suggestion in
    L<http://stackoverflow.com/questions/14515153/use-dbixclass-with-a-single-result-class-definition-to-handle-several-tables-w>

=head1 EXAMPLES

    my $schema = GenOO::Data::DB::DBIC::Species::Schema->connect("dbi:mysql:dbname=$database;host=$host;", $user, $pass);
    my $result_set = $schema->resultset('sample_table_name');
    
=cut

# Let the code begin...

package GenOO::Data::DB::DBIC::Species::Schema;


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
extends 'DBIx::Class::Schema';


#######################################################################
########################   Interface Methods   ########################
#######################################################################
sub sample_resultset {
	my ($self, $records_class, @args) = @_;
	
	my $table_name = $args[0];
	my $class = ref($self) || $self;
	
	if (not $self->_source_exists($table_name)) {
		$self->_create_and_register_result_class_for($table_name, $records_class);
	}
	
	return $self->resultset(@args);
}


#######################################################################
#########################   Private Methods   #########################
#######################################################################
sub _source_exists {
	my ($self, $table_name) = @_;
	
	return 1 if (grep {$_ eq $table_name} $self->sources);
	return 0;
}

sub _create_and_register_result_class_for {
	my ($self, $table_name, $records_class) = @_;
	
	$self->_create_sample_result_class_for($table_name, $records_class);
	$self->register_class($table_name, 'GenOO::Data::DB::DBIC::Species::Schema::Result::'.$table_name);
}

=head2 _create_sample_result_class_for
  Arg [1]    : The database table name for a sample table.
  Description: A result class is created using the provided table name
               The new class inherits from $records_class
  Returntype : DBIx::Class Result class
=cut
sub _create_sample_result_class_for {
	my ($self, $table_name, $records_class) = @_;
	
	eval "require $records_class";
	
	my $table_class = "GenOO::Data::DB::DBIC::Species::Schema::Result::$table_name";
	{
		no strict 'refs';
		@{$table_class . '::ISA'} = ($records_class);
	}
	$table_class->table($table_name);
}


#######################################################################
#########################   Package Methods   #########################
#######################################################################
__PACKAGE__->load_namespaces; # Load classes from GenOO::Data::DB::DBIC::Species::Schema::Result/ResultSet


#######################################################################
############################   Finalize   #############################
#######################################################################
__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
