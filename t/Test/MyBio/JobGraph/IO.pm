package Test::MyBio::JobGraph::IO;
use strict;

use base qw(Test::MyBio);
use Test::More;
use Test::TestObjects;

#######################################################################
###########################   To Do Dev     ###########################
#######################################################################

#######################################################################
###########################   Test Data     ###########################
#######################################################################
sub sample_object {
	return Test::TestObjects->get_testobject_MyBio_JobGraph_IO;
}
sub data {
	return {
		name => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		source => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		type => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		devel_source => {
			INPUT  => ['anything_devel'],
			OUTPUT => ['anything_devel']
		},
		set_to_development => {
			INPUT  => [sample_object->[0]],
			OUTPUT => [1,'anything_devel']
		},
	};
}

#######################################################################
###########################   Basic Tests   ###########################
#######################################################################
sub _loading_test : Test(4) {
	my ($self) = @_;
	
	use_ok $self->class;
	can_ok $self->class, 'new';
 	ok my $obj = $self->class->new($self->sample_object->[0]), '... and the constructor succeeds';
 	isa_ok $obj, $self->class, '... and the object';
}

# #######################################################################
# #########################   Attributes Tests   ########################
# #######################################################################
sub name : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('name', $self->get_input_for('name')->[0], $self->get_output_for('name')->[0]);
}

sub source : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('source', $self->get_input_for('source')->[0], $self->get_output_for('source')->[0]);
}

sub type : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('type', $self->get_input_for('type')->[0], $self->get_output_for('type')->[0]);
}

sub devel_source : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('devel_source', $self->get_input_for('devel_source')->[0], $self->get_output_for('devel_source')->[0]);
}

#######################################################################
#############################   Methods   #############################
#######################################################################
sub set_to_development : Test(3) {
	my ($self) = @_;

	my $obj = $self->class->new; 
	can_ok $obj, 'set_to_development';
	
	$obj = $self->class->new($self->get_input_for('set_to_development')->[0]);
	
	is $obj->set_to_development(), $self->get_output_for('set_to_development')->[0], "... and should return the correct value";
	$obj->set_to_development();
	is $obj->get_source(), $self->get_output_for('set_to_development')->[1], "... and should return the correct value"; 
}

#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub simple_attribute_test {
	my ($self,$attribute,$value,$expected) = @_;
	
	my $get = 'get_'.$attribute;
	my $set = 'set_'.$attribute;
	
	my $obj = $self->class->new;
	
	can_ok $obj, $get;
	ok !defined $obj->$get, "... and $attribute should start as undefined";
	
	can_ok $obj, $set;
	$obj->$set($value);
	is $obj->$get, $expected, "... and setting its value should succeed";
}

sub deep_attribute_test {
	my ($self,$attribute,$value,$expected) = @_;
	
	my $get = 'get_'.$attribute;
	my $set = 'set_'.$attribute;
	
	my $obj = $self->class->new;
	
	can_ok $obj, $get;
	ok !defined $obj->$get, "... and $attribute should start as undefined";
	
	can_ok $obj, $set;
	$obj->$set($value);
	is_deeply $obj->$get, $expected, "... and setting its value should succeed";
}

1;
