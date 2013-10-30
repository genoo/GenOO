package TestsFor::GenOO::RegionCollection::Factory::DBIC;


#######################################################################
#######################   Load External modules   #####################
#######################################################################
use Test::Class::Moose;
with 'MyTCM::Testable';


#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub test_setup {
	my ( $test, $report ) = @_;
	
	$test->next::method;
	$test->_clear_testable_objects;
}


#######################################################################
###########################   Test methods   ##########################
#######################################################################
sub test_class_type {
	my ($test) = @_;
	
	isa_ok $test->get_testable_object(0), $test->class_name, "1st object";
	isa_ok $test->get_testable_object(1), $test->class_name, "2nd object";
}

sub test_dsn {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(0), 'dsn';
	
	my $expected_0 = 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db';
	is $test->get_testable_object(0)->dsn, $expected_0, "dsn should be correct";
	my $expected_1 = 'dbi:mysql:database=sample_db;host=localhost;port=3306';
	is $test->get_testable_object(1)->dsn, $expected_1, "dsn should be created correctly";
}


sub test_read_collection {
	my ($test) = @_;
	
	can_ok $test->get_testable_object(1), 'read_collection';
	
	isa_ok $test->get_testable_object(0)->read_collection, 'GenOO::RegionCollection::Type::DBIC', "returned object";
	isa_ok $test->get_testable_object(1)->read_collection, 'GenOO::RegionCollection::Type::DBIC', "returned object";
}


#######################################################################
#########################   Private Methods   #########################
#######################################################################
sub _init_testable_objects {
	my ($test) = @_;
	
	return [$test->map_data_for_testable_objects(sub {$test->class_name->new($_)})];
}

sub _init_data_for_testable_objects {
	my ($test) = @_;
	
	my @data;
	
	push @data, {
		dsn => 'dbi:SQLite:database=t/sample_data/sample.alignments.sqlite.db',
	};
	
	push @data, {
		driver   => 'mysql',
		database => 'sample_db',
		host     => 'localhost',
		port     => '3306',
	};
	
	return \@data;
}

1;
