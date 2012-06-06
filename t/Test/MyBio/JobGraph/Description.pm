package Test::MyBio::JobGraph::Description;
use strict;

use base qw(Test::MyBio);
use Test::More;

#######################################################################
###########################   To Do Dev     ###########################
#######################################################################

#######################################################################
###########################   Test Data     ###########################
#######################################################################
sub sample_object {
	return [
		{
			#this is a generic object of the class
			HEADER     => 'anything {{var1}} anything {{var2}}',
			ABSTRACT   => 'anything',
			TEXT 	   => 'anything',
			VARIABLES  => {
					'var1' => 'value for var1',
					'var2' => 'value for var2',
				      },
		},
	];
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

1;
