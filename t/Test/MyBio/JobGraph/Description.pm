package Test::MyBio::JobGraph::Description;
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
	return Test::TestObjects->get_testobject_MyBio_JobGraph_Description;
}
sub data {
	return {
		header => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		abstract => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		text => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		variables => {
			INPUT  => [{
					'var1' => 'value for var1',
					'var2' => 'value for var2',
				      }],
			OUTPUT => [{
					'var1' => 'value for var1',
					'var2' => 'value for var2',
				      }]
		},
		to_string => {
			INPUT  => [sample_object->[0]],
			OUTPUT => ["anything value for var1 anything value for var2\nanything\nanything\n"]
		}
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
sub header : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('header', $self->get_input_for('header')->[0], $self->get_output_for('header')->[0]);
}

sub abstract : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('abstract', $self->get_input_for('abstract')->[0], $self->get_output_for('abstract')->[0]);
}

sub text : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('text', $self->get_input_for('text')->[0], $self->get_output_for('text')->[0]);
}

sub variables : Test(4) {
	my ($self) = @_;
	$self->deep_attribute_test('variables', $self->get_input_for('variables')->[0], $self->get_output_for('variables')->[0]);
}

#######################################################################
#############################   Methods   #############################
#######################################################################

sub to_string : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new($self->get_input_for('to_string')->[0]);
	can_ok $obj, 'to_string';
	$obj->to_string(); 
	is $obj->to_string, $self->get_output_for('to_string')->[0], "... and should return the correct value";
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
