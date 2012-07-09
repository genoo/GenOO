package Test::MyBio::JobGraph::Job;
use strict;

use Test::Most;
use base qw(Test::MyBio);

use MyBio::JobGraph::Job::Input;
use MyBio::JobGraph::Job::Output;
use MyBio::JobGraph::Job::Log;

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
sub new_object : Test(setup) {
	my ($self) = @_;
	
	$self->{OBJ} = $self->class->new({
		INPUT => [MyBio::JobGraph::Job::Input->new()],
		OUTPUT => [MyBio::JobGraph::Job::Output->new()],
	});
};

#######################################################################
###########################   Actual Tests   ##########################
#######################################################################
sub _isa_test : Test(1) {
	my ($self) = @_;
	
	isa_ok $self->obj, $self->class, "... and the object";
}

sub input : Test(4) {
	my ($self) = @_;
	$self->deep_attribute_test('input', [MyBio::JobGraph::Job::Input->new()], [MyBio::JobGraph::Job::Input->new()]);
}

sub output : Test(4) {
	my ($self) = @_;
	$self->deep_attribute_test('output', [MyBio::JobGraph::Job::Output->new()], [MyBio::JobGraph::Job::Output->new()]);
}

sub log : Test(4) {
	my ($self) = @_;
	$self->deep_attribute_test('log', [MyBio::JobGraph::Job::Log->new()], [MyBio::JobGraph::Job::Log->new()]);
}

sub is_input_appropriate : Test(4) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_input_appropriate';
	
	ok $self->obj->is_input_appropriate([MyBio::JobGraph::Job::Input->new]), '... and the check should succeed';
	dies_ok {$self->obj->is_input_appropriate({})} '... and the check should fail';
	dies_ok {$self->obj->is_input_appropriate([MyBio::JobGraph::Job::Output->new])} '... and the check should fail again';
}

sub is_output_appropriate : Test(4) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_output_appropriate';
	
	ok $self->obj->is_output_appropriate([MyBio::JobGraph::Job::Output->new]), '... and the check should succeed';
	dies_ok {$self->obj->is_output_appropriate({})} '... and the check should fail';
	dies_ok {$self->obj->is_output_appropriate([MyBio::JobGraph::Job::Input->new])} '... and the check should fail again';
}

sub is_io_appropriate : Test(4) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_io_appropriate';
	
	ok $self->obj->is_io_appropriate([MyBio::JobGraph::Job::Input->new], 'MyBio::JobGraph::Job::Input'), '... and the check should succeed';
	ok $self->obj->is_io_appropriate([MyBio::JobGraph::Job::Output->new], 'MyBio::JobGraph::Job::Output'), '... and the check should fail again';
	dies_ok {$self->obj->is_io_appropriate({})} '... and the check should fail';
}

sub clean : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'clean';
}

sub start_devel_mode : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'start_devel_mode';
}

sub stop_devel_mode : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'stop_devel_mode';
}

sub is_devel_mode_on : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'is_devel_mode_on';
}

sub run : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'run';
}

sub description : Test(1) {
	my ($self) = @_;
	
	can_ok $self->class, 'description';
}



#######################################################################
##########################   Helper Methods   #########################
#######################################################################
sub obj {
	my ($self) = @_;
	return $self->{OBJ};
}

1;
