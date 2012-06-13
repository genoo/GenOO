package Test::MyBio::JobGraph::Job::Generic;
use strict;

use base qw(Test::MyBio);
use Test::More;
use Test::TestObjects;

#######################################################################
###########################   To Do Dev     ###########################
#######################################################################

# Fix documentation examples


#######################################################################
###########################   Test Data     ###########################
#######################################################################
sub sample_object {
	return Test::TestObjects->get_testobject_MyBio_JobGraph_Job_Generic;
}
sub data {
	return {
		input => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		output => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		description => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		'log' => {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		code =>  {
			INPUT  => ['anything'],
			OUTPUT => ['anything']
		},
		run =>  {
			INPUT  => [sample_object->[0]],
			OUTPUT => ['anything']
		},
		add_default_variables_to_description => {
			INPUT  => [sample_object->[0]],
			OUTPUT => [1,1]
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
sub input : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('input', $self->get_input_for('input')->[0], $self->get_output_for('input')->[0]);
}

sub output : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('output', $self->get_input_for('output')->[0], $self->get_output_for('output')->[0]);
}

sub description : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('description', $self->get_input_for('description')->[0], $self->get_output_for('description')->[0]);
}

sub log : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('log', $self->get_input_for('log')->[0], $self->get_output_for('log')->[0]);
}

sub code : Test(4) {
	my ($self) = @_;
	$self->simple_attribute_test('code', $self->get_input_for('code')->[0], $self->get_output_for('code')->[0]);
}
#######################################################################
#############################   Methods   #############################
#######################################################################

sub run : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new; 
	can_ok $obj, 'run';
	
	$obj = $self->class->new($self->get_input_for('run')->[0]);
	is $obj->run(), $self->get_output_for('run')->[0], "... and should return the correct value";
}


sub add_default_variables_to_description : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new; 
	can_ok $obj, 'add_default_variables_to_description';
	
	$obj = $self->class->new($self->get_input_for('add_default_variables_to_description')->[0]);
	
	is $obj->add_default_variables_to_description(), $self->get_output_for('add_default_variables_to_description')->[0], "... and should return the correct value"; 
}

1;

