package Test::MyBio::JobGraph::Job::Generic;
use strict;

use base qw(Test::MyBio);
use Test::More;
use MyBio::JobGraph::Description;
use MyBio::JobGraph::Input;
use MyBio::JobGraph::Output;

#######################################################################
###########################   To Do Dev     ###########################
#######################################################################

# Fix documentation examples


#######################################################################
###########################   Test Data     ###########################
#######################################################################
sub sample_object {
	return [
		{
			#this is a generic object of the class
			INPUT        => [
						MyBio::JobGraph::Input->new({
								NAME       => 'anything1',
								SOURCE     => 'anything',
								TYPE       => 'anything',
						}), 
						MyBio::JobGraph::Input->new({
								NAME       => 'anything2',
								SOURCE     => 'anything',
								TYPE       => 'anything',
						})
					],
			OUTPUT        => [
						MyBio::JobGraph::Output->new({
								NAME       => 'anything1',
								SOURCE     => 'anything',
								TYPE       => 'anything',
						}), 
						MyBio::JobGraph::Output->new({
								NAME       => 'anything2',
								SOURCE     => 'anything',
								TYPE       => 'anything',
						})
					],
			DESCRIPTION  => MyBio::JobGraph::Description->new({
						HEADER     => 'anything {{var1}} anything {{var2}}',
						ABSTRACT   => 'anything',
						TEXT 	   => 'anything',
						VARIABLES  => {
								'var1' => 'value for var1',
								'var2' => 'value for var2',
							},
					}),
			LOG          => 'anything',
		},
	];
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
		add_default_variables_to_description => {
			INPUT  => [],
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

#######################################################################
#############################   Methods   #############################
#######################################################################
sub add_default_variables_to_description : Test(2) {
	my ($self) = @_;
	
	my $obj = $self->class->new;
	can_ok $obj, 'add_default_variables_to_description';
	
	$obj = $self->class->new(sample_object->[0]);
	
	is $obj->add_default_variables_to_description($self->get_input_for('add_default_variables_to_description')->[0]), $self->get_output_for('add_default_variables_to_description')->[0], "... and should return the correct value";
}



1;

