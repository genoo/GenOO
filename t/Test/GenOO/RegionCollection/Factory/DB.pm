package Test::GenOO::RegionCollection::Factory::DB;
use strict;

use base qw(Test::GenOO);
use Test::Most;
use Test::Moose;

#######################################################################
################   Startup (Runs once in the begining  ################
#######################################################################
sub _check_loading : Test(startup => 1) {
	my ($self) = @_;
	use_ok $self->class;
};

#######################################################################
#################   Setup (Runs before every method)  #################
#######################################################################
sub create_new_test_objects : Test(setup) {
	my ($self) = @_;
	
	my $test_class = ref($self) || $self;
	$self->{TEST_OBJECTS} = $test_class->test_objects();
};

#######################################################################
##########################   Initial Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	isa_ok $self->obj(0), $self->class, "... and the object";
}

sub _role_check : Test(1) {
	my ($self) = @_;
	does_ok($self->obj(0), 'GenOO::RegionCollection::Factory::Requires', '... does the appropriate role');
}

#######################################################################
#######################   Class Interface Tests   #####################
#######################################################################
sub driver : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'driver', "... test object has the 'driver' attribute");
	is $self->obj(0)->driver, 'mysql', "... and returns the correct value";
}

sub host : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'host', "... test object has the 'host' attribute");
	is $self->obj(0)->host, 'localhost', "... and returns the correct value";
}

sub database : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'database', "... test object has the 'database' attribute");
	is $self->obj(0)->database, 'test', "... and returns the correct value";
}

sub table : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'table', "... test object has the 'table' attribute");
	is $self->obj(0)->table, 'test_table', "... and returns the correct value";
}

sub record_type : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'record_type', "... test object has the 'record_type' attribute");
	is $self->obj(0)->record_type, 'GenOO::Data::DB::Alignment::Record', "... and returns the correct value";
}

sub user : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'user', "... test object has the 'user' attribute");
	is $self->obj(0)->user, 'test_user', "... and returns the correct value";
}

sub password : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'password', "... test object has the 'password' attribute");
	is $self->obj(0)->password, 'test_user_pass', "... and returns the correct value";
}

sub port : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'port', "... test object has the 'port' attribute");
	is $self->obj(0)->port, 3306, "... and returns the correct value";
}

sub read_collection : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'read_collection';
	
	my $collection = $self->obj(0)->read_collection;
	does_ok($collection, 'GenOO::RegionCollection', "... and the returned object does the GenOO::RegionCollection role");
# 	is $collection->records_count, 804442, "... and it contains the correct number of records";
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self, $index) = @_;
	
	return $self->{TEST_OBJECTS}->[$index];
}

sub objs {
	my ($self) = @_;
	
	return @{$self->{TEST_OBJECTS}};
}


#######################################################################
###############   Class method to create test objects   ###############
#######################################################################
sub test_objects {
	my ($test_class) = @_;
	
	eval "require ".$test_class->class;
	
	my @test_objects;
	
	push @test_objects, $test_class->class->new(
		driver      => 'mysql',
		host        => 'localhost',
		database    => 'test',
		table       => 'test_table',
		record_type => 'GenOO::Data::DB::Alignment::Record',
		user        => 'test_user',
		password    => 'test_user_pass',
		port        => 3306,
	);
	
	push @test_objects, $test_class->class->new(
		driver      => 'mysql',
		host        => 'localhost',
		database    => 'test',
		table       => 'test_table',
		record_type => 'GenOO::Data::DB::Alignment::Record',
	);
	
	return \@test_objects;
}

1;
