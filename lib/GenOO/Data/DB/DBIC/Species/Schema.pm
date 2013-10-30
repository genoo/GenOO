# POD documentation - main docs before the code

=head1 NAME

GenOO::Data::DB::DBIC::Species::Schema - Schema object

=head1 SYNOPSIS

    # All the database manipulation with DBIx::Class is done via one central Schema object
    # which maintains the connection to the database. This class inherits from DBIx::Class::Schema
    # and loads the tables for the sequencing samples automatically.
    
    # To create a schema object, call connect on GenOO::Data::DB::DBIC::Species::Schema, passing it a Data Source Name.
    GenOO::Data::DB::DBIC::Species::Schema->connect("$connection_string");

=head1 DESCRIPTION

    This class dynamically creates a new class for each sequencing sample database table and automatically
    loads it under the schema namespace. Since all tables have almost the same structure all dynamically
    created classes are subclasses of a main class under GenOO::Data::DB::DBIC::Species::Schema::SampleResultBase
    which contains the common functionality. If a table has special structure and requires a class of its
    own a new class must be hard coded under the namespace GenOO::Data::DB::DBIC::Species::Schema::Result.
    
    The implementation follows draegtun suggestion in
    L<http://stackoverflow.com/questions/14515153/use-dbixclass-with-a-single-result-class-definition-to-handle-several-tables-w>

=head1 EXAMPLES

    my $schema = GenOO::Data::DB::DBIC::Species::Schema->connect("dbi:mysql:dbname=$database;host=$host;", $user, $pass);
    my $result_set = $schema->resultset('sample_table_name');
    
=cut

# Let the code begin...

package GenOO::Data::DB::DBIC::Species::Schema;

use Modern::Perl;
use Moose;
use namespace::autoclean;
use MooseX::MarkAsMethods autoclean => 1;

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
	
	if (grep {$_ eq $table_name} $self->sources) {
		return 1;
	}
	else {
		return 0;
	}
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
#######################   Call Package Methods   ######################
#######################################################################
__PACKAGE__->load_namespaces; # Load classes from GenOO::Data::DB::DBIC::Species::Schema::Result/ResultSet

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
