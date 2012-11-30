package Test::MyBio::RegionCollection::Type::DB;
use strict;

use base qw(Test::MyBio);
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
	does_ok($self->obj(0), 'MyBio::RegionCollection', '... does the MyBio::RegionCollection role');
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

sub name : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'name', "... test object has the 'name' attribute");
	is $self->obj(0)->name, 'test_object_1', "... and returns the correct value";
}

sub species : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'species', "... test object has the 'species' attribute");
	is $self->obj(0)->species, 'human', "... and returns the correct value";
}

sub description : Test(2) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'description', "... test object has the 'description' attribute");
	is $self->obj(0)->description, 'just a test object', "... and returns the correct value";
}

sub longest_record : Test(1) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), 'longest_record', "... test object has the 'longest_record' attribute");
}
 
sub add_record : Test(2) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'add_record';
}

sub foreach_record_do : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'foreach_record_do';
}

sub records_count : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'records_count';
}

sub strands : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'strands';
}

sub rnames_for_strand : Test(3) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'rnames_for_strand';
}

sub rnames_for_all_strands : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'rnames_for_all_strands';
}

sub is_empty : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_empty';
}

sub is_not_empty : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'is_not_empty';
}

sub foreach_overlapping_record_do : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'foreach_overlapping_record_do';
}

sub records_overlapping_region  : Test(1) {
	my ($self) = @_;
	
	can_ok $self->obj(0), 'records_overlapping_region';
}

#######################################################################
########################   Class Private Tests   ######################
#######################################################################
sub private_db_connector : Test(1) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), '_db_connector', "... test object has the '_db_connector' attribute");
}

sub private_db_handle : Test(1) {
	my ($self) = @_;
	
	has_attribute_ok($self->obj(0), '_db_handle', "... test object has the '_db_handle' attribute");
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
	
	my $test_object_1 = $test_class->class->new({
		driver      => 'mysql',
		host        => 'localhost',
		database    => 'test',
		table       => 'test_table',
		user        => 'test_user',
		password    => 'test_user_pass',
		port        => 3306,
		record_type => 'MyBio::Data::DB::Alignment::Record',
		name        => 'test_object_1',
		species     => 'human',
		description => 'just a test object'
	});
	
	return [$test_object_1];
}

1;