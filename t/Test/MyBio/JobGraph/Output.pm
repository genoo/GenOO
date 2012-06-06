package Test::MyBio::JobGraph::Output;
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
			NAME       => 'anything',
			SOURCE     => 'anything',
			TYPE 	   => 'anything',
		},
	];
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

#######################################################################
#############################   Methods   #############################
#######################################################################

1;
